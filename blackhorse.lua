local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Основной экран
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackHorseUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- Переменные для хранения состояния
local isVerified = false
local verificationTime = 0
local currentKey = ""
local currentTab = "Main"

-- Сохранение данных
local function saveData()
    local data = {
        isVerified = isVerified,
        verificationTime = verificationTime,
        currentKey = currentKey
    }
    pcall(function()
        writefile("blackhorse_data.txt", HttpService:JSONEncode(data))
    end)
end

local function loadData()
    pcall(function()
        if isfile("blackhorse_data.txt") then
            local data = HttpService:JSONDecode(readfile("blackhorse_data.txt"))
            isVerified = data.isVerified or false
            verificationTime = data.verificationTime or 0
            currentKey = data.currentKey or ""
        end
    end)
end

loadData()

-- Функция для проверки ключа
local function verifyKey(inputKey)
    if string.sub(inputKey, 1, 5) ~= "FREE_" then
        return false
    end
    
    local rest = string.sub(inputKey, 6)
    local lettersFound = {h = false, o = false, r = false, s = false, e = false}
    local temp = rest:lower()
    
    for letter in pairs(lettersFound) do
        local pos = string.find(temp, letter)
        if pos then
            lettersFound[letter] = true
            temp = temp:sub(1, pos-1) .. temp:sub(pos+1)
        end
    end
    
    for _, found in pairs(lettersFound) do
        if not found then
            return false
        end
    end
    
    return true
end

-- Функция создания закругленного окна
local function createRoundedFrame(parent, size, position, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    frame.Parent = parent
    return frame
end

-- Функция создания кнопки
local function createButton(parent, text, size, position, callback, isOutline)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = isOutline and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    button.TextColor3 = isOutline and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
    button.Text = text
    button.Font = Enum.Font.SourceSansSemibold
    button.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    if isOutline then
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(1, 1, 1)
        stroke.Thickness = 2
        stroke.Parent = button
    end
    
    button.MouseButton1Click:Connect(callback)
    button.Parent = parent
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = isOutline and Color3.new(0.2, 0.2, 0.2) or Color3.new(0.9, 0.9, 0.9)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = isOutline and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    end)
    
    return button
end

-- Функция создания переключателя iOS стиля
local function createToggle(parent, text, position, defaultState)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 300, 0, 30)
    toggleFrame.Position = position
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 250, 0, 30)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -45, 0, 5)
    toggleButton.BackgroundColor3 = defaultState and Color3.new(0, 0.7, 0) or Color3.new(0.5, 0.5, 0.5)
    toggleButton.Text = ""
    toggleButton.ZIndex = 2
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toggleButton
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = defaultState and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
    toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleCircle.ZIndex = 3
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0, 8)
    circleCorner.Parent = toggleCircle
    
    local isOn = defaultState
    
    local function updateToggle()
        if isOn then
            toggleButton.BackgroundColor3 = Color3.new(0, 0.7, 0)
            toggleCircle.Position = UDim2.new(0, 22, 0, 2)
        else
            toggleButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
            toggleCircle.Position = UDim2.new(0, 2, 0, 2)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateToggle()
    end)
    
    toggleCircle.Parent = toggleButton
    toggleButton.Parent = toggleFrame
    
    updateToggle()
    
    return toggleButton, function() return isOn end, function(value) isOn = value; updateToggle() end
end

-- Функция создания выпадающего списка
local function createDropdown(parent, options, position, defaultText)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0, 200, 0, 30)
    dropdownFrame.Position = position
    dropdownFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    dropdownFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dropdownFrame
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(0, 170, 0, 30)
    selectedLabel.Position = UDim2.new(0, 10, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = defaultText or "Select..."
    selectedLabel.TextColor3 = Color3.new(1, 1, 1)
    selectedLabel.Font = Enum.Font.SourceSans
    selectedLabel.TextSize = 14
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Parent = dropdownFrame
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 0, 30)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.new(1, 1, 1)
    arrow.Font = Enum.Font.SourceSans
    arrow.TextSize = 12
    arrow.Parent = dropdownFrame
    
    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Size = UDim2.new(0, 200, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
    optionsFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsFrame.ScrollBarThickness = 5
    optionsFrame.Parent = dropdownFrame
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 8)
    corner2.Parent = optionsFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = optionsFrame
    
    local selectedOption = nil
    
    local function toggleOptions()
        optionsFrame.Visible = not optionsFrame.Visible
        if optionsFrame.Visible then
            optionsFrame.Size = UDim2.new(0, 200, 0, math.min(#options * 30, 150))
        else
            optionsFrame.Size = UDim2.new(0, 200, 0, 0)
        end
    end
    
    dropdownFrame.MouseButton1Click:Connect(toggleOptions)
    
    for _, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(0, 200, 0, 30)
        optionButton.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
        optionButton.TextColor3 = Color3.new(1, 1, 1)
        optionButton.Text = option
        optionButton.Font = Enum.Font.SourceSans
        optionButton.TextSize = 14
        optionButton.BorderSizePixel = 0
        
        optionButton.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            selectedOption = option
            toggleOptions()
        end)
        
        optionButton.Parent = optionsFrame
    end
    
    return dropdownFrame, function() return selectedOption end
end

-- Создание главного окна авторизации
local mainWindow = createRoundedFrame(ScreenGui, UDim2.new(0, 320, 0, 280), UDim2.new(0.5, -160, 0.5, -140), 15)
mainWindow.Visible = not (isVerified and (os.time() - verificationTime) < (7 * 24 * 60 * 60))

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 0, 40)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Text = "Enter Key"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = mainWindow

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 300, 0, 40)
keyInput.Position = UDim2.new(0, 10, 0, 60)
keyInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
keyInput.TextColor3 = Color3.new(1, 1, 1)
keyInput.PlaceholderText = "FREE_xxxxxxxx"
keyInput.Font = Enum.Font.SourceSans
keyInput.TextSize = 16
keyInput.Parent = mainWindow

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = keyInput

local verifyButton = createButton(mainWindow, "Verify", UDim2.new(0, 300, 0, 40), UDim2.new(0, 10, 0, 110), function()
    local key = keyInput.Text
    if verifyKey(key) then
        isVerified = true
        currentKey = key
        verificationTime = os.time()
        keyInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        saveData()
        mainWindow.Visible = false
        showG1Page()
    else
        keyInput.BackgroundColor3 = Color3.new(1, 0, 0)
        local errorMsg = Instance.new("TextLabel")
        errorMsg.Size = UDim2.new(0, 300, 0, 20)
        errorMsg.Position = UDim2.new(0, 10, 0, 155)
        errorMsg.BackgroundTransparency = 1
        errorMsg.Text = "Invalid key format!"
        errorMsg.TextColor3 = Color3.new(1, 0, 0)
        errorMsg.Font = Enum.Font.SourceSans
        errorMsg.TextSize = 14
        errorMsg.Parent = mainWindow
        
        task.wait(2)
        keyInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        errorMsg:Destroy()
    end
end, false)

local getKeyButton = createButton(mainWindow, "Get Key", UDim2.new(0, 300, 0, 40), UDim2.new(0, 10, 0, 160), function()
    -- Открытие веб-страницы
    pcall(function()
        TeleportService:Teleport(1234567890, Player) -- Замените на реальный ID места
    end)
end, true)

-- Функция показа страницы G1
local function showG1Page()
    if isVerified and (os.time() - verificationTime) >= (7 * 24 * 60 * 60) then
        isVerified = false
        saveData()
        mainWindow.Visible = true
        return
    end
    
    local g1Window = createRoundedFrame(ScreenGui, UDim2.new(0, 600, 0, 500), UDim2.new(0.5, -300, 0.5, -250), 15)
    g1Window.Visible = true
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(0, 250, 0, 30)
    header.Position = UDim2.new(0, 15, 0, 15)
    header.BackgroundTransparency = 1
    header.Text = "BlackHorse @blckhorsehub"
    header.TextColor3 = Color3.new(1, 1, 1)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 16
    header.Parent = g1Window
    
    -- Создание вкладок
    local tabs = {"Main", "Stealer", "Player", "Spawner", "Server"}
    local tabButtons = {}
    local tabFrames = {}
    
    for i, tabName in ipairs(tabs) do
        local tabButton = createButton(g1Window, tabName, UDim2.new(0, 80, 0, 30), UDim2.new(1, -85 * (6 - i), 0, 15), function()
            currentTab = tabName
            for _, frame in pairs(tabFrames) do
                frame.Visible = false
            end
            tabFrames[i].Visible = true
        end, true)
        
        tabButtons[i] = tabButton
        
        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(0, 580, 0, 430)
        tabFrame.Position = UDim2.new(0, 10, 0, 55)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = i == 1
        tabFrame.ScrollBarThickness = 5
        tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabFrame.Parent = g1Window
        
        tabFrames[i] = tabFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.Parent = tabFrame
        
        -- Заполнение содержимым вкладок
        if i == 1 then -- Main
            local farmTitle = Instance.new("TextLabel")
            farmTitle.Size = UDim2.new(0, 200, 0, 30)
            farmTitle.BackgroundTransparency = 1
            farmTitle.Text = "Farm"
            farmTitle.TextColor3 = Color3.new(1, 1, 1)
            farmTitle.Font = Enum.Font.SourceSansBold
            farmTitle.TextSize = 18
            farmTitle.Parent = tabFrame
            
            local brainrotToggle, getBrainrotState = createToggle(tabFrame, "Auto buy Brainrot", UDim2.new(0, 0, 0, 0), false)
            
            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(0, 400, 0, 20)
            desc.BackgroundTransparency = 1
            desc.Text = "Turn off Speed Boost first."
            desc.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            desc.Font = Enum.Font.SourceSans
            desc.TextSize = 12
            desc.Parent = tabFrame
            
            createToggle(tabFrame, "Anti AFK", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Auto Lock Base", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Auto Collect", UDim2.new(0, 0, 0, 0), false)
            
            local sellTitle = Instance.new("TextLabel")
            sellTitle.Size = UDim2.new(0, 200, 0, 30)
            sellTitle.BackgroundTransparency = 1
            sellTitle.Text = "Auto Sell"
            sellTitle.TextColor3 = Color3.new(1, 1, 1)
            sellTitle.Font = Enum.Font.SourceSansBold
            sellTitle.TextSize = 18
            sellTitle.Parent = tabFrame
            
            createToggle(tabFrame, "Auto Sell All", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Auto Sell Bad Brainrot (<10k)", UDim2.new(0, 0, 0, 0), false)
            
        elseif i == 2 then -- Stealer
            local stealTitle = Instance.new("TextLabel")
            stealTitle.Size = UDim2.new(0, 200, 0, 30)
            stealTitle.BackgroundTransparency = 1
            stealTitle.Text = "Steal Options"
            stealTitle.TextColor3 = Color3.new(1, 1, 1)
            stealTitle.Font = Enum.Font.SourceSansBold
            stealTitle.TextSize = 18
            stealTitle.Parent = tabFrame
            
            createToggle(tabFrame, "Hack Steal", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Instant Steal", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Up Steal", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Auto Steal", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Auto Kick", UDim2.new(0, 0, 0, 0), false)
            
        elseif i == 3 then -- Player
            local playerTitle = Instance.new("TextLabel")
            playerTitle.Size = UDim2.new(0, 200, 0, 30)
            playerTitle.BackgroundTransparency = 1
            playerTitle.Text = "Player Options"
            playerTitle.TextColor3 = Color3.new(1, 1, 1)
            playerTitle.Font = Enum.Font.SourceSansBold
            playerTitle.TextSize = 18
            playerTitle.Parent = tabFrame
            
            createToggle(tabFrame, "Anti Ragdoll", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Speed Boost (3 rebirths required)", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Infinity Jump", UDim2.new(0, 0, 0, 0), false)
            
            local jumpBoostFrame = Instance.new("Frame")
            jumpBoostFrame.Size = UDim2.new(0, 300, 0, 30)
            jumpBoostFrame.BackgroundTransparency = 1
            jumpBoostFrame.Parent = tabFrame
            
            local jumpLabel = Instance.new("TextLabel")
            jumpLabel.Size = UDim2.new(0, 150, 0, 30)
            jumpLabel.Position = UDim2.new(0, 0, 0, 0)
            jumpLabel.BackgroundTransparency = 1
            jumpLabel.Text = "Jump Boost"
            jumpLabel.TextColor3 = Color3.new(1, 1, 1)
            jumpLabel.Font = Enum.Font.SourceSansSemibold
            jumpLabel.TextSize = 14
            jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
            jumpLabel.Parent = jumpBoostFrame
            
            local jumpSlider = Instance.new("TextBox")
            jumpSlider.Size = UDim2.new(0, 100, 0, 25)
            jumpSlider.Position = UDim2.new(0, 160, 0, 2)
            jumpSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            jumpSlider.TextColor3 = Color3.new(1, 1, 1)
            jumpSlider.Text = "100"
            jumpSlider.Font = Enum.Font.SourceSans
            jumpSlider.TextSize = 14
            jumpSlider.Parent = jumpBoostFrame
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = jumpSlider
            
            createToggle(tabFrame, "Noclip (FIXED)", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Anti Trap", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Anti Bee Launcher", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Anti Taser Gun", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Anti Boogie Bomb", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Anti Medusa Head", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Anti Slinger", UDim2.new(0, 0, 0, 0), false)
            createToggle(tabFrame, "Anti Body Swap", UDim2.new(0, 0, 0, 0), false)
            
        elseif i == 4 then -- Spawner
            local spawnerTitle = Instance.new("TextLabel")
            spawnerTitle.Size = UDim2.new(0, 200, 0, 30)
            spawnerTitle.BackgroundTransparency = 1
            spawnerTitle.Text = "Spawner"
            spawnerTitle.TextColor3 = Color3.new(1, 1, 1)
            spawnerTitle.Font = Enum.Font.SourceSansBold
            spawnerTitle.TextSize = 18
            spawnerTitle.Parent = tabFrame
            
            local brainrotDropdown, getBrainrot = createDropdown(tabFrame, {"Noobini", "Pizzanini", "Pipi Kiwi", "Cappuchinno", "Assasino"}, UDim2.new(0, 0, 0, 0), "Choose Brainrot")
            
            local idFrame = Instance.new("Frame")
            idFrame.Size = UDim2.new(0, 300, 0, 40)
            idFrame.BackgroundTransparency = 1
            idFrame.Parent = tabFrame
            
            local idInput = Instance.new("TextBox")
            idInput.Size = UDim2.new(0, 200, 0, 30)
            idInput.Position = UDim2.new(0, 0, 0, 5)
            idInput.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            idInput.TextColor3 = Color3.new(1, 1, 1)
            idInput.PlaceholderText = "Enter ID"
            idInput.Font = Enum.Font.SourceSans
            idInput.TextSize = 14
            idInput.Parent = idFrame
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = idInput
            
            local spawnButton = createButton(idFrame, "Spawn", UDim2.new(0, 80, 0, 30), UDim2.new(0, 210, 0, 5), function()
                -- Логика спавна
            end, false)
            
        elseif i == 5 then -- Server
            local serverTitle = Instance.new("TextLabel")
            serverTitle.Size = UDim2.new(0, 300, 0, 30)
            serverTitle.BackgroundTransparency = 1
            serverTitle.Text = "Min money per sec to find"
            serverTitle.TextColor3 = Color3.new(1, 1, 1)
            serverTitle.Font = Enum.Font.SourceSansBold
            serverTitle.TextSize = 18
            serverTitle.Parent = tabFrame
            
            local moneyOptions = {"20K/s", "50K/s", "200K/s", "500K/s", "1M/s", "5M/s", "30M/s"}
            local moneyDropdown, getMoney = createDropdown(tabFrame, moneyOptions, UDim2.new(0, 0, 0, 0), "Select money")
        end
    end
    
    -- Кнопка сворачивания для G1 окна
    createButton(g1Window, "-", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 15), function()
        g1Window.Visible = false
        
        local restoreButton = createButton(ScreenGui, "○", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 15), function()
            g1Window.Visible = true
            restoreButton:Destroy()
        end, true)
    end, true)
end

-- Автоматическое открытие G1 если верифицирован
if isVerified and (os.time() - verificationTime) < (7 * 24 * 60 * 60) then
    showG1Page()
elseif isVerified then
    isVerified = false
    saveData()
    mainWindow.Visible = true
    
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(0.5, -150, 0.5, -30)
    notification.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    notification.TextColor3 = Color3.new(1, 1, 1)
    notification.Text = "Your key has expired!\nPlease enter a new key."
    notification.Font = Enum.Font.SourceSansBold
    notification.TextSize = 16
    notification.TextWrapped = true
    notification.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notification
    
    task.wait(3)
    notification:Destroy()
end

-- Кнопка сворачивания для главного окна
createButton(mainWindow, "-", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 10), function()
    mainWindow.Visible = false
    
    local restoreButton = createButton(ScreenGui, "○", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 10), function()
        mainWindow.Visible = true
        restoreButton:Destroy()
    end, true)
end, true)

-- Функция для создания модального окна Steal
local function createStealWindow(titleText)
    local stealWindow = createRoundedFrame(ScreenGui, UDim2.new(0, 300, 0, 200), UDim2.new(0.5, -150, 0.5, -100), 15)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 280, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = stealWindow
    
    local stealButton = createButton(stealWindow, "STEALING", UDim2.new(0, 280, 0, 50), UDim2.new(0, 10, 0, 60), function()
        -- Логика стила
    end, false)
    
    local closeButton = createButton(stealWindow, "X", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 10), function()
        stealWindow:Destroy()
    end, true)
    
    -- Перетаскивание окна
    local dragInput
    local startPos
    local dragging
    
    stealWindow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    stealWindow.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startPos
            stealWindow.Position = UDim2.new(stealWindow.Position.X.Scale, stealWindow.Position.X.Offset + delta.X,
                                            stealWindow.Position.Y.Scale, stealWindow.Position.Y.Offset + delta.Y)
            startPos = input.Position
        end
    end)
    
    return stealWindow
end
