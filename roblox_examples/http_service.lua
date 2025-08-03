--[[
    Roblox HTTP Service Integration for Chatbot API
    Place this in a ServerScript (HttpService only works on the server)
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Configuration
local API_BASE_URL = "https://your-domain.com/api"  -- Replace with your actual domain
local CHAT_ENDPOINT = API_BASE_URL .. "/chat"
local HEALTH_ENDPOINT = API_BASE_URL .. "/health"

-- Create RemoteEvents for client-server communication
local chatRequestEvent = Instance.new("RemoteEvent")
chatRequestEvent.Name = "ChatRequest"
chatRequestEvent.Parent = ReplicatedStorage

local chatResponseEvent = Instance.new("RemoteEvent")
chatResponseEvent.Name = "ChatResponse"
chatResponseEvent.Parent = ReplicatedStorage

-- Rate limiting to prevent spam
local playerCooldowns = {}
local COOLDOWN_TIME = 3 -- seconds between requests per player

-- Function to check API health
local function checkApiHealth()
    local success, response = pcall(function()
        return HttpService:GetAsync(HEALTH_ENDPOINT)
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        print("API Health Check:", data.status)
        return data.success
    else
        warn("API Health Check Failed:", response)
        return false
    end
end

-- Function to send chat message to API
local function sendChatMessage(message, userId)
    local requestData = {
        message = message,
        userId = tostring(userId)
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(
            CHAT_ENDPOINT,
            HttpService:JSONEncode(requestData),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    if success then
        local data = HttpService:JSONDecode(response)
        if data.success then
            return true, data.response
        else
            warn("Chat API Error:", data.message or data.error)
            return false, data.message or "An error occurred while processing your message."
        end
    else
        warn("HTTP Request Failed:", response)
        return false, "Failed to connect to the chatbot service. Please try again later."
    end
end

-- Handle chat requests from clients
chatRequestEvent.OnServerEvent:Connect(function(player, message)
    -- Validate player
    if not player or not player.Parent then
        return
    end
    
    -- Validate message
    if not message or type(message) ~= "string" or #message == 0 then
        chatResponseEvent:FireClient(player, "Please enter a valid message.")
        return
    end
    
    -- Check message length
    if #message > 1000 then
        chatResponseEvent:FireClient(player, "Message is too long. Please keep it under 1000 characters.")
        return
    end
    
    -- Rate limiting
    local currentTime = tick()
    local playerId = tostring(player.UserId)
    
    if playerCooldowns[playerId] and (currentTime - playerCooldowns[playerId]) < COOLDOWN_TIME then
        local remainingTime = math.ceil(COOLDOWN_TIME - (currentTime - playerCooldowns[playerId]))
        chatResponseEvent:FireClient(player, "Please wait " .. remainingTime .. " seconds before sending another message.")
        return
    end
    
    playerCooldowns[playerId] = currentTime
    
    -- Send message to API
    local success, response = sendChatMessage(message, player.UserId)
    
    -- Send response back to client
    chatResponseEvent:FireClient(player, response)
    
    -- Log the interaction
    print(string.format("Chat - %s (%d): %s -> %s", 
        player.Name, 
        player.UserId, 
        message:sub(1, 50) .. (message:len() > 50 and "..." or ""),
        response:sub(1, 50) .. (response:len() > 50 and "..." or "")
    ))
end)

-- Clean up cooldowns when players leave
Players.PlayerRemoving:Connect(function(player)
    local playerId = tostring(player.UserId)
    if playerCooldowns[playerId] then
        playerCooldowns[playerId] = nil
    end
end)

-- Check API health on startup
spawn(function()
    wait(2) -- Wait a bit for the game to initialize
    local isHealthy = checkApiHealth()
    if isHealthy then
        print("✅ Chatbot API is online and ready!")
    else
        warn("❌ Chatbot API is not responding. Check your configuration.")
    end
end)

-- Optional: Periodic health checks
spawn(function()
    while true do
        wait(300) -- Check every 5 minutes
        checkApiHealth()
    end
end)

print("Roblox Chatbot HTTP Service loaded successfully!")
