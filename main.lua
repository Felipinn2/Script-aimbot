-- ================= CONFIG =================
local ESP_BOX = true
local ESP_LINE = true
local ESP_NAME = true
local AIMBOT = false
local TEAM_CHECK = true
local AIM_FOV = 200
local AIMING = false

-- ================= SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ================= INPUT (PC + MOBILE) =================
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton2
	or input.UserInputType == Enum.UserInputType.Touch then
		AIMING = true
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2
	or input.UserInputType == Enum.UserInputType.Touch then
		AIMING = false
	end
end)

-- ================= GUI (OPEN BUTTON SIMPLES) =================
local gui = Instance.new("ScreenGui", game.CoreGui)

local open = Instance.new("TextButton", gui)
open.Size = UDim2.new(0,50,0,50)
open.Position = UDim2.new(0,20,0.5,0)
open.Text = "≡"
open.TextSize = 24
open.BackgroundColor3 = Color3.fromRGB(30,30,30)
open.TextColor3 = Color3.new(1,1,1)

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0,220,0,260)
panel.Position = UDim2.new(0,80,0.3,0)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Active = true
panel.Draggable = true

open.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

local function button(text,y,callback)
	local b = Instance.new("TextButton",panel)
	b.Size = UDim2.new(1,-20,0,35)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	b.MouseButton1Click:Connect(callback)
	return b
end

button("AIMBOT",20,function() AIMBOT = not AIMBOT end)
button("ESP BOX",60,function() ESP_BOX = not ESP_BOX end)
button("ESP LINE",100,function() ESP_LINE = not ESP_LINE end)
button("ESP NAME",140,function() ESP_NAME = not ESP_NAME end)
button("FOV +",180,function()
	AIM_FOV += 50
	if AIM_FOV > 400 then AIM_FOV = 100 end
end)

-- ================= FOV CIRCLE =================
local fov = Drawing.new("Circle")
fov.Color = Color3.fromRGB(255,255,255)
fov.Thickness = 1
fov.Filled = false

-- ================= ESP =================
local esp = {}

local function addESP(p)
	if p == LocalPlayer then return end
	esp[p] = {
		box = Drawing.new("Square"),
		line = Drawing.new("Line"),
		name = Drawing.new("Text")
	}
	esp[p].box.Thickness = 2
	esp[p].box.Color = Color3.fromRGB(255,0,0)
	esp[p].box.Filled = false

	esp[p].line.Thickness = 1
	esp[p].line.Color = Color3.fromRGB(255,255,255)

	esp[p].name.Size = 14
	esp[p].name.Center = true
	esp[p].name.Outline = true
end

for _,p in pairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)

-- ================= TARGET =================
local function valid(p)
	if TEAM_CHECK and p.Team == LocalPlayer.Team then return false end
	return true
end

local function getTarget()
	local closest, dist = nil, AIM_FOV
	local mousePos = UIS:GetMouseLocation()

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and valid(p)
		and p.Character and p.Character:FindFirstChild("Head") then
			local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
			if vis then
				local d = (Vector2.new(pos.X,pos.Y) - mousePos).Magnitude
				if d < dist then
					dist = d
					closest = p
				end
			end
		end
	end
	return closest
end

-- ================= MAIN LOOP =================
RunService.RenderStepped:Connect(function()
	local mousePos = UIS:GetMouseLocation()
	fov.Position = mousePos
	fov.Radius = AIM_FOV
	fov.Visible = AIMBOT

	for p,e in pairs(esp) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and valid(p) then
			local pos,vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
			if vis then
				e.box.Visible = ESP_BOX
				e.box.Size = Vector2.new(40,60)
				e.box.Position = Vector2.new(pos.X-20,pos.Y-30)

				e.line.Visible = ESP_LINE
				e.line.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
				e.line.To = Vector2.new(pos.X,pos.Y)

				e.name.Visible = ESP_NAME
				e.name.Text = p.Name
				e.name.Position = Vector2.new(pos.X,pos.Y-40)
			else
				e.box.Visible = false
				e.line.Visible = false
				e.name.Visible = false
			end
		end
	end

	if AIMBOT and AIMING then
		local t = getTarget()
		if t and t.Character and t.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.Head.Position)
		end
	end
end)
