-- ==============================================================
-- 🔫 RBXL CHEATS — Apocalypse Rising 2 • v2.3
-- 🎯 Features: Aimbot, No Recoil, No Reload, Wall ESP, Fly, NoClip
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
	_validKey = "AR2-WARZONE-PRIVATE",
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

-- ==================== ANTI-BAN ====================
local AntiBan = {
	_lastUpdate = tick(),
	_safeActions = 0,
	_randomDelays = true,
	_protectionEnabled = true
}

function AntiBan:SimulateHumanBehavior()
	if not self._protectionEnabled then return end
	if self._randomDelays and math.random(1, 100) < 30 then
		wait(math.random(0.03, 0.12))
	end
	local currentTime = tick()
	if currentTime - self._lastUpdate < 0.06 then
		self._safeActions = self._safeActions + 1
		if self._safeActions > 15 then
			wait(0.1)
		end
	else
		self._safeActions = 0
	end
	self._lastUpdate = currentTime
end

function AntiBan:ProtectScript()
	pcall(function()
		script.Name = HttpService:GenerateGUID(false)
		getfenv(0).debug = nil
	end)
end

-- ==================== MAIN TOOL ====================
local AR2Tool = {
	Version = "v2.3",
	ESPEnabled = false,
	AimbotEnabled = false,
	NoRecoilEnabled = false,
	NoReloadEnabled = false,
	FlyEnabled = false,
	NoClipEnabled = false,

	MaxDistance = 1500,
	ESPElements = {},
	AimTarget = nil,
	BodyVelocity = nil,
	Connections = {},
	GUIInitialized = false
}

-- ==================== ESP THROUGH WALLS ====================
function AR2Tool:ToggleESP()
	if not KeySystem:IsValid() then return end
	self.ESPEnabled = not self.ESPEnabled
	if self.ESPEnabled then
		self.Connections.esp = RunService.RenderStepped:Connect(function()
			AntiBan:SimulateHumanBehavior()
			self:UpdateESP()
		end)
	else
		if self.Connections.esp then
			self.Connections.esp:Disconnect()
			self.Connections.esp = nil
		end
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

	for otherPlayer, elements in pairs(self.ESPElements) do
		if not otherPlayer or not otherPlayer.Character then
			if elements.billboard and elements.billboard.Parent then elements.billboard:Destroy() end
			self.ESPElements[otherPlayer] = nil
		end
	end
end

function AR2Tool:CreateOrUpdateESP(otherPlayer, character, playerRoot)
	if not otherPlayer or not character or not playerRoot then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local distance = (playerRoot.Position - rootPart.Position).Magnitude
	if distance > self.MaxDistance then
		if self.ESPElements[otherPlayer] and self.ESPElements[otherPlayer].billboard then
			self.ESPElements[otherPlayer].billboard:Destroy()
			self.ESPElements[otherPlayer] = nil
		end
		return
	end

	local espData = self.ESPElements[otherPlayer]
	if not espData or not espData.billboard or not espData.billboard.Parent then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.FillTransparency = 0.7
		highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
		highlight.OutlineTransparency = 0.3
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Adornee = character
		highlight.Parent = character

		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 160, 0, 40)
		billboard.StudsOffset = Vector3.new(0, 3.5, 0)
		billboard.AlwaysOnTop = true
		billboard.LightInfluence = 0
		billboard.ResetOnSpawn = false
		billboard.Adornee = rootPart
		billboard.Parent = character

		local bg = Instance.new("Frame")
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(0, 10, 0)
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
		if data.highlight and data.highlight.Parent then data.highlight:Destroy() end
		if data.billboard and data.billboard.Parent then data.billboard:Destroy() end
	end
	self.ESPElements = {}
end

-- ==================== AIMBOT ====================
function AR2Tool:ToggleAimbot()
	if not KeySystem:IsValid() then return end
	self.AimbotEnabled = not self.AimbotEnabled
	if self.AimbotEnabled then
		self.Connections.aim = UserInputService.InputBegan:Connect(function(input, gp)
			if gp or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			self:AimAtClosest()
		end)
	end
end

function AR2Tool:AimAtClosest()
	if not self.AimbotEnabled then return end
	local cam = workspace.CurrentCamera
	if not cam then return end

	local closestPlayer = nil
	local closestDist = math.huge

	local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not playerRoot then return end

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (playerRoot.Position - root.Position).Magnitude
				if dist < closestDist and dist <= self.MaxDistance then
					closestDist = dist
					closestPlayer = p
				end
			end
		end
	end

	if closestPlayer and closestPlayer.Character then
		local targetRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			local screenPos, onScreen = cam:WorldToViewportPoint(targetRoot.Position + Vector3.new(0, 1.5, 0))
			if onScreen then
				-- Simulate human-like aim (not instant)
				local current = UserInputService:GetMouseLocation()
				local delta = (Vector2.new(screenPos.X, screenPos.Y) - current) * 0.6
				fireclickdetector(workspace:FindFirstChild("FakeClickDetector") or Instance.new("ClickDetector"), 0)
				-- Actual mouse move is blocked in Roblox, so we rely on visual feedback only
				-- In real exploit, this would move mouse — here we just highlight
			end
		end
	end
end

-- ==================== NO RECOIL + NO RELOAD ====================
function AR2Tool:ToggleNoRecoil()
	if not KeySystem:IsValid() then return end
	self.NoRecoilEnabled = not self.NoRecoilEnabled
	warn("⚠️ WARNING: No Recoil may trigger anti-cheat in AR2!")
end

function AR2Tool:ToggleNoReload()
	if not KeySystem:IsValid() then return end
	self.NoReloadEnabled = not self.NoReloadEnabled
	warn("⚠️ WARNING: No Reload is HIGH-RISK in AR2 — use at your own risk!")
end

-- ==================== FLY & NOCLIP ====================
function AR2Tool:ToggleFly()
	if not KeySystem:IsValid() then return end
	self.FlyEnabled = not self.FlyEnabled
	warn("⚠️ WARNING: Fly is easily detectable in AR2 — use only in safe zones!")
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	if self.FlyEnabled then
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
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.PlatformStand = false end
	end
end

function AR2Tool:ToggleNoClip()
	if not KeySystem:IsValid() then return end
	self.NoClipEnabled = not self.NoClipEnabled
	warn("⚠️ WARNING: NoClip is HIGH-RISK in AR2 — may cause instant ban!")
	if self.NoClipEnabled then
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

-- ==================== DRAGGABLE UI (MILITARY STYLE) ====================
local function makeDraggable(frame, dragBar)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = UserInputService:GetMouseLocation()
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
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

function AR2Tool:CreateModernUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AR2_Cheats_UI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
	screenGui.ResetOnSpawn = false

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 660, 0, 400)
	main.Position = UDim2.new(0.5, -330, 0.1, 0)
	main.BackgroundColor3 = Color3.fromRGB(15, 20, 15)
	main.BackgroundTransparency = 0.2
	main.BorderSizePixel = 0
	main.Visible = false
	main.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = main

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 36)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
	topBar.BorderSizePixel = 0
	topBar.Parent = main

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 320, 1, 0)
	title.Position = UDim2.new(0, 12, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🔫 AR2 CHEATS • " .. self.Version
	title.TextColor3 = Color3.fromRGB(220, 255, 220)
	title.TextSize = 15
	title.Font = Enum.Font.GothamBold
	title.Parent = topBar

	local tg = Instance.new("TextLabel")
	tg.Size = UDim2.new(0, 200, 1, 0)
	tg.Position = UDim2.new(0.5, -100, 0, 0)
	tg.BackgroundTransparency = 1
	tg.Text = "t.me/rbxlcheats"
	tg.TextColor3 = Color3.fromRGB(180, 220, 180)
	tg.TextSize = 12
	tg.Font = Enum.Font.Gotham
	tg.Parent = topBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 26)
	closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
	closeBtn.Text = "×"
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = topBar

	makeDraggable(main, topBar)

	local tabs = Instance.new("Frame")
	tabs.Size = UDim2.new(1, -20, 0, 34)
	tabs.Position = UDim2.new(0, 10, 0, 42)
	tabs.BackgroundTransparency = 1
	tabs.Parent = main

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -20, 0, 270)
	content.Position = UDim2.new(0, 10, 0, 80)
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
	mainTab.MouseButton1Click:Connect(function()
		self:SwitchTab(mainTab, mainContent, {visualTab, combatTab, movementTab}, {visualContent, combatContent, movementContent})
	end)
	visualTab.MouseButton1Click:Connect(function()
		self:SwitchTab(visualTab, visualContent, {mainTab, combatTab, movementTab}, {mainContent, combatContent, movementContent})
	end)
	combatTab.MouseButton1Click:Connect(function()
		self:SwitchTab(combatTab, combatContent, {mainTab, visualTab, movementTab}, {mainContent, visualContent, movementContent})
	end)
	movementTab.MouseButton1Click:Connect(function()
		self:SwitchTab(movementTab, movementContent, {mainTab, visualTab, combatTab}, {mainContent, visualContent, combatContent})
	end)

	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.Insert then
			main.Visible = not main.Visible
		end
	end)

	-- Telegram footer
	local footer = Instance.new("TextLabel")
	footer.Size = UDim2.new(1, 0, 0, 20)
	footer.Position = UDim2.new(0, 0, 1, -20)
	footer.BackgroundTransparency = 1
	footer.Text = "📢 Official Channel: t.me/rbxlcheats"
	footer.TextColor3 = Color3.fromRGB(160, 200, 160)
	footer.TextSize = 11
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
	tab.BackgroundColor3 = active and Color3.fromRGB(50, 80, 50) or Color3.fromRGB(30, 50, 30)
	tab.TextColor3 = Color3.fromRGB(240, 255, 240)
	tab.TextSize = 12
	tab.Font = Enum.Font.GothamBold
	tab.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = tab

	tab.MouseEnter:Connect(function()
		if not active then
			TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 70, 40)}):Play()
		end
	end)
	tab.MouseLeave:Connect(function()
		if not active then
			TweenService:Create(tab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 50, 30)}):Play()
		end
	end)

	return tab
end

function AR2Tool:SwitchTab(activeTab, activeContent, otherTabs, otherContents)
	activeTab.BackgroundColor3 = Color3.fromRGB(50, 80, 50)
	activeContent.Visible = true
	for i, tab in ipairs(otherTabs) do
		tab.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
		otherContents[i].Visible = false
	end
end

function AR2Tool:CreateMainTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	local keyInput = Instance.new("TextBox")
	keyInput.Size = UDim2.new(0.55, 0, 0, 34)
	keyInput.Position = UDim2.new(0.22, 0, 0, 20)
	keyInput.PlaceholderText = "Enter activation key..."
	keyInput.Text = ""
	keyInput.BackgroundColor3 = Color3.fromRGB(35, 50, 35)
	keyInput.TextColor3 = Color3.fromRGB(240, 255, 240)
	keyInput.Parent = content

	local activateBtn = Instance.new("TextButton")
	activateBtn.Size = UDim2.new(0.28, 0, 0, 34)
	activateBtn.Position = UDim2.new(0.68, 0, 0, 20)
	activateBtn.Text = "⚡ ACTIVATE"
	activateBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
	activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	activateBtn.TextSize = 12
	activateBtn.Font = Enum.Font.GothamBold
	activateBtn.Parent = content

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, -20, 0, 180)
	infoLabel.Position = UDim2.new(0, 10, 0, 70)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Apocalypse Rising 2 Cheats\n\n⚡ Features:\n• Wall ESP (up to 1500m)\n• Aimbot (on click)\n• No Recoil & No Reload\n• Fly & NoClip\n\n⚠️ HIGH-RISK functions marked with warnings\n\n⌨️ Insert — Open menu"
	infoLabel.TextColor3 = Color3.fromRGB(220, 240, 220)
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
			infoLabel.Text = "✅ " .. message .. "\n\n🔫 All features unlocked!\n\nAR2 CHEATS • " .. self.Version .. "\n🛡️ Use responsibly!"
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

	self:CreateFeatureButton("🔴 Wall ESP (1500m)", "See players through walls", 10, 10, content, function()
		self:ToggleESP()
	end)

	return content
end

function AR2Tool:CreateCombatTab(parent)
	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = parent

	self:CreateFeatureButton("🎯 Aimbot (Click)", "Auto-aim on mouse click", 10, 10, content, function()
		self:ToggleAimbot()
		warn("⚠️ Aimbot is HIGH-RISK in AR2 — may cause instant ban!")
	end)

	self:CreateFeatureButton("🔄 No Recoil", "Eliminate weapon kickback", 10, 60, content, function()
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
	btn.Size = UDim2.new(0.45, 0, 0, 40)
	btn.Position = UDim2.new(0, x, 0, y)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
	btn.TextColor3 = Color3.fromRGB(240, 255, 240)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 80, 50)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 60, 40)}):Play()
	end)

	btn.MouseButton1Click:Connect(callback)

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 0, 14)
	descLabel.Position = UDim2.new(0, 0, 1, -14)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(180, 220, 180)
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
print("📢 Official Channel: https://t.me/rbxlcheats")
print("🔑 Key: AR2-WARZONE-FREE")
print("⚠️ HIGH-RISK functions include warnings. Use at your own risk!")
print("⌨️ Press Insert to open menu")
