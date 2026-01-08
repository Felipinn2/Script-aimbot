-- =================================================================
-- CONFIGURAÇÕES ELITE V7
-- =================================================================
local Settings = {
    Aimbot = false,
    WallCheck = true, -- Só mira se não houver paredes na frente
    Box = false,
    Skeleton = false,
    Lines = false,
    Health = false,
    TeamCheck = false,
    FOV = 120,
    MaxDistance = 800,
    Smoothness = 0.25
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- =================================================================
-- INTERFACE (GUI)
-- =================================================================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local OpenBtn = Instance.new("TextButton", ScreenGui)

OpenBtn.Size = UDim2.new(0, 100, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "ABRIR"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
Instance.new("UICorner", OpenBtn)

MainFrame.Size = UDim2.new(0, 240, 0, 420)
MainFrame.Position = UDim2.new(0, 10, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local List = Instance.new("UIListLayout", MainFrame)
List.Padding = UDim.new(0, 5)
List.HorizontalAlignment = "Center"

local function AddToggle(text, prop)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0, 220, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = text .. ": OFF"
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = "Gotham"
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        Settings[prop] = not Settings[prop]
        b.Text = text .. ": " .. (Settings[prop] and "ON" or "OFF")
        b.BackgroundColor3 = Settings[prop] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(40, 40, 40)
    end)
end

AddToggle("Aimbot", "Aimbot")
AddToggle("Wall Check", "WallCheck")
AddToggle("ESP Box", "Box")
AddToggle("ESP Skeleton", "Skeleton")
AddToggle("ESP Linha", "Lines")
AddToggle("ESP Vida", "Health")

local FOVBtn = Instance.new("TextButton", MainFrame)
FOVBtn.Size = UDim2.new(0, 220, 0, 35)
FOVBtn.Text = "FOV: " .. Settings.FOV
FOVBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", FOVBtn)
FOVBtn.MouseButton1Click:Connect(function()
    Settings.FOV = (Settings.FOV >= 400) and 80 or Settings.FOV + 40
    FOVBtn.Text = "FOV: " .. Settings.FOV
end)

-- =================================================================
-- FUNÇÕES DE SUPORTE
-- =================================================================
local function IsVisible(target)
    if not Settings.WallCheck then return true end
    local char = target.Parent
    local ray = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 1000)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    if hit and hit:IsDescendantOf(char) then
        return true
    end
    return false
end

local ESP_Table = {}
local function CreateESP(Player)
    if Player == LocalPlayer then return end
    local d = {
        Box = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        Health = Drawing.new("Line"),
        S1 = Drawing.new("Line"), -- Cabeça para Torso
        S2 = Drawing.new("Line")  -- Ombro a Ombro
    }
    d.Box.Filled = false; d.Box.Thickness = 1
    ESP_Table[Player] = d
end

-- =================================================================
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
