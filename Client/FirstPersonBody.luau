local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
-- Wait for character to load or get it if already loaded | Warte darauf, dass der Charakter geladen wird oder hole ihn, falls er schon da ist
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Initial camera offset (moves camera backward a bit) | Anfangs-Kamera-Versatz (bewegt die Kamera etwas nach hinten)
humanoid.CameraOffset = Vector3.new(0, 0, -0.75)

local head = character:WaitForChild("Head")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Target and current offset for smooth camera movement | Ziel- und aktueller Versatz für sanfte Kamerabewegung
local targetOffset = Vector3.new(0, 0, -0.75)
local currentOffset = Vector3.new(0, 0, -0.75)

-- Make all parts (except head) keep their transparency consistent locally | Alle Teile (außer Kopf) behalten ihre Transparenz lokal konstant
for _, part in ipairs(character:GetChildren()) do
	if part:IsA("BasePart") and part.Name ~= "Head" then
		part.LocalTransparencyModifier = part.Transparency
		-- If LocalTransparencyModifier changes, reset it to the part's transparency | Wenn LocalTransparencyModifier sich ändert, setze ihn zurück zur ursprünglichen Transparenz
		part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			part.LocalTransparencyModifier = part.Transparency
		end)
	end
end

-- Set up raycast to ignore the character itself | Raycast so einstellen, dass der Charakter selbst ignoriert wird
local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = {character}
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- Linear interpolation between two Vector3 values for smooth movement | Lineare Interpolation zwischen zwei Vector3-Werten für sanfte Bewegung
local function lerpVec3(a, b, t)
	return a + (b - a) * t
end

-- Runs every frame before rendering, smooth camera offset adjustment to avoid clipping | Wird in jedem Frame vor dem Rendern ausgeführt, passt den Kamera-Versatz sanft an, um Clipping zu verhindern
RunService.PreRender:Connect(function(dt)	
	local origin = head.Position
	-- Get horizontal direction player is looking at (ignore vertical) | Horizontale Blickrichtung des Spielers holen (vertikale ignorieren)
	local flatLook = rootPart.CFrame.LookVector
	flatLook = Vector3.new(flatLook.X, 0, flatLook.Z).Unit

	-- Raycast forward 2 studs to check for obstacles in front of the head | Raycast 2 Studs nach vorne, um Hindernisse vor dem Kopf zu erkennen
	local result = workspace:Raycast(origin, flatLook * 2, rayParams)

	if result then
		-- Calculate distance to obstacle, clamp it between 0.5 and 2 studs | Abstand zum Hindernis berechnen, auf 0.5 bis 2 Studs begrenzen
		local dist = (origin - result.Position).Magnitude
		-- Adjust camera offset backward based on obstacle distance to prevent clipping | Kamera-Versatz basierend auf Abstand anpassen, um Clipping zu vermeiden
		targetOffset = Vector3.new(0, 0, -math.clamp(dist, 0.5, 2))
	else
		-- No obstacle close, use default offset | Kein nahes Hindernis, Standard-Versatz verwenden
		targetOffset = Vector3.new(0, 0, -0.75)
	end

	-- Smoothly move current offset towards target offset for nicer camera movement | Aktuellen Versatz sanft zum Zielversatz bewegen für bessere Kamerabewegung
	currentOffset = lerpVec3(currentOffset, targetOffset, 0.15)
	humanoid.CameraOffset = currentOffset
end)
