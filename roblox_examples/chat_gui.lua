--[[
    Roblox Chat GUI for Chatbot Integration
    Place this in StarterPlayer > StarterPlayerScripts as a LocalScript
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local chatRequestEvent = ReplicatedStorage:WaitForChild("ChatRequest")
local chatResponseEvent = ReplicatedStorage:WaitForChild("ChatResponse")

-- GUI Configuration
local GUI_CONFIG = {
    Position = UDim2.new(0, 10, 0.5, -150),
    Size = UDim2.new(0, 350, 0, 300),
    ToggleKey = Enum.KeyCode.F1
}

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChatbotGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = GUI_CONFIG.Size
mainFrame.Position = GUI_CONFIG.Position
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🤖 AI Assistant"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 2.5)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Chat display area
local chatFrame = Instance.new("ScrollingFrame")
chatFrame.Name = "ChatFrame"
chatFrame.Size = UDim2.new(1, -10, 1, -75)
chatFrame.Position = UDim2.new(0, 5, 0, 35)
chatFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
chatFrame.BorderSizePixel = 0
chatFrame.ScrollBarThickness = 6
chatFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
chatFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatFrame.Parent = mainFrame

local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 6)
chatCorner.Parent = chatFrame

local chatLayout = Instance.new("UIListLayout")
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Padding = UDim.new(0, 5)
chatLayout.Parent = chatFrame

-- Input area
local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.Size = UDim2.new(1, -10, 0, 30)
inputFrame.Position = UDim2.new(0, 5, 1, -35)
inputFrame.BackgroundTransparency = 1
inputFrame.Parent = mainFrame

local messageBox = Instance.new("TextBox")
messageBox.Name = "MessageBox"
messageBox.Size = UDim2.new(1, -40, 1, 0)
messageBox.Position = UDim2.new(0, 0, 0, 0)
messageBox.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
messageBox.BorderSizePixel = 0
messageBox.PlaceholderText = "Type your message..."
messageBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
messageBox.Text = ""
messageBox.TextColor3 = Color3.fromRGB(255, 255, 255)
messageBox.TextScaled = true
messageBox.Font = Enum.Font.SourceSans
messageBox.ClearTextOnFocus = false
messageBox.Parent = inputFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = messageBox

local sendButton = Instance.new("TextButton")
sendButton.Name = "SendButton"
sendButton.Size = UDim2.new(0, 35, 1, 0)
sendButton.Position = UDim2.new(1, -35, 0, 0)
sendButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
sendButton.BorderSizePixel = 0
sendButton.Text = "➤"
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.TextScaled = true
sendButton.Font = Enum.Font.SourceSansBold
sendButton.Parent = inputFrame

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 4)
sendCorner.Parent = sendButton

-- Status indicator
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 15)
statusLabel.Position = UDim2.new(0, 0, 1, -15)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = mainFrame

-- Variables
local isVisible = true
local messageCount = 0
local isWaitingForResponse = false

-- Functions
local function createMessage(text, isUser, timestamp)
    messageCount = messageCount + 1
    
    local messageFrame = Instance.new("Frame")
    messageFrame.Name = "Message" .. messageCount
    messageFrame.Size = UDim2.new(1, -10, 0, 0)
    messageFrame.BackgroundTransparency = 1
    messageFrame.LayoutOrder = messageCount
    messageFrame.Parent = chatFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "MessageLabel"
    messageLabel.Size = UDim2.new(0.8, 0, 0, 0)
    messageLabel.BackgroundColor3 = isUser and Color3.fromRGB(0, 123, 255) or Color3.fromRGB(75, 75, 75)
    messageLabel.BorderSizePixel = 0
    messageLabel.Text = text
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextWrapped = true
    messageLabel.Font = Enum.Font.SourceSans
    messageLabel.TextSize = 14
    messageLabel.Parent = messageFrame
    
    if isUser then
        messageLabel.Position = UDim2.new(0.2, 0, 0, 0)
    else
        messageLabel.Position = UDim2.new(0, 0, 0, 0)
    end
    
    local messageCorner = Instance.new("UICorner")
    messageCorner.CornerRadius = UDim.new(0, 8)
    messageCorner.Parent = messageLabel
    
    -- Calculate text size
    local textSize = TextService:GetTextSize(
        text,
        14,
        Enum.Font.SourceSans,
        Vector2.new(messageLabel.AbsoluteSize.X - 10, math.huge)
    )
    
    local finalHeight = math.max(25, textSize.Y + 10)
    messageLabel.Size = UDim2.new(0.8, 0, 0, finalHeight)
    messageFrame.Size = UDim2.new(1, -10, 0, finalHeight + 5)
    
    -- Add timestamp
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(0.15, 0, 0, 12)
    timeLabel.Position = isUser and UDim2.new(0, 0, 1, -12) or UDim2.new(0.85, 0, 1, -12)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = timestamp or os.date("%H:%M")
    timeLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.SourceSans
    timeLabel.Parent = messageFrame
    
    -- Scroll to bottom
    spawn(function()
        wait(0.1)
        chatFrame.CanvasPosition = Vector2.new(0, chatFrame.AbsoluteCanvasSize.Y)
    end)
end

local function sendMessage()
    local message = messageBox.Text:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    
    if message == "" or isWaitingForResponse then
        return
    end
    
    if #message > 1000 then
        statusLabel.Text = "Message too long (max 1000 characters)"
        statusLabel.TextColor3 = Color3.fromRGB(220, 53, 69)
        return
    end
    
    -- Add user message
    createMessage(message, true)
    messageBox.Text = ""
    
    -- Update status
    isWaitingForResponse = true
    statusLabel.Text = "Thinking..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 193, 7)
    sendButton.Text = "⟳"
    
    -- Send to server
    chatRequestEvent:FireServer(message)
end

local function toggleGui()
    isVisible = not isVisible
    local targetPosition = isVisible and GUI_CONFIG.Position or UDim2.new(0, -360, GUI_CONFIG.Position.Y.Scale, GUI_CONFIG.Position.Y.Offset)
    
    local tween = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = targetPosition}
    )
    tween:Play()
end

local function setStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color or Color3.fromRGB(150, 150, 150)
end

-- Event connections
sendButton.MouseButton1Click:Connect(sendMessage)

messageBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        sendMessage()
    end
end)

closeButton.MouseButton1Click:Connect(toggleGui)

-- Handle responses from server
chatResponseEvent.OnClientEvent:Connect(function(response)
    isWaitingForResponse = false
    sendButton.Text = "➤"
    
    if response then
        createMessage(response, false)
        setStatus("Ready", Color3.fromRGB(40, 167, 69))
    else
        setStatus("Error occurred", Color3.fromRGB(220, 53, 69))
    end
end)

-- Toggle GUI with hotkey
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == GUI_CONFIG.ToggleKey then
        toggleGui()
    end
end)

-- Make frame draggable
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStart = nil
    end
end)

-- Initial message
createMessage("Hello! I'm your AI assistant. Ask me anything about Roblox development! Press F1 to toggle this window.", false)
setStatus("Ready", Color3.fromRGB(40, 167, 69))

print("Chatbot GUI loaded! Press F1 to toggle the chat window.")
