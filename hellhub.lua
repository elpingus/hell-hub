--[[
   GARDAS HUB - COMBAT WARRIORS
   Mercury UI Library (External)
]]--

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    autoParry = false,
    autoKick = false,
    parryRange = 18,
    minDelay = 50,
    maxDelay = 120,
    missChance = 12,
    parryCooldown = 0.3,
    predictSwing = true,
    antiRagdoll = true,
}

-- LOAD MERCURY LIBRARY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

-- CREATE WINDOW
local Window = Library:create{
    Name = "Gardas Hub - Combat Warriors",
    Size = UDim2.fromOffset(580, 400),
    Theme = Library.Themes.Dark
}

-----------------------------------------------------------------
-- PARRY TAB
-----------------------------------------------------------------
local ParryTab = Window:tab{
    Name = "Parry",
    Icon = "rbxassetid://8569322835"
}

ParryTab:toggle{
    Name = "Auto Parry",
    Description = "Automatically parry incoming attacks",
    StartingState = false,
    Callback = function(state)
        Settings.autoParry = state
    end
}

ParryTab:toggle{
    Name = "Auto Kick",
    Description = "Automatically kick after parry (Q)",
    StartingState = false,
    Callback = function(state)
        Settings.autoKick = state
    end
}

ParryTab:slider{
    Name = "Parry Range",
    Description = "Detection range for enemies",
    Min = 10,
    Max = 30,
    Default = 18,
    Callback = function(val)
        Settings.parryRange = val
    end
}

ParryTab:slider{
    Name = "Min Delay (ms)",
    Description = "Minimum reaction delay",
    Min = 20,
    Max = 100,
    Default = 50,
    Callback = function(val)
        Settings.minDelay = val
    end
}

ParryTab:slider{
    Name = "Max Delay (ms)",
    Description = "Maximum reaction delay",
    Min = 50,
    Max = 200,
    Default = 120,
    Callback = function(val)
        Settings.maxDelay = val
    end
}

ParryTab:slider{
    Name = "Miss Chance %",
    Description = "Chance to miss parry (legit)",
    Min = 0,
    Max = 30,
    Default = 12,
    Callback = function(val)
        Settings.missChance = val
    end
}

-----------------------------------------------------------------
-- SETTINGS TAB
-----------------------------------------------------------------
local SettingsTab = Window:tab{
    Name = "Settings",
    Icon = "rbxassetid://8559790237"
}

SettingsTab:toggle{
    Name = "Predict Swing",
    Description = "Predict enemy attacks",
    StartingState = true,
    Callback = function(state)
        Settings.predictSwing = state
    end
}

SettingsTab:toggle{
    Name = "Anti Ragdoll",
    Description = "Prevent ragdoll state",
    StartingState = true,
    Callback = function(state)
        Settings.antiRagdoll = state
    end
}

SettingsTab:button{
    Name = "Reset Settings",
    Description = "Reset all settings to default",
    Callback = function()
        Settings.autoParry = false
        Settings.autoKick = false
        Settings.parryRange = 18
        Settings.minDelay = 50
        Settings.maxDelay = 120
        Settings.missChance = 12
        Settings.predictSwing = true
        Settings.antiRagdoll = true
        Library:notification{
            Title = "Settings Reset",
            Text = "All settings have been reset to default values.",
            Duration = 3
        }
    end
}

-----------------------------------------------------------------
-- INFO TAB
-----------------------------------------------------------------
local InfoTab = Window:tab{
    Name = "Info",
    Icon = "rbxassetid://8577523456"
}

InfoTab:label{
    Text = "Gardas Hub",
    Description = "Combat Warriors Edition v1.0"
}

InfoTab:label{
    Text = "Player",
    Description = LocalPlayer.Name
}

local statusLabel = InfoTab:label{
    Text = "Auto Parry Status",
    Description = "OFF"
}

local parryCountLabel = InfoTab:label{
    Text = "Total Parries",
    Description = "0"
}

local comboCountLabel = InfoTab:label{
    Text = "Current Combo",
    Description = "0"
}

-----------------------------------------------------------------
-- PARRY LOGIC
-----------------------------------------------------------------
local lastParry = 0
local parryCount = 0
local comboCount = 0

local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChild("Humanoid")
end

local function gaussRand(min, max)
    local u1, u2 = math.random(), math.random()
    if u1 < 0.0001 then u1 = 0.0001 end
    local z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return math.clamp((min + max) / 2 + z * (max - min) / 4, min, max)
end

local function isSwinging(targetChar)
    if not targetChar then return false end
    local myHRP = getHRP()
    if not myHRP then return false end
    
    local animator = targetChar:FindFirstChildOfClass("Animator")
    if not animator then
        local hum = targetChar:FindFirstChild("Humanoid")
        if hum then animator = hum:FindFirstChildOfClass("Animator") end
    end
    
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            if track.IsPlaying and track.Speed > 0.8 then
                local name = string.lower(track.Name)
                if name:find("swing") or name:find("slash") or name:find("attack") or 
                   name:find("hit") or name:find("m1") or name:find("combo") or
                   name:find("light") or name:find("heavy") then
                    return true
                end
            end
        end
    end
    
    local tool = targetChar:FindFirstChildOfClass("Tool")
    if tool then
        local handle = tool:FindFirstChild("Handle")
        if handle and (myHRP.Position - handle.Position).Magnitude < 12 then
            if handle.Velocity.Magnitude > 15 then
                return true
            end
        end
    end
    
    return false
end

local function isApproaching(targetChar)
    local myHRP = getHRP()
    if not (myHRP and targetChar) then return false end
    
    local tHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not tHRP then return false end
    
    local direction = (myHRP.Position - tHRP.Position).Unit
    return direction:Dot(tHRP.Velocity) > 8
end

local function getClosestEnemy()
    local myHRP = getHRP()
    if not myHRP then return nil end
    
    local closest, minDist = nil, Settings.parryRange
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local tHum = p.Character:FindFirstChild("Humanoid")
            if tHRP and tHum and tHum.Health > 0 then
                local dist = (myHRP.Position - tHRP.Position).Magnitude
                if dist < minDist then
                    local hasTool = p.Character:FindFirstChildOfClass("Tool")
                    if hasTool or not closest then
                        minDist = dist
                        closest = p
                    end
                end
            end
        end
    end
    return closest
end

local function doParry()
    if math.random(1, 100) <= Settings.missChance then return end
    
    local delay = gaussRand(Settings.minDelay / 1000, Settings.maxDelay / 1000)
    task.wait(delay)
    
    if keypress then
        keypress(0x46) -- F key
        task.wait(0.03)
        keyrelease(0x46)
    end
    
    lastParry = tick()
    parryCount = parryCount + 1
    parryCountLabel:SetDescription(tostring(parryCount))
    
    if Settings.autoKick then
        task.wait(0.08)
        if keypress then
            keypress(0x51) -- Q key
            task.wait(0.02)
            keyrelease(0x51)
        end
        comboCount = comboCount + 1
        comboCountLabel:SetDescription(tostring(comboCount))
    end
end

-- MAIN LOOP
local checkCount = 0
RunService.Heartbeat:Connect(function()
    checkCount = checkCount + 1
    if checkCount < 2 then return end
    checkCount = 0
    
    -- Update UI
    statusLabel:SetDescription(Settings.autoParry and "ON" or "OFF")
    Library:set_status(Settings.autoParry and "Active" or "Idle")
    
    -- Cooldown check
    if tick() - lastParry < Settings.parryCooldown then return end
    
    local myHRP = getHRP()
    local myHum = getHum()
    if not (myHRP and myHum and myHum.Health > 0) then return end
    
    -- Reset combo
    if tick() - lastParry > 3 then
        comboCount = 0
        comboCountLabel:SetDescription("0")
    end
    
    -- Auto Parry
    if Settings.autoParry then
        local enemy = getClosestEnemy()
        if enemy and enemy.Character then
            local tChar = enemy.Character
            local tHRP = tChar:FindFirstChild("HumanoidRootPart")
            
            if tHRP then
                local distance = (myHRP.Position - tHRP.Position).Magnitude
                if distance <= Settings.parryRange then
                    local swinging = isSwinging(tChar)
                    local approaching = isApproaching(tChar)
                    
                    if swinging or (approaching and Settings.predictSwing and distance < 10) then
                        task.spawn(doParry)
                    end
                end
            end
        end
    end
end)

-- ANTI RAGDOLL
RunService.Stepped:Connect(function()
    if Settings.antiRagdoll then
        local hum = getHum()
        if hum then
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            end)
        end
    end
end)

-- LOADED NOTIFICATION
Library:notification{
    Title = "Gardas Hub Loaded",
    Text = "Combat Warriors script is now active!",
    Duration = 5
}

print("[GARDAS HUB] Mercury UI loaded successfully!")
