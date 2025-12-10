-- Zehub Script

--// Servicios
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local p = game.Players.LocalPlayer
local c = p.Character or p.CharacterAdded:Wait()
local r = c:WaitForChild("HumanoidRootPart")

--// Config
local active = false
local maxDist = 30

--// GUI
local gui = Instance.new("ScreenGui")
gui.Parent = p:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 100)
frame.Position = UDim2.new(1, -160, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local tog = Instance.new("TextButton")
tog.Size = UDim2.new(1, 0, 0.5, 0)
tog.Text = "rapidFire"
tog.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tog.TextColor3 = Color3.fromRGB(255, 255, 255)
tog.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 0.5, 0)
btn.Position = UDim2.new(0, 0, 0.5, 0)
btn.Text = "fireOnce"
btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Parent = frame


--// LISTA OPTIMIZADA DE PROMPTS
local prompts = {}

local function addPrompt(obj)
    if obj:IsA("ProximityPrompt") then
        table.insert(prompts, obj)
    end
end

-- Carga inicial
for _, v in ipairs(workspace:GetDescendants()) do
    addPrompt(v)
end

-- Si aparece un nuevo prompt en el mapa
workspace.DescendantAdded:Connect(addPrompt)


--// BUSCA EL PROXIMITY MÁS CERCANO (rápido)
local function getNearestPrompt()
    local nearest, distMin = nil, maxDist

    for _, pr in ipairs(prompts) do
        if pr and pr.Enabled then
            local att = pr.Parent
            if att and att:IsA("Attachment") then
                local dist = (r.Position - att.WorldPosition).Magnitude
                if dist < distMin then
                    distMin = dist
                    nearest = pr
                end
            end
        end
    end

    return nearest
end


--// FIRE SIN LAG
local function activatePrompt(pr)
    if not pr then return end

    pr.HoldDuration = 0
    pr.RequiresLineOfSight = false
    pr.MaxActivationDistance = math.huge
    pr.KeyboardKeyCode = Enum.KeyCode.Unknown
    pr.GamepadKeyCode = Enum.KeyCode.Unknown

    fireproximityprompt(pr, 0)
end


--// BOTONES
tog.MouseButton1Click:Connect(function()
    active = not active
    tog.Text = "rapidFire: " .. (active and "On" or "Off")
end)

btn.MouseButton1Click:Connect(function()
    activatePrompt(getNearestPrompt())
end)


--// LOOP SIN LAG
rs.Heartbeat:Connect(function()
    if active then
        local pr = getNearestPrompt()
        if pr then
            activatePrompt(pr)
        end
    end
end)


game.StarterGui:SetCore("SendNotification",{
    Title = "BY.Zehub",
    Text = "OPTIMIZADO SIN LAG",
    Duration = 8
})
