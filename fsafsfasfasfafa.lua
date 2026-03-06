-- Завантаження бібліотеки (це і є "готова" частина, яку написали розробники Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Створення вікна
local Window = Rayfield:CreateWindow({
   Name = "Norvixes(було зроблено vasilkovenumo999)",
   LoadingTitle = "Norvixes Load",
   LoadingSubtitle = "Norvixes",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Norvixes_configurations", 
      FileName = "NorvixesConfig"
   },
   KeySystem = false, -- Вимкнено для зручності
})

-- Створення вкладки

local MainTab = Window:CreateTab("Global", 4483362458)

-- Секція
local Section = MainTab:CreateSection("Модифікації")

-- 1. Кнопка (Button)
MainTab:CreateButton({
   Name = "Im Kill",
   Callback = function()
       -- Сюди вставляй свій код для вбивства
	   game.Players.LocalPlayer.Character.Humanoid.Health = 0
   end,
})

-- 2. Перемикач (Toggle)
MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump", -- Прапорець для збереження налаштувань
   Callback = function(Value)
       _G.InfJump = Value
       game:GetService("UserInputService").JumpRequest:Connect(function()
           if _G.InfJump then
               game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
           end
       end)
   end,
})

-- 3. Слайдер (Slider)
MainTab:CreateSlider({
   Name = "Швидкість бігу",
   Range = {16, 1000000},
   Increment = 1,
   Suffix = "speed",
   CurrentValue = 16,
   Flag = "WS_Slider", 
   Callback = function(Value)
       game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})
MainTab:CreateSlider({
   Name = "Сила Скакання",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Jump",
   CurrentValue = 7,
   Flag = "WS_Slider2", 
   Callback = function(Value)
       game.Players.LocalPlayer.Character.Humanoid.JumpHeight = Value
   end,
})
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
