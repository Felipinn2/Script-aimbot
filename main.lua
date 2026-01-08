-- =====================================================
--        PRO ESP & AIM PANEL (PC + MOBILE)
-- =====================================================

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
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ================== GUI ==================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ProESPPanel"
gui.ResetOnSpawn = false

-- OPEN BUTTON
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 56, 0, 56)
openBtn.Position = UDim2.new(0, 20, 0.5, -28)
openBtn.Text = "☰"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 26
openBtn.BackgroundColor3 = Color3.fromRGB(22,22,22)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BorderSizePixel = 0
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0,14)

-- PANEL
local panel = Instance.new("Frame", gui)
panel.Size = UDim2.new(0, 280, 0, 380)
panel.Position = UDim2.new(0, -320, 0.5, -190)
panel.BackgroundColor3 = Color3.fromRGB(18,18,18)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,16)

-- TOP BAR
local top = Instance.new("Frame", panel)
top.Size = UDim2.new(1, 0, 0, 44)
top.BackgroundColor3 = Color3.fromRGB(28,28,28)
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "PRO ESP PANEL"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Left

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -40, 0.5, -16)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(140,40,40)
close.TextColor3 = Color3.new(1,1,1)
close.BorderSizePixel = 0
Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)

-- ================== TABS ==================
local tabs = Instance.new("Frame", panel)
tabs.Size = UDim2.new(1, -20, 0, 36)
tabs.Position = UDim2.new(0, 10, 0, 54)
tabs.BackgroundTransparency = 1

local function tabButton(text, x)
	local b = Instance.new("TextButton", tabs)
	b.Size = UDim2.new(0.33, -6, 1, 0)
	b.Position = UDim2.new(x, 0, 0, 0)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

local espTabBtn   = tabButton("ESP", 0)
local aimTabBtn   = tabButton("AIMBOT", 0.34)
local visTabBtn   = tabButton("VISUAL", 0.68)

-- ================== PAGES ==================
local pages = {}

local function createPage()
	local f = Instance.new("Frame", panel)
	f.Size = UDim2.new(1, -20, 1, -110)
	f.Position = UDim2.new(0, 10, 0, 100)
	f.BackgroundTransparency = 1
	f.Visible = false
	return f
end

pages.ESP = createPage()
pages.AIM = createPage()
pages.VIS = createPage()

-- ================== SWITCH ==================
local function createSwitch(parent, text, y, state, callback)
	local holder = Instance.new("Frame", parent)
	holder.Size = UDim2.new(1, 0, 0, 42)
	holder.Position = UDim2.new(0, 0, 0, y)
	holder.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", holder)
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Color3.new(1,1,1)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Left

	local btn = Instance.new("TextButton", holder)
	btn.Size = UDim2.new(0, 50, 0, 26)
	btn.Position = UDim2.new(1, -50, 0.5, -13)
	btn.BackgroundColor3 = state and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80)
	btn.Text = ""
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)

	local ball = Instance.new("Frame", btn)
	ball.Size = UDim2.new(0, 22, 0, 22)
	ball.Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
	ball.BackgroundColor3 = Color3.new(1,1,1)
	ball.BorderSizePixel = 0
	Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)

	btn.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = state and Color3.fromRGB(0,170,120) or Color3.fromRGB(80,80,80)
		}):Play()

		TweenService:Create(ball, TweenInfo.new(0.2), {
			Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
		}):Play()

		callback(state)
	end)
end

-- ESP PAGE
createSwitch(pages.ESP,"ESP BOX",0,ESP_BOX,function(v) ESP_BOX=v end)
createSwitch(pages.ESP,"ESP LINE",50,ESP_LINE,function(v) ESP_LINE=v end)
createSwitch(pages.ESP,"ESP NAME",100,ESP_NAME,function(v) ESP_NAME=v end)
createSwitch(pages.ESP,"TEAM CHECK",150,TEAM_CHECK,function(v) TEAM_CHECK=v end)

-- AIM PAGE
createSwitch(pages.AIM,"AIMBOT",0,AIMBOT,function(v) AIMBOT=v end)

-- ================== TAB LOGIC ==================
local function showPage(p)
	for _,pg in pairs(pages) do pg.Visible=false end
	pages[p].Visible=true
end

espTabBtn.MouseButton1Click:Connect(function() showPage("ESP") end)
aimTabBtn.MouseButton1Click:Connect(function() showPage("AIM") end)
visTabBtn.MouseButton1Click:Connect(function() showPage("VIS") end)

showPage("ESP")

-- ================== PANEL ANIMATION ==================
local openTween = TweenService:Create(panel,TweenInfo.new(0.35,Enum.EasingStyle.Quint),{
	Position = UDim2.new(0, 90, 0.5, -190)
})
local closeTween = TweenService:Create(panel,TweenInfo.new(0.35,Enum.EasingStyle.Quint),{
	Position = UDim2.new(0, -320, 0.5, -190)
})

openBtn.MouseButton1Click:Connect(function()
	openBtn.Visible=false
	openTween:Play()
end)

close.MouseButton1Click:Connect(function()
	closeTween:Play()
	task.delay(0.35,function()
		openBtn.Visible=true
	end)
end)

-- ================== FOV ==================
local circle = Drawing.new("Circle")
circle.Thickness = 1
circle.Color = Color3.new(1,1,1)
circle.Filled = false

-- ================== ESP & AIM LOGIC ==================
local esp = {}

local function validTarget(p)
	return p~=LocalPlayer
		and p.Character
		and p.Character:FindFirstChild("Head")
		and p.Character:FindFirstChild("Humanoid")
		and p.Character.Humanoid.Health>0
		and (not TEAM_CHECK or p.Team~=LocalPlayer.Team)
end

local aiming=false
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.UserInputType==Enum.UserInputType.MouseButton2
	or i.UserInputType==Enum.UserInputType.Touch then
		aiming=true
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton2
	or i.UserInputType==Enum.UserInputType.Touch then
		aiming=false
	end
end)

RunService.RenderStepped:Connect(function()
	local center = Camera.ViewportSize/2
	circle.Position=center
	circle.Radius=AIM_FOV
	circle.Visible=AIMBOT
end)		and p.Character and p.Character:FindFirstChild("Head") then
			local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
			if vis then
				local d = (Vector2.new(pos.X,pos.Y) - Vector2.new(center.X,center.Y)).Magnitude
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
	local center = Camera.ViewportSize / 2

	fov.Position = Vector2.new(center.X, center.Y)
	fov.Radius = AIM_FOV
	fov.Visible = AIMBOT

	for p,e in pairs(esp) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		and validTarget(p) then
			local pos,vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
			if vis then
				e.box.Visible = ESP_BOX
				e.box.Size = Vector2.new(40,60)
				e.box.Position = Vector2.new(pos.X-20,pos.Y-30)

				e.line.Visible = ESP_LINE
				e.line.From = Vector2.new(center.X, Camera.ViewportSize.Y)
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
			e.box.Visible = false
			e.line.Visible = false
			e.name.Visible = false
		end
	end

	if AIMBOT and AIMING then
		local t = getTarget()
		if t and t.Character and t.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(
				Camera.CFrame.Position,
				t.Character.Head.Position
			)
		end
	end
end)
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
