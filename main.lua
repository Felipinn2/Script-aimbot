-- ================== CONFIG ==================
local ESP_BOX = true
local ESP_LINE = true
local ESP_NAME = true
local AIMBOT = false
local TEAM_CHECK = true
local AIM_FOV = 200

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ================== GUI ==================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "UniversalESPPanel"

-- OPEN BUTTON
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0.5, 0)
openBtn.Text = "≡"
openBtn.TextSize = 24
openBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BorderSizePixel = 0
openBtn.Visible = true

-- PANEL
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 220, 0, 320)
panel.Position = UDim2.new(0, 80, 0.3, 0)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.BorderSizePixel = 0
panel.Visible = true
panel.Active = true
panel.Draggable = true

-- TOP BAR
local top = Instance.new("Frame", panel)
top.Size = UDim2.new(1, 0, 0, 30)
top.BackgroundColor3 = Color3.fromRGB(35,35,35)
top.BorderSizePixel = 0

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0, 30, 1, 0)
close.Position = UDim2.new(1, -30, 0, 0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(150,40,40)
close.TextColor3 = Color3.new(1,1,1)
close.BorderSizePixel = 0

local minimize = Instance.new("TextButton", top)
minimize.Size = UDim2.new(0, 30, 1, 0)
minimize.Position = UDim2.new(1, -60, 0, 0)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(60,60,60)
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BorderSizePixel = 0

-- BUTTON CREATOR
local function btn(text, y)
	local b = Instance.new("TextButton", panel)
	b.Size = UDim2.new(1, -20, 0, 35)
	b.Position = UDim2.new(0, 10, 0, y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	b.TextSize = 15
	return b
end

local boxBtn   = btn("ESP BOX: ON", 40)
local lineBtn  = btn("ESP LINE: ON", 80)
local nameBtn  = btn("ESP NAME: ON", 120)
local teamBtn  = btn("TEAM CHECK: ON", 160)
local aimBtn   = btn("AIMBOT: OFF", 200)

local fovText = Instance.new("TextLabel", panel)
fovText.Size = UDim2.new(1, -20, 0, 25)
fovText.Position = UDim2.new(0, 10, 0, 245)
fovText.Text = "FOV: "..AIM_FOV
fovText.BackgroundTransparency = 1
fovText.TextColor3 = Color3.new(1,1,1)

local fovBtn = btn("ALTERAR FOV", 270)

-- ================== BUTTON LOGIC ==================
boxBtn.MouseButton1Click:Connect(function()
	ESP_BOX = not ESP_BOX
	boxBtn.Text = "ESP BOX: "..(ESP_BOX and "ON" or "OFF")
end)

lineBtn.MouseButton1Click:Connect(function()
	ESP_LINE = not ESP_LINE
	lineBtn.Text = "ESP LINE: "..(ESP_LINE and "ON" or "OFF")
end)

nameBtn.MouseButton1Click:Connect(function()
	ESP_NAME = not ESP_NAME
	nameBtn.Text = "ESP NAME: "..(ESP_NAME and "ON" or "OFF")
end)

teamBtn.MouseButton1Click:Connect(function()
	TEAM_CHECK = not TEAM_CHECK
	teamBtn.Text = "TEAM CHECK: "..(TEAM_CHECK and "ON" or "OFF")
end)

aimBtn.MouseButton1Click:Connect(function()
	AIMBOT = not AIMBOT
	aimBtn.Text = "AIMBOT: "..(AIMBOT and "ON" or "OFF")
end)

fovBtn.MouseButton1Click:Connect(function()
	AIM_FOV += 50
	if AIM_FOV > 400 then AIM_FOV = 100 end
	fovText.Text = "FOV: "..AIM_FOV
end)

close.MouseButton1Click:Connect(function()
	panel.Visible = false
	openBtn.Visible = true
end)

minimize.MouseButton1Click:Connect(function()
	panel.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	panel.Visible = true
	openBtn.Visible = false
end)

-- ================== FOV CIRCLE ==================
local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(255,255,255)
circle.Thickness = 1
circle.Filled = false

-- ================== ESP ==================
local esp = {}

local function addESP(p)
	if p == LocalPlayer then return end
	esp[p] = {
		box = Drawing.new("Square"),
		line = Drawing.new("Line"),
		name = Drawing.new("Text")
	}
	esp[p].box.Thickness = 2
	esp[p].box.Filled = false
	esp[p].box.Color = Color3.fromRGB(255,0,0)

	esp[p].line.Color = Color3.fromRGB(255,255,255)
	esp[p].line.Thickness = 1

	esp[p].name.Size = 14
	esp[p].name.Center = true
	esp[p].name.Outline = true
end

for _,p in pairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)

-- ================== TARGET ==================
local function validTarget(p)
	if TEAM_CHECK and p.Team == LocalPlayer.Team then
		return false
	end
	return true
end

local function getTarget()
	local closest, dist = nil, AIM_FOV
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and validTarget(p) and p.Character and p.Character:FindFirstChild("Head") then
			local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
			if vis then
				local d = (Vector2.new(pos.X,pos.Y)-Vector2.new(Mouse.X,Mouse.Y)).Magnitude
				if d < dist then
					dist = d
					closest = p
				end
			end
		end
	end
	return closest
end

-- ================== LOOP ==================
RunService.RenderStepped:Connect(function()
	circle.Position = Vector2.new(Mouse.X, Mouse.Y)
	circle.Radius = AIM_FOV
	circle.Visible = AIMBOT

	for p,e in pairs(esp) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and validTarget(p) then
			local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
			if vis then
				e.box.Visible = ESP_BOX
				e.box.Size = Vector2.new(40,60)
				e.box.Position = Vector2.new(pos.X-20,pos.Y-30)

				e.line.Visible = ESP_LINE
				e.line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
				e.line.To = Vector2.new(pos.X,pos.Y)

				e.name.Visible = ESP_NAME
				e.name.Text = p.Name
				e.name.Position = Vector2.new(pos.X,pos.Y-40)
			else
				e.box.Visible = false
				e.line.Visible = false
				e.name.Visible = false
			end
		else
			if e then
				e.box.Visible = false
				e.line.Visible = false
				e.name.Visible = false
			end
		end
	end

	-- Aimbot PC + Mobile (segurar toque)
	if AIMBOT and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local t = getTarget()
		if t and t.Character and t.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
		end
	end
end)
