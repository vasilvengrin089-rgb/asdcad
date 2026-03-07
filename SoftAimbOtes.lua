local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Comparation:Norvixes",
   LoadingTitle = "Creator:Norvix",
   LoadingSubtitle = "Norvixes",
   ConfigurationSaving = { Enabled = false }
})

-- Налаштування
local AimbotEnabled = false
local AimSpeed = 10 
local FOVRadius = 200
local ShowFOV = true
local TargetMode = "Distance" -- "Distance" або "Mouse"
local Flying = false
local FlySpeed = 60

-- Коло FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.NumSides = 64

-- Вкладка Movement
local MoveTab = Window:CreateTab("Movement", 4483345998)

local function StopFly()
    Flying = false
    local Char = game.Players.LocalPlayer.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        local HRP = Char.HumanoidRootPart
        for _, v in pairs(HRP:GetChildren()) do if v.Name == "XenoFly" then v:Destroy() end end
        HRP.Velocity = Vector3.new(0,0,0)
        Char.Humanoid.PlatformStand = false
    end
end

local function StartFly()
    local LP = game.Players.LocalPlayer
    local Char = LP.Character or LP.CharacterAdded:Wait()
    local HRP = Char:WaitForChild("HumanoidRootPart")
    StopFly()
    Flying = true
    local BV = Instance.new("BodyVelocity", HRP)
    BV.Name = "XenoFly"
    BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    local BG = Instance.new("BodyGyro", HRP)
    BG.Name = "XenoFly"
    BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    BG.P = 15000
    task.spawn(function()
        local UIS = game:GetService("UserInputService")
        local Cam = workspace.CurrentCamera
        while Flying and Char and HRP.Parent do
            local moveVector = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector + Vector3.new(0, -1, 0) end
            Char.Humanoid.PlatformStand = true
            BV.Velocity = Cam.CFrame:VectorToWorldSpace(moveVector * FlySpeed)
            BG.CFrame = Cam.CFrame
            if moveVector.Magnitude == 0 then BV.Velocity = Vector3.new(0, 0, 0) end
            task.wait()
        end
        StopFly()
    end)
end

MoveTab:CreateToggle({Name = "Pro Fly", CurrentValue = false, Callback = function(v) if v then StartFly() else StopFly() end end})
MoveTab:CreateSlider({Name = "Fly Speed", Range = {10, 500}, Increment = 10, CurrentValue = 60, Callback = function(v) FlySpeed = v end})

-- Вкладка Combat
local CombatTab = Window:CreateTab("Combat", 4483345998)

local AimToggle = CombatTab:CreateToggle({Name = "Активація Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v end})

CombatTab:CreateDropdown({
   Name = "Режим вибору цілі",
   Options = {"Distance (Ближчий до мене)", "Mouse (Ближчий до курсора)"},
   CurrentOption = "Distance (Ближчий до мене)",
   Callback = function(Option)
       if Option == "Distance (Ближчий до мене)" then TargetMode = "Distance" else TargetMode = "Mouse" end
   end,
})

CombatTab:CreateKeybind({Name = "Aimbot Bind", CurrentKeybind = "Q", Callback = function() AimbotEnabled = not AimbotEnabled AimToggle:Set(AimbotEnabled) end})
CombatTab:CreateSlider({Name = "Швидкість наведення", Range = {1, 100}, Increment = 1, CurrentValue = 10, Callback = function(v) AimSpeed = v end})
CombatTab:CreateSlider({Name = "Радіус FOV", Range = {50, 1000}, Increment = 10, CurrentValue = 200, Callback = function(v) FOVRadius = v end})

-- Логіка Aimbot
game:GetService("RunService").RenderStepped:Connect(function()
    local LP = game.Players.LocalPlayer
    local Cam = workspace.CurrentCamera
    local MousePos = game:GetService("UserInputService"):GetMouseLocation()

    FOVCircle.Position = MousePos
    FOVCircle.Radius = FOVRadius
    FOVCircle.Visible = ShowFOV and AimbotEnabled

    if AimbotEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local target = nil
        local shortestVal = math.huge

        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local head = p.Character.Head
                local pos, onScreen = Cam:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    if TargetMode == "Mouse" then
                        local mag = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                        if mag < shortestVal and mag < FOVRadius then
                            target = head
                            shortestVal = mag
                        end
                    elseif TargetMode == "Distance" then
                        local dist = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        -- Все одно перевіряємо FOV, щоб аім не крутив камеру на 180 градусів без твого відома
                        local mouseMag = (Vector2.new(pos.X, pos.Y) - MousePos).Magnitude
                        if dist < shortestVal and mouseMag < FOVRadius then
                            target = head
                            shortestVal = dist
                        end
                    end
                end
            end
        end

        if target then
            local smoothness = AimSpeed / 100
            Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, target.Position), smoothness)
        end
    end
end)
