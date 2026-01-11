--[[
    Hell Hub Loader
    This script loads the key system, which then loads the main Combat Warriors script
]]

-- Key System Configuration
local KeySystemURL = "https://raw.githubusercontent.com/elpingus/hell-hub/refs/heads/main/key-system.lua"
local MainScriptURL = "https://raw.githubusercontent.com/elpingus/hell-hub/refs/heads/main/combat-warriors.lua"
local GetKeyURL = "https://work.ink/2dxZ/hell-hub-key"
local ValidKey = "testcw"

-- Create Key System UI
local function createKeySystem()
    local keyGui = Instance.new("ScreenGui")
    keyGui.Name = "HellHubKeySystem"
    keyGui.Parent = game:GetService("CoreGui")
    keyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "KeyFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 220)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = keyGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Hell Hub - Key System"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 45)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enter your key to access"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0, 300, 0, 35)
    keyInput.Position = UDim2.new(0.5, -150, 0, 80)
    keyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = "Enter your key..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextSize = 16
    keyInput.Font = Enum.Font.Gotham
    keyInput.ClearTextOnFocus = false
    keyInput.Parent = mainFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = keyInput
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0, 145, 0, 35)
    getKeyBtn.Position = UDim2.new(0.5, -150, 0, 130)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.Text = "Get Key"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.TextSize = 16
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.Parent = mainFrame
    
    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 6)
    getKeyCorner.Parent = getKeyBtn
    
    local checkKeyBtn = Instance.new("TextButton")
    checkKeyBtn.Size = UDim2.new(0, 145, 0, 35)
    checkKeyBtn.Position = UDim2.new(0.5, 5, 0, 130)
    checkKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    checkKeyBtn.BorderSizePixel = 0
    checkKeyBtn.Text = "Check Key"
    checkKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkKeyBtn.TextSize = 16
    checkKeyBtn.Font = Enum.Font.GothamBold
    checkKeyBtn.Parent = mainFrame
    
    local checkKeyCorner = Instance.new("UICorner")
    checkKeyCorner.CornerRadius = UDim.new(0, 6)
    checkKeyCorner.Parent = checkKeyBtn
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 175)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = mainFrame
    
    getKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(GetKeyURL)
            statusLabel.Text = "Link copied to clipboard!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
        end
    end)
    
    checkKeyBtn.MouseButton1Click:Connect(function()
        if keyInput.Text == ValidKey then
            statusLabel.Text = "Key valid! Loading script..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            task.wait(0.5)
            keyGui:Destroy()
            
            -- Load main Combat Warriors script
            pcall(function()
                loadstring(game:HttpGet(MainScriptURL))()
            end)
        else
            statusLabel.Text = "Invalid key! Try again."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            keyInput.Text = ""
        end
    end)
end

-- Run Key System
createKeySystem()
