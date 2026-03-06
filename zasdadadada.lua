local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Norvixes Hub | Sharp Aim",
   LoadingTitle = "Гіпер-реакція активована...",
   LoadingSubtitle = "by vasilvengrin089",
   ConfigurationSaving = { Enabled = true, FolderName = "NorvixesConfig" },
   KeySystem = false
})

local Options = {
    AimbotEnabled = false,
    AimbotActive = false,
    Fov = 150,
    InfiniteJump = false,
    FlyEnabled = false,
    FlySpeed = 50
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0) -- Червоний для агресивного стилю
FOVCircle.Filled = false
FOVCircle.Visible = false

local CombatTab = Window:CreateTab("Combat", 4483362458)
local GriblTab = Window:CreateTab("Gribl2", 4483362458)

-- ================= COMBAT (MAX REACTION) =================
CombatTab:CreateSection("Sharp Aim Settings")

CombatTab:CreateToggle({
   Name = "Master Switch (Увімкнути)",
   CurrentValue = false,
   Callback = function(Value) Options.AimbotEnabled = Value end,
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

-- ================= GRIBL2 (FLY / JUMP / IY) =================
GriblTab:CreateSection("Утиліти")

GriblTab:CreateButton({
   Name = "Infinite Yield 📜",
   Callback = function()
      loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
   end,
})

GriblTab:CreateToggle({
   Name = "Infinite Jump 🦘",
   CurrentValue = false,
   Callback = function(Value) Options.InfiniteJump = Value end,
})

GriblTab:CreateSection("Fly Settings")

GriblTab:CreateToggle({
   Name = "Fly (Політ) ✈️",
   CurrentValue = false,
   Callback = function(Value) 
      Options.FlyEnabled = Value 
      local lp = game.Players.LocalPlayer
      if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
          lp.Character.Humanoid.PlatformStand = Value
      end
   end,
})

GriblTab:CreateSlider({
   Name = "Швидкість Fly",
   Range = {10, 500},
   Increment = 10,
   CurrentValue = 50,
   Callback = function(Value) Options.FlySpeed = Value end,
})

-- ================= LOGIC (REWRITTEN FOR SPEED) =================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Infinite Jump Logic
UserInputService.JumpRequest:Connect(function()
    if Options.InfiniteJump then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

-- AimBot Key Check
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode[Rayfield.Flags.AimbotKeybind.CurrentKeybind] then
        Options.AimbotActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[Rayfield.Flags.AimbotKeybind.CurrentKeybind] then
        Options.AimbotActive = false
    end
end)

local function GetClosestPlayer()
    local target = nil
    local dist = Options.Fov
    local mouse = UserInputService:GetMouseLocation()

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
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

-- Основний цикл оновлення
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Options.AimbotEnabled

    local lp = game.Players.LocalPlayer
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Fly Logic (Летіти вгору/вниз за камерою)
    if Options.FlyEnabled then
        local root = char.HumanoidRootPart
        local moveDir = char:FindFirstChildOfClass("Humanoid").MoveDirection
        if moveDir.Magnitude > 0 then
            root.Velocity = Camera.CFrame.LookVector * Options.FlySpeed
        else
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end

    -- AimBot Logic (Миттєва реакція на Head)
    if Options.AimbotEnabled and Options.AimbotActive then
        local target = GetClosestPlayer()
        if target and target.Character:FindFirstChild("Head") then
            -- Наведення без затримки
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
