--[[
BlackHorse UI — полный каркас (LocalScript)
- Черно-белая Apple-style палитра
- Ключ: должен содержать "FREE_" и буквы для слова "horse" (в любом порядке)
- Сохранение настроек в "__bh_store.json" (writefile/readfile) или fallback -> getgenv()
- G1: вкладки Main, Stealer, Player, Spawner, Server
- Все "чит"-функции — заглушки (print/toast)
--]]

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Storage helpers
local SAVE_FILE = "__bh_store.json"
local function safeIsFile(name)
    local ok, res = pcall(function() return isfile and isfile(name) end)
    if ok then return res else return false end
end
local function safeRead(name)
    local ok, res = pcall(function() return readfile and readfile(name) end)
    if ok then return res end
    return nil
end
local function safeWrite(name, content)
    local ok = pcall(function() if writefile then writefile(name, content) end end)
    if not ok then
        getgenv().__BH_TEMP_STORE = getgenv().__BH_TEMP_STORE or {}
        getgenv().__BH_TEMP_STORE[name] = content
    end
end
local function safeLoadStore()
    local raw = safeRead(SAVE_FILE)
    if raw then
        local ok, dat = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and type(dat) == "table" then return dat end
    end
    if getgenv().__BH_TEMP_STORE and getgenv().__BH_TEMP_STORE[SAVE_FILE] then
        local ok, dat = pcall(function() return HttpService:JSONDecode(getgenv().__BH_TEMP_STORE[SAVE_FILE]) end)
        if ok and type(dat) == "table" then return dat end
    end
    -- default store
    return {
        key = nil,
        lastAuth = nil,
        toggles = {},
        inputs = {},
        selections = {}
    }
end
local function safeSaveStore(store)
    local ok, raw = pcall(function() return HttpService:JSONEncode(store) end)
    if ok then safeWrite(SAVE_FILE, raw) end
end

local Store = safeLoadStore()

-- Utils
local function new(inst, props, parent)
    local o = Instance.new(inst)
    if props then for k,v in pairs(props) do pcall(function() o[k] = v end) end end
    if parent then o.Parent = parent end
    return o
end
local function roundify(obj, r) new("UICorner", {CornerRadius = UDim.new(0, r or 10)}, obj) end
local function stroke(obj, props)
    props = props or {}
    new("UIStroke", {
        Color = props.Color or Color3.fromRGB(255,255,255),
        Thickness = props.Thickness or 1,
        Transparency = props.Transparency or 0.85,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end
local function pad(obj, p) new("UIPadding", {
    PaddingTop = UDim.new(0, p or 8),
    PaddingBottom = UDim.new(0, p or 8),
    PaddingLeft = UDim.new(0, p or 8),
    PaddingRight = UDim.new(0, p or 8)
}, obj) end

-- Parent GUI (gethui or CoreGui)
local GUI_PARENT = (gethui and gethui()) or game:GetService("CoreGui")

-- Toast helper
local function toast(msg, dur)
    dur = dur or 2.2
    local frame = new("Frame", {Size = UDim2.new(0, 360, 0, 52), Position = UDim2.new(0.5, -180, 1, -80), BackgroundColor3 = Color3.fromRGB(18,18,18)}, GUI_PARENT)
    frame.AnchorPoint = Vector2.new(0.5, 1)
    roundify(frame, 12); stroke(frame, {Transparency=0.6})
    pad(frame, 10)
    new("TextLabel", {Parent = frame, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = msg, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansSemibold, TextSize = 16}, frame)
    frame.Position = UDim2.new(0.5, -180, 1, 80)
    TweenService:Create(frame, TweenInfo.new(0.18), {Position = UDim2.new(0.5, -180, 1, -80)}):Play()
    task.delay(dur, function()
        TweenService:Create(frame, TweenInfo.new(0.14), {Position = UDim2.new(0.5, -180, 1, 80)}):Play()
        task.delay(0.16, function() pcall(function() frame:Destroy() end) end)
    end)
end

-- Simple helper for buttons
local function createButton(parent, text, style)
    style = style or "filled" -- or "outline"
    local btn = new("TextButton", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = (style=="filled") and Color3.fromRGB(255,255,255) or Color3.fromRGB(16,16,16),
        Text = text,
        Font = Enum.Font.SourceSansBold,
        TextSize = 16,
        TextColor3 = (style=="filled") and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255),
        AutoButtonColor = true
    })
    roundify(btn, 8)
    if style == "outline" then stroke(btn, {Transparency=0.8, Thickness=1}) end
    return btn
end

-- Toggle creation (iOS style)
local function createToggle(parent, labelText, default, onChange, nameInStore)
    local holder = new("Frame", {Parent = parent, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,44)})
    local label = new("TextLabel", {Parent = holder, BackgroundTransparency = 1, Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,8,0,0), Text = labelText, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansSemibold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
    local toggle = new("TextButton", {Parent = holder, Size = UDim2.new(0,56,0,30), Position = UDim2.new(1,-68,0,7), BackgroundColor3 = Color3.fromRGB(60,60,60), Text = ""})
    roundify(toggle, 16)
    local knob = new("Frame", {Parent = toggle, Size = UDim2.new(0,26,0,26), Position = UDim2.new(0,2,0,2), BackgroundColor3 = Color3.fromRGB(255,255,255)})
    roundify(knob, 16); stroke(knob, {Transparency=0.5, Thickness=1})
    -- initial state check store
    local current = default
    if nameInStore and Store.toggles and Store.toggles[nameInStore] ~= nil then
        current = Store.toggles[nameInStore]
    end
    -- apply initial visuals
    if current then
        toggle.BackgroundColor3 = Color3.fromRGB(90,200,90)
        knob.Position = UDim2.new(0, 28, 0, 2)
    else
        toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
        knob.Position = UDim2.new(0, 2, 0, 2)
    end
    local function setState(v, call)
        current = v and true or false
        local bgGoal = {BackgroundColor3 = current and Color3.fromRGB(90,200,90) or Color3.fromRGB(60,60,60)}
        local knobGoal = {Position = current and UDim2.new(0,28,0,2) or UDim2.new(0,2,0,2)}
        TweenService:Create(toggle, TweenInfo.new(0.12), bgGoal):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), knobGoal):Play()
        if nameInStore then
            Store.toggles[nameInStore] = current
            safeSaveStore(Store)
        end
        if call and onChange then pcall(onChange, current) end
    end
    toggle.MouseButton1Click:Connect(function() setState(not current, true) end)
    return {
        Set = function(v) setState(v, false) end,
        Get = function() return current end,
        Holder = holder
    }
end

-- Input creation
local function createInput(parent, placeholder, nameInStore)
    local box = new("TextBox", {Parent = parent, Size = UDim2.new(1,0,0,36), BackgroundColor3 = Color3.fromRGB(28,28,28), Text = "", PlaceholderText = placeholder or "", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSans, TextSize = 16})
    roundify(box, 8); pad(box, 6)
    if nameInStore and Store.inputs and Store.inputs[nameInStore] then
        box.Text = tostring(Store.inputs[nameInStore])
    end
    box.FocusLost:Connect(function(enter)
        if nameInStore then
            Store.inputs[nameInStore] = box.Text
            safeSaveStore(Store)
        end
    end)
    return box
end

-- Simple dropdown using prev/next
local function createPicker(parent, options, nameInStore)
    local frame = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 0})
    roundify(frame, 8); stroke(frame, {Transparency=0.7})
    local label = new("TextLabel", {Parent = frame, Size = UDim2.new(1,-120,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Text = options[1], TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansSemibold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
    local btnPrev = createButton(frame, "‹", "outline"); btnPrev.Size = UDim2.new(0,44,1,-12); btnPrev.Position = UDim2.new(1,-96,0,6)
    local btnNext = createButton(frame, "›", "outline"); btnNext.Size = UDim2.new(0,44,1,-12); btnNext.Position = UDim2.new(1,-48,0,6)
    local idx = 1
    if nameInStore and Store.selections and Store.selections[nameInStore] then
        for i,opt in ipairs(options) do if opt == Store.selections[nameInStore] then idx = i break end end
    end
    label.Text = options[idx]
    btnPrev.MouseButton1Click:Connect(function()
        idx = (idx - 2) % #options + 1
        label.Text = options[idx]
        if nameInStore then Store.selections[nameInStore] = label.Text; safeSaveStore(Store) end
    end)
    btnNext.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        label.Text = options[idx]
        if nameInStore then Store.selections[nameInStore] = label.Text; safeSaveStore(Store) end
    end)
    return {
        Frame = frame,
        Get = function() return options[idx] end,
        Set = function(v) for i,opt in ipairs(options) do if opt==v then idx=i; label.Text=opt; if nameInStore then Store.selections[nameInStore]=opt; safeSaveStore(Store) end; break end end
    }
end

-- Window builder
local function createWindow(titleText, w, h)
    local win = new("Frame", {Parent = GUI_PARENT, Size = UDim2.new(0, w or 680, 0, h or 420), Position = UDim2.new(0.5, -(w or 680)/2, 0.5, -(h or 420)/2), BackgroundColor3 = Color3.fromRGB(0,0,0), Active = true, Draggable = true})
    roundify(win, 14); stroke(win, {Transparency=0.7})
    local titlebar = new("Frame", {Parent = win, Size = UDim2.new(1,0,0,44), BackgroundColor3 = Color3.fromRGB(10,10,10)})
    roundify(titlebar, 12); stroke(titlebar, {Transparency=0.8})
    local title = new("TextLabel", {Parent = titlebar, Position = UDim2.new(0,12,0,0), Size = UDim2.new(1,-160,1,0), BackgroundTransparency = 1, Text = titleText, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})
    local controls = new("Frame", {Parent = titlebar, Size = UDim2.new(0,128,1,0), Position = UDim2.new(1,-128,0,0), BackgroundTransparency = 1})
    pad(controls, 6)
    -- control buttons
    local btnMin = createButton(controls, "—", "outline"); btnMin.Size = UDim2.new(0,36,1,-12)
    local btnMax = createButton(controls, "▢", "outline"); btnMax.Size = UDim2.new(0,36,1,-12)
    local btnClose = createButton(controls, "✕", "outline"); btnClose.Size = UDim2.new(0,36,1,-12)
    local content = new("Frame", {Parent = win, Size = UDim2.new(1,-24,1,-44-16), Position = UDim2.new(0,12,0,44+8), BackgroundTransparency = 1})
    pad(content, 8)
    -- minimize/max behavior
    local isFullscreen = false
    local original = {Position = win.Position, Size = win.Size}
    btnMax.MouseButton1Click:Connect(function()
        isFullscreen = not isFullscreen
        if isFullscreen then
            original.Position = win.Position; original.Size = win.Size
            TweenService:Create(win, TweenInfo.new(0.18), {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,1,0)}):Play()
        else
            TweenService:Create(win, TweenInfo.new(0.18), {Position = original.Position, Size = original.Size}):Play()
        end
    end)
    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        win.Size = minimized and UDim2.new(win.Size.X.Scale, win.Size.X.Offset, 0, 44) or (isFullscreen and UDim2.new(1,0,1,0) or original.Size)
    end)
    -- close -> bubble
    local launcher
    local function ensureLauncher()
        if launcher and launcher.Parent then return end
        launcher = new("ImageButton", {Parent = GUI_PARENT, Size = UDim2.new(0,56,0,56), Position = UDim2.new(0,20,1,-96), BackgroundColor3 = Color3.fromRGB(22,22,22), AutoButtonColor = true})
        roundify(launcher, 28); stroke(launcher, {Transparency=0.7})
        new("TextLabel", {Parent = launcher, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "🐎", Font = Enum.Font.SourceSansBold, TextSize = 28, TextColor3 = Color3.fromRGB(255,255,255)})
        launcher.Active = true; launcher.Draggable = true
        launcher.MouseButton1Click:Connect(function()
            win.Visible = true
            pcall(function() launcher:Destroy() end)
        end)
    end
    btnClose.MouseButton1Click:Connect(function()
        win.Visible = false
        ensureLauncher()
        toast("BlackHorse UI hidden. Click bubble to restore.")
    end)
    return win, content, title
end

-- Subwindow helper (draggable modal)
local function createSubwindow(titleText, w, h)
    local sub = new("Frame", {Parent = GUI_PARENT, Size = UDim2.new(0, w or 380, 0, h or 220), Position = UDim2.new(0.5, -(w or 380)/2, 0.5, -(h or 220)/2), BackgroundColor3 = Color3.fromRGB(12,12,12), Active = true, Draggable = true})
    roundify(sub, 12); stroke(sub, {Transparency=0.7})
    local tb = new("Frame", {Parent = sub, Size = UDim2.new(1,0,0,40), BackgroundColor3 = Color3.fromRGB(18,18,18)})
    roundify(tb, 10); stroke(tb, {Transparency=0.7})
    new("TextLabel", {Parent = tb, BackgroundTransparency = 1, Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,12,0,0), Text = titleText, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
    local close = createButton(tb, "✕", "outline"); close.Size = UDim2.new(0,36,1,-8); close.Position = UDim2.new(1,-44,0,4)
    local content = new("Frame", {Parent = sub, Size = UDim2.new(1,-20,1,-40-12), Position = UDim2.new(0,10,0,40+6), BackgroundTransparency = 1})
    pad(content, 8)
    close.MouseButton1Click:Connect(function() pcall(function() sub:Destroy() end) end)
    return sub, content
end

-- Key check
local function keyIsValid(k)
    if type(k) ~= "string" then return false end
    if not k:find("FREE_") then return false end
    local lower = k:lower()
    local needed = {h=true,o=true,r=true,s=true,e=true}
    for ch in lower:gmatch(".") do
        if needed[ch] then needed[ch] = nil end
        if not next(needed) then break end
    end
    return next(needed) == nil
end

-- Placeholder game-actions (stubs) — заменяй своим кодом
local function DoHackSteal() print("[BlackHorse] DoHackSteal (stub)"); toast("Hack Steal (stub)") end
local function DoInstantSteal() print("[BlackHorse] DoInstantSteal (stub)"); toast("Instant Steal (stub)") end
local function DoUpSteal() print("[BlackHorse] DoUpSteal (stub)"); toast("Up Steal (stub)") end
local function DoSpawn(choice, id) print(("Spawn: %s (%s)"):format(choice, tostring(id))); toast("Spawn (stub)") end
local function DoFindServer(option) print("Find server with min:", option); toast("Find Server (stub)") end

-- Build Key Window (если нет валидного ключа или ключ просрочен)
local function openKeyWindow()
    local win, content = createWindow("BlackHorse — Enter Key", 560, 340)
    pad(content, 6)
    new("TextLabel", {Parent = content, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30), Text = "Enter Key:", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansSemibold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})
    local keyBox = createInput(content, "FREE_... (must include letters to form 'horse')", nil)
    keyBox.Size = UDim2.new(1,0,0,40)
    local btnRow = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,46), BackgroundTransparency = 1})
    local verify = createButton(btnRow, "Verify", "filled"); verify.Position = UDim2.new(0,0,0,6)
    verify.Size = UDim2.new(0.48, -6, 1, 0)
    local getBtn = createButton(btnRow, "Get", "outline"); getBtn.Position = UDim2.new(0.52, 6, 0, 6); getBtn.Size = UDim2.new(0.48, -6, 1, 0)
    verify.MouseButton1Click:Connect(function()
        local key = keyBox.Text or ""
        if keyIsValid(key) then
            Store.key = key; Store.lastAuth = os.time(); safeSaveStore(Store)
            toast("Key accepted ✓", 2)
            task.delay(0.4, function()
                win:Destroy()
                openG1()
            end)
        else
            keyBox.Text = "Invalid Key!"
            keyBox.TextColor3 = Color3.fromRGB(255,120,120)
            toast("Invalid key", 2)
        end
    end)
    getBtn.MouseButton1Click:Connect(function()
        local ok = pcall(function() if setclipboard then setclipboard("https://getkey-del.github.io/blackhorse/") end end)
        toast("Link copied to clipboard (if available)", 2)
        print("Open: https://getkey-del.github.io/blackhorse/")
    end)
end

-- Build G1 window (main)
function openG1()
    -- main window
    local win, content = createWindow("BlackHorse — G1", 900, 540)
    -- sidebar
    local sidebar = new("Frame", {Parent = content, Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = Color3.fromRGB(12,12,12)})
    roundify(sidebar, 12); stroke(sidebar, {Transparency=0.7})
    pad(sidebar, 10)
    new("TextLabel", {Parent = sidebar, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,48), Text = "BlackHorse\n@blckhorsehub", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
    local tabsHolder = new("Frame", {Parent = sidebar, Size = UDim2.new(1,0,1,-56), BackgroundTransparency = 1})
    local function addTabButton(txt) local b = createButton(tabsHolder, txt, "outline"); b.Size = UDim2.new(1,0,0,38); return b end

    local pagesHolder = new("Frame", {Parent = content, Size = UDim2.new(1,-200,1,0), Position = UDim2.new(0,200,0,0), BackgroundTransparency = 1})
    pad(pagesHolder, 8)

    local pageMain = new("Frame", {Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}); pageMain.Visible = true
    local pageStealer = new("Frame", {Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}); pageStealer.Visible = false
    local pagePlayer = new("Frame", {Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}); pagePlayer.Visible = false
    local pageSpawner = new("Frame", {Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}); pageSpawner.Visible = false
    local pageServer = new("Frame", {Parent = pagesHolder, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1}); pageServer.Visible = false

    local pages = {Main=pageMain, Stealer=pageStealer, Player=pagePlayer, Spawner=pageSpawner, Server=pageServer}
    local btnMain = addTabButton("🏠  Main")
    local btnStealer = addTabButton("🛰️  Stealer")
    local btnPlayer = addTabButton("👤  Player")
    local btnSpawner = addTabButton("🧪  Spawner")
    local btnServer = addTabButton("🖥️  Server")
    local function switch(to)
        for k,v in pairs(pages) do v.Visible = (k==to) end
    end
    btnMain.MouseButton1Click:Connect(function() switch("Main") end)
    btnStealer.MouseButton1Click:Connect(function() switch("Stealer") end)
    btnPlayer.MouseButton1Click:Connect(function() switch("Player") end)
    btnSpawner.MouseButton1Click:Connect(function() switch("Spawner") end)
    btnServer.MouseButton1Click:Connect(function() switch("Server") end)

    -- === PAGE: Main ===
    new("TextLabel", {Parent = pageMain, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), Text = "Farm", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left})
    new("TextLabel", {Parent = pageMain, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,28), Size = UDim2.new(1,0,0,20), Text = "Turn off Speed Boost first.", TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.SourceSans, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})

    local vAutoBuy = createToggle(pageMain, "Auto buy Brainrot", false, function(v) print("AutoBuyBrainrot:", v) end, "AutoBuyBrainrot")
    vAutoBuy.Holder.Position = UDim2.new(0,0,0,56)
    local vAntiAFK = createToggle(pageMain, "Anti AFK", false, function(v) print("AntiAFK:", v) end, "AntiAFK"); vAntiAFK.Holder.Position = UDim2.new(0,0,0,56+52)
    local vAutoLock = createToggle(pageMain, "Auto Lock Base", false, function(v) print("AutoLockBase:", v) end, "AutoLockBase"); vAutoLock.Holder.Position = UDim2.new(0,0,0,56+104)
    local vAutoCollect = createToggle(pageMain, "Auto Collect", false, function(v) print("AutoCollect:", v) end, "AutoCollect"); vAutoCollect.Holder.Position = UDim2.new(0,0,0,56+156)

    new("TextLabel", {Parent=pageMain, BackgroundTransparency=1, Position=UDim2.new(0,0,0,260), Size=UDim2.new(1,0,0,28), Text="Auto Sell", TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.SourceSansBold, TextSize=18, TextXAlignment = Enum.TextXAlignment.Left})
    local as1 = createToggle(pageMain, "Auto Sell All", false, function(v) print("AutoSellAll:", v) end, "AutoSellAll"); as1.Holder.Position = UDim2.new(0,0,0,300)
    local as2 = createToggle(pageMain, "Auto Sell Bad Brainrot (<10k)", false, function(v) print("AutoSellBad:", v) end, "AutoSellBad"); as2.Holder.Position = UDim2.new(0,0,0,352)

    -- === PAGE: Stealer ===
    new("TextLabel", {Parent = pageStealer, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), Text = "Stealer Tools", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left})
    -- Hack Steal toggle opens subwindow
    local hackToggle = createToggle(pageStealer, "Hack Steal", false, function(v)
        if v then
            local sub, content = createSubwindow("Hack Steal", 420, 200)
            new("TextLabel", {Parent=content, BackgroundTransparency=1, Size=UDim2.new(1,0,0,22), Text="Press to simulate STEALING action", TextColor3=Color3.fromRGB(200,200,200), Font=Enum.Font.SourceSans, TextSize=14})
            local btn = createButton(content, "STEALING", "filled")
            btn.MouseButton1Click:Connect(function() DoHackSteal() end)
        else
            print("Hack Steal disabled")
        end
    end, "HackSteal")
    hackToggle.Holder.Position = UDim2.new(0,0,0,44)

    -- Instant Steal button -> subwindow
    local insBtn = createButton(pageStealer, "Instant Steal (Need 3 rebirths + open base)", "outline"); insBtn.Position = UDim2.new(0,0,0,110)
    insBtn.MouseButton1Click:Connect(function()
        local sub, content = createSubwindow("Instant Steal", 420, 200)
        new("TextLabel", {Parent=content, BackgroundTransparency=1, Size=UDim2.new(1,0,0,22), Text="Instant Steal: Need 3 rebirths and open base", TextColor3=Color3.fromRGB(200,200,200), Font=Enum.Font.SourceSans, TextSize=14})
        local btn = createButton(content, "STEALING", "filled")
        btn.MouseButton1Click:Connect(DoInstantSteal)
    end)

    -- Up Steal
    local upBtn = createButton(pageStealer, "Up Steal", "outline"); upBtn.Position = UDim2.new(0,0,0,160)
    upBtn.MouseButton1Click:Connect(function()
        local sub, content = createSubwindow("Up Steal", 420, 230)
        local infToggle = createToggle(content, "Infinity Jump", false, function(v) print("InfJump:", v) end, "UpStealInfJump")
        infToggle.Holder.Position = UDim2.new(0,0,0,36)
        local btn = createButton(content, "Steal", "filled"); btn.Position = UDim2.new(0,0,0,88)
        btn.MouseButton1Click:Connect(DoUpSteal)
    end)

    local autoSteal = createToggle(pageStealer, "Auto Steal", false, function(v) print("AutoSteal:", v) end, "AutoSteal"); autoSteal.Holder.Position = UDim2.new(0,0,0,220)
    local autoKick = createToggle(pageStealer, "Auto Kick", false, function(v) print("AutoKick:", v) end, "AutoKick"); autoKick.Holder.Position = UDim2.new(0,0,0,272)

    -- === PAGE: Player ===
    new("TextLabel", {Parent = pagePlayer, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), Text = "Player", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left})
    local pr = createToggle(pagePlayer, "Anti Ragdoll", false, function(v) print("AntiRagdoll:", v) end, "AntiRagdoll"); pr.Holder.Position = UDim2.new(0,0,0,44)
    local sp = createToggle(pagePlayer, "Speed Boost (3 rebirths required)", false, function(v) print("SpeedBoost:", v) end, "SpeedBoost"); sp.Holder.Position = UDim2.new(0,0,0,96)
    local ij = createToggle(pagePlayer, "Infinity Jump", false, function(v) print("InfinityJump:", v) end, "InfinityJump"); ij.Holder.Position = UDim2.new(0,0,0,148)
    local jb = createToggle(pagePlayer, "Jump Boost", false, function(v) print("JumpBoostToggle:", v) end, "JumpBoostToggle"); jb.Holder.Position = UDim2.new(0,0,0,200)

    new("TextLabel", {Parent = pagePlayer, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,252), Size = UDim2.new(1,0,0,18), Text="Jump Boost Power (100–1000)", TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.SourceSans, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    local powerHolder = new("Frame", {Parent = pagePlayer, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 1}); powerHolder.Position = UDim2.new(0,0,0,278)
    local minus = createButton(powerHolder, "–", "outline"); minus.Size = UDim2.new(0,44,1,0); minus.Position = UDim2.new(0,8,0,4)
    local inputPower = createInput(powerHolder, "300", "JumpPower"); inputPower.Size = UDim2.new(0,120,1,0); inputPower.Position = UDim2.new(0,60,0,4)
    local plus = createButton(powerHolder, "+", "outline"); plus.Size = UDim2.new(0,44,1,0); plus.Position = UDim2.new(0,192,0,4)
    local applyBtn = createButton(powerHolder, "Apply", "filled"); applyBtn.Size = UDim2.new(0,92,1,0); applyBtn.Position = UDim2.new(0,252,0,4)
    -- initialize value
    inputPower.Text = tostring(Store.inputs.JumpPower or 300)
    minus.MouseButton1Click:Connect(function() local v = tonumber(inputPower.Text) or 300; v = math.clamp(v - 50, 100, 1000); inputPower.Text = tostring(v); Store.inputs.JumpPower = v; safeSaveStore(Store) end)
    plus.MouseButton1Click:Connect(function() local v = tonumber(inputPower.Text) or 300; v = math.clamp(v + 50, 100, 1000); inputPower.Text = tostring(v); Store.inputs.JumpPower = v; safeSaveStore(Store) end)
    applyBtn.MouseButton1Click:Connect(function() local v = tonumber(inputPower.Text) or 300; v = math.clamp(v, 100, 1000); inputPower.Text = tostring(v); Store.inputs.JumpPower = v; safeSaveStore(Store); toast("Jump Power set to "..tostring(v)) end)

    -- other player toggles
    local noclip = createToggle(pagePlayer, "Noclip (FIXED)", false, function(v) print("Noclip:", v) end, "Noclip"); noclip.Holder.Position = UDim2.new(0,0,0,340)
    local antiTrap = createToggle(pagePlayer, "Anti Trap", false, function(v) print("AntiTrap:", v) end, "AntiTrap"); antiTrap.Holder.Position = UDim2.new(0,0,0,392)
    createToggle(pagePlayer, "Anti Bee Launcher", false, function(v) print("AntiBee:", v) end, "AntiBee").Holder.Position = UDim2.new(0,0,0,444)
    createToggle(pagePlayer, "Anti Taser Gun", false, function(v) print("AntiTaser:", v) end, "AntiTaser").Holder.Position = UDim2.new(0,0,0,496)
    -- and others: Anti Boogie Bomb, Anti Medusa Head, Anti Slinger, Anti Body Swap
    createToggle(pagePlayer, "Anti Boogie Bomb", false, function(v) print("AntiBoogie:", v) end, "AntiBoogie").Holder.Position = UDim2.new(0,420,0,0)
    createToggle(pagePlayer, "Anti Medusa Head", false, function(v) print("AntiMedusa:", v) end, "AntiMedusa").Holder.Position = UDim2.new(0,420,0,0)
    createToggle(pagePlayer, "Anti Slinger", false, function(v) print("AntiSlinger:", v) end, "AntiSlinger").Holder.Position = UDim2.new(0,420,0,0)
    createToggle(pagePlayer, "Anti Body Swap", false, function(v) print("AntiBodySwap:", v) end, "AntiBodySwap").Holder.Position = UDim2.new(0,420,0,0)

    -- === PAGE: Spawner ===
    new("TextLabel", {Parent = pageSpawner, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), Text = "Spawner", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left})
    new("TextLabel", {Parent = pageSpawner, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,28), Size = UDim2.new(1,0,0,20), Text = "Choose Brainrot", TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.SourceSans, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    local choices = {"Noobini Pizzanini", "Pipi Kiwi", "Cappuchinno Assasino"}
    local picker = createPicker(pageSpawner, choices, "SpawnChoice")
    picker.Frame.Position = UDim2.new(0,0,0,56)
    local idBox = createInput(pageSpawner, "Enter ID", "SpawnID"); idBox.Position = UDim2.new(0,0,0,116)
    local spawnBtn = createButton(pageSpawner, "Spawn", "filled"); spawnBtn.Position = UDim2.new(0,0,0,172)
    spawnBtn.MouseButton1Click:Connect(function()
        DoSpawn(picker.Get(), idBox.Text)
    end)

    -- === PAGE: Server ===
    new("TextLabel", {Parent = pageServer, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,28), Text = "Server", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.SourceSansBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left})
    new("TextLabel", {Parent = pageServer, BackgroundTransparency = 1, Position = UDim2.new(0,0,0,28), Size = UDim2.new(1,0,0,20), Text = "Min money per sec to find", TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.SourceSans, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    local serverOptions = {"20K/s","50K/s","200K/s","500K/s","1m/s","5m/s","30m/s"}
    local serverPicker = createPicker(pageServer, serverOptions, "ServerMinSpeed"); serverPicker.Frame.Position = UDim2.new(0,0,0,56)
    local findBtn = createButton(pageServer, "Search Server", "filled"); findBtn.Position = UDim2.new(0,0,0,120)
    findBtn.MouseButton1Click:Connect(function() DoFindServer(serverPicker.Get()) end)

    toast("G1 opened")
end

-- Auto-load: if there is a stored valid key and not expired -> open G1; if expired -> open G1 then ask reverify (per spec)
local function autoFlow()
    if Store.key and Store.lastAuth and (type(Store.lastAuth) == "number") then
        local age = os.time() - Store.lastAuth
        if age < 7 * 24 * 60 * 60 then
            openG1()
            return
        else
            -- expired: open G1 and then prompt re-verify
            openG1()
            toast("Key expired — please re-verify.", 3)
            local sub, content = createSubwindow("Re-Verify Key", 420, 230)
            new("TextLabel", {Parent=content, BackgroundTransparency=1, Size=UDim2.new(1,0,0,24), Text="Enter Key (FREE_...)", TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.SourceSansSemibold, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left})
            local rebox = createInput(content, "FREE_... (must include letters for 'horse')", nil)
            rebox.Size = UDim2.new(1,0,0,36)
            local row = new("Frame", {Parent = content, Size = UDim2.new(1,0,0,46), BackgroundTransparency=1})
            local ok = createButton(row, "Verify", "filled"); ok.Size = UDim2.new(0.48, -6, 1, 0); ok.Position = UDim2.new(0,0,0,6)
            local getb = createButton(row, "Get", "outline"); getb.Size = UDim2.new(0.48, -6, 1, 0); getb.Position = UDim2.new(0.52, 6, 0, 6)
            ok.MouseButton1Click:Connect(function()
                if keyIsValid(rebox.Text) then
                    Store.key = rebox.Text; Store.lastAuth = os.time(); safeSaveStore(Store)
                    toast("Key updated ✓", 2)
                    pcall(function() sub:Destroy() end)
                else
                    rebox.Text = "Invalid Key!"; rebox.TextColor3 = Color3.fromRGB(255,120,120)
                    toast("Invalid key", 2)
                end
            end)
            getb.MouseButton1Click:Connect(function() pcall(function() if setclipboard then setclipboard("https://getkey-del.github.io/blackhorse/") end end); toast("Link copied (if available)") end)
            return
        end
    else
        -- no key -> open key window
        openKeyWindow()
    end
end

-- Hotkey: RightControl toggles UI visibility
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        -- hide/show all BlackHorse GUIs (quick approach: toggle all children that we created)
        for _,c in pairs(GUI_PARENT:GetChildren()) do
            if c:IsA("Frame") or c:IsA("ScreenGui") then
                -- heuristic: has UICorner and text containing "BlackHorse" or emoji — we won't touch other GUIs (best-effort)
                if c.Name:match("BlackHorse") or (c:FindFirstChildWhichIsA("UICorner") and c.Parent == GUI_PARENT) then
                    c.Visible = not c.Visible
                end
            end
        end
    end
end)

-- Start
pcall(function() safeSaveStore(Store) end) -- ensure file exists
autoFlow()
print("BlackHorse UI loaded (full single-file).")
