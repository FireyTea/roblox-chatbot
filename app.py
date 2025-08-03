import os
import logging
from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from datetime import datetime
import json
from gemini_service import GeminiChatbot
from rate_limiter import RateLimiter

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Create the Flask app
app = Flask(__name__)
app.secret_key = os.environ.get("SESSION_SECRET", "dev-secret-key-change-in-production")

# Enable CORS for Roblox Studio requests
CORS(app, origins=["*"], methods=["GET", "POST", "OPTIONS"])

# Initialize services
gemini_chatbot = GeminiChatbot()
rate_limiter = RateLimiter()

@app.before_request
def log_request_info():
    """Log incoming requests for debugging"""
    logger.debug(f"Request: {request.method} {request.url}")
    if request.is_json:
        logger.debug(f"JSON Body: {request.get_json()}")

@app.errorhandler(400)
def bad_request(error):
    """Handle bad request errors"""
    return jsonify({
        "success": False,
        "error": "Bad Request",
        "message": "Invalid request format or missing required fields"
    }), 400

@app.errorhandler(429)
def rate_limit_exceeded(error):
    """Handle rate limit errors"""
    return jsonify({
        "success": False,
        "error": "Rate Limit Exceeded",
        "message": "Too many requests. Please wait before sending another message."
    }), 429

@app.errorhandler(500)
def internal_error(error):
    """Handle internal server errors"""
    logger.error(f"Internal error: {error}")
    return jsonify({
        "success": False,
        "error": "Internal Server Error",
        "message": "An unexpected error occurred. Please try again later."
    }), 500

# API Routes
@app.route('/api/chat', methods=['POST', 'OPTIONS'])
def chat():
    """Main chat endpoint for Roblox Studio"""
    if request.method == 'OPTIONS':
        return '', 200
    
    try:
        # Validate request
        if not request.is_json:
            return jsonify({
                "success": False,
                "error": "Invalid Content-Type",
                "message": "Request must be JSON with Content-Type: application/json"
            }), 400
        
        data = request.get_json()
        
        # Validate required fields
        if not data:
            return jsonify({
                "success": False,
                "error": "Empty Request",
                "message": "Request body cannot be empty"
            }), 400
        
        message = data.get('message', '').strip()
        user_id = data.get('userId', 'anonymous')
        
        if not message:
            return jsonify({
                "success": False,
                "error": "Missing Message",
                "message": "The 'message' field is required and cannot be empty"
            }), 400
        
        if len(message) > 1000:
            return jsonify({
                "success": False,
                "error": "Message Too Long",
                "message": "Message cannot exceed 1000 characters"
            }), 400
        
        # Check rate limit
        client_ip = request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr)
        if not rate_limiter.check_rate_limit(f"{client_ip}_{user_id}"):
            return jsonify({
                "success": False,
                "error": "Rate Limit Exceeded",
                "message": "Too many requests. Please wait 60 seconds before sending another message."
            }), 429
        
        # Generate AI response
        ai_response = gemini_chatbot.generate_response(message, user_id)
        
        # Log successful interaction
        logger.info(f"Chat interaction - User: {user_id}, Message length: {len(message)}")
        
        return jsonify({
            "success": True,
            "response": ai_response,
            "timestamp": datetime.now().isoformat(),
            "userId": user_id
        })
        
    except Exception as e:
        logger.error(f"Chat endpoint error: {str(e)}")
        return jsonify({
            "success": False,
            "error": "Processing Error",
            "message": "Failed to process your message. Please try again."
        }), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "success": True,
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "gemini_available": gemini_chatbot.is_available()
    })

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get API usage statistics"""
    return jsonify({
        "success": True,
        "stats": rate_limiter.get_stats(),
        "timestamp": datetime.now().isoformat()
    })

# Web Interface Routes
@app.route('/')
def index():
    """Main testing interface"""
    return render_template('index.html')

@app.route('/docs')
def api_docs():
    """API documentation page"""
    return render_template('api_docs.html')

if __name__ == '__main__':
    # Check if Gemini API key is configured
    if not os.environ.get("GEMINI_API_KEY"):
        logger.warning("GEMINI_API_KEY not found in environment variables. Please set it for AI functionality.")
    
    # Start the server
    app.run(host='0.0.0.0', port=5000, debug=True)
