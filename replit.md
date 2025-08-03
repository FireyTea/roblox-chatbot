# Roblox Chatbot API

## Overview

This is a Flask-based web API service that provides an AI-powered chatbot specifically designed for integration with Roblox Studio. The application serves as a bridge between Roblox games and Google's Gemini AI, enabling developers to add intelligent chat functionality to their Roblox experiences. The service includes a web-based testing interface and comprehensive API documentation.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Backend Architecture
- **Framework**: Flask web framework with Python
- **AI Integration**: Google Gemini 2.5 Flash model for natural language processing
- **Rate Limiting**: Custom in-memory rate limiter to prevent API abuse
- **CORS Support**: Configured to accept requests from any origin to support Roblox Studio integration
- **Error Handling**: Centralized error handling with proper HTTP status codes

### Frontend Architecture
- **Templates**: Server-side rendered HTML using Jinja2 templating
- **Styling**: Bootstrap 5 with dark theme for consistent UI
- **JavaScript**: Vanilla JavaScript for interactive chat testing interface
- **Icons**: Font Awesome for UI iconography

### API Design
- **RESTful Endpoints**: Clean REST API structure for chat interactions
- **JSON Communication**: All API responses use JSON format
- **Health Monitoring**: Built-in health check endpoint for service monitoring

### Security & Performance
- **Rate Limiting**: 10 requests per minute per user to prevent abuse
- **Request Logging**: Comprehensive logging for debugging and monitoring
- **Environment Configuration**: Secure handling of API keys through environment variables
- **Input Validation**: Proper validation of incoming requests

### Application Structure
- **Modular Design**: Separated concerns with dedicated modules for AI service and rate limiting
- **Service Layer**: Clean separation between web layer and business logic
- **Static Assets**: Organized static files for JavaScript and potential CSS customizations

## External Dependencies

### AI Services
- **Google Gemini API**: Primary AI service for generating chatbot responses
- **API Key Required**: GEMINI_API_KEY environment variable must be configured

### Web Framework
- **Flask**: Core web framework
- **Flask-CORS**: Cross-origin resource sharing support for Roblox integration

### Frontend Libraries
- **Bootstrap 5**: UI framework with dark theme
- **Font Awesome 6**: Icon library for UI elements
- **Prism.js**: Syntax highlighting for code examples in documentation

### Development Tools
- **Python Logging**: Built-in logging for debugging and monitoring
- **Environment Variables**: Configuration management through OS environment

### Hosting Requirements
- **Python Runtime**: Requires Python environment
- **Port Configuration**: Runs on port 5000 by default
- **Environment Setup**: Needs GEMINI_API_KEY and optional SESSION_SECRET