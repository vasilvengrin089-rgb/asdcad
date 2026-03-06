local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()



local Window = Rayfield:CreateWindow({

   Name = "Norvixes Hub | Sharp Aim",

   LoadingTitle = "Norvixes comabat Load",

   LoadingSubtitle = "Creator:vasilkovenumo999",

   ConfigurationSaving = { Enabled = true, FolderName = "NorvixesConfig" },

   KeySystem = false

})



-- Стан систем

local Options = {

    AimbotEnabled = false,

    AimbotActive = false,

    Fov = 150,

    HitboxSize = 10,

    FlyEnabled = false,

    FlySpeed = 50

}



-- FOV Коло 🎯

local FOVCircle = Drawing.new("Circle")

FOVCircle.Thickness = 1

FOVCircle.Color = Color3.fromRGB(255, 255, 255)

FOVCircle.Filled = false

FOVCircle.Visible = false



local CombatTab = Window:CreateTab("Combat", 4483362458)



-- ================= COMBAT SECTION =================

CombatTab:CreateSection("Sharp Aim Settings")



CombatTab:CreateToggle({

   Name = "Master Switch (Увімкнути)",

   CurrentValue = false,

   Callback = function(Value) 

      Options.AimbotEnabled = Value 

   end,

})



CombatTab:CreateKeybind({

   Name = "AimBot Bind",

   CurrentKeybind = "E",

   HoldToInteract = true,

   Flag = "AimbotKeybind",

   Callback = function() end,

})



CombatTab:CreateSlider({

   Name = "Aim FOV",

   Range = {0, 600},

   Increment = 10,

   CurrentValue = 150,

   Callback = function(Value) Options.Fov = Value; FOVCircle.Radius = Value end,

})



-- ================= LOGIC =================



local UserInputService = game:GetService("UserInputService")

local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera



-- Перевірка клавіші ⌨️

UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if gameProcessed then return end

    local currentBind = Rayfield.Flags.AimbotKeybind.CurrentKeybind

    if input.KeyCode == Enum.KeyCode[currentBind] then

        Options.AimbotActive = true

    end

end)



UserInputService.InputEnded:Connect(function(input)

    local currentBind = Rayfield.Flags.AimbotKeybind.CurrentKeybind

    if input.KeyCode == Enum.KeyCode[currentBind] then

        Options.AimbotActive = false

    end

end)



-- Пошук найближчого гравця 🔍

local function GetClosestPlayer()

    local target = nil

    local dist = Options.Fov

    local mouse = UserInputService:GetMouseLocation()



    for _, v in pairs(game.Players:GetPlayers()) do

        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then

            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)

            if onScreen then

                local magnitude = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude

                if magnitude < dist then

                    target = v

                    dist = magnitude

                end

            end

        end

    end

    return target

end



RunService.RenderStepped:Connect(function()

    FOVCircle.Position = UserInputService:GetMouseLocation()

    FOVCircle.Visible = Options.AimbotEnabled



    -- Різкий AimBot (без плавності) 🚀

    if Options.AimbotEnabled and Options.AimbotActive then

        local target = GetClosestPlayer()

        if target and target.Character:FindFirstChild("Head") then

            -- Миттєво повертаємо камеру до цілі

            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)

        end

    end

end)
local MainTab = Window:CreateTab("Global2", 4483362458)

MainTab:CreateButton({
   Name = "Open Infinite Yeld",
   Callback = function()
       -- Сюди вставляй свій код для вбивства
	   loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
   end,
})
local antiAfkEnabled = false -- Стан (спочатку вимкнено)
local antiAfkConnection = nil -- Тут ми зберігаємо підключення, щоб його можна було розірвати

local function toggleAntiAFK()
    antiAfkEnabled = not antiAfkEnabled -- Змінюємо стан на протилежний
    
    if antiAfkEnabled then
        -- ЛОГІКА УВІМКНЕННЯ
        local VU = game:GetService("VirtualUser")
        antiAfkConnection = game.Players.LocalPlayer.Idled:Connect(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
            warn("Xeno: Anti-AFK Enable!")
        end)

        Rayfield:Notify({
            Title = "Xeno Anti-AFK",
            Content = "Увімкнено! Тепер вас не Kick.",
            Duration = 3,
        })
    else
        -- ЛОГІКА ВИМКНЕННЯ
        if antiAfkConnection then
            antiAfkConnection:Disconnect() -- Вимикаємо "прослуховування" афк
            antiAfkConnection = nil
        end

        Rayfield:Notify({
            Title = "Xeno Anti-AFK",
            Content = "Вимкнено! Стандартний захист Roblox активований.",
            Duration = 3,
        })
    end
end
MainTab:CreateButton({
   Name = "Anti-AFK (Вкл/Викл)",
   Callback = function()
       toggleAntiAFK() -- Викликаємо функцію, яку написали вище
   end,
})
local espEnabled = false
local espConnection = nil

-- Функція для створення підсвітки
local function addRedHighlight(char)
    if not char:FindFirstChild("XenoRedESP") then
        local h = Instance.new("Highlight")
        h.Name = "XenoRedESP"
        h.FillColor = Color3.fromRGB(255, 0, 0)      -- Чистий червоний
        h.OutlineColor = Color3.fromRGB(255, 255, 255) -- Біла обводка для чіткості
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.Parent = char
    end
end

-- Кнопка в меню
MainTab:CreateButton({
    Name = "Red ESP (Вкл/Викл)",
    Callback = function()
        espEnabled = not espEnabled
        
        if espEnabled then
            -- Увімкнення
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    addRedHighlight(player.Character)
                end
                -- Слідкуємо за респавном
                player.CharacterAdded:Connect(function(char)
                    if espEnabled then addRedHighlight(char) end
                end)
            end
            
            -- Слідкуємо за новими гравцями
            espConnection = game.Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(char)
                    if espEnabled then addRedHighlight(char) end
                end)
            end)
            
            Rayfield:Notify({Title = "Xeno", Content = "ESP Увімкнено", Duration = 3})
        else
            -- Вимкнення
            if espConnection then espConnection:Disconnect() espConnection = nil end
            for _, player in pairs(game.Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("XenoRedESP") then
                    player.Character.XenoRedESP:Destroy()
                end
            end
            
            Rayfield:Notify({Title = "Xeno", Content = "ESP Вимкнено", Duration = 3})
        end
    end,
})
local flying = false
local flySpeed = 50
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

local function toggleFly()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    flying = not flying

    if flying then
        -- Створюємо силу польоту
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = root

        -- Створюємо стабілізатор (щоб персонаж не перевертався)
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bodyGyro.CFrame = root.CFrame
        bodyGyro.Parent = root

        -- Цикл руху за камерою
        flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            -- Логіка керування (WASD)
            local uis = game:GetService("UserInputService")
            if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            
            bodyVelocity.Velocity = moveDir * flySpeed
            bodyGyro.CFrame = cam.CFrame
        end)
        
        Rayfield:Notify({Title = "Xeno Hub", Content = "Fly Увімкнено! (WASD)", Duration = 3})
    else
        -- Вимкнення польоту
        if flyConnection then flyConnection:Disconnect() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        
        Rayfield:Notify({Title = "Xeno Hub", Content = "Fly Вимкнено", Duration = 3})
    end
end
MainTab:CreateButton({
   Name = "Fly (Лети/Впади)",
   Callback = function()
       toggleFly()
   end,
})

-- Додамо слайдер для швидкості польоту, щоб було зручніше
MainTab:CreateSlider({
   Name = "Швидкість польоту",
   Range = {10, 1000},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(Value)
       flySpeed = Value
   end,
})
-- Якщо ми хочемо видалити вкладку через код:
if GriblTab then
    -- У Rayfield об'єкти зазвичай мають внутрішній шлях до елементів UI
    -- Найпростіший спосіб — звернутися до батьківського об'єкта в GUI
    GriblTab:Destroy() 
end
