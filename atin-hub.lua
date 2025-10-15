local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Define positions
local positions = {
    Vector3.new(5.89, 12.62, -403.72),
    Vector3.new(-184.20, 125.91, 410.07),
    Vector3.new(-166.78, 227.96, 651.50),
    Vector3.new(-38.21, 406.26, 614.54),
    Vector3.new(126.69, 646.39, 616.77),
    Vector3.new(-247.49, 665.12, 731.53),
    Vector3.new(-684.89, 640.81, 867.30),
    Vector3.new(-658.28, 688.45, 1458.37),
    Vector3.new(-507.91, 902.89, 1868.18),
    Vector3.new(61.22, 947.76, 2088.64),
    Vector3.new(51.82, 981.50, 2450.12),
    Vector3.new(72.70, 1094.75, 2457.12),
    Vector3.new(261.96, 1267.86, 2038.33),
    Vector3.new(-420.00, 1302.10, 2395.13),
    Vector3.new(-773.23, 1313.91, 2664.62),
    Vector3.new(-837.15, 1474.87, 2625.87),
    Vector3.new(-469.09, 1465.61, 2769.40),
    Vector3.new(-469.09, 1465.61, 2769.40),
    Vector3.new(-384.69, 1640.24, 2794.26),
    Vector3.new(-208.05, 1665.74, 2749.33),
    Vector3.new(-231.87, 1742.10, 2792.10),
    Vector3.new(-423.92, 1740.46, 2798.97),
    Vector3.new(-423.51, 1712.17, 3420.01),
    Vector3.new(71.05, 1718.65, 3426.70),
    Vector3.new(436.05, 1720.55, 3430.56),
    Vector3.new(624.53, 1798.81, 3431.57),
    Vector3.new(780.56, 2151.63, 3911.67)
}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI"
ScreenGui.ResetOnSpawn = false -- Prevent GUI from resetting on character death
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.ClipsDescendants = true
MainFrame.BackgroundTransparency = 1 -- Start transparent for fade-in

-- UI Corner for smooth edges
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Scrolling Frame for teleport and misc sections
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -70)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 65)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.Parent = MainFrame
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (#positions + 6) * 40 + 60) -- Adjusted for headers and buttons

-- UI List Layout for sections
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollingFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Teleport GUI"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = TitleBar

-- Minimize Button (Bubble Style)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -35, 0, 2.5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = TitleBar
local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 12.5)
MinimizeCorner.Parent = MinimizeButton

-- Rejoin Button
local RejoinButton = Instance.new("TextButton")
RejoinButton.Size = UDim2.new(0, 100, 0, 30)
RejoinButton.Position = UDim2.new(0, 5, 0, 30)
RejoinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
RejoinButton.Text = "Rejoin Server"
RejoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinButton.TextSize = 14
RejoinButton.Font = Enum.Font.SourceSans
RejoinButton.Parent = MainFrame
local RejoinCorner = Instance.new("UICorner")
RejoinCorner.CornerRadius = UDim.new(0, 5)
RejoinCorner.Parent = RejoinButton

-- Fade-in effect for GUI
local function fadeIn()
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(MainFrame, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
end
fadeIn()

-- Dragging functionality
local dragging
local dragInput
local dragStart
local startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Minimize functionality
local isMinimized = false
local originalSize = MainFrame.Size
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    if isMinimized then
        local tween = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 30)})
        tween:Play()
        MinimizeButton.Text = "+"
        ScrollingFrame.Visible = false
        RejoinButton.Visible = false
    else
        local tween = TweenService:Create(MainFrame, tweenInfo, {Size = originalSize})
        tween:Play()
        MinimizeButton.Text = "-"
        ScrollingFrame.Visible = true
        RejoinButton.Visible = true
    end
end)

-- Button visual effect function
local function addButtonEffects(button)
    local glow = Instance.new("UIStroke")
    glow.Thickness = 2
    glow.Color = Color3.fromRGB(255, 255, 255)
    glow.Transparency = 1
    glow.Parent = button

    button.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
        tween:Play()
    end)

    button.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        tween:Play()
    end)

    return glow
end

-- Rejoin functionality with visual feedback
RejoinButton.MouseButton1Click:Connect(function()
    local glow = addButtonEffects(RejoinButton)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local glowTween = TweenService:Create(glow, tweenInfo, {Transparency = 0})
    glowTween:Play()
    local tween = TweenService:Create(RejoinButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
    tween:Play()
    tween.Completed:Connect(function()
        local revertTween = TweenService:Create(RejoinButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        local revertGlow = TweenService:Create(glow, tweenInfo, {Transparency = 1})
        revertTween:Play()
        revertGlow:Play()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end)

-- Teleport Place Section Frame
local TeleportFrame = Instance.new("Frame")
TeleportFrame.Size = UDim2.new(1, -10, 0, (#positions + 1) * 40)
TeleportFrame.BackgroundTransparency = 1
TeleportFrame.Parent = ScrollingFrame

-- UI List Layout for Teleport buttons
local TeleportListLayout = Instance.new("UIListLayout")
TeleportListLayout.Padding = UDim.new(0, 5)
TeleportListLayout.Parent = TeleportFrame

-- Teleport Place Section Header
local TeleportHeader = Instance.new("TextLabel")
TeleportHeader.Size = UDim2.new(1, 0, 0, 30)
TeleportHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TeleportHeader.Text = "Teleport Place"
TeleportHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportHeader.TextSize = 16
TeleportHeader.Font = Enum.Font.SourceSansBold
TeleportHeader.TextXAlignment = Enum.TextXAlignment.Left
TeleportHeader.TextTransparency = 0.2
TeleportHeader.Parent = TeleportFrame
local TeleportHeaderCorner = Instance.new("UICorner")
TeleportHeaderCorner.CornerRadius = UDim.new(0, 5)
TeleportHeaderCorner.Parent = TeleportHeader

-- Create teleport buttons with visual effects
for i, pos in ipairs(positions) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, 0) -- Indent for visual hierarchy
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = "POS " .. i
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.Parent = TeleportFrame
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 5)
    buttonCorner.Parent = button

    -- Glow effect
    local glow = Instance.new("UIStroke")
    glow.Thickness = 2
    glow.Color = Color3.fromRGB(255, 255, 255)
    glow.Transparency = 1
    glow.Parent = button

    -- Hover effect
    button.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
        tween:Play()
    end)

    button.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        tween:Play()
    end)

    -- Click effect
    button.MouseButton1Click:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Glow animation
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            local glowTween = TweenService:Create(glow, tweenInfo, {Transparency = 0})
            glowTween:Play()
            glowTween.Completed:Connect(function()
                local revertTween = TweenService:Create(glow, tweenInfo, {Transparency = 1})
                revertTween:Play()
            end)
            -- Teleport
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
        end
    end)
end

-- Misc Section Frame
local MiscFrame = Instance.new("Frame")
MiscFrame.Size = UDim2.new(1, -10, 0, 5 * 40)
MiscFrame.BackgroundTransparency = 1
MiscFrame.Parent = ScrollingFrame

-- UI List Layout for Misc buttons
local MiscListLayout = Instance.new("UIListLayout")
MiscListLayout.Padding = UDim.new(0, 5)
MiscListLayout.Parent = MiscFrame

-- Misc Section Header
local MiscHeader = Instance.new("TextLabel")
MiscHeader.Size = UDim2.new(1, 0, 0, 30)
MiscHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MiscHeader.Text = "Misc"
MiscHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
MiscHeader.TextSize = 16
MiscHeader.Font = Enum.Font.SourceSansBold
MiscHeader.TextXAlignment = Enum.TextXAlignment.Left
MiscHeader.TextTransparency = 0.2
MiscHeader.Parent = MiscFrame
local MiscHeaderCorner = Instance.new("UICorner")
MiscHeaderCorner.CornerRadius = UDim.new(0, 5)
MiscHeaderCorner.Parent = MiscHeader

-- Boombox Atin Button (Misc Section)
local BoomboxButton = Instance.new("TextButton")
BoomboxButton.Size = UDim2.new(1, -10, 0, 30)
BoomboxButton.Position = UDim2.new(0, 5, 0, 0) -- Indent for visual hierarchy
BoomboxButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BoomboxButton.Text = "Boombox Atin"
BoomboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BoomboxButton.TextSize = 14
BoomboxButton.Font = Enum.Font.SourceSans
BoomboxButton.Parent = MiscFrame
local BoomboxCorner = Instance.new("UICorner")
BoomboxCorner.CornerRadius = UDim.new(0, 5)
BoomboxCorner.Parent = BoomboxButton

-- Animation Hub Button (Misc Section)
local AnimationButton = Instance.new("TextButton")
AnimationButton.Size = UDim2.new(1, -10, 0, 30)
AnimationButton.Position = UDim2.new(0, 5, 0, 0) -- Indent for visual hierarchy
AnimationButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AnimationButton.Text = "Animation Hub"
AnimationButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AnimationButton.TextSize = 14
AnimationButton.Font = Enum.Font.SourceSans
AnimationButton.Parent = MiscFrame
local AnimationCorner = Instance.new("UICorner")
AnimationCorner.CornerRadius = UDim.new(0, 5)
AnimationCorner.Parent = AnimationButton

-- CMDxLTE Button (Misc Section)
local CMDxLTEButton = Instance.new("TextButton")
CMDxLTEButton.Size = UDim2.new(1, -10, 0, 30)
CMDxLTEButton.Position = UDim2.new(0, 5, 0, 0) -- Indent for visual hierarchy
CMDxLTEButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CMDxLTEButton.Text = "CMDxLTE"
CMDxLTEButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CMDxLTEButton.TextSize = 14
CMDxLTEButton.Font = Enum.Font.SourceSans
CMDxLTEButton.Parent = MiscFrame
local CMDxLTECorner = Instance.new("UICorner")
CMDxLTECorner.CornerRadius = UDim.new(0, 5)
CMDxLTECorner.Parent = CMDxLTEButton

-- AKAadmin Button (Misc Section)
local AKAadminButton = Instance.new("TextButton")
AKAadminButton.Size = UDim2.new(1, -10, 0, 30)
AKAadminButton.Position = UDim2.new(0, 5, 0, 0) -- Indent for visual hierarchy
AKAadminButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AKAadminButton.Text = "AKAadmin"
AKAadminButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AKAadminButton.TextSize = 14
AKAadminButton.Font = Enum.Font.SourceSans
AKAadminButton.Parent = MiscFrame
local AKAadminCorner = Instance.new("UICorner")
AKAadminCorner.CornerRadius = UDim.new(0, 5)
AKAadminCorner.Parent = AKAadminButton

-- Boombox Atin functionality
BoomboxButton.MouseButton1Click:Connect(function()
    local glow = addButtonEffects(BoomboxButton)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local glowTween = TweenService:Create(glow, tweenInfo, {Transparency = 0})
    glowTween:Play()
    local tween = TweenService:Create(BoomboxButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
    tween:Play()
    tween.Completed:Connect(function()
        local revertTween = TweenService:Create(BoomboxButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        local revertGlow = TweenService:Create(glow, tweenInfo, {Transparency = 1})
        revertTween:Play()
        revertGlow:Play()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/fransiusdragnel2-bit/BOOMBOX_ATIN/refs/heads/main/Boombox_atin.lua'))()
    end)
end)

-- Animation Hub functionality
AnimationButton.MouseButton1Click:Connect(function()
    local glow = addButtonEffects(AnimationButton)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local glowTween = TweenService:Create(glow, tweenInfo, {Transparency = 0})
    glowTween:Play()
    local tween = TweenService:Create(AnimationButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
    tween:Play()
    tween.Completed:Connect(function()
        local revertTween = TweenService:Create(AnimationButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        local revertGlow = TweenService:Create(glow, tweenInfo, {Transparency = 1})
        revertTween:Play()
        revertGlow:Play()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Gazer-Ha/Reimagined/refs/heads/main/FE%20Animation%20editor'))()
    end)
end)

-- CMDxLTE functionality
CMDxLTEButton.MouseButton1Click:Connect(function()
    local glow = addButtonEffects(CMDxLTEButton)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local glowTween = TweenService:Create(glow, tweenInfo, {Transparency = 0})
    glowTween:Play()
    local tween = TweenService:Create(CMDxLTEButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
    tween:Play()
    tween.Completed:Connect(function()
        local revertTween = TweenService:Create(CMDxLTEButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        local revertGlow = TweenService:Create(glow, tweenInfo, {Transparency = 1})
        revertTween:Play()
        revertGlow:Play()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/main.lua"))()
    end)
end)

-- AKAadmin functionality
AKAadminButton.MouseButton1Click:Connect(function()
    local glow = addButtonEffects(AKAadminButton)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local glowTween = TweenService:Create(glow, tweenInfo, {Transparency = 0})
    glowTween:Play()
    local tween = TweenService:Create(AKAadminButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)})
    tween:Play()
    tween.Completed:Connect(function()
        local revertTween = TweenService:Create(AKAadminButton, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
        local revertGlow = TweenService:Create(glow, tweenInfo, {Transparency = 1})
        revertTween:Play()
        revertGlow:Play()
        loadstring(game:HttpGet("https://angelical.me/ak.lua"))()
    end)
end)

-- Handle character respawn to prevent GUI destruction
LocalPlayer.CharacterAdded:Connect(function()
    -- Re-parent the ScreenGui to ensure it persists
    if ScreenGui.Parent ~= LocalPlayer.PlayerGui then
        ScreenGui.Parent = LocalPlayer.PlayerGui
        fadeIn() -- Reapply fade-in effect on respawn
    end
end)
