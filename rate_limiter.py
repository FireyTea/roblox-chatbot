import time
from typing import Dict, Optional
from collections import defaultdict
import logging

logger = logging.getLogger(__name__)

class RateLimiter:
    """Simple in-memory rate limiter for API requests"""
    
    def __init__(self, max_requests: int = 10, window_seconds: int = 60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests: Dict[str, list] = defaultdict(list)
        self.stats = {
            'total_requests': 0,
            'blocked_requests': 0,
            'unique_users': 0
        }
    
    def check_rate_limit(self, identifier: str) -> bool:
        """Check if request is within rate limit"""
        current_time = time.time()
        
        # Clean old requests outside the window
        self.requests[identifier] = [
            req_time for req_time in self.requests[identifier]
            if current_time - req_time < self.window_seconds
        ]
        
        # Update stats
        self.stats['total_requests'] += 1
        if identifier not in self.requests or len(self.requests[identifier]) == 0:
            self.stats['unique_users'] = len([k for k, v in self.requests.items() if v])
        
        # Check if within limit
        if len(self.requests[identifier]) >= self.max_requests:
            self.stats['blocked_requests'] += 1
            logger.warning(f"Rate limit exceeded for identifier: {identifier}")
            return False
        
        # Add current request
        self.requests[identifier].append(current_time)
        logger.debug(f"Request allowed for {identifier}. Count: {len(self.requests[identifier])}/{self.max_requests}")
        return True
    
    def get_stats(self) -> dict:
        """Get rate limiter statistics"""
        active_users = len([k for k, v in self.requests.items() if v])
        return {
            'total_requests': self.stats['total_requests'],
            'blocked_requests': self.stats['blocked_requests'],
            'active_users': active_users,
            'max_requests_per_window': self.max_requests,
            'window_seconds': self.window_seconds
        }
    
    def reset_user(self, identifier: str) -> bool:
        """Reset rate limit for a specific user"""
        if identifier in self.requests:
            del self.requests[identifier]
            logger.info(f"Rate limit reset for identifier: {identifier}")
            return True
        return False
    
    def cleanup_old_entries(self):
        """Clean up old entries to prevent memory leaks"""
        current_time = time.time()
        keys_to_remove = []
        
        for identifier, timestamps in self.requests.items():
            # Remove timestamps outside the window
            valid_timestamps = [
                ts for ts in timestamps 
                if current_time - ts < self.window_seconds
            ]
            
            if not valid_timestamps:
                keys_to_remove.append(identifier)
            else:
                self.requests[identifier] = valid_timestamps
        
        # Remove empty entries
        for key in keys_to_remove:
            del self.requests[key]
        
        logger.debug(f"Cleaned up {len(keys_to_remove)} old rate limit entries")
