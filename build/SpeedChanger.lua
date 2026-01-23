local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SpeedInput = Instance.new("TextBox")
local ApplyBtn = Instance.new("TextButton")
local MinimizeBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

-- Properties
ScreenGui.Name = "FuturisticSpeedUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -75, 0.5, -50)
MainFrame.Size = UDim2.new(0, 150, 0, 110)
MainFrame.Active = true
MainFrame.Draggable = true -- Standard dragging for executors

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

UIStroke.Color = Color3.fromRGB(0, 200, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "SPEED HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -25, 0, 5)
MinimizeBtn.Text = "-"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(1, 0)

SpeedInput.Size = UDim2.new(0, 120, 0, 30)
SpeedInput.Position = UDim2.new(0, 15, 0, 35)
SpeedInput.PlaceholderText = "Enter Speed..."
SpeedInput.Text = ""
SpeedInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Parent = MainFrame
Instance.new("UICorner", SpeedInput)

ApplyBtn.Size = UDim2.new(0, 120, 0, 25)
ApplyBtn.Position = UDim2.new(0, 15, 0, 75)
ApplyBtn.Text = "APPLY"
ApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
ApplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ApplyBtn.Font = Enum.Font.GothamBold
ApplyBtn.Parent = MainFrame
Instance.new("UICorner", ApplyBtn)

-- Functionality
local minimized = false
local originalSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        SpeedInput.Visible = false
        ApplyBtn.Visible = false
        Title.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 30, 0, 30), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "+"
        MinimizeBtn.Position = UDim2.new(0, 5, 0, 5)
    else
        MainFrame:TweenSize(originalSize, "Out", "Quad", 0.3, true)
        task.wait(0.3)
        SpeedInput.Visible = true
        ApplyBtn.Visible = true
        Title.Visible = true
        MinimizeBtn.Text = "-"
        MinimizeBtn.Position = UDim2.new(1, -25, 0, 5)
    end
end)

ApplyBtn.MouseButton1Click:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local newSpeed = tonumber(SpeedInput.Text)
        if newSpeed then
            char.Humanoid.WalkSpeed = newSpeed
        end
    end
end)

