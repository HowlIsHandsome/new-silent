if getgenv().HowlSilent then return getgenv().HowlSilent end

-- // Vars
local Workspace = game.GetService(game, "Workspace")
local Heartbeat = game.GetService(game, "RunService").Heartbeat
local GuiService = game.GetService(game, "GuiService")
local Players = game.GetService(game, "Players")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = game:GetService("Workspace").CurrentCamera
local Mouse = LocalPlayer.GetMouse(LocalPlayer)

-- // Silent Aim Vars
getgenv().HowlSilent = {
    SilentAimEnabled = true,
    ShowFOV = true,
    VisibleCheck = true,
    TeamCheck = true,
    FOV = 15,
    FOVSides, = 12,
    HitChance = 100,
    TargetPart = {"Head", "LowerTorso", "UpperTorso", "RightArm", "LeftArm", "LeftLeg", "RightLeg", "HumandoidRootPart"
    Selected = LocalPlayer,
    BlacklistedTeams = {
        {
            Team = LocalPlayer.Team,
            TeamColor = LocalPlayer.TeamColor,
        },
    },
    BlacklistedPlayers = {LocalPlayer},
    WhitelistedPUIDs = {127207167},
}

-- // Show FOV
local circle = Drawing.new("Circle")
function HowlSilent.updateCircle()
    if (circle) then
        -- // Set Circe Properties
        circle.Transparency = 1
        circle.Visible = HowlSilent["ShowFOV"]
        circle.Thickness = 2
        circle.Color = Color3.fromRGB(0, 0, 0)
        circle.NumSides = 12
        circle.Radius = (HowlSilent["FOV"] * 6) / 2
        circle.Filled = false
        circle.Position = Vector2.new(Mouse.X, Mouse.Y + (GuiService.GetGuiInset(GuiService).Y))

        -- // Return circle
        return circle
    end
end

-- // Custom Functions
setreadonly(math, false); math.chance = function(percentage) local percentage = math.floor(percentage); local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100)/100; return chance <= percentage/100 end; setreadonly(math, true);
setreadonly(table, false); table.loopforeach = function(tbl, func) for index, value in pairs(tbl) do if type(value) == 'table' then table.loopforeach(value, func); elseif type(value) == 'function' then table.loopforeach(debug.getupvalues(value)); else func(index, value); end; end; end; setreadonly(table, true);

-- // Customisable Checking Functions: Is a part visible
function HowlSilent.isPartVisible(Part, PartDescendant)
    -- // Vars
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded.Wait(LocalPlayer.CharacterAdded)
    local Origin = CurrentCamera.CFrame.Position
    local _, OnScreen = CurrentCamera.WorldToViewportPoint(CurrentCamera, Part.Position)

    -- // If Part is on the screen
    if (OnScreen) then
        -- // Vars: Calculating if is visible
        local newRay = Ray.new(Origin, Part.Position - Origin)
        local PartHit, _ = Workspace.FindPartOnRayWithIgnoreList(Workspace, newRay, {Character, CurrentCamera})
        local Visible = (not PartHit or PartHit.IsDescendantOf(PartHit, PartDescendant))

        -- // Return
        return Visible
    end

    -- // Return
    return false
end

-- // Check teams
function HowlSilent.checkTeam(targetPlayerA, targetPlayerB)
    -- // If player is not on your team
    if (targetPlayerA.Team ~= targetPlayerB.Team) then

        -- // Check if team is blacklisted
        for i = 1, #HowlSilent.BlacklistedTeams do
            local v = HowlSilent.BlacklistedTeams

            if (targetPlayerA.Team ~= v.Team and targetPlayerA.TeamColor ~= v.TeamColor) then
                return true
            end
        end
    end

    -- // Return
    return false
end

-- // Check if player is blacklisted
function HowlSilent.checkPlayer(targetPlayer)
    for i = 1, #HowlSilent.BlacklistedPlayers do
        local v = HowlSilent.BlacklistedPlayers[i]

        if (v ~= targetPlayer) then
            return true
        end
    end

    -- // Return
    return false
end

-- // Check if player is whitelisted
function HowlSilent.checkWhitelisted(targetPlayer)
    for i = 1, #HowlSilent.WhitelistedPUIDs do
        local v = HowlSilent.WhitelistedPUIDs[i]

        if (targetPlayer.UserId == v) then
            return true
        end
    end

    -- // Return
    return false
end

-- // Get the Direction, Normal and Material
function HowlSilent.findDirectionNormalMaterial(Origin, Destination, UnitMultiplier)
    if (typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3") then
        -- // Handling
        if (not UnitMultiplier) then UnitMultiplier = 1 end

        -- // Vars
        local Direction = (Destination - Origin).Unit * UnitMultiplier
        local RaycastResult = Workspace.Raycast(Workspace, Origin, Direction)

        if (RaycastResult ~= nil) then
            local Normal = RaycastResult.Normal
            local Material = RaycastResult.Material

            return Direction, Normal, Material
        end
    end

    -- // Return
    return nil
end

-- // Check if silent aim can used
function HowlSilent.checkSilentAim()
    return (rawget(HowlSilent, "SilentAimEnabled") == true and rawget(HowlSilent, "Selected") ~= LocalPlayer)
end

-- // Silent Aim Function
function HowlSilent.getClosestPlayerToCursor()
    -- // Vars
    local ClosestPlayer = nil
    local Chance = math.chance(HowlSilent["HitChance"])
    local ShortestDistance = 1/0

    -- // Chance
    if (not Chance) then 
        HowlSilent["Selected"] = (Chance and LocalPlayer or LocalPlayer)
        
        return (Chance and LocalPlayer or LocalPlayer)
    end

    -- // Loop through all players
    local AllPlayers = Players.GetPlayers(Players)
    for i = 1, #AllPlayers do
        local plr = AllPlayers[i]

        if (not HowlSilent.checkWhitelisted(plr) and HowlSilent.checkPlayer(plr) and plr.Character and plr.Character.PrimaryPart and plr.Character.FindFirstChildWhichIsA(plr.Character, "Humanoid") and plr.Character.FindFirstChildWhichIsA(plr.Character, "Humanoid").Health > 0) then
            -- // Team Check
            if (HowlSilent["TeamCheck"] and not HowlSilent.checkTeam(plr, LocalPlayer)) then break end

            -- // Vars
            local PartPos, OnScreen = CurrentCamera.WorldToViewportPoint(CurrentCamera, plr.Character.PrimaryPart.Position)
            local Magnitude = (Vector2.new(PartPos.X, PartPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

            -- // Check if is in FOV
            if (Magnitude < (HowlSilent["FOV"] * 6 - 8)) and (Magnitude < ShortestDistance) then
                -- // Check if Visible
                if (HowlSilent["VisibleCheck"] and HowlSilent.isPartVisible(plr.Character.PrimaryPart, plr.Character)) or (not HowlSilent["VisibleCheck"]) then
                    ClosestPlayer = plr
                    ShortestDistance = Magnitude
                end
            end
        end
    end

    -- // End
    HowlSilent["Selected"] = (Chance and ClosestPlayer or LocalPlayer)
    return (Chance and ClosestPlayer or LocalPlayer)
end

-- // Heartbeat Function
local HBFuncs = function()
    HowlSilent.updateCircle()
    HowlSilent.getClosestPlayerToCursor()
end
Heartbeat.Connect(Heartbeat, HBFuncs)

return HowlSilent
