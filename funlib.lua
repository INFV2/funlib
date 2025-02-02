-- EnhancedUILibrary ModuleScript
local EnhancedUILibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Utility function to create UI objects
local function create(className, properties)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    return inst
end

-- Create a new window with title, size, and position.
function EnhancedUILibrary:CreateWindow(title, size, position)
    -- ScreenGui container
    local screenGui = create("ScreenGui", {
        Name = "EnhancedUILibrary",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui"),
    })

    -- Main window frame with red border
    local mainFrame = create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, size.X, 0, size.Y),
        Position = UDim2.new(0, position.X, 0, position.Y),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(255, 0, 0),
        Parent = screenGui,
    })

    -- Title bar (draggable)
    local titleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Parent = mainFrame,
    })

    -- Title label
    local titleLabel = create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Window",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamSemibold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    -- Close button ("X")
    local closeButton = create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundColor3 = Color3.fromRGB(150, 0, 0),
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BorderSizePixel = 0,
        Parent = titleBar,
    })

    -- Minimize button ("–")
    local minimizeButton = create("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = "–",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        BorderSizePixel = 0,
        Parent = titleBar,
    })

    -- Content frame: holds nav bar and main content panels
    local contentFrame = create("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Parent = mainFrame,
    })

    -- Navigation bar on the left (for tabs)
    local navBar = create("Frame", {
        Name = "NavBar",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(255, 0, 0),
        Parent = contentFrame,
    })
    local navList = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = navBar,
    })

    -- Container for tab content: fills the remainder of the window
    local tabContainer = create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 150, 0, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(255, 0, 0),
        Parent = contentFrame,
    })

    -- Variables for dragging the window
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    -- RightShift toggle for window visibility
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    -- Store the original content size for minimize
    local originalContentSize = contentFrame.Size
    local isMinimized = false

    -- Minimize functionality: tween the content frame height (leaving the title bar intact)
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(contentFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        else
            TweenService:Create(contentFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = originalContentSize}):Play()
        end
    end)

    -- Close functionality: destroy entire GUI
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Data structure to hold tabs
    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TitleBar = titleBar,
        TitleLabel = titleLabel,
        CloseButton = closeButton,
        MinimizeButton = minimizeButton,
        ContentFrame = contentFrame,
        NavBar = navBar,
        TabContainer = tabContainer,
        Tabs = {},
    }

    -- Function: Add a new navigation tab with associated content frame.
    -- The callback is called when the tab is selected.
    function window:AddTab(tabName, callback)
        -- Create nav button for the tab
        local button = create("TextButton", {
            Name = tabName .. "NavButton",
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(255, 0, 0),
            Text = tabName,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            Parent = navBar,
        })

        -- Create the associated content frame (hidden by default)
        local tabContent = create("Frame", {
            Name = tabName .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            BorderSizePixel = 0,
            Parent = tabContainer,
            Visible = false,
        })

        window.Tabs[tabName] = tabContent

        -- When the nav button is clicked, show this tab and hide others.
        button.MouseButton1Click:Connect(function()
            for name, frame in pairs(window.Tabs) do
                frame.Visible = (name == tabName)
            end
            if callback then
                callback(tabContent)
            end
        end)
    end

    -- Function: Create a slider inside a parent frame.
    -- sliderText: the label; minValue/maxValue: range; defaultValue: starting value;
    -- callback(value) is called when the slider is moved.
    function window:CreateSlider(parent, sliderText, minValue, maxValue, defaultValue, callback)
        local sliderFrame = create("Frame", {
            Name = sliderText .. "Slider",
            Size = UDim2.new(0, 250, 0, 50),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(255, 0, 0),
            Parent = parent,
        })
        local sliderLabel = create("TextLabel", {
            Name = "SliderLabel",
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = sliderText .. " (" .. tostring(defaultValue) .. ")",
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            Parent = sliderFrame,
        })
        local sliderBar = create("Frame", {
            Name = "SliderBar",
            Size = UDim2.new(1, -20, 0, 10),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(255, 0, 0),
            Parent = sliderFrame,
        })
        local percent = (defaultValue - minValue) / (maxValue - minValue)
        local sliderFill = create("Frame", {
            Name = "SliderFill",
            Size = UDim2.new(percent, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(0, 200, 0),
            BorderSizePixel = 0,
            Parent = sliderBar,
        })
        local sliderButton = create("TextButton", {
            Name = "SliderButton",
            Size = UDim2.new(0, 10, 1, 0),
            Position = UDim2.new(percent, -5, 0, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Text = "",
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Parent = sliderBar,
        })

        local currentValue = defaultValue
        local draggingSlider = false

        sliderButton.MouseButton1Down:Connect(function()
            draggingSlider = true
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                local absolutePos = sliderBar.AbsolutePosition.X
                local mouseX = input.Position.X
                local relativeX = math.clamp(mouseX - absolutePos, 0, sliderBar.AbsoluteSize.X)
                local newPercent = relativeX / sliderBar.AbsoluteSize.X
                currentValue = minValue + (maxValue - minValue) * newPercent
                sliderFill.Size = UDim2.new(newPercent, 0, 1, 0)
                sliderButton.Position = UDim2.new(newPercent, -5, 0, 0)
                sliderLabel.Text = sliderText .. " (" .. math.floor(currentValue) .. ")"
                if callback then
                    callback(currentValue)
                end
            end
        end)

        return {
            SliderFrame = sliderFrame,
            SliderLabel = sliderLabel,
            SliderBar = sliderBar,
            SliderFill = sliderFill,
            SliderButton = sliderButton,
            GetValue = function()
                return currentValue
            end
        }
    end

    -- Function: Create a switch toggle inside a parent frame.
    -- switchText: the label; defaultState: boolean; callback(state) is called when toggled.
    function window:CreateSwitch(parent, switchText, defaultState, callback)
        local switchFrame = create("Frame", {
            Name = switchText .. "Switch",
            Size = UDim2.new(0, 200, 0, 40),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(255, 0, 0),
            Parent = parent,
        })
        local switchLabel = create("TextLabel", {
            Name = "SwitchLabel",
            Size = UDim2.new(0.6, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = switchText,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            Parent = switchFrame,
        })
        local toggleButton = create("TextButton", {
            Name = "ToggleButton",
            Size = UDim2.new(0, 50, 0, 30),
            Position = UDim2.new(0.65, 0, 0.15, 0),
            BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0),
            Text = defaultState and "ON" or "OFF",
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(255, 0, 0),
            Parent = switchFrame,
        })

        local state = defaultState
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            toggleButton.Text = state and "ON" or "OFF"
            if callback then
                callback(state)
            end
        end)

        return {
            SwitchFrame = switchFrame,
            SwitchLabel = switchLabel,
            ToggleButton = toggleButton,
            GetState = function()
                return state
            end
        }
    end

    return window
end

return EnhancedUILibrary
