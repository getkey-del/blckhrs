-- BlackHorse UI Premium Design for Roblox
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Основной экран
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackHorseUIPremium"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Цветовая палитра
local Colors = {
    Dark = Color3.fromRGB(28, 28, 30),
    Darker = Color3.fromRGB(18, 18, 20),
    Light = Color3.fromRGB(242, 242, 247),
    Accent = Color3.fromRGB(0, 122, 255),
    Green = Color3.fromRGB(52, 199, 89),
    Red = Color3.fromRGB(255, 59, 48),
    Purple = Color3.fromRGB(175, 82, 222),
    Yellow = Color3.fromRGB(255, 204, 0)
}

-- Анимации
local function tweenElement(element, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    local tween = TweenService:Create(element, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Создание UI элементов с улучшенным дизайном
local function createRoundedFrame(parent, size, position, color, transparency, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = transparency
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 40)
    stroke.Thickness = 1
    stroke.Parent = frame
    
    frame.Parent = parent
    return frame
end

local function createTextLabel(parent, text, size, position, textColor, textSize, font)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor
    label.TextSize = textSize
    label.Font = font or Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createIconLabel(parent, icon, size, position, color)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = icon
    label.TextColor3 = color
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = parent
    return label
end

local function createTextField(parent, size, position, placeholder)
    local frame = createRoundedFrame(parent, size, position, Colors.Darker, 0, 10)
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 1, -10)
    textBox.Position = UDim2.new(0, 10, 0, 5)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = Colors.Light
    textBox.TextSize = 14
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    textBox.Font = Enum.Font.Gotham
    textBox.Text = ""
    textBox.Parent = frame
    
    return textBox, frame
end

local function createButton(parent, text, size, position, onClick, isAccent)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = isAccent and Colors.Accent or Colors.Darker
    button.TextColor3 = isAccent and Colors.Light or Colors.Light
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Анимация наведения
    button.MouseEnter:Connect(function()
        tweenElement(button, {BackgroundColor3 = isAccent and Color3.fromRGB(10, 132, 255) or Color3.fromRGB(40, 40, 42)}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        tweenElement(button, {BackgroundColor3 = isAccent and Colors.Accent or Colors.Darker}, 0.2)
    end)
    
    button.MouseButton1Down:Connect(function()
        tweenElement(button, {BackgroundTransparency = 0.3}, 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        tweenElement(button, {BackgroundTransparency = 0}, 0.1)
        onClick()
    end)
    
    button.Parent = parent
    return button
end

local function createToggle(parent, text, size, position, initialState, onChange)
    local toggleFrame = createRoundedFrame(parent, UDim2.new(0, 51, 0, 31), position, Color3.fromRGB(50, 50, 52), 0, 15)
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 27, 0, 27)
    toggleButton.Position = initialState and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleButton.BackgroundColor3 = Colors.Light
    toggleButton.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleButton
    
    local label = createTextLabel(parent, text, UDim2.new(0, 200, 0, 30), UDim2.new(position.X.Scale, position.X.Offset + 60, position.Y.Scale, position.Y.Offset), Colors.Light, 14)
    
    local isEnabled = initialState
    toggleFrame.BackgroundColor3 = isEnabled and Colors.Green or Color3.fromRGB(50, 50, 52)
    
    toggleFrame.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        onChange(isEnabled)
        
        if isEnabled then
            tweenElement(toggleButton, {Position = UDim2.new(0, 22, 0, 2)}, 0.2)
            tweenElement(toggleFrame, {BackgroundColor3 = Colors.Green}, 0.2)
        else
            tweenElement(toggleButton, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
            tweenElement(toggleFrame, {BackgroundColor3 = Color3.fromRGB(50, 50, 52)}, 0.2)
        end
    end)
    
    toggleButton.Parent = toggleFrame
    return toggleFrame, label
end

local function createDropdown(parent, options, size, position, defaultIndex, onChange)
    local dropdownFrame = createRoundedFrame(parent, size, position, Colors.Darker, 0, 8)
    dropdownFrame.ClipsDescendants = true
    
    local selectedIndex = defaultIndex or 1
    local isOpen = false
    
    local selectedText = createTextLabel(dropdownFrame, options[selectedIndex], UDim2.new(1, -30, 1, 0), UDim2.new(0, 10, 0, 0), Colors.Light, 14)
    
    local arrow = createTextLabel(dropdownFrame, "▼", UDim2.new(0, 20, 1, 0), UDim2.new(1, -25, 0, 0), Colors.Light, 12)
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    
    local optionsFrame = createRoundedFrame(dropdownFrame, UDim2.new(1, 0, 0, #options * 30), UDim2.new(0, 0, 1, 5), Colors.Dark, 0, 8)
    optionsFrame.Visible = false
    
    for i, option in ipairs(options) do
        local optionButton = createButton(optionsFrame, option, UDim2.new(1, -10, 0, 25), UDim2.new(0, 5, 0, (i-1)*30), function()
            selectedIndex = i
            selectedText.Text = option
            onChange(i, option)
            toggleDropdown()
        end)
        optionButton.BackgroundColor3 = Colors.Darker
    end
    
    local function toggleDropdown()
        isOpen = not isOpen
        if isOpen then
            optionsFrame.Visible = true
            tweenElement(optionsFrame, {Size = UDim2.new(1, 0, 0, #options * 30)}, 0.2)
            tweenElement(arrow, {Rotation = 180}, 0.2)
        else
            tweenElement(optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            tweenElement(arrow, {Rotation = 0}, 0.2)
            wait(0.2)
            optionsFrame.Visible = false
        end
    end
    
    dropdownFrame.MouseButton1Click:Connect(toggleDropdown)
    
    return dropdownFrame
end

-- Состояния приложения
local appState = {
    currentPage = "auth",
    keyVerified = false,
    lastVerificationTime = 0,
    currentTab = "main",
    settings = {
        autoBuyBrainrot = false,
        antiAFK = false,
        autoLockBase = false,
        autoCollect = false,
        autoSellAll = false,
        autoSellBad = false,
        hackSteal = false,
        instantSteal = false,
        upSteal = false,
        autoSteal = false,
        autoKick = false,
        antiRagdoll = false,
        speedBoost = false,
        infinityJump = false,
        jumpBoost = false,
        jumpPower = 100,
        noclip = false,
        antiTrap = false,
        antiBee = false,
        antiTaser = false,
        antiBoogie = false,
        antiMedusa = false,
        antiSlinger = false,
        antiBodySwap = false,
        selectedBrainrot = 1,
        serverMoneyFilter = 1
    }
}

-- Проверка ключа
local function verifyKey(key)
    if not key:find("FREE_") then
        return false
    end
    
    local rest = key:sub(6):lower()
    local horseLetters = {"h", "o", "r", "s", "e"}
    
    for _, letter in ipairs(horseLetters) do
        if not rest:find(letter) then
            return false
        end
    end
    
    return true
end

-- Создание основного интерфейса
local mainFrame = createRoundedFrame(ScreenGui, UDim2.new(0, 500, 0, 600), UDim2.new(0.5, -250, 0.5, -300), Colors.Dark, 0, 14)
mainFrame.Visible = true

-- Заголовок окна
local titleBar = createRoundedFrame(mainFrame, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), Colors.Darker, 0, 12)
titleBar.ZIndex = 2

createTextLabel(titleBar, "BlackHorse", UDim2.new(0, 120, 1, 0), UDim2.new(0, 15, 0, 0), Colors.Light, 16, Enum.Font.GothamBold)

-- Кнопки управления окном
local windowControls = createRoundedFrame(titleBar, UDim2.new(0, 90, 0, 20), UDim2.new(1, -100, 0.5, -10), Color3.fromRGB(40, 40, 42), 0, 10)

local closeBtn = createButton(windowControls, "×", UDim2.new(0, 20, 0, 20), UDim2.new(0, 5, 0, 0), function()
    mainFrame.Visible = false
    restoreButton.Visible = true
end)

local minimizeBtn = createButton(windowControls, "−", UDim2.new(0, 20, 0, 20), UDim2.new(0, 30, 0, 0), function()
    mainFrame.Visible = false
    restoreButton.Visible = true
end)

local maximizeBtn = createButton(windowControls, "□", UDim2.new(0, 20, 0, 20), UDim2.new(0, 55, 0, 0), function()
    if mainFrame.Size == UDim2.new(0, 500, 0, 600) then
        mainFrame.Size = UDim2.new(0.9, 0, 0.9, 0)
        mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    else
        mainFrame.Size = UDim2.new(0, 500, 0, 600)
        mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    end
end)

-- Кнопка восстановления
local restoreButton = createRoundedFrame(ScreenGui, UDim2.new(0, 50, 0, 50), UDim2.new(0, 30, 0, 30), Colors.Accent, 0, 25)
restoreButton.Visible = false

createIconLabel(restoreButton, "↗", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Colors.Light)

restoreButton.MouseButton1Click:Connect(function()
    tweenElement(mainFrame, {Position = UDim2.new(0.5, -250, 0.5, -300)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    mainFrame.Visible = true
    restoreButton.Visible = false
end)

-- Drag functionality
local dragging = false
local dragInput, dragStart, startPos

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
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Функции для страниц
local currentContentFrame = nil

local function clearContent()
    if currentContentFrame then
        currentContentFrame:Destroy()
        currentContentFrame = nil
    end
end

local function showAuthPage()
    clearContent()
    local authFrame = createRoundedFrame(mainFrame, UDim2.new(1, -20, 1, -60), UDim2.new(0, 10, 0, 50), Colors.Darker, 0, 10)
    currentContentFrame = authFrame
    
    createTextLabel(authFrame, "🔑 Enter License Key", UDim2.new(1, 0, 0, 40), UDim2.new(0, 20, 0, 20), Colors.Light, 18, Enum.Font.GothamBold)
    
    local keyInput, inputFrame = createTextField(authFrame, UDim2.new(1, -40, 0, 45), UDim2.new(0, 20, 0, 70), "FREE_xxxxxxxxxxxx")
    
    local errorLabel = createTextLabel(authFrame, "", UDim2.new(1, -40, 0, 20), UDim2.new(0, 20, 0, 125), Colors.Red, 12)
    
    createButton(authFrame, "✅ Verify Key", UDim2.new(1, -40, 0, 45), UDim2.new(0, 20, 0, 160), function()
        if verifyKey(keyInput.Text) then
            appState.keyVerified = true
            appState.lastVerificationTime = os.time()
            
            tweenElement(inputFrame, {BackgroundColor3 = Colors.Green}, 0.3)
            wait(0.5)
            
            showMainPage()
        else
            errorLabel.Text = "❌ Invalid key format. Must contain 'FREE_' and 'horse'"
            tweenElement(inputFrame, {BackgroundColor3 = Colors.Red}, 0.3)
            wait(1.5)
            tweenElement(inputFrame, {BackgroundColor3 = Colors.Darker}, 0.3)
        end
    end, true)
    
    createButton(authFrame, "🌐 Get Key Online", UDim2.new(1, -40, 0, 45), UDim2.new(0, 20, 0, 215), function()
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow("https://getkey-del.github.io/blackhorse/")
        end)
    end)
    
    createTextLabel(authFrame, "Your key should look like: FREE_u3H4o8fR9nSe", UDim2.new(1, -40, 0, 20), UDim2.new(0, 20, 0, 270), Color3.fromRGB(150, 150, 150), 12)
end

local function showMainPage()
    clearContent()
    local mainContent = createRoundedFrame(mainFrame, UDim2.new(1, -20, 1, -60), UDim2.new(0, 10, 0, 50), Colors.Darker, 0, 10)
    currentContentFrame = mainContent
    
    -- Вкладки
    local tabs = {
        {name = "Main", icon = "🏠"},
        {name = "Stealer", icon = "🎯"}, 
        {name = "Player", icon = "👤"},
        {name = "Spawner", icon = "🔄"},
        {name = "Server", icon = "🌐"}
    }
    
    local tabButtons = {}
    for i, tab in ipairs(tabs) do
        local tabBtn = createButton(mainContent, tab.icon .. " " .. tab.name, UDim2.new(0.2, -2, 0, 35), UDim2.new((i-1) * 0.2, 1, 0, 10), function()
            appState.currentTab = tab.name:lower()
            for _, btn in pairs(tabButtons) do
                tweenElement(btn, {BackgroundColor3 = Colors.Darker}, 0.2)
            end
            tweenElement(tabBtn, {BackgroundColor3 = Colors.Accent}, 0.2)
            showTabContent()
        end)
        tabButtons[i] = tabBtn
    end
    
    local contentArea = createRoundedFrame(mainContent, UDim2.new(1, -20, 1, -55), UDim2.new(0, 10, 0, 50), Color3.fromRGB(35, 35, 37), 0, 8)
    
    local function showTabContent()
        contentArea:ClearAllChildren()
        
        if appState.currentTab == "main" then
            createTextLabel(contentArea, "🚜 Farm Automation", UDim2.new(1, 0, 0, 30), UDim2.new(0, 15, 0, 10), Colors.Light, 16, Enum.Font.GothamBold)
            
            local toggle1, label1 = createToggle(contentArea, "Auto buy Brainrot", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 50), appState.settings.autoBuyBrainrot, function(state)
                appState.settings.autoBuyBrainrot = state
            end)
            
            createTextLabel(contentArea, "⚠️ Turn off Speed Boost first", UDim2.new(1, -20, 0, 20), UDim2.new(0, 15, 0, 85), Colors.Yellow, 12)
            
            local toggle2, label2 = createToggle(contentArea, "Anti AFK", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 120), appState.settings.antiAFK, function(state)
                appState.settings.antiAFK = state
            end)
            
            local toggle3, label3 = createToggle(contentArea, "Auto Lock Base", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 160), appState.settings.autoLockBase, function(state)
                appState.settings.autoLockBase = state
            end)
            
            local toggle4, label4 = createToggle(contentArea, "Auto Collect", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 200), appState.settings.autoCollect, function(state)
                appState.settings.autoCollect = state
            end)
            
            createTextLabel(contentArea, "💰 Auto Sell", UDim2.new(1, 0, 0, 30), UDim2.new(0, 15, 0, 240), Colors.Light, 16, Enum.Font.GothamBold)
            
            local toggle5, label5 = createToggle(contentArea, "Auto Sell All", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 280), appState.settings.autoSellAll, function(state)
                appState.settings.autoSellAll = state
            end)
            
            local toggle6, label6 = createToggle(contentArea, "Auto Sell Bad Brainrot (<10k)", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 320), appState.settings.autoSellBad, function(state)
                appState.settings.autoSellBad = state
            end)
            
        elseif appState.currentTab == "stealer" then
            createTextLabel(contentArea, "🎯 Stealer Options", UDim2.new(1, 0, 0, 30), UDim2.new(0, 15, 0, 10), Colors.Light, 16, Enum.Font.GothamBold)
            
            local toggle1, label1 = createToggle(contentArea, "Hack Steal", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 50), appState.settings.hackSteal, function(state)
                appState.settings.hackSteal = state
            end)
            
            if appState.settings.hackSteal then
                createButton(contentArea, "🚨 STEALING", UDim2.new(0, 120, 0, 35), UDim2.new(0, 15, 0, 85), function()
                    -- Stealing logic
                end, true)
            end
            
            local toggle2, label2 = createToggle(contentArea, "Instant Steal", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 130), appState.settings.instantSteal, function(state)
                appState.settings.instantSteal = state
            end)
            
            createTextLabel(contentArea, "Need 3 rebirths and open base", UDim2.new(1, -20, 0, 20), UDim2.new(0, 15, 0, 165), Color3.fromRGB(150, 150, 150), 12)
            
            local toggle3, label3 = createToggle(contentArea, "Up Steal", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 190), appState.settings.upSteal, function(state)
                appState.settings.upSteal = state
            end)
            
            local toggle4, label4 = createToggle(contentArea, "Auto Steal", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 230), appState.settings.autoSteal, function(state)
                appState.settings.autoSteal = state
            end)
            
            local toggle5, label5 = createToggle(contentArea, "Auto Kick", UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, 270), appState.settings.autoKick, function(state)
                appState.settings.autoKick = state
            end)
            
        elseif appState.currentTab == "player" then
            createTextLabel(contentArea, "👤 Player Modifications", UDim2.new(1, 0, 0, 30), UDim2.new(0, 15, 0, 10), Colors.Light, 16, Enum.Font.GothamBold)
            
            local toggles = {
                {"Anti Ragdoll", "antiRagdoll", 50},
                {"Speed Boost (3 rebirths required)", "speedBoost", 90},
                {"Infinity Jump", "infinityJump", 130},
                {"Jump Boost", "jumpBoost", 170},
                {"Noclip (FIXED)", "noclip", 210},
                {"Anti Trap", "antiTrap", 250},
                {"Anti Bee Launcher", "antiBee", 290},
                {"Anti Taser Gun", "antiTaser", 330},
                {"Anti Boogie Bomb", "antiBoogie", 370},
                {"Anti Medusa Head", "antiMedusa", 410},
                {"Anti Slinger", "antiSlinger", 450},
                {"Anti Body Swap", "antiBodySwap", 490}
            }
            
            for i, toggleData in ipairs(toggles) do
                local toggle, label = createToggle(contentArea, toggleData[1], UDim2.new(0, 51, 0, 31), UDim2.new(0, 15, 0, toggleData[3]), appState.settings[toggleData[2]], function(state)
                    appState.settings[toggleData[2]] = state
                end)
            end
            
            if appState.settings.jumpBoost then
                createTextLabel(contentArea, "Jump Power: " .. appState.settings.jumpPower, UDim2.new(1, -20, 0, 20), UDim2.new(0, 15, 0, 530), Colors.Light, 12)
                local slider = createRoundedFrame(contentArea, UDim2.new(0, 200, 0, 5), UDim2.new(0, 15, 0, 555), Colors.Darker, 0, 3)
                local sliderBtn = createRoundedFrame(slider, UDim2.new(0, 15, 0, 15), UDim2.new((appState.settings.jumpPower - 100) / 900, -7, 0, -5), Colors.Accent, 0, 8)
            end
            
        elseif appState.currentTab == "spawner" then
            createTextLabel(contentArea, "🔄 Spawner Options", UDim2.new(1, 0, 0, 30), UDim2.new(0, 15, 0, 10), Colors.Light, 16, Enum.Font.GothamBold)
            
            createTextLabel(contentArea, "Choose Brainrot", UDim2.new(1, 0, 0, 20), UDim2.new(0, 15, 0, 50), Colors.Light, 14)
            
            local brainrots = {"Noobini Pizzanini", "Pipi Kiwi", "Cappuchinno Assasino"}
            local dropdown = createDropdown(contentArea, brainrots, UDim2.new(0, 200, 0, 30), UDim2.new(0, 15, 0, 75), appState.settings.selectedBrainrot, function(index, value)
                appState.settings.selectedBrainrot = index
            end)
            
            createTextLabel(contentArea, "Enter ID", UDim2.new(1, 0, 0, 20), UDim2.new(0, 15, 0, 115), Colors.Light, 14)
            
            local idInput = createTextField(contentArea, UDim2.new(0, 200, 0, 30), UDim2.new(0, 15, 0, 140), "Player ID")
            
            createButton(contentArea, "🚀 Spawn", UDim2.new(0, 100, 0, 35), UDim2.new(0, 15, 0, 180), function()
                -- Spawn logic
            end, true)
            
        elseif appState.currentTab == "server" then
            createTextLabel(contentArea, "🌐 Server Finder", UDim2.new(1, 0, 0, 30), UDim2.new(0, 15, 0, 10), Colors.Light, 16, Enum.Font.GothamBold)
            
            createTextLabel(contentArea, "Min money per sec to find", UDim2.new(1, 0, 0, 20), UDim2.new(0, 15, 0, 50), Colors.Light, 14)
            
            local moneyOptions = {"20K/s", "50k/s", "200k/s", "500k/s", "1m/s", "5m/s", "30m/s"}
            local dropdown = createDropdown(contentArea, moneyOptions, UDim2.new(0, 150, 0, 30), UDim2.new(0, 15, 0, 75), appState.settings.serverMoneyFilter, function(index, value)
                appState.settings.serverMoneyFilter = index
            end)
        end
    end
    
    showTabContent()
end

-- Запуск приложения
if appState.keyVerified and (os.time() - appState.lastVerificationTime) < 604800 then
    showMainPage()
else
    showAuthPage()
end

-- 7-day notification check
if appState.keyVerified and (os.time() - appState.lastVerificationTime) >= 604800 then
    local notify = createTextLabel(ScreenGui, "⚠️ Please renew your license key!", UDim2.new(0, 250, 0, 40), UDim2.new(0.5, -125, 0, 20), Colors.Light, 14)
    notify.BackgroundColor3 = Colors.Red
    notify.TextXAlignment = Enum.TextXAlignment.Center
    notify.ZIndex = 100
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notify
    
    wait(5)
    tweenElement(notify, {BackgroundTransparency = 1, TextTransparency = 1}, 0.5)
    wait(0.5)
    notify:Destroy()
end