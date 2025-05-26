local PathModule = {}

local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

-- Visualise the waypoints | Wegpunkte visualisieren
local function visualiseWaypoint(waypoint)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Size = Vector3.new(1, 1, 1)
	part.Position = waypoint.Position + Vector3.new(0, 2, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Parent = Workspace
end

-- Follow the path to the goal with visualisation of the waypoints | Verfolge den Weg zum Ziel mit Visualisierung der Wegpunkte
local function followPathVS(humanoid, waypoints)
	for _, waypoint in ipairs(waypoints) do
		visualiseWaypoint(waypoint)
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		humanoid:MoveTo(waypoint.Position)
		humanoid.MoveToFinished:Wait()
	end
end

-- Follow the path to the goal without visualisation of the waypoints | Verfolge den Weg zum Ziel ohne Visualisierung der Wegpunkte
local function followPath(humanoid, waypoints)
	for _, waypoint in ipairs(waypoints) do
		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		humanoid:MoveTo(waypoint.Position)
		humanoid.MoveToFinished:Wait()
	end
end

-- Standard pathfinding without visualisation of the waypoints | Standard-Wegfindung ohne Visualisierung der Wegpunkte
function PathModule.FollowTo(humanoid, startPos, goalPos)
	local path = PathfindingService:CreatePath()

	path.Blocked:Connect(function()
		PathModule.FollowTo(humanoid, humanoid.Parent.PrimaryPart.Position, goalPos)
	end)

	path:ComputeAsync(startPos, goalPos)

	if path.Status == Enum.PathStatus.Success then
		followPath(humanoid, path:GetWaypoints())
	else
		warn("Path not computed successfully:", path.Status)
	end
end

-- Standard pathfinding with visualisation of the waypoints | Standard-Wegfindung mit Visualisierung der Wegpunkte
function PathModule.FollowToVS(humanoid, startPos, goalPos)
	local path = PathfindingService:CreatePath()

	path.Blocked:Connect(function()
		PathModule.FollowToVS(humanoid, humanoid.Parent.PrimaryPart.Position, goalPos)
	end)

	path:ComputeAsync(startPos, goalPos)

	if path.Status == Enum.PathStatus.Success then
		followPathVS(humanoid, path:GetWaypoints())
	else
		warn("Path not computed successfully:", path.Status)
	end
end

return PathModule
