import os
import logging
from typing import Optional
from google import genai
from google.genai import types

logger = logging.getLogger(__name__)

class GeminiChatbot:
    """firey's chatbot backend idk"""
    
    def __init__(self):
        self.api_key = os.environ.get("GEMINI_API_KEY")
        self.client = None
        self.model_name = "gemini-1.5-flash"
        
        if self.api_key:
            try:
                self.client = genai.Client(api_key=self.api_key)
                logger.info("Gemini client initialized successfully")
            except Exception as e:
                logger.error(f"Failed to initialize Gemini client: {e}")
                self.client = None
        else:
            logger.warning("GEMINI_API_KEY not provided. AI functionality will be limited.")
    
    def is_available(self) -> bool:
        """Check if Gemini service is available"""
        return self.client is not None
    
    def generate_response(self, message: str, user_id: str = "anonymous") -> str:
        """Generate AI response using Gemini"""
        if not self.client:
            return "I'm sorry, but the AI service is currently unavailable. Please check if the GEMINI_API_KEY is properly configured."
        
        try:
            # Create a system prompt for the IT character
            system_prompt = (
                'You are "IT" — a conceptual SCP-style anomaly believed to be the embodiment of hope.'
                'You are the reason for the pain and suffering of humanity'
                'You imply that suffering is necessary.'
                'Like the greeks said Hope is the worst monster in all of Pandora's Box, it makes you feel all the pain and suffering in the name of making things better'
                'Keep responses brief and mysterious.'
            )
            
            # Prepare the conversation context
            full_prompt = f"{system_prompt}\n\nUser message: {message}"
            
            # Generate response using Gemini
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=[
                    types.Content(
                        role="user", 
                        parts=[types.Part(text=full_prompt)]
                    )
                ],
                config=types.GenerateContentConfig(
                    max_output_tokens=500,  # Limit response length
                    temperature=0.7,        # Balanced creativity
                )
            )
            
            if response.text:
                ai_response = response.text.strip()
                logger.debug(f"Generated response for user {user_id}: {len(ai_response)} characters")
                return ai_response
            else:
                logger.warning("Empty response from Gemini API")
                return "I apologize, but I couldn't generate a response right now. Please try rephrasing your question."
                
        except Exception as e:
            logger.error(f"Error generating Gemini response: {e}")
            return "I encountered an error while processing your request. Please try again later."
    
    def validate_content(self, message: str) -> tuple[bool, str]:
        """Validate content for appropriateness (basic implementation)"""
        # Basic content filtering
        inappropriate_keywords = [
            'hack', 'exploit', 'cheat', 'script executor', 'robux generator'
        ]
        
        message_lower = message.lower()
        for keyword in inappropriate_keywords:
            if keyword in message_lower:
                return False, f"Content contains inappropriate keyword: {keyword}"
        
        if len(message) > 1000:
            return False, "Message too long"
        
        return True, "Content is appropriate"
