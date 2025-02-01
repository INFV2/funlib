local FunLib = {}

function FunLib:CreateWindow(config)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game.CoreGui
    screenGui.ResetOnSpawn = false

    local windowFrame = Instance.new("Frame")
    windowFrame.Size = UDim2.new(0, config.Size.Width, 0, config.Size.Height)
    windowFrame.Position = UDim2.new(0, config.Position.X, 0, config.Position.Y)
    windowFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    windowFrame.BorderSizePixel = 0
    windowFrame.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Untitled Window"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = windowFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = windowFrame

    -- Function to create a button
    local function CreateButton(buttonConfig)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Text = buttonConfig.Text or "Button"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.Parent = contentFrame

        button.MouseButton1Click:Connect(function()
            if buttonConfig.OnClick then
                buttonConfig.OnClick()
            end
        end)
    end

    -- Function to create a toggle
    local function CreateToggle(toggleConfig)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(1, 0, 0, 30)
        toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggle.Text = toggleConfig.Text .. ": " .. (toggleConfig.Default and "ON" or "OFF")
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.Font = Enum.Font.Gotham
        toggle.TextSize = 14
        toggle.Parent = contentFrame

        local state = toggleConfig.Default or false

        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = toggleConfig.Text .. ": " .. (state and "ON" or "OFF")
            if toggleConfig.OnToggle then
                toggleConfig.OnToggle(state)
            end
        end)
    end

    -- Function to create a slider
    local function CreateSlider(sliderConfig)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 30)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sliderFrame.Parent = contentFrame

        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Size = UDim2.new(1, 0, 0, 15)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = sliderConfig.Text .. ": " .. sliderConfig.Default
        sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        sliderLabel.Font = Enum.Font.Gotham
        sliderLabel.TextSize = 14
        sliderLabel.Parent = sliderFrame

        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, 0, 0, 5)
        sliderBar.Position = UDim2.new(0, 0, 0, 20)
        sliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        sliderBar.Parent = sliderFrame

        local sliderHandle = Instance.new("Frame")
        sliderHandle.Size = UDim2.new(0, 10, 0, 15)
        sliderHandle.Position = UDim2.new((sliderConfig.Default - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 0, 17.5)
        sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderHandle.Parent = sliderFrame

        local dragging = false
        local userInputService = game:GetService("UserInputService")

        sliderHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        sliderHandle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        userInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePosition = userInputService:GetMouseLocation().X
                local relativePosition = (mousePosition - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                local value = math.clamp(sliderConfig.Min + (sliderConfig.Max - sliderConfig.Min) * relativePosition, sliderConfig.Min, sliderConfig.Max)
                sliderHandle.Position = UDim2.new((value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 0, 17.5)
                sliderLabel.Text = sliderConfig.Text .. ": " .. math.floor(value)
                if sliderConfig.OnChange then
                    sliderConfig.OnChange(math.floor(value))
                end
            end
        end)
    end

    -- Function to create a dropdown
    local function CreateDropdown(dropdownConfig)
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropdownFrame.Parent = contentFrame

        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(1, 0, 1, 0)
        dropdownButton.BackgroundTransparency = 1
        dropdownButton.Text = dropdownConfig.Text .. ": Select Option"
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.TextSize = 14
        dropdownButton.Parent = dropdownFrame

        local dropdownMenu = Instance.new("Frame")
        dropdownMenu.Size = UDim2.new(1, 0, 0, 0)
        dropdownMenu.Position = UDim2.new(0, 0, 1, 0)
        dropdownMenu.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        dropdownMenu.Visible = false
        dropdownMenu.Parent = dropdownFrame

        local function UpdateDropdownMenu()
            dropdownMenu.Size = UDim2.new(1, 0, 0, #dropdownConfig.Options * 30)
            for _, child in pairs(dropdownMenu:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            for i, option in ipairs(dropdownConfig.Options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, 0, 0, 30)
                optionButton.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
                optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                optionButton.Text = option
                optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionButton.Font = Enum.Font.Gotham
                optionButton.TextSize = 14
                optionButton.Parent = dropdownMenu

                optionButton.MouseButton1Click:Connect(function()
                    dropdownButton.Text = dropdownConfig.Text .. ": " .. option
                    dropdownMenu.Visible = false
                    if dropdownConfig.OnSelect then
                        dropdownConfig.OnSelect(option)
                    end
                end)
            end
        end

        UpdateDropdownMenu()

        dropdownButton.MouseButton1Click:Connect(function()
            dropdownMenu.Visible = not dropdownMenu.Visible
        end)
    end

    -- Function to show a notification
    local function ShowNotification(notificationConfig)
        local notificationFrame = Instance.new("Frame")
        notificationFrame.Size = UDim2.new(0, 300, 0, 100)
        notificationFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
        notificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        notificationFrame.BorderSizePixel = 0
        notificationFrame.Parent = screenGui

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 20)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = notificationConfig.Title or "Notification"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 16
        titleLabel.Parent = notificationFrame

        local messageLabel = Instance.new("TextLabel")
        messageLabel.Size = UDim2.new(1, 0, 0, 40)
        messageLabel.Position = UDim2.new(0, 0, 0, 20)
        messageLabel.BackgroundTransparency = 1
        messageLabel.Text = notificationConfig.Message or "No message provided."
        messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextSize = 14
        messageLabel.Parent = notificationFrame

        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(1, 0, 0, 30)
        closeButton.Position = UDim2.new(0, 0, 0, 60)
        closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        closeButton.Text = notificationConfig.ButtonText or "Close"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.Font = Enum.Font.Gotham
        closeButton.TextSize = 14
        closeButton.Parent = notificationFrame

        closeButton.MouseButton1Click:Connect(function()
            notificationFrame:Destroy()
        end)
    end

    return {
        AddButton = CreateButton,
        AddToggle = CreateToggle,
        AddSlider = CreateSlider,
        AddDropdown = CreateDropdown,
        Notification = ShowNotification
    }
end

return FunLib
