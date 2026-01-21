--[[ 
    DELTA CLI V3.0 [ADVANCED HUB LOADER]
    ------------------------------------------------
    • Database: GitHub-Powered (Live Updates)
    • Architecture: Cloud-Based Execution
    • UI: Mobile-First, Draggable, Minimalist
--]]

-------------------------------
-- CONFIGURATION
-------------------------------
-- REPLACE THIS URL WITH YOUR RAW GITHUB DATABASE LINK:
local DATABASE_URL = "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME/main/database.lua" 

-------------------------------
-- SERVICES
-------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-------------------------------
-- PROTECTION
-------------------------------
if getgenv().DeltaCLI_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Delta CLI",
        Text = "Interface is already active.",
        Duration = 3
    })
    return 
end
getgenv().DeltaCLI_Loaded = true

-------------------------------
-- DATABASE SYSTEM
-------------------------------
local CommandDatabase = {}
local ScriptCache = {}

local function FetchDatabase()
    local success, result = pcall(function()
        -- Append random time to bypass caching for the database file itself
        return loadstring(game:HttpGet(DATABASE_URL .. "?t=" .. os.time()))()
    end)
    
    if success and type(result) == "table" then
        CommandDatabase = result
        print("[DeltaCLI] Database synced successfully.")
        return true
    else
        warn("[DeltaCLI] Failed to fetch database: " .. tostring(result))
        return false
    end
end

-------------------------------
-- UI UTILITIES
-------------------------------
local function createTween(obj, props, info)
    local tween = TweenService:Create(obj, info or TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(guiObject, TweenInfo.new(0.1), {Position = targetPos}):Play()
    end

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

local function newGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = PlayerGui end
    return gui
end

-------------------------------
-- LOCAL COMMANDS (Built-in)
-------------------------------
local LocalCommands = {
    ["rejoin"] = function()
        if #Players:GetPlayers() <= 1 then
            LP:Kick("\nRejoining...")
            task.wait()
            game:GetService('TeleportService'):Teleport(game.PlaceId, LP)
        else
            game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end
    end,
    
    ["exit"] = function()
        if CoreGui:FindFirstChild("DeltaCommandLine") then CoreGui.DeltaCommandLine:Destroy() end
        if PlayerGui:FindFirstChild("DeltaCommandLine") then PlayerGui.DeltaCommandLine:Destroy() end
        getgenv().DeltaCLI_Loaded = false
    end,
    
    ["sync"] = function()
        if FetchDatabase() then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Delta CLI", Text="Database Re-Synced!", Duration=3})
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Delta CLI", Text="Sync Failed.", Duration=3})
        end
    end,

    ["help"] = function()
         game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Delta CLI Help",
            Text = "Built-in: rejoin, exit, sync\nCloud: (Check your GitHub DB)",
            Duration = 5
        })
    end
}

-------------------------------
-- MAIN UI SETUP
-------------------------------
local cliGui = newGui("DeltaCommandLine")
local cliFrame = Instance.new("Frame", cliGui)
cliFrame.Size = UDim2.fromOffset(50, 50)
cliFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
cliFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
cliFrame.BorderSizePixel = 0
cliFrame.ClipsDescendants = true
Instance.new("UICorner", cliFrame).CornerRadius = UDim.new(1, 0)
makeDraggable(cliFrame)

-- Stroke for visibility
local stroke = Instance.new("UIStroke", cliFrame)
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.Thickness = 1.5

-- Toggle Button
local toggleBtn = Instance.new("TextButton", cliFrame)
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = "Δ"
toggleBtn.Font = Enum.Font.GothamBlack
toggleBtn.TextSize = 26
toggleBtn.TextColor3 = Color3.fromRGB(0, 170, 255)

-- Input Container
local inputContainer = Instance.new("Frame", cliFrame)
inputContainer.BackgroundTransparency = 1
inputContainer.Size = UDim2.new(1, -55, 1, 0)
inputContainer.Position = UDim2.new(0, 55, 0, 0)
inputContainer.Visible = false

local input = Instance.new("TextBox", inputContainer)
input.PlaceholderText = "Execute cmd..."
input.Text = ""
input.Font = Enum.Font.GothamBold
input.TextSize = 14
input.TextColor3 = Color3.new(1,1,1)
input.PlaceholderColor3 = Color3.fromRGB(150,150,150)
input.BackgroundTransparency = 1
input.Size = UDim2.new(1, -35, 1, 0)
input.Position = UDim2.new(0, 0, 0, 0)
input.TextXAlignment = Enum.TextXAlignment.Left

local execBtn = Instance.new("TextButton", inputContainer)
execBtn.Text = "►"
execBtn.Font = Enum.Font.Gotham
execBtn.TextSize = 16
execBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
execBtn.BackgroundTransparency = 1
execBtn.Size = UDim2.fromOffset(30, 50)
execBtn.Position = UDim2.new(1, -30, 0, 0)

-------------------------------
-- LOGIC & EXECUTION
-------------------------------
local expanded = false

local function toggleUI()
    expanded = not expanded
    if expanded then
        createTween(cliFrame, {Size = UDim2.fromOffset(280, 50)}, TweenInfo.new(0.4, Enum.EasingStyle.Back))
        createTween(cliFrame.UICorner, {CornerRadius = UDim.new(0, 12)})
        toggleBtn.Text = "×"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        task.delay(0.25, function() inputContainer.Visible = true end)
    else
        inputContainer.Visible = false
        createTween(cliFrame, {Size = UDim2.fromOffset(50, 50)}, TweenInfo.new(0.4, Enum.EasingStyle.Back))
        createTween(cliFrame.UICorner, {CornerRadius = UDim.new(1, 0)})
        toggleBtn.Text = "Δ"
        toggleBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
        input.Text = ""
    end
end

local function runCloudScript(url)
    -- Notify user script is fetching
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fetching...",
        Text = "Downloading script from cloud...",
        Duration = 2
    })
    
    local success, err = pcall(function()
        local scriptStr = game:HttpGet(url .. "?t=" .. os.time()) -- Bypass cache
        loadstring(scriptStr)()
    end)
    
    if not success then
        warn("Script Execution Error: " .. tostring(err))
        createTween(cliFrame, {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}, TweenInfo.new(0.2))
        task.delay(0.5, function() createTween(cliFrame, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}, TweenInfo.new(0.5)) end)
    end
end

local function executeCommand()
    local text = input.Text
    if text == "" then return end
    
    local args = string.split(string.lower(text), " ")
    local cmd = args[1]
    
    -- 1. Check Local Commands
    if LocalCommands[cmd] then
        LocalCommands[cmd]()
        createTween(cliFrame, {BackgroundColor3 = Color3.fromRGB(0, 100, 0)}, TweenInfo.new(0.2)) -- Green flash
        
    -- 2. Check Cloud Database
    elseif CommandDatabase[cmd] then
        runCloudScript(CommandDatabase[cmd])
        createTween(cliFrame, {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}, TweenInfo.new(0.2)) -- Blue flash
        
    -- 3. Command Not Found
    else
        createTween(cliFrame, {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}, TweenInfo.new(0.2)) -- Red flash
    end

    -- Reset Flash
    task.delay(0.5, function()
        createTween(cliFrame, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}, TweenInfo.new(0.5))
    end)
    
    input.Text = ""
    input:ReleaseFocus()
end

toggleBtn.MouseButton1Click:Connect(toggleUI)
execBtn.MouseButton1Click:Connect(executeCommand)
input.FocusLost:Connect(function(enter) if enter then executeCommand() end end)

-------------------------------
-- INITIALIZE
-------------------------------
task.spawn(FetchDatabase) -- Fetch DB on load
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Delta CLI v3.0",
    Text = "Cloud System Active. Tap Δ to open.",
    Duration = 5
})
