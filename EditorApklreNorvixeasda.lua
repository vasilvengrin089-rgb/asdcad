local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local setclipboard = setclipboard or toclipboard or print -- Підтримка різних читів

local Selection = nil
local MoveHandles, ResizeHandles, SelectionBox
local IsEditorEnabled = false

-- Змінна для кнопки-заголовка
local NameDisplay = nil

local Config = {
    LuaCode = "part.Transparency = 0.5",
    LastColor = Color3.fromRGB(0, 255, 255)
}

-- ФУНКЦІЯ ОЧИЩЕННЯ
local function clear()
    if MoveHandles then pcall(function() MoveHandles:Destroy() end) end
    if ResizeHandles then pcall(function() ResizeHandles:Destroy() end) end
    if SelectionBox then pcall(function() SelectionBox:Destroy() end) end
    MoveHandles, ResizeHandles, SelectionBox, Selection = nil, nil, nil, nil
    if NameDisplay then 
        NameDisplay:Set("Selected: None (Click to copy)") 
    end
end

-- СТВОРЕННЯ ГІЗМО ТА ОНОВЛЕННЯ ІМЕНІ
local function create(target)
    if not target or not target:IsA("BasePart") then return end
    clear()
    if not IsEditorEnabled then return end
    
    Selection = target
    
    -- ОНОВЛЕННЯ ТЕКСТУ
    if NameDisplay then
        NameDisplay:Set("Selected: " .. tostring(target.Name))
    end
    
    local pg = Player:WaitForChild("PlayerGui")
    
    SelectionBox = Instance.new("SelectionBox", pg)
    SelectionBox.Adornee = target
    SelectionBox.Color3 = Color3.fromRGB(0, 255, 255)
    
    MoveHandles = Instance.new("Handles", pg)
    MoveHandles.Adornee = target
    MoveHandles.Style = "Movement"
    MoveHandles.Color3 = Color3.fromRGB(255, 255, 0)
    
    ResizeHandles = Instance.new("Handles", pg)
    ResizeHandles.Adornee = target
    ResizeHandles.Style = "Resize"
    ResizeHandles.Color3 = Color3.fromRGB(0, 150, 255)

    -- Логіка Пересування
    local startCF
    MoveHandles.MouseButton1Down:Connect(function() startCF = target.CFrame end)
    MoveHandles.MouseDrag:Connect(function(axis, dist)
        if target.Parent then target.CFrame = startCF + (Vector3.FromNormalId(axis) * dist) end
    end)

    -- Логіка Розміру
    local startS, startP
    ResizeHandles.MouseButton1Down:Connect(function() startS, startP = target.Size, target.Position end)
    ResizeHandles.MouseDrag:Connect(function(axis, dist)
        if target.Parent then
            local vec = Vector3.FromNormalId(axis)
            target.Size = startS + (vec * dist)
            target.Position = startP + (vec * (dist/2))
        end
    end)
end

-- ВІКНО
local Window = Rayfield:CreateWindow({
    Name = "Norvixes Studio v4",
    LoadingTitle = "UI Loading...",
    ConfigurationSaving = {Enabled = false}
})

local MainTab = Window:CreateTab("Main", 4483362458)
local PropTab = Window:CreateTab("Properties", 4483362458)

-- === MAIN ===
MainTab:CreateToggle({
    Name = "ENABLE EDITOR",
    CurrentValue = false,
    Callback = function(v) IsEditorEnabled = v if not v then clear() end end
})

MainTab:CreateButton({
    Name = "Create Block",
    Callback = function()
        local p = Instance.new("Part", workspace)
        p.Name = "Part_" .. math.random(100, 999)
        p.Size = Vector3.new(4, 4, 4)
        p.Anchored = true
        p.CFrame = Player.Character.HumanoidRootPart.CFrame + (Player.Character.HumanoidRootPart.CFrame.LookVector * 10)
        p.Color = Config.LastColor
        create(p)
    end
})

-- === PROPERTIES ===

-- ТЕПЕР ЦЕ КНОПКА, ЯКА КОПІЮЄ ІМ'Я
NameDisplay = PropTab:CreateButton({
    Name = "Selected: None (Click to copy)",
    Callback = function()
        if Selection then
            setclipboard(tostring(Selection.Name))
            Rayfield:Notify({
                Title = "Copied!",
                Content = "Name '" .. Selection.Name .. "' copied to clipboard.",
                Duration = 2
            })
        end
    end,
})

PropTab:CreateSection("Appearance")

PropTab:CreateInput({
    Name = "Rename Object",
    PlaceholderText = "Введіть назву...",
    Callback = function(t) 
        if Selection then 
            Selection.Name = t 
            NameDisplay:Set("Selected: " .. t)
        end 
    end
})

PropTab:CreateColorPicker({
    Name = "Color",
    Color = Color3.fromRGB(0, 255, 255),
    Callback = function(c) if Selection then Selection.Color = c end Config.LastColor = c end
})

PropTab:CreateSlider({
    Name = "Transparency",
    Range = {0, 1}, Increment = 0.1, CurrentValue = 0,
    Callback = function(v) if Selection then Selection.Transparency = v end end
})

PropTab:CreateSection("Physics & Actions")

PropTab:CreateButton({
    Name = "Duplicate (Копіювати)",
    Callback = function()
        if Selection then
            local c = Selection:Clone()
            c.Parent = Selection.Parent
            c.CFrame = Selection.CFrame + Vector3.new(0, 5, 0)
            create(c)
        end
    end
})

PropTab:CreateButton({
    Name = "Delete Object",
    Callback = function() if Selection then Selection:Destroy() clear() end end
})

PropTab:CreateSection("Scripting")

PropTab:CreateInput({
    Name = "Lua Code",
    PlaceholderText = "Напиши код...",
    RemoveTextAfterFocusLost = false,
    Callback = function(t) Config.LuaCode = t end
})

PropTab:CreateButton({
    Name = "Run Script",
    Callback = function()
        if Selection then
            local func = loadstring("local part = ...\n" .. Config.LuaCode)
            if func then
                local s, e = pcall(func, Selection)
                if not s then Rayfield:Notify({Title="Script Error", Content=e}) end
            end
        end
    end
})

-- ОБРОБКА КЛІКУ
Mouse.Button1Down:Connect(function()
    if not IsEditorEnabled then return end
    task.wait(0.05)
    if Mouse.Target and not Mouse.Target:IsA("Terrain") then
        create(Mouse.Target)
    end
end)

Rayfield:Notify({Title = "Studio Ready", Content = "Click the selection name to copy it!", Duration = 3})
