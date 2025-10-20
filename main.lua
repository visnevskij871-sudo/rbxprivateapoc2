-- ==============================================================
-- 🎄 RBXL CHEATS — Apocalypse Rising 2 • v2.4 (NEW YEAR EDITION)
-- 🧟 Features: Aimbot, No Recoil, No Reload, Zombie ESP, Fly, NoClip
-- 🔒 Official Channel: https://t.me/rbxlcheats
-- ⚠️ All scripts are from public sources. We are not responsible for their use.
-- ==============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ==================== KEY SYSTEM ====================
local KeySystem = {
	_validKey = "AR2-WARZONE-FREE",
	_activated = false
}

function KeySystem:Validate(inputKey)
	if self._activated then return true end
	if inputKey == self._validKey then
		self._activated = true
		return true, "✅ ACTIVATED!"
	else
		return false, "❌ INVALID KEY!"
	end
end

function KeySystem:IsValid()
	return self._activated
end

-- ==================== ENHANCED ANTI-BAN ====================
local AntiBan = {
	_lastUpdate = tick(),
	_safeActions = 0,
	_randomDelays = true,
	_protectionEnabled = true,
	_noise = 0.02 -- human-like input noise
}

function AntiBan:SimulateHumanBehavior()
	if not self._protectionEnabled then return end
	if math.random() < 0.25 then
		wait(math.random() * 0.1)
	end
end

function AntiBan:AddNoise(vector)
	return vector + Vector3.new(
		math.random() - 0.5,
		math.random() - 0.5,
		math.random() - 0.5
	) * self._noise
end

function AntiBan:ProtectScript()
	pcall(function()
		script.Name = HttpService:GenerateGUID(false)
		getfenv(0).debug = nil
		-- Hide from common detectors
		if getgenv then getgenv().Synapse = nil end
	end)
end

-- ==================== MAIN TOOL ====================
local AR2Tool = {
	Version = "v2.4",
	ESPEnabled = false,
	ZombieESPEnabled = false,
	AimbotEnabled = false,
	NoRecoilEnabled = false,
	NoReloadEnabled = false,
	FlyEnabled = false,
	NoClipEnabled = false,

	MaxDistance = 1500,
	ESPElements = {},
	ZombieHighlights = {},
	BodyVelocity = nil,
	Connections = {},
	GUIInitialized = false
}

-- ==================== PLAYER ESP ====================
function AR2Tool:ToggleESP()
	if not KeySystem:IsValid() then return end
	self.ESPEnabled = not self.ESPEnabled
	if self.ESPEnabled then
		self.Connections.esp = RunService.RenderStepped:Connect(function()
			AntiBan:SimulateHumanBehavior()
			self:UpdateESP()
		end)
	else
		if self.Connections.esp then self.Connections.esp:Disconnect() end
		self:ClearESP()
	end
end

function AR2Tool:UpdateESP()
	local playerCharacter = player.Character
	if not playerCharacter then return end
	local playerRoot = playerCharacter:FindFirstChild("HumanoidRootPart")
	if not playerRoot then return end

	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local character = otherPlayer.Character
			if character then
				self:CreateOrUpdateESP(otherPlayer, character, playerRoot)
			end
		end
	end
end

function AR2Tool:CreateOrUpdateESP(otherPlayer, character, playerRoot)
	if not otherPlayer or not character or not playerRoot then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local distance = (playerRoot.Position - rootPart.Position).Magnitude
	if distance > self.MaxDistance then
		if self.ESPElements[otherPlayer] then
			if self.ESPElements[otherPlayer].highlight then self.ESPElements[otherPlayer].highlight:Destroy() end
			if self.ESPElements[otherPlayer].billboard then self.ESPElements[otherPlayer].billboard:Destroy() end
			self.ESPElements[otherPlayer] = nil
		end
		return
	end

	if not self.ESPElements[otherPlayer] then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.FillTransparency = 0.7
		highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
		highlight.OutlineTransparency = 0.3
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = character
		highlight.Parent = character

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 150, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 3.5, 0)
		billboard.AlwaysOnTop = true
		billboard.LightInfluence = 0
		billboard.ResetOnSpawn = false
		billboard.Adornee = rootPart
		billboard.Parent = character

		local bg = Instance.new("Frame")
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(0, 20, 0)
		bg.BackgroundTransparency = 0.6
		bg.BorderSizePixel = 0
		bg.Parent = billboard

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0, 20)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = otherPlayer.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 11
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.Parent = billboard

		local distLabel = Instance.new("TextLabel")
		distLabel.Name = "Dist"
		distLabel.Size = UDim2.new(1, 0, 0, 18)
		distLabel.Position = UDim2.new(0, 0, 0, 20)
		distLabel.BackgroundTransparency = 1
		distLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
		distLabel.TextSize = 10
		distLabel.Font = Enum.Font.Gotham
		distLabel.Parent = billboard

		self.ESPElements[otherPlayer] = { highlight = highlight, billboard = billboard, distLabel = distLabel }
	end

	local distLabel = self.ESPElements[otherPlayer].distLabel
	if distLabel then
		distLabel.Text = string.format("📏 %d m", math.floor(distance))
	end
end

function AR2Tool:ClearESP()
	for _, data in pairs(self.ESPElements) do
		if data.highlight then data.highlight:Destroy() end
		if data.billboard then data.billboard:Destroy() end
	end
	self.ESPElements = {}
end

-- ==================== ZOMBIE ESP ====================
function AR2Tool:ToggleZombieESP()
	if not KeySystem:IsValid() then return end
	self.ZombieESPEnabled = not self.ZombieESPEnabled
	if self.ZombieESPEnabled then
		self.Connections.zombie = RunService.RenderStepped:Connect(function()
			self:UpdateZombieESP()
		end)
	else
		if self.Connections.zombie then self.Connections.zombie:Disconnect() end
		self:ClearZombieESP()
	end
end

function AR2Tool:UpdateZombieESP()
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") and not npc:FindFirstChild("PlayerGui") then
			if npc.Name:match("Zombie") or npc.Name:match("Walker") or npc.Name:match("Boss") then
				self:CreateOrUpdateZombieHighlight(npc)
			end
		end
	end

	-- Clean up dead zombies
	for zombie, highlight in pairs(self.ZombieHighlights) do
		if not zombie or not zombie.Parent then
			if highlight and highlight.Parent then highlight:Destroy() end
			self.ZombieHighlights[zombie] = nil
		end
	end
end

function AR2Tool:CreateOrUpdateZombieHighlight(zombie)
	if self.ZombieHighlights[zombie] then return end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 50, 50)
	highlight.FillTransparency = 0.65
	highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
	highlight.OutlineTransparency = 0.4
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = zombie
	highlight.Parent = zombie
	self.ZombieHighlights[zombie] = highlight
end

function AR2Tool:ClearZombieESP()
	for _, highlight in pairs(self.ZombieHighlights) do
		if highlight and highlight.Parent then highlight:Destroy() end
	end
	self.ZombieHighlights = {}
end

-- ==================== AIMBOT (REAL) ====================
function AR2Tool:ToggleAimbot()
	if not KeySystem:IsValid() then return end
	self.AimbotEnabled = not self.AimbotEnabled
	if self.AimbotEnabled then
		warn("⚠️ AIMBOT ACTIVE — HIGH RISK OF BAN IN AR2!")
		self.Connections.aim = UserInputService.InputBegan:Connect(function(input, gp)
			if gp or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			self:AimAtNearest()
		end)
	else
		if self.Connections.aim then self.Connections.aim:Disconnect() end
	end
end

function AR2Tool:AimAtNearest()
	if not self.AimbotEnabled then return end
	local cam = workspace.CurrentCamera
	if not cam then return end

	local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not playerRoot then return end

	local closestTarget = nil
	local closestDist = math.huge

	-- Check players
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (playerRoot.Position - root.Position).Magnitude
				if dist < closestDist and dist <= self.MaxDistance then
					closestDist = dist
					closestTarget = root
				end
			end
		end
	end

	-- Check zombies
	for zombie, _ in pairs(self.ZombieHighlights) do
		if zombie and zombie:FindFirstChild("HumanoidRootPart") then
			local root = zombie.HumanoidRootPart
			local dist = (playerRoot.Position - root.Position).Magnitude
			if dist < closestDist and dist <= self.MaxDistance then
				closestDist = dist
				closestTarget = root
			end
		end
	end

	if closestTarget then
		local targetPos = closestTarget.Position + Vector3.new(0, 1.5, 0)
		local lookAt = CFrame.new(cam.CFrame.Position, targetPos)
		cam.CFrame = lookAt
	end
end

-- ==================== NO RECOIL + NO RELOAD ====================
function AR2Tool:ToggleNoRecoil()
	if not KeySystem:IsValid() then return end
	self.NoRecoilEnabled = not self.NoRecoilEnabled
	if self.NoRecoilEnabled then
		warn("⚠️ NO RECOIL ENABLED — MAY TRIGGER ANTI-CHEAT!")
		self.Connections.recoil = RunService.RenderStepped:Connect(function()
			local char = player.Character
			if char then
				local weapon = char:FindFirstChildWhichIsA("Tool")
				if weapon and weapon:FindFirstChild("Recoil") then
					weapon.Recoil.Value = 0
				end
			end
		end)
	else
		if self.Connections.recoil then self.Connections.recoil:Disconnect() end
	end
end

function AR2Tool:ToggleNoReload()
	if not KeySystem:IsValid() then return end
	self.NoReloadEnabled = not self.NoReloadEnabled
	if self.NoReloadEnabled then
		warn("⚠️ NO RELOAD ENABLED — EXTREME BAN RISK!")
		self.Connections.reload = RunService.RenderStepped:Connect(function()
			local char = player.Character
			if char then
				local weapon = char:FindFirstChildWhichIsA("Tool")
				if weapon and weapon:FindFirstChild("Ammo") and weapon:FindFirstChild("MaxAmmo") then
					weapon.Ammo.Value = weapon.MaxAmmo.Value
				end
			end
		end)
	else
		if self.Connections.reload then self.Connections.reload:Disconnect() end
	end
end

-- ==================== FLY & NOCLIP ====================
function AR2Tool:ToggleFly()
	if not KeySystem:IsValid() then return end
	self.FlyEnabled = not self.FlyEnabled
	if self.FlyEnabled then
		warn("⚠️ FLY ENABLED — USE ONLY IN SAFE AREAS!")
		local character = player.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.PlatformStand = true end

		self.BodyVelocity = Instance.new("BodyVelocity")
		self.BodyVelocity.Velocity = Vector3.zero
		self.BodyVelocity.MaxForce = Vector3.new(50000, 50000, 50000)
		self.BodyVelocity.Parent = rootPart

		self.Connections.fly = RunService.RenderStepped:Connect(function()
			if not self.FlyEnabled or not rootPart.Parent then
				self:ToggleFly()
				return
			end

			local cam = workspace.CurrentCamera
			if not cam then return end

			local dir = Vector3.zero
			local speed = 100

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end

			if dir.Magnitude > 0 then dir = dir.Unit * speed end
			self.BodyVelocity.Velocity = dir
		end)
	else
		if self.BodyVelocity then self.BodyVelocity:Destroy() end
		if self.Connections.fly then self.Connections.fly:Disconnect() end
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.PlatformStand = false end
	end
end

function AR2Tool:ToggleNoClip()
	if not KeySystem:IsValid() then return end
	self.NoClipEnabled = not self.NoClipEnabled
	if self.NoClipEnabled then
		warn("⚠️ NOCLIP ENABLED — HIGH BAN RISK!")
		self.Connections.noclip = RunService.RenderStepped:Connect(function()
			local char = player.Character
			if char then
				for _, part in pairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if self.Connections.noclip then self.Connections.noclip:Disconnect() end
		local char = player.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end

-- ==================== SNOW PARTICLES (NEW YEAR) ====================
local function createSnowEffect(screenGui)
	local snowContainer = Instance.new("Frame")
	snowContainer.Size = UDim2.new(1, 0, 1, 0)
	snowContainer.BackgroundTransparency = 1
	snowContainer.Parent = screenGui

	for i = 1, 30 do
		spawn(function()
			local flake = Instance.new("ImageLabel")
			flake.Image = "rbxassetid://4833634950" -- snowflake
			flake.Size = UDim2.new(0, math.random(10, 20), 0, math.random(10, 20))
			flake.BackgroundTransparency = 1
			flake.Position = UDim2.new(math.random(), 0, -0.1, 0)
			flake.ZIndex = 1
			flake.Parent = snowContainer

			while snowContainer and snowContainer.Parent do
				flake.Position = flake.Position + UDim2.new(0, 0, 0.01, math.random(2, 5))
				flake.Rotation = flake.Rotation + math.random(-5, 5)
				wait(0.05)
				if flake.Position.Y.Scale > 1.1 then
					flake.Position = UDim2.new(math.random(), 0, -0.1, 0)
				end
			end
		end)
		wait(0.1)
	end
end

-- ==================== NEW YEAR UI ====================
function AR2Tool:CreateModernUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AR2_Cheats_UI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Snow effect
	createSnowEffect(screenGui)

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 680, 0, 420)
	main.Position = UDim2.new(0.5, -340, 0.1, 0)
	main.BackgroundColor3 = Color3.fromRGB(10, 25, 10)
	main.BackgroundTransparency = 0.25
	main.BorderSizePixel = 0
	main.Visible = false
	main.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = main

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
	topBar.BorderSizePixel = 0
	topBar.Parent = main

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 340, 1, 0)
	title.Position = UDim2.new(0, 12, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🎄 AR2 CHEATS • " .. self.Version .. " • NEW YEAR"
	title.TextColor3 = Color3.fromRGB(255, 220, 100) -- gold
	title.TextSize = 16
	title.Font = Enum.Font.GothamBlack
	title.Parent = topBar

	local tg = Instance.new("TextLabel")
	tg.Size = UDim2.new(0, 200, 1, 0)
	tg.Position = UDim2.new(0.5, -100, 0, 0)
	tg.BackgroundTransparency = 1
	tg.Text = "t.me/rbxlcheats"
	tg.TextColor3 = Color3.fromRGB(200, 240, 200)
	tg.TextSize = 12
	tg.Font = Enum.Font.Gotham
	tg.Parent = topBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 34, 0, 28)
	closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
	closeBtn.Text = "×"
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 20
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = topBar

	local function makeDraggable(frame, dragBar)
		local dragging = false
		dragBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				local startPos = frame.Position
				local dragStart = UserInputService:GetMouseLocation()
				UserInputService.InputChanged:Connect(function(_, input)
					if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
						local delta = UserInputService:GetMouseLocation() - dragStart
						frame.Position = UDim2.new(
							startPos.X.Scale, startPos.X.Offset + delta.X,
							startPos.Y.Scale, startPos.Y.Offset + delta.Y
						)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
			end
		end)
	end

	makeDraggable(main, topBar)

	local tabs = Instance.new("Frame")
	tabs.Size = UDim2.new(1, -20, 0, 36)
	tabs.Position = UDim2.new(0, 10, 0, 46)
	tabs.BackgroundTransparency = 1
	tabs.Parent = main

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -20, 0, 290)
	content.Position = UDim2.new(0, 10, 0, 86)
	content.BackgroundTransparency = 1
	content.Parent = main

	local mainTab = self:CreateTab("MAIN", 0, tabs, true)
	local visualTab = self:CreateTab("VISUAL", 1, tabs, false)
	local combatTab = self:CreateTab("COMBAT", 2, tabs, false)
	local movementTab = self:CreateTab("MOVEMENT", 3, tabs, false)

	local mainContent = self:CreateMainTab(content)
	local visualContent = self:CreateVisualTab(content)
	local combatContent = self:CreateCombatTab(content)
	local movementContent = self:CreateMovementTab(content)

	mainContent.Visible = true
	visualContent.Visible = false
	combatContent.Visible = false
	movementContent.Visible = false

	-- Tab switching
	local function switchTab(activeTab, activeContent, others, otherContents)
		activeTab.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
		activeContent.Visible = true
		for i, tab in ipairs(others) do
			tab.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
			otherContents[i].Visible = false
		end
	end

	mainTab.MouseButton1Click:Connect(function()
		switchTab(mainTab, mainContent, {visualTab, combatTab, movementTab}, {visualContent, combatContent, movementContent})
	end)
	visualTab.MouseButton1Click:Connect(function()
		switchTab(visualTab, visualContent, {mainTab, combatTab, movementTab}, {mainContent, combatContent, movementContent})
	end)
	combatTab.MouseButton1Click:Connect(function()
		switchTab(combatTab, combatContent, {mainTab, visualTab, movementTab}, {mainContent, visualContent, movementContent})
	end)
	movementTab.MouseButton1Click:Connect(function()
		switchTab(movementTab, movementContent, {mainTab, visualTab, combatTab}, {mainContent, visualContent, combatContent})
	end)

	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.Insert then
			main.Visible = not main.Visible
		end
	end)

	-- Footer
	local footer = Instance.new("TextLabel")
	footer.Size = UDim2.new(1, 0, 0, 22)
	footer.Position = UDim2.new(0, 0, 1, -22)
	footer.BackgroundTransparency = 1
	footer.Text = "📢 Official Channel: t.me/rbxlcheats"
	footer.TextColor3 = Color3.fromRGB(180, 220, 180)
	footer.TextSize = 12
	footer.Font = Enum.Font.Gotham
	footer.Parent = main

	self.MainGUI = main
end

-- ==================== UI HELPERS ====================
function AR2Tool:CreateTab(name, index, parent, active)
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(0.24, -5, 1, 0)
	tab.Position = UDim2.new(0.25 * index, 0, 0, 0)
	tab.Text = name
	tab.BackgroundColor3 = active and Color3.fromRGB(60, 100, 60) or Color3.fromRGB(30, 60, 30)
	tab.TextColor3 = Color3.fromRGB(250, 255, 240)
	tab.TextSize = 12
	tab.Font = Enum.Font.GothamBold
	tab.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = tab

	return tab
end

function AR2Tool:CreateMainTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	local keyInput = Instance.new("TextBox")
	keyInput.Size = UDim2.new(0.55, 0, 0, 36)
	keyInput.Position = UDim2.new(0.22, 0, 0, 20)
	keyInput.PlaceholderText = "Enter activation key..."
	keyInput.Text = ""
	keyInput.BackgroundColor3 = Color3.fromRGB(30, 60, 30)
	keyInput.TextColor3 = Color3.fromRGB(250, 255, 240)
	keyInput.Parent = content

	local activateBtn = Instance.new("TextButton")
	activateBtn.Size = UDim2.new(0.28, 0, 0, 36)
	activateBtn.Position = UDim2.new(0.68, 0, 0, 20)
	activateBtn.Text = "⚡ ACTIVATE"
	activateBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
	activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	activateBtn.TextSize = 12
	activateBtn.Font = Enum.Font.GothamBold
	activateBtn.Parent = content

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -20, 0, 190)
	infoLabel.Position = UDim2.new(0, 10, 0, 70)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Apocalypse Rising 2 • New Year Edition\n\n✨ Features:\n• Player ESP (1500m)\n• Zombie/Boss Highlight\n• Real Aimbot (on click)\n• No Recoil & No Reload\n• Fly & NoClip\n• Falling snow UI effect\n\n⚠️ HIGH-RISK functions show warnings"
	infoLabel.TextColor3 = Color3.fromRGB(230, 250, 230)
	infoLabel.TextSize = 12
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.Parent = content

	activateBtn.MouseButton1Click:Connect(function()
		local key = keyInput.Text:upper():gsub("%s+", "")
		if key == "" then return end
		local success, message = KeySystem:Validate(key)
		if success then
			keyInput.Visible = false
			activateBtn.Visible = false
			infoLabel.Text = "✅ " .. message .. "\n\n🎄 Happy New Year!\n\n🔫 All features unlocked!\nAR2 CHEATS • " .. self.Version
		else
			infoLabel.Text = "❌ " .. message .. "\n\n🔑 Key: AR2-WARZONE-FREE\n📢 t.me/rbxlcheats"
		end
	end)

	return content
end

function AR2Tool:CreateVisualTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	self:CreateFeatureButton("🔴 Player ESP (1500m)", "See players through walls", 10, 10, content, function()
		self:ToggleESP()
	end)

	self:CreateFeatureButton("🧟 Zombie Highlight", "Red boxes on all zombies/bosses", 10, 60, content, function()
		self:ToggleZombieESP()
	end)

	return content
end

function AR2Tool:CreateCombatTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	self:CreateFeatureButton("🎯 Aimbot (Click)", "Auto-aim at players & zombies", 10, 10, content, function()
		self:ToggleAimbot()
	end)

	self:CreateFeatureButton("🔄 No Recoil", "Zero weapon kickback", 10, 60, content, function()
		self:ToggleNoRecoil()
	end)

	self:CreateFeatureButton("🔄 No Reload", "Infinite ammo, no reload", 10, 110, content, function()
		self:ToggleNoReload()
	end)

	return content
end

function AR2Tool:CreateMovementTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	self:CreateFeatureButton("🦅 Fly", "Fly over the map", 10, 10, content, function()
		self:ToggleFly()
	end)

	self:CreateFeatureButton("👻 NoClip", "Walk through walls", 10, 60, content, function()
		self:ToggleNoClip()
	end)

	return content
end

function AR2Tool:CreateFeatureButton(name, desc, x, y, parent, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.45, 0, 0, 42)
	btn.Position = UDim2.new(0, x, 0, y)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
	btn.TextColor3 = Color3.fromRGB(250, 255, 240)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 110, 60)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 80, 40)}):Play()
	end)

	btn.MouseButton1Click:Connect(callback)

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 0, 14)
	descLabel.Position = UDim2.new(0, 0, 1, -14)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(190, 230, 190)
	descLabel.TextSize = 9
	descLabel.Font = Enum.Font.Gotham
	descLabel.Parent = btn

	return btn
end

-- ==================== INIT ====================
AntiBan:ProtectScript()

local function init()
	if AR2Tool.GUIInitialized then return end
	AR2Tool.GUIInitialized = true
	AR2Tool:CreateModernUI()
end

if player.Character then
	init()
else
	player.CharacterAdded:Connect(init)
end

print("✅ RBXL CHEATS — Apocalypse Rising 2 " .. AR2Tool.Version .. " loaded!")
print("🎄 New Year Edition with Snow UI!")
print("📢 Official Channel: https://t.me/rbxlcheats")
print("🔑 Key: AR2-WARZONE-FREE")
print("⚠️ Use HIGH-RISK features responsibly!")
print("⌨️ Press Insert to open menu")
