local FunLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Default user info
local pfp, user, tag, userinfo = nil, nil, nil, {}
pcall(function()
    userinfo = HttpService:JSONDecode(readfile("funlibinfo.txt"))
end)
pfp = userinfo["pfp"] or "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
user = userinfo["user"] or LocalPlayer.Name
tag = userinfo["tag"] or tostring(math.random(1000, 9999))

-- Save user info to a file
local function SaveInfo()
    userinfo["pfp"] = pfp
    userinfo["user"] = user
    userinfo["tag"] = tag
    writefile("funlibinfo.txt", HttpService:JSONEncode(userinfo))
end

-- Make UI draggable
local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        object.Position = pos
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

-- Create the main GUI
local FunUI = Instance.new("ScreenGui")
FunUI.Name = "FunLib"
FunUI.Parent = game.CoreGui
FunUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Function to create a new window
function FunLib:Window(text)
    local currentservertoggled = ""
    local minimized = false
    local fs = false
    local settingsopened = false

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = FunUI
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 681, 0, 396)

    -- Top Bar
    local TopFrame = Instance.new("Frame")
    TopFrame.Name = "TopFrame"
    TopFrame.Parent = MainFrame
    TopFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
    TopFrame.BackgroundTransparency = 1.000
    TopFrame.BorderSizePixel = 0
    TopFrame.Position = UDim2.new(0, 0, 0, 0)
    TopFrame.Size = UDim2.new(0, 681, 0, 28)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopFrame
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.Position = UDim2.new(0.01, 0, 0, 0)
    Title.Size = UDim2.new(0, 200, 0, 28)
    Title.Font = Enum.Font.Gotham
    Title.Text = text
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14.000
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopFrame
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.Position = UDim2.new(0.95, 0, 0, 0)
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Font = Enum.Font.SourceSans
    CloseBtn.Text = ""
    CloseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.TextSize = 14.000

    -- Close Icon
    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Name = "CloseIcon"
    CloseIcon.Parent = CloseBtn
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundTransparency = 1.000
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(0, 16, 0, 16)
    CloseIcon.Image = "rbxassetid://6031091004"

    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TopFrame
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.BackgroundTransparency = 1.000
    MinimizeBtn.Position = UDim2.new(0.9, 0, 0, 0)
    MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
    MinimizeBtn.Font = Enum.Font.SourceSans
    MinimizeBtn.Text = ""
    MinimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    MinimizeBtn.TextSize = 14.000

    -- Minimize Icon
    local MinimizeIcon = Instance.new("ImageLabel")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = MinimizeBtn
    MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinimizeIcon.BackgroundTransparency = 1.000
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinimizeIcon.Size = UDim2.new(0, 16, 0, 16)
    MinimizeIcon.Image = "rbxassetid://6031091004"

    -- Servers Holder
    local ServersHolder = Instance.new("Folder")
    ServersHolder.Name = "ServersHolder"
    ServersHolder.Parent = MainFrame

    -- User Panel
    local Userpad = Instance.new("Frame")
    Userpad.Name = "Userpad"
    Userpad.Parent = MainFrame
    Userpad.BackgroundColor3 = Color3.fromRGB(47, 49, 54)
    Userpad.BorderSizePixel = 0
    Userpad.Position = UDim2.new(0, 0, 0.9, 0)
    Userpad.Size = UDim2.new(0, 681, 0, 36)

    -- User Icon
    local UserIcon = Instance.new("Frame")
    UserIcon.Name = "UserIcon"
    UserIcon.Parent = Userpad
    UserIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UserIcon.BackgroundTransparency = 1.000
    UserIcon.Position = UDim2.new(0.02, 0, 0.2, 0)
    UserIcon.Size = UDim2.new(0, 28, 0, 28)

    -- User Image
    local UserImage = Instance.new("ImageLabel")
    UserImage.Name = "UserImage"
    UserImage.Parent = UserIcon
    UserImage.BackgroundTransparency = 1.000
    UserImage.Size = UDim2.new(0, 28, 0, 28)
    UserImage.Image = pfp

    -- User Name
    local UserName = Instance.new("TextLabel")
    UserName.Name = "UserName"
    UserName.Parent = Userpad
    UserName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UserName.BackgroundTransparency = 1.000
    UserName.Position = UDim2.new(0.1, 0, 0, 0)
    UserName.Size = UDim2.new(0, 100, 0, 36)
    UserName.Font = Enum.Font.Gotham
    UserName.Text = user
    UserName.TextColor3 = Color3.fromRGB(255, 255, 255)
    UserName.TextSize = 14.000
    UserName.TextXAlignment = Enum.TextXAlignment.Left

    -- User Tag
    local UserTag = Instance.new("TextLabel")
    UserTag.Name = "UserTag"
    UserTag.Parent = Userpad
    UserTag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UserTag.BackgroundTransparency = 1.000
    UserTag.Position = UDim2.new(0.1, 0, 0.5, 0)
    UserTag.Size = UDim2.new(0, 100, 0, 18)
    UserTag.Font = Enum.Font.Gotham
    UserTag.Text = "#" .. tag
    UserTag.TextColor3 = Color3.fromRGB(185, 187, 190)
    UserTag.TextSize = 12.000
    UserTag.TextXAlignment = Enum.TextXAlignment.Left

    -- Make the UI draggable
    MakeDraggable(TopFrame, MainFrame)

    -- Close Button Functionality
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame:Destroy()
    end)

    -- Minimize Button Functionality
    MinimizeBtn.MouseButton1Click:Connect(function()
        if minimized then
            MainFrame:TweenSize(UDim2.new(0, 681, 0, 396), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
            minimized = false
        else
            MainFrame:TweenSize(UDim2.new(0, 681, 0, 36), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
            minimized = true
        end
    end)

    -- Return table for additional functions
    return {
        Notification = function(titletext, desctext, btntext)
            print("Notification:", titletext, desctext, btntext)
        end,
        Toggle = function(name, callback)
            print("Toggle Created:", name)
        end,
        Button = function(name, callback)
            print("Button Created:", name)
        end
    }
end

return FunLib
