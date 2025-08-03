// API Testing Interface JavaScript
class ChatInterface {
    constructor() {
        this.messageContainer = document.getElementById('chat-messages');
        this.messageInput = document.getElementById('message-input');
        this.userIdInput = document.getElementById('user-id');
        this.sendButton = document.getElementById('send-btn');
        this.chatForm = document.getElementById('chat-form');
        this.apiStatusContainer = document.getElementById('api-status');
        
        this.initializeEventListeners();
        this.checkApiStatus();
        
        // Auto-refresh status every 30 seconds
        setInterval(() => this.checkApiStatus(), 30000);
    }
    
    initializeEventListeners() {
        // Form submission
        this.chatForm.addEventListener('submit', (e) => {
            e.preventDefault();
            this.sendMessage();
        });
        
        // Enter key handling
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });
    }
    
    async checkApiStatus() {
        try {
            const response = await fetch('/api/health');
            const data = await response.json();
            
            if (data.success) {
                this.updateApiStatus(true, data);
            } else {
                this.updateApiStatus(false, data);
            }
        } catch (error) {
            this.updateApiStatus(false, { error: 'Connection failed' });
        }
    }
    
    updateApiStatus(isHealthy, data) {
        const statusHtml = isHealthy 
            ? `
                <div class="text-success">
                    <i class="fas fa-check-circle me-2"></i>
                    API Online
                </div>
                <small class="text-muted">
                    Gemini: ${data.gemini_available ? '✓ Available' : '✗ Unavailable'}<br>
                    Last check: ${new Date(data.timestamp).toLocaleTimeString()}
                </small>
            `
            : `
                <div class="text-danger">
                    <i class="fas fa-times-circle me-2"></i>
                    API Offline
                </div>
                <small class="text-muted">
                    ${data.message || data.error || 'Unknown error'}
                </small>
            `;
        
        this.apiStatusContainer.innerHTML = statusHtml;
    }
    
    async sendMessage() {
        const message = this.messageInput.value.trim();
        const userId = this.userIdInput.value.trim() || 'test-user';
        
        if (!message) return;
        
        // Disable form while sending
        this.setFormEnabled(false);
        
        // Add user message to chat
        this.addMessage('user', message, userId);
        
        // Clear input
        this.messageInput.value = '';
        
        try {
            const response = await fetch('/api/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    message: message,
                    userId: userId
                })
            });
            
            const data = await response.json();
            
            if (data.success) {
                this.addMessage('bot', data.response, 'Assistant');
            } else {
                this.addMessage('error', data.message || 'Unknown error occurred', 'Error');
            }
        } catch (error) {
            this.addMessage('error', 'Failed to connect to the API', 'Error');
        } finally {
            this.setFormEnabled(true);
            this.messageInput.focus();
        }
    }
    
    addMessage(type, content, sender) {
        // Clear empty state if this is the first message
        if (this.messageContainer.children.length === 1 && 
            this.messageContainer.querySelector('.text-muted')) {
            this.messageContainer.innerHTML = '';
        }
        
        const messageDiv = document.createElement('div');
        messageDiv.className = `mb-3 ${type === 'user' ? 'text-end' : ''}`;
        
        const timestamp = new Date().toLocaleTimeString();
        let badgeClass = 'bg-primary';
        let icon = 'fas fa-user';
        
        if (type === 'bot') {
            badgeClass = 'bg-success';
            icon = 'fas fa-robot';
        } else if (type === 'error') {
            badgeClass = 'bg-danger';
            icon = 'fas fa-exclamation-triangle';
        }
        
        messageDiv.innerHTML = `
            <div class="d-inline-block ${type === 'user' ? 'text-end' : ''}" style="max-width: 70%;">
                <div class="badge ${badgeClass} mb-1">
                    <i class="${icon} me-1"></i>
                    ${sender}
                </div>
                <div class="card ${type === 'user' ? 'bg-primary text-white' : type === 'error' ? 'bg-danger text-white' : ''}">
                    <div class="card-body py-2">
                        <div style="white-space: pre-wrap;">${this.escapeHtml(content)}</div>
                        <small class="opacity-75">${timestamp}</small>
                    </div>
                </div>
            </div>
        `;
        
        this.messageContainer.appendChild(messageDiv);
        this.messageContainer.scrollTop = this.messageContainer.scrollHeight;
    }
    
    setFormEnabled(enabled) {
        this.sendButton.disabled = !enabled;
        this.messageInput.disabled = !enabled;
        this.userIdInput.disabled = !enabled;
        
        if (enabled) {
            this.sendButton.innerHTML = '<i class="fas fa-paper-plane"></i>';
        } else {
            this.sendButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
        }
    }
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Quick test functions
function sendTestMessage(message) {
    const messageInput = document.getElementById('message-input');
    messageInput.value = message;
    messageInput.focus();
}

// Initialize the chat interface when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new ChatInterface();
});
