-- =================================================================
-- CONFIGURAÇÕES ELITE V9 - IKARO MOBILE
-- =================================================================
local Settings = {
    Aimbot = false,
    WallCheck = true,
    Box = false,
    Skeleton = false,
    Lines = false,
    Names = false,
    Dist = false,
    Health = false,
    Fly = false,
    FlySpeed = 50,
    FOV = 120,
    MaxDistance = 800,
    Smoothness = 0.2
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- =================================================================
-- INTERFACE (ESTILO ABAS + iOS SWITCHES)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local OpenBtn = Instance.new("TextButton", ScreenGui)

OpenBtn.Size = UDim2.new(0, 100, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.Text = "ABRIR"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
OpenBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", OpenBtn)

MainFrame.Size = UDim2.new(0, 260, 0, 350)
MainFrame.Position = UDim2.new(0.5, -130, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "IKARO MOBILE"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = "GothamBold"

local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, -20, 0, 35)
TabFrame.Position = UDim2.new(0, 10, 0, 40)
TabFrame.BackgroundTransparency = 1
Instance.new("UIListLayout", TabFrame).FillDirection = "Horizontal"
TabFrame.UIListLayout.Padding = UDim.new(0, 5)

local AimTab = Instance.new("ScrollingFrame", MainFrame)
local EspTab = Instance.new("ScrollingFrame", MainFrame)
local MiscTab = Instance.new("ScrollingFrame", MainFrame)

for _, f in pairs({AimTab, EspTab, MiscTab}) do
    f.Size = UDim2.new(1, -20, 1, -100)
    f.Position = UDim2.new(0, 10, 0, 85)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 0
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 5)
end
AimTab.Visible = true

local function CreateTabBtn(name, target)
    local b = Instance.new("TextButton", TabFrame)
    b.Size = UDim2.new(0.23, 0, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = "GothamBold"
    b.TextSize = 10
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        AimTab.Visible = false; EspTab.Visible = false; MiscTab.Visible = false
        target.Visible = true
    end)
    return b
end

CreateTabBtn("AIM", AimTab)
CreateTabBtn("ESP", EspTab)
CreateTabBtn("MISC", MiscTab)
local fch = CreateTabBtn("FECHA", AimTab)
fch.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)

local function AddSwitch(text, prop, parent)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 35)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.7, 0, 1, 0); l.Text = text .. ": " .. (Settings[prop] and "ON" or "OFF")
    l.TextColor3 = Color3.new(1,1,1); l.TextXAlignment = "Left"; l.BackgroundTransparency = 1
    local sw = Instance.new("TextButton", f)
    sw.Size = UDim2.new(0, 40, 0, 20); sw.Position = UDim2.new(1, -40, 0.5, -10)
    sw.BackgroundColor3 = Settings[prop] and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(60, 60, 65)
    sw.Text = ""; Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local c = Instance.new("Frame", sw)
    c.Size = UDim2.new(0, 16, 0, 16); c.Position = Settings[prop] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    c.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
    sw.MouseButton1Click:Connect(function()
        Settings[prop] = not Settings[prop]
        l.Text = text .. ": " .. (Settings[prop] and "ON" or "OFF")
        TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = Settings[prop] and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(60, 60, 65)}):Play()
        TweenService:Create(c, TweenInfo.new(0.2), {Position = Settings[prop] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
    end)
end

-- Botões
AddSwitch("Aimbot Master", "Aimbot", AimTab)
AddSwitch("Wall Check", "WallCheck", AimTab)
AddSwitch("ESP Box", "Box", EspTab)
AddSwitch("ESP Nome", "Names", EspTab)
AddSwitch("ESP Linha", "Lines", EspTab)
AddSwitch("ESP Skeleton", "Skeleton", EspTab)
AddSwitch("ESP Health", "Health", EspTab)
AddSwitch("Fly Mode", "Fly", MiscTab)

-- =================================================================
-- LÓGICA DE VOO (FLY)
-- =================================================================
local bodyVelocity, bodyGyro
RunService.RenderStepped:Connect(function()
    if Settings.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity", HRP)
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro = Instance.new("BodyGyro", HRP)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 9e4
        end
        bodyGyro.CFrame = Camera.CFrame
        local moveDir = LocalPlayer.Character.Humanoid.MoveDirection
        local flyDir = moveDir * Settings.FlySpeed
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyDir = flyDir + Vector3.new(0, Settings.FlySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            flyDir = flyDir - Vector3.new(0, Settings.FlySpeed, 0)
        end
        bodyVelocity.Velocity = flyDir
    else
        if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    end
end)

-- =================================================================
-- LÓGICA DE COMBATE & VISUAIS
-- =================================================================
local function IsVisible(target)
    if not Settings.WallCheck then return true end
    local char = target.Parent
    local direction = (target.Position - Camera.CFrame.Position).Unit * 1000
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(Camera.CFrame.Position, direction, params)
    return res and res.Instance:IsDescendantOf(char) or false
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Color = Color3.fromRGB(40, 40, 40); FOVCircle.Transparency = 0.3

local ESP_Table = {}
local function CreateESP(P)
    if P == LocalPlayer then return end
    ESP_Table[P] = {
        Box = Drawing.new("Square"), Line = Drawing.new("Line"),
        Name = Drawing.new("Text"), Health = Drawing.new("Line"), Skeleton = Drawing.new("Line")
    }
    ESP_Table[P].Name.Size = 14; ESP_Table[P].Name.Center = true; ESP_Table[P].Name.Outline = true
end

RunService.RenderStepped:Connect(function()
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Visible = Settings.Aimbot; FOVCircle.Radius = Settings.FOV; FOVCircle.Position = Center

    for P, D in pairs(ESP_Table) do
        local Char = P.Character
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
        
        if Char and Hum and HRP and Hum.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(HRP.Position)
            if vis then
                local head = Char:FindFirstChild("Head")
                if head then
                    local headP = Camera:WorldToViewportPoint(head.Position)
                    local h = math.abs(headP.Y - Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0,3.5,0)).Y)
                    local w = h / 1.6
                    
                    D.Box.Visible = Settings.Box; D.Box.Size = Vector2.new(w, h); D.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    D.Box.Color = IsVisible(head) and Color3.new(0,1,0) or Color3.new(1,0,0)
                    
                    D.Name.Visible = Settings.Names; D.Name.Text = P.Name; D.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 15)
                    D.Line.Visible = Settings.Lines; D.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); D.Line.To = Vector2.new(pos.X, pos.Y + h/2)
                    D.Skeleton.Visible = Settings.Skeleton; D.Skeleton.From = Vector2.new(headP.X, headP.Y); D.Skeleton.To = Vector2.new(pos.X, pos.Y)
                    
                    D.Health.Visible = Settings.Health; local hp = Hum.Health / Hum.MaxHealth
                    D.Health.From = Vector2.new(pos.X - w/2 - 5, pos.Y + h/2); D.Health.To = Vector2.new(pos.X - w/2 - 5, (pos.Y + h/2) - (h * hp))
                    D.Health.Color = Color3.fromHSV(hp * 0.3, 1, 1)
                end
            else for _, v in pairs(D) do v.Visible = false end end
        else for _, v in pairs(D) do v.Visible = false end end
    end

    if Settings.Aimbot then
        local target = nil
        local mDist = Settings.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local head = p.Character.Head
                local p_pos, vis = Camera:WorldToViewportPoint(head.Position)
                if vis and IsVisible(head) then
                    local d = (Vector2.new(p_pos.X, p_pos.Y) - Center).Magnitude
                    if d < mDist then mDist = d; target = head end
                end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothness) end
    end
end)

Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
-- LOOP PRINCIPAL
-- =================================================================
RunService.RenderStepped:Connect(function()
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for Player, Drawings in pairs(ESP_Table) do
        local Char = Player.Character
        local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
        
        if Char and HRP and Hum and Hum.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(HRP.Position)
            local dist = (Camera.CFrame.Position - HRP.Position).Magnitude

            if vis and dist <= Settings.MaxDistance and (not Settings.TeamCheck or Player.Team ~= LocalPlayer.Team) then
                local head = Char:FindFirstChild("Head")
                if head then
                    local headP = Camera:WorldToViewportPoint(head.Position)
                    local h = math.abs(headP.Y - Camera:WorldToViewportPoint(HRP.Position - Vector3.new(0,3,0)).Y)
                    local w = h / 1.5

                    -- BOX & LINHA
                    Drawings.Box.Visible = Settings.Box
                    Drawings.Box.Size = Vector2.new(w, h)
                    Drawings.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    Drawings.Box.Color = IsVisible(head) and Color3.new(0,1,0) or Color3.new(1,0,0)

                    Drawings.Line.Visible = Settings.Lines
                    Drawings.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    Drawings.Line.To = Vector2.new(pos.X, pos.Y + h/2)

                    -- VIDA
                    Drawings.Health.Visible = Settings.Health
                    local hp = Hum.Health / Hum.MaxHealth
                    Drawings.Health.From = Vector2.new(pos.X - w/2 - 5, pos.Y + h/2)
                    Drawings.Health.To = Vector2.new(pos.X - w/2 - 5, (pos.Y + h/2) - (h * hp))
                    Drawings.Health.Color = Color3.fromHSV(hp * 0.3, 1, 1)

                    -- SKELETON CORRIGIDO
                    Drawings.S1.Visible = Settings.Skeleton
                    Drawings.S1.From = Vector2.new(headP.X, headP.Y)
                    Drawings.S1.To = Vector2.new(pos.X, pos.Y)
                end
            else
                for _, v in pairs(Drawings) do v.Visible = false end
            end
        else
            for _, v in pairs(Drawings) do v.Visible = false end
        end
    end

    -- AIMBOT COM WALL CHECK
    if Settings.Aimbot then
        local target = nil
        local closest = Settings.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local head = p.Character.Head
                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                if vis and IsVisible(head) then
                    local mag = (Vector2.new(pos.X, pos.Y) - Center).Magnitude
                    if mag < closest then
                        closest = mag
                        target = head
                    end
                end
            end
        end
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothness)
        end
    end
end)

Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
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
