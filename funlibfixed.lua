-- Modern UI Library for Roblox Executors
local Library = {
    theme = {
        main = Color3.fromRGB(30, 30, 30),
        secondary = Color3.fromRGB(40, 40, 40),
        accent = Color3.fromRGB(60, 120, 255),
        text = Color3.fromRGB(255, 255, 255),
        stroke = Color3.fromRGB(60, 60, 60),
        darkAccent = Color3.fromRGB(40, 80, 180),
        lightAccent = Color3.fromRGB(80, 140, 255)
    }
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Utility Functions
local function Create(class, properties)
    local instance = Instance.new(class)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function CreateStroke(parent, properties)
    local stroke = Create("UIStroke", {
        Parent = parent,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Library.theme.stroke,
        Thickness = 1
    })
    
    for property, value in pairs(properties or {}) do
        stroke[property] = value
    end
    
    return stroke
end

local function CreateShadow(parent)
    local shadow = Create("ImageLabel", {
        Parent = parent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 24, 1, 24),
        ZIndex = -1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })
    return shadow
end

local function Drag(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.2), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

function Library:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        Library.theme[key] = value
    end
end

function Library:CreateWindow(title)
    local Window = {}
    Window.tabs = {}
    Window.currentTab = nil
    
    -- Main GUI Creation
    local ScreenGui = Create("ScreenGui", {
        Name = "ModernUILibrary",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Library.theme.main,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true
    })

    CreateShadow(MainFrame)
    
    local UICorner = Create("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 8)
    })

    -- Top Bar
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Library.theme.secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30)
    })

    local UICornerTop = Create("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, 8)
    })

    -- Title
    local TitleLabel = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Library.theme.text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Close Button
    local CloseButton = Create("ImageButton", {
        Name = "Close",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -26, 0, 4),
        Size = UDim2.new(0, 22, 0, 22),
        Image = "rbxassetid://6031094678",
        ImageColor3 = Library.theme.text,
        ImageTransparency = 0.2
    })

    -- Minimize Button
    local MinimizeButton = Create("ImageButton", {
        Name = "Minimize",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -52, 0, 4),
        Size = UDim2.new(0, 22, 0, 22),
        Image = "rbxassetid://6031090990",
        ImageColor3 = Library.theme.text,
        ImageTransparency = 0.2
    })

    -- Tab Container
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Library.theme.secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(0, 150, 1, -30)
    })

    local TabList = Create("ScrollingFrame", {
        Name = "TabList",
        Parent = TabContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.theme.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local TabListLayout = Create("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 30),
        Size = UDim2.new(1, -150, 1, -30),
        ClipsDescendants = true
    })

    -- Make window draggable
    Drag(MainFrame, TopBar)

    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Minimize button functionality
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            Size = minimized and UDim2.new(0, 600, 0, 30) or UDim2.new(0, 600, 0, 400)
        }):Play()
    end)

    -- Tab Creation
    function Window:CreateTab(name, icon)
        local Tab = {}
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = name.."Tab",
            Parent = TabList,
            BackgroundColor3 = Library.theme.main,
            Size = UDim2.new(1, -10, 0, 32),
            Position = UDim2.new(0, 5, 0, 0),
            AutoButtonColor = false,
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = Library.theme.text,
            TextSize = 14
        })

        local UICorner = Create("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 6)
        })

        -- Tab Icon
        if icon then
            local IconImage = Create("ImageLabel", {
                Name = "Icon",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = icon,
                ImageColor3 = Library.theme.text
            })
        end

        -- Tab Text
        local TabText = Create("TextLabel", {
            Name = "Title",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, icon and 32 or 12, 0, 0),
            Size = UDim2.new(1, icon and -40 or -20, 1, 0),
            Font = Enum.Font.Gotham,
            Text = name,
            TextColor3 = Library.theme.text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = name.."Content",
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.theme.accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })

        local ContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5)
        })

        local ContentPadding = Create("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10)
        })

        -- Tab Selection
        TabButton.MouseButton1Click:Connect(function()
            if Window.currentTab == Tab then return end
            
            -- Deselect current tab
            if Window.currentTab then
                TweenService:Create(Window.currentTab.button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Library.theme.main
                }):Play()
                Window.currentTab.content.Visible = false
            end
            
            -- Select new tab
            Window.currentTab = Tab
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Library.theme.accent
            }):Play()
            TabContent.Visible = true
        end)

        -- Create Elements
        function Tab:CreateButton(text, callback)
            callback = callback or function() end
            
            local Button = Create("TextButton", {
                Name = "Button",
                Parent = TabContent,
                BackgroundColor3 = Library.theme.secondary,
                Size = UDim2.new(1, 0, 0, 32),
                AutoButtonColor = false,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.theme.text,
                TextSize = 13
            })

            local UICorner = Create("UICorner", {
                Parent = Button,
                CornerRadius = UDim.new(0, 6)
            })

            CreateStroke(Button)

            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Library.theme.accent
                }):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Library.theme.secondary
                }):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                callback()
                
                -- Click effect
                local Circle = Create("Frame", {
                    Parent = Button,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.9,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 0, 0, 0)
                })

                local UICorner = Create("UICorner", {
                    Parent = Circle,
                    CornerRadius = UDim.new(1, 0)
                })

                TweenService:Create(Circle, TweenInfo.new(0.5), {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1
                }):Play()

                game.Debris:AddItem(Circle, 0.5)
            end)

            return Button
        end

        function Tab:CreateToggle(text, default, callback)
            callback = callback or function() end
            local toggled = default or false

            local Toggle = Create("Frame", {
                Name = "Toggle",
                Parent = TabContent,
                BackgroundColor3 = Library.theme.secondary,
                Size = UDim2.new(1, 0, 0, 32)
            })

            local UICorner = Create("UICorner", {
                Parent = Toggle,
                CornerRadius = UDim.new(0, 6)
            })

            CreateStroke(Toggle)

            local Label = Create("TextLabel", {
                Name = "Label",
                Parent = Toggle,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ToggleButton = Create("Frame", {
                Name = "ToggleButton",
                Parent = Toggle,
                BackgroundColor3 = toggled and Library.theme.accent or Library.theme.stroke,
                Position = UDim2.new(1, -42, 0.5, -8),
                Size = UDim2.new(0, 32, 0, 16)
            })

            local UICorner = Create("UICorner", {
                Parent = ToggleButton,
                CornerRadius = UDim.new(1, 0)
            })

            local Circle = Create("Frame", {
                Name = "Circle",
                Parent = ToggleButton,
                BackgroundColor3 = Library.theme.text,
                Position = UDim2.new(0, toggled and 16 or 2, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12)
            })

            local UICorner = Create("UICorner", {
                Parent = Circle,
                CornerRadius = UDim.new(1, 0)
            })

            Toggle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggled = not toggled
                    callback(toggled)
                    
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = toggled and Library.theme.accent or Library.theme.stroke
                    }):Play()
                    
                    TweenService:Create(Circle, TweenInfo.new(0.2), {
                        Position = toggled and UDim2.new(0, 16, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                    }):Play()
                end
            end)

            return Toggle
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            callback = callback or function() end
            default = math.clamp(default or min, min, max)

            local Slider = Create("Frame", {
                Name = "Slider",
                Parent = TabContent,
                BackgroundColor3 = Library.theme.secondary,
                Size = UDim2.new(1, 0, 0, 50)
            })

            local UICorner = Create("UICorner", {
                Parent = Slider,
                CornerRadius = UDim.new(0, 6)
            })

            CreateStroke(Slider)

            local Label = Create("TextLabel", {
                Name = "Label",
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLabel = Create("TextLabel", {
                Name = "Value",
                Parent = Slider,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 0),
                Size = UDim2.new(0, 40, 0, 30),
                Font = Enum.Font.Gotham,
                Text = tostring(default),
                TextColor3 = Library.theme.text,
                TextSize = 13
            })

            local SliderBar = Create("Frame", {
                Name = "SliderBar",
                Parent = Slider,
                BackgroundColor3 = Library.theme.stroke,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 0, 4)
            })

            local UICorner = Create("UICorner", {
                Parent = SliderBar,
                CornerRadius = UDim.new(1, 0)
            })

            local Fill = Create("Frame", {
                Name = "Fill",
                Parent = SliderBar,
                BackgroundColor3 = Library.theme.accent,
                Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
            })

            local UICorner = Create("UICorner", {
                Parent = Fill,
                CornerRadius = UDim.new(1, 0)
            })

            local function update(input)
                local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 1, 0)
                Fill.Size = pos
                local value = math.floor(min + ((max - min) * pos.X.Scale))
                ValueLabel.Text = tostring(value)
                callback(value)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local connection
                    connection = RunService.RenderStepped:Connect(function()
                        local mousePos = UserInputService:GetMouseLocation()
                        local input = {Position = Vector2.new(mousePos.X, mousePos.Y)}
                        update(input)
                        
                        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            connection:Disconnect()
                        end
                    end)
                    
                    update(input)
                end
            end)

            return Slider
        end

        function Tab:CreateDropdown(text, options, default, callback)
            callback = callback or function() end
            
            local Dropdown = Create("Frame", {
                Name = "Dropdown",
                Parent = TabContent,
                BackgroundColor3 = Library.theme.secondary,
                Size = UDim2.new(1, 0, 0, 32),
                ClipsDescendants = true
            })

            local UICorner = Create("UICorner", {
                Parent = Dropdown,
                CornerRadius = UDim.new(0, 6)
            })

            CreateStroke(Dropdown)

            local Label = Create("TextLabel", {
                Name = "Label",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 0, 32),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Arrow = Create("ImageLabel", {
                Name = "Arrow",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -26, 0, 8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://6031094670",
                ImageColor3 = Library.theme.text,
                Rotation = 0
            })

            local OptionContainer = Create("Frame", {
                Name = "OptionContainer",
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, #options * 24)
            })

            local UIListLayout = Create("UIListLayout", {
                Parent = OptionContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0)
            })

            local selected = default or options[1]
            local open = false

            local function updateDropdown()
                Label.Text = text .. ": " .. selected
                callback(selected)
            end

            for i, option in ipairs(options) do
                local OptionButton = Create("TextButton", {
                    Name = option,
                    Parent = OptionContainer,
                    BackgroundColor3 = Library.theme.main,
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = Library.theme.text,
                    TextSize = 13
                })

                OptionButton.MouseButton1Click:Connect(function()
                    selected = option
                    updateDropdown()
                    
                    TweenService:Create(Dropdown, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, 32)
                    }):Play()
                    
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {
                        Rotation = 0
                    }):Play()
                    
                    open = false
                end)
            end

            Dropdown.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    open = not open
                    
                    TweenService:Create(Dropdown, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, open and 32 + (#options * 24) or 32)
                    }):Play()
                    
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {
                        Rotation = open and 180 or 0
                    }):Play()
                end
            end)

            updateDropdown()
            return Dropdown
        end

        function Tab:CreateTextbox(text, placeholder, callback)
            callback = callback or function() end
            
            local Textbox = Create("Frame", {
                Name = "Textbox",
                Parent = TabContent,
                BackgroundColor3 = Library.theme.secondary,
                Size = UDim2.new(1, 0, 0, 32)
            })

            local UICorner = Create("UICorner", {
                Parent = Textbox,
                CornerRadius = UDim.new(0, 6)
            })

            CreateStroke(Textbox)

            local Label = Create("TextLabel", {
                Name = "Label",
                Parent = Textbox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 100, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local TextBox = Create("TextBox", {
                Name = "TextBox",
                Parent = Textbox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 110, 0, 0),
                Size = UDim2.new(1, -120, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "",
                PlaceholderText = placeholder,
                TextColor3 = Library.theme.text,
                PlaceholderColor3 = Library.theme.stroke,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false
            })

            TextBox.FocusLost:Connect(function(enterPressed)
                callback(TextBox.Text, enterPressed)
            end)

            return Textbox
        end

        function Tab:CreateColorPicker(text, default, callback)
            callback = callback or function() end
            default = default or Color3.fromRGB(255, 255, 255)
            
            local ColorPicker = Create("Frame", {
                Name = "ColorPicker",
                Parent = TabContent,
                BackgroundColor3 = Library.theme.secondary,
                Size = UDim2.new(1, 0, 0, 32)
            })

            local UICorner = Create("UICorner", {
                Parent = ColorPicker,
                CornerRadius = UDim.new(0, 6)
            })

            CreateStroke(ColorPicker)

            local Label = Create("TextLabel", {
                Name = "Label",
                Parent = ColorPicker,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Library.theme.text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Preview = Create("Frame", {
                Name = "Preview",
                Parent = ColorPicker,
                BackgroundColor3 = default,
                Position = UDim2.new(1, -42, 0.5, -8),
                Size = UDim2.new(0, 32, 0, 16)
            })

            local UICorner = Create("UICorner", {
                Parent = Preview,
                CornerRadius = UDim.new(0, 4)
            })

            -- Color picker functionality would go here
            -- This is a simplified version without the actual color picker UI
            -- You would typically create a color wheel and value slider

            return ColorPicker
        end

        -- Store tab data
        Tab.button = TabButton
        Tab.content = TabContent
        table.insert(Window.tabs, Tab)
        
        -- Select first tab
        if #Window.tabs == 1 then
            Window.currentTab = Tab
            TabButton.BackgroundColor3 = Library.theme.accent
            TabContent.Visible = true
        end
        
        return Tab
    end

    -- Update canvas sizes
    local function updateCanvasSizes()
        for _, tab in ipairs(Window.tabs) do
            local contentSize = tab.content.UIListLayout.AbsoluteContentSize
            tab.content.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 20)
        end
        
        local tabListSize = TabListLayout.AbsoluteContentSize
        TabList.CanvasSize = UDim2.new(0, 0, 0, tabListSize.Y + 10)
    end
    
    RunService.RenderStepped:Connect(updateCanvasSizes)

    return Window
end

return Library
