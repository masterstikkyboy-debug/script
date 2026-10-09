local Kittylol = loadstring(game:HttpGet("https://raw.githubusercontent.com/uh-12/Ok/refs/heads/main/Source_KITTYLOL_BLACK_WHITE.txt"))()

local Window = Kittylol:CreateWindow({
    Name = "Kittylol",
    LoadingSubtitle = "by KTL",
    Icon = "cat",
    ToggleUIKeybind = "RightControl",
    Size = UDim2.fromOffset(640, 480),
    MinSize = Vector2.new(480, 360),
    MaxSize = Vector2.new(1000, 700),
    MaxNotifications = 4,
    KeepOnScreen = true,
    OpenButton = { Title = "Kittylol", Icon = "cat" },
    Loading = { Enabled = true, Title = "Kittylol", Text = "Starting", Steps = {"Preparing interface", "Loading icons", "Almost there"}, Duration = 1.6 },
    ConfigurationSaving = { Enabled = true, FolderName = "Kittylol", FileName = "default" },
    Home = {
        Name = "Home",
        Welcome = "Hello, ",
        Stats = {"FPS", "Ping", "Executor", "Game", "Region", "Time"},
        Pages = {
            {
                Name = "Changelog",
                Icon = "scroll-text",
                Entries = {
                    {
                        Title = "Kittylol",
                        Tag = "Latest",
                        Changes = {"Kittylol", "SCRIPT FREE", "#1 BLADE BALL"}
                    }
                }
            },
            {
                Name = "Info",
                Icon = "info",
                Content = "Welcome to Kittylol"
            }
        }
    },
    Parent = game:GetService("CoreGui"),
})
Window:Toggle(true)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StatsService = game:GetService("Stats")
local LocalPlayer = PlayersService.LocalPlayer
local Camera = workspace.CurrentCamera

local T = TweenService
local LP = LocalPlayer
local WS = workspace
local RS = ReplicatedStorage
local UIS = UserInputService
local RunS = RunService
local HS = HttpService
local Stats = StatsService

local flyteBBState = {
    Loaded = false,
    ParryMethod = nil,
    ESPLabels = {},
    ESPConnections = {},
    AbilityActive = {},
    AbilityCooldowns = {},
    AbilityUses = {},
    Connections = {},
    SpamParries = {},
    AutoSpamData = {{}, {0, 0}},
    StatsPeak = {},
    ExtraStats = {},
    StaffDetected = {},
    DetectionState = {
        ForcefieldActive = false,
        Dribble = {phase = "Idle", ball = nil, firedAt = 0},
        DribbleParry = {pending = {}},
        PhantomActive = false,
        FuryActive = false,
        FuryCatch = false,
    },
}
getgenv().FlyteBB_State = flyteBBState

local features = {}
local flags = {}

flags.AutoParryEnabled = false
flags.AutoParryType = "Remote"
flags.SelectedParryType = "Camera"
flags.ParryLoopType = "PreSimulation"
flags.ParryAccuracy = 80
flags.ParryRange = 0
flags.AntiCurveEnabled = true
flags.BackwardsAntiCurveEnabled = true
flags.RandomizedParryAccuracy = false
flags.RandomAccuracyMin = 1
flags.RandomAccuracyMax = 100
flags.CooldownProtectionEnabled = false
flags.AutoAbilityEnabled = false
flags.AutoSpamEnabled = false
flags.AutoSpamType = "Remote"
flags.AutoSpamAnimFix = true
flags.AutoSpamAnimFixType = "Animation"
flags.AutoSpamThreshold = 2
flags.DynamicSpamThreshold = false
flags.ManualSpamEnabled = false
flags.ManualSpamType = "Remote"
flags.ManualSpamAnimFix = true
flags.ManualSpamAnimFixType = "Animation"
flags.TriggerbotEnabled = false
flags.TriggerbotType = "Remote"
flags.TriggerbotDelay = 0
flags.TriggerbotRandomize = false
flags.TriggerbotDelayMin = 0
flags.TriggerbotDelayMax = 200
flags.TriggerbotIgnoreSpawn = false
flags.AutoPreclickEnabled = false
flags.PreclickForAll = false
flags.PreclickAfterVelocity = 0
flags.PreclickDelay = 135
flags.FuryDetection = false
flags.FurySpamHit = false
flags.FuryParryAmount = 35
flags.FuryParryDelay = 0.05
flags.FuryParryMethod = "Remote"
flags.InfinityDetection = false
flags.DeathSlashDetection = false
flags.DeathSlashMinigame = false
flags.SingularityDetection = false
flags.TimeHoleDetection = false
flags.FreezeDetection = false
flags.ForcefieldDetection = false
flags.ParryOnDribble = false
flags.DribbleDetection = false
flags.AntiPhantomEnabled = false
flags.AntiPhantomBlatant = false
flags.AntiPhantomType = "Spam"
flags.AntiFlashCounterEnabled = false
flags.AntiFlashCounterBlatant = false
flags.AntiFlashCounterType = "Spam"
flags.AntiBlindness = false
flags.AntiDisorientate = false
flags.HitFreeze = false
flags.SpamJump = false

local smallest = WS:WaitForChild("Alive")
local newRoot = WS:WaitForChild("Runtime")
local playerGui = WS:WaitForChild("Balls")
local TrainingGui = WS:FindFirstChild("TrainingBalls")
local newCharacter = LP:WaitForChild("PlayerGui")

local Data = nil
pcall(function()
    Data = require(RS.Packages.Replion).Client:WaitReplion("Data")
end)
if not Data then
    Data = { Get = function() return nil end, OnChange = function() return { Disconnect = function() end } end }
end

local VIM = Instance.new("VirtualInputManager")
local mouseMap = { MouseButton1 = 0, MouseButton2 = 1, MouseButton3 = 2 }
local blockBind = "F"

local function refreshBlockBind()
    local sel = Data:Get({"Settings", "Keybinds", "Block", "PC"})
    if sel then
        local b1, b2, b3 = sel.Bind1, sel.Bind2, sel.Bind3
        blockBind = (b1 and not mouseMap[b1] and b1) or (b2 and not mouseMap[b2] and b2) or (b3 and not mouseMap[b3] and b3) or b1 or b2 or b3 or "F"
    end
end
refreshBlockBind()

local function simulateClick()
    if UIS.TouchEnabled then
        local vp = WS.CurrentCamera.ViewportSize
        VIM:SendTouchEvent(10, 0, vp.X / 2, vp.Y / 2)
        VIM:SendTouchEvent(10, 2, vp.X / 2, vp.Y / 2)
        return true
    end
    local mouseIdx = mouseMap[blockBind]
    if mouseIdx then
        VIM:SendMouseButtonEvent(0, 0, mouseIdx, true, game, 0)
        VIM:SendMouseButtonEvent(0, 0, mouseIdx, false, game, 0)
        return true
    end
    local keyCode = Enum.KeyCode[blockBind]
    if not keyCode then return false end
    VIM:SendKeyEvent(true, keyCode, false, game)
    VIM:SendKeyEvent(false, keyCode, false, game)
    return true
end

local managerInstance = setmetatable({}, {__mode = "k"})
local managerObject = setmetatable({}, {__mode = "k"})
local latestPingMs = 0

task.spawn(function()
    while true do
        local ok, v = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok and type(v) == "number" then latestPingMs = v end
        task.wait(0.1)
    end
end)

local function getPing()
    return latestPingMs > 0 and latestPingMs or (LP:GetNetworkPing() * 1000)
end

local function executeFunction(line)
    if line then
        line = line:IsA("BasePart") and line or (line:IsA("Model") and line.PrimaryPart) or line:FindFirstChild("Body")
    end
    return line
end

local function redoFunction(line, object)
    local st = managerInstance[line]
    if not st then
        local p = object or executeFunction(line)
        st = p and managerInstance[p]
    end
    if st and (os.clock() - (st.UpdatedAt or 0)) <= 0.2 then
        return st.Position
    end
end

local function unexecuteFunction(line)
    return redoFunction(line) or (executeFunction(line) and executeFunction(line).Position) or Vector3.zero
end

local function index4(line)
    local lv = line and line:FindFirstChild("zoomies")
    if lv then return lv.VectorVelocity end
    local v = line and line:GetAttribute("Velocity")
    return typeof(v) == "Vector3" and v or Vector3.zero
end

local function index5(line)
    if line then
        if line:IsA("BasePart") and line:GetAttribute("realBall") then return true end
        if line:IsA("Model") and line:FindFirstChild("Body") then return true end
    end
    return false
end

local function index6(line)
    return line and line:IsA("Model") and line:FindFirstChild("Body") and not line:FindFirstChild("zoomies")
end

local function index7(line)
    local st = managerObject[line]
    if not st then
        st = {Parried = false, ParryResetAt = 0, Target = nil, LoopTarget = nil}
        managerObject[line] = st
    end
    return st
end

local function compareFunction(line)
    local attr = line and line:GetAttribute("target")
    if attr and attr ~= "" then return attr end
    local tAttach = line and line:FindFirstChild("TargetAttachment")
    local other = tAttach and tAttach.Value and tAttach.Value:FindFirstAncestorWhichIsA("Model")
    while other and other:FindFirstChild("ActualCharacter") do
        other = other.ActualCharacter.Value
    end
    return other and other.Name
end

local function is_model_targeting_me(model)
    local wl = model:FindFirstChild("CollisionWhitelist")
    return wl and wl.Value == LP.Character
end

features.Curve = {Random = Random.new()}

features.Curve.GetCFrame = function(line, object)
    local curveType = flags.SelectedParryType or "Camera"
    local camCFrame = Camera.CFrame
    if curveType == "Camera" or curveType == "BB Camera" then
        return camCFrame
    end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return camCFrame end
    if curveType == "Randomized Backwards" then
        local cframe = root.CFrame
        local ang = features.Curve.Random:NextNumber(0, math.pi * 2)
        local rad = features.Curve.Random:NextNumber(0.2, 0.7)
        local up = cframe.UpVector
        return CFrame.lookAt(root.Position, root.Position + (-cframe.LookVector + (cframe.RightVector * math.cos(ang) + up * math.sin(ang)) * rad).Unit * 10000)
    end
    if curveType == "Backwards" then
        local d = -camCFrame.LookVector * 10000
        return CFrame.new(camCFrame.Position, camCFrame.Position + Vector3.new(d.X, 0, d.Z))
    end
    line = line or features.Player.GetClosest()
    if line then
        line = line:IsA("BasePart") and line or line.PrimaryPart or line:FindFirstChild("HumanoidRootPart")
    end
    if line and object then
        local sp = Camera:WorldToScreenPoint(line.Position)
        object[1] = sp.X
        object[2] = sp.Y
    end
    if curveType == "Stop" then
        return CFrame.new(root.Position, root.Position + Vector3.new(0, -3500, 0))
    end
    if curveType == "Random" then
        local rel = line and (line.Position - root.Position) or camCFrame.LookVector
        if rel.Magnitude < 0.001 then return camCFrame end
        local dir = rel.Unit
        local orth = dir:Cross(math.abs(dir.Y) < 0.9 and Vector3.new(0, 1, 0) or Vector3.new(1, 0, 0)).Unit
        local orth2 = orth:Cross(dir)
        local ang = features.Curve.Random:NextNumber(0, math.pi * 2)
        return CFrame.new(root.Position, root.Position + (orth * math.cos(ang) + orth2 * math.sin(ang) - dir * features.Curve.Random:NextNumber(0.25, 0.8)).Unit * 1500)
    end
    if curveType == "High" then
        return CFrame.new(root.Position, root.Position + Vector3.new(0, 9e18, 0))
    end
    if not line then return root.CFrame end
    local targetPos = line.Position
    if curveType == "Straight" then
        return CFrame.new(root.Position, targetPos + Vector3.new(0, 10, 0))
    end
    if curveType == "Dot" then
        return (targetPos - root.Position).Magnitude > 0.001 and CFrame.lookAt(root.Position, targetPos) or root.CFrame
    end
    return root.CFrame
end

features.Parry = {}
local parrySignal = nil

local function initParrySignal()
    if parrySignal then return true end
    local ok1, signal = pcall(function()
        return require(RS.Packages.Signal)
    end)
    if not ok1 or not signal then return false end
    local ctrl = nil
    for _, c in ipairs(RS.Controllers:GetChildren()) do
        if c.Name:find("SwordsController", 1, true) == 1 then
            ctrl = c
            break
        end
    end
    if not ctrl then return false end
    local pry = ctrl:FindFirstChild("PRY")
    if not pry then return false end
    local ok2, fn = pcall(require, pry)
    if not ok2 or type(fn) ~= "function" then return false end
    parrySignal = signal.new()
    parrySignal:Connect(fn)
    return true
end

features.Parry.NativeClick = function() return simulateClick() end

local function vectorLength(lines, sourceTable, needClosest)
    lines = lines or {}
    sourceTable = sourceTable or {0, 0}
    table.clear(lines)
    local char = LP.Character
    local mouse
    if UIS.TouchEnabled then
        local vp = Camera.ViewportSize
        mouse = Vector2.new(vp.X / 2, vp.Y / 2)
    else
        mouse = UIS:GetMouseLocation()
    end
    sourceTable[1] = mouse.X
    sourceTable[2] = mouse.Y
    local alive = smallest and smallest.Parent and smallest or WS:FindFirstChild("Alive")
    if not alive then return lines, sourceTable end
    local bestDist = math.huge
    local closest
    for _, model in pairs(alive:GetChildren()) do
        if model ~= char then
            local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
            if root then
                local sp, onScreen = Camera:WorldToScreenPoint(root.Position)
                lines[model.Name] = sp
                if needClosest and onScreen then
                    local dx = sp.X - mouse.X
                    local dy = sp.Y - mouse.Y
                    local d = dx * dx + dy * dy
                    if d < bestDist then
                        bestDist = d
                        closest = model
                    end
                end
            end
        end
    end
    return lines, sourceTable, closest
end

features.Parry.GetData = function(line, object)
    local neighbors = object or {{}, {0, 0}}
    local slider, sourceTable, closest = vectorLength(neighbors[1], neighbors[2], not line)
    line = line or features.Curve.GetCFrame(closest, sourceTable)
    neighbors[1] = slider
    neighbors[2] = sourceTable
    neighbors[3] = line
    return neighbors
end

features.Parry.Fire = function(line, object, descendant, radius)
    if not initParrySignal() then return false end
    local char = LP.Character
    local slider, sourceTable
    if descendant then
        slider = descendant[1]
        sourceTable = descendant[2]
        line = descendant[3]
    else
        local closest
        slider, sourceTable, closest = vectorLength(nil, nil, not line)
        line = line or features.Curve.GetCFrame(closest, sourceTable)
    end
    local timing = 0.5
    local cframe = line
    radius = radius or 1
    local target = slider
    local coords = sourceTable
    if UIS.TouchEnabled then
        timing = 0.5
        cframe = WS.CurrentCamera and WS.CurrentCamera.CFrame or line
        target = {}
        coords = {0, 0}
    end
    local ok = pcall(function()
        for k = 1, radius do
            parrySignal:Fire(timing, cframe, target, coords, false)
        end
    end)
    return ok
end

features.Animation = {}
pcall(function()
    features.Animation.Controller = require(RS.Controllers.AnimationController)
    features.Animation.SwordAPI = require(RS.Shared.SwordAPI)
end)

features.Animation.Reset = function() end
features.Animation.GetSword = function(line)
    return line and line:GetAttribute("CurrentlyEquippedSword") or LP:GetAttribute("CurrentlyEquippedSword")
end
features.Animation.VIM = function(line) return simulateClick() end
features.Animation.Input = function(line, object)
    flyteBBState.ParryMethod = "VIM"
    if line ~= "Mouse Click" then return features.Animation.VIM(object) end
    return simulateClick()
end
features.Animation.PlayAnimation = function() return features.Animation.VIM() end
features.Animation.BypassCooldown = function() end

features.Player = {}
features.Player.GetClosest = function()
    local char = LP.Character
    if not char or not char.PrimaryPart or not smallest then return nil end
    local best, bestDist = nil, math.huge
    for _, c in smallest:GetChildren() do
        if c ~= char then
            local root = c.PrimaryPart or c:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (char.PrimaryPart.Position - root.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = c
                end
            end
        end
    end
    return best
end

features.Ball = {List = {}, TrainingList = {}}

function features.Ball.GetAllBalls()
    local char = LP.Character
    return (char and char.Parent ~= smallest and features.Ball.TrainingList) or features.Ball.List
end

function features.Ball.GetFirstBall()
    local folder = WS:FindFirstChild("Balls")
    if not folder then return nil end
    for _, c in ipairs(folder:GetChildren()) do
        if index5(c) then return c end
    end
    for _, c in ipairs(folder:GetChildren()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

function features.Ball.GetMainBall()
    local list = features.Ball.GetAllBalls()
    local char = LP.Character
    local rootPos = char and char.PrimaryPart and char.PrimaryPart.Position
    local best, bestMetric, bestDist = nil, nil, nil
    for _, b in pairs(list) do
        if b and b.Parent then
            if compareFunction(b) == LP.Name or is_model_targeting_me(b) then
                if not rootPos then return b end
                local bp = unexecuteFunction(b)
                local d = (bp - rootPos).Magnitude
                local vel = index4(b)
                local dot = (bp - rootPos):Dot(vel)
                local metric = dot > 0 and (d * d / dot) or math.huge
                if not best or metric < bestMetric or (metric == bestMetric and d < bestDist) then
                    best = b
                    bestMetric = metric
                    bestDist = d
                end
            end
        end
    end
    return best
end

features.Detection = {}

local function refreshForcefieldDetection()
    local c = LP.Character
    if not c then
        flyteBBState.DetectionState.ForcefieldActive = false
        return
    end

    local equipped = LP:GetAttribute("CurrentlyEquippedAbility") or c:GetAttribute("CurrentlyEquippedAbility")
    if type(equipped) ~= "string" then
        flyteBBState.DetectionState.ForcefieldActive = false
        return
    end

    equipped = equipped:lower():gsub("%s+", "")
    flyteBBState.DetectionState.ForcefieldActive =
        equipped == "forcefield" and c:GetAttribute("AbilityActive") == true
end

features.Detection.BlocksParry = function(line, object, descendant)
    local root = descendant or (object and object:FindFirstChild("HumanoidRootPart"))
    if not root then return true end

    local ds = flyteBBState.DetectionState

    if flags.InfinityDetection and flyteBBState.InfinityActive then return true end
    if flags.DeathSlashDetection and flyteBBState.DeathSlash then return true end
    if flags.SingularityDetection and root:FindFirstChild("SingularityCape") then return true end
    if flags.TimeHoleDetection and flyteBBState.TimeHole then return true end
    if flags.FuryDetection and (ds.FuryCatch or ds.FuryActive or flyteBBState.FuryCatch or flyteBBState.FuryActive) then return true end
    if flags.ForcefieldDetection and ds.ForcefieldActive then return true end

    local torn = newRoot:FindFirstChild("Tornado")
    if torn then
        local t = torn:GetAttribute("TornadoTime") or 1
        if os.clock() - (flyteBBState.TornadoAt or 0) < t + 0.314 then
            return true
        end
    end

    if ds.PhantomActive then return true end
    return false
end

features.Detection.ProcessDribble = function()
    local ds = flyteBBState.DetectionState
    local dr = ds.Dribble
    local dp = ds.DribbleParry
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not root then return end

    local ballsFolder = WS:FindFirstChild("Balls")
    if not ballsFolder then return end

    local localName = LP.Name
    local equipped = LP:GetAttribute("CurrentlyEquippedAbility") or char:GetAttribute("CurrentlyEquippedAbility")

    for _, ball in ipairs(ballsFolder:GetChildren()) do
        if not ball:IsA("BasePart") then continue end

        local targeted = ball:GetAttribute("target") == localName
        local dribbleActive = ball:GetAttribute("DribbleActive") == true

        if flags.DribbleDetection and equipped == "Dribble" and targeted and not dribbleActive then
            if dr.phase == "Idle" and os.clock() - (flyteBBState.LastDribbleUse or 0) > 0.75 then
                flyteBBState.LastDribbleUse = os.clock()
                dr.phase = "Pending"
                dr.ball = ball
                dr.firedAt = os.clock()
                pcall(function()
                    local remotes = RS:FindFirstChild("Remotes")
                    local ability = remotes and remotes:FindFirstChild("AbilityButtonPress")
                    if ability then ability:Fire() end
                end)
            end
        end

        if dribbleActive and targeted then
            dr.phase = "Outbound"
            dr.ball = ball
            flyteBBState.LastDribbleSuccess = os.clock()
        elseif dr.ball == ball and dr.phase == "Outbound" and not dribbleActive and targeted then
            dr.phase = "Return"
            flyteBBState.LastDribbleSuccess = os.clock()
            if flags.DribbleDetection then
                pcall(function()
                    attemptAutoParry(ball, flags.AutoParryType, false, true, getPing(), flags.ParryAccuracy)
                end)
            end
            dr.phase = "Idle"
            dr.ball = nil
        end

        if flags.ParryOnDribble and dribbleActive and targeted and not dp.pending[ball] then
            dp.pending[ball] = true
            local delay = tonumber(flyteBBState.DribbleParryDelay or 0) or 0
            if delay <= 0 then
                pcall(function()
                    attemptAutoParry(ball, flags.AutoParryType, false, true, getPing(), flags.ParryAccuracy)
                end)
            else
                task.delay(delay, function()
                    if flags.ParryOnDribble and ball.Parent then
                        pcall(function()
                            attemptAutoParry(ball, flags.AutoParryType, false, true, getPing(), flags.ParryAccuracy)
                        end)
                    end
                end)
            end
        elseif not dribbleActive then
            dp.pending[ball] = nil
        end
    end

    if dr.phase ~= "Idle" and dr.firedAt > 0 and os.clock() - dr.firedAt > 2 then
        dr.phase = "Idle"
        dr.ball = nil
    end
end

features.Detection.Start = function()
    pcall(function()
        local remotes = RS:FindFirstChild("Remotes")
        if not remotes then return end

        local infinity = remotes:FindFirstChild("InfinityBall")
        if infinity then
            flyteBBState.Connections.Infinity = infinity.OnClientEvent:Connect(function(_, v)
                flyteBBState.InfinityActive = v == true
            end)
        end

        local death = remotes:FindFirstChild("DeathBall")
        if death then
            flyteBBState.Connections["Death Slash"] = death.OnClientEvent:Connect(function(_, v)
                flyteBBState.DeathSlash = v == true
            end)
        end

        local visualCD = remotes:FindFirstChild("VisualCD")
        if visualCD then
            flyteBBState.Connections["Parry Cooldown"] = visualCD.OnClientEvent:Connect(function(_, object)
                if object then
                    flyteBBState.ParryCooldownUntil = os.clock() + 1.3
                else
                    flyteBBState.ParryCooldownUntil = nil
                end
            end)
        end

        local phantom = remotes:FindFirstChild("Phantom")
        local abilityButton = remotes:FindFirstChild("AbilityButtonPress")
        if phantom then
            flyteBBState.Connections.Phantom = phantom.OnClientEvent:Connect(function(_, target)
                if typeof(target) ~= "Instance" or target.Name ~= LP.Name then return end
                if not flags.AntiPhantomEnabled then return end

                local char = LP.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local range = 130
                local closestBall, closestDist
                for _, b in ipairs(features.Ball.GetAllBalls()) do
                    if b and b.Parent then
                        local d = (unexecuteFunction(b) - root.Position).Magnitude
                        if d <= range and (not closestDist or d < closestDist) then
                            closestDist = d
                            closestBall = b
                        end
                    end
                end
                if not closestBall then return end

                flyteBBState.DetectionState.PhantomActive = true

                if flags.AntiPhantomType == "Ability" then
                    if abilityButton then pcall(function() abilityButton:Fire() end) end
                    task.delay(1, function()
                        flyteBBState.DetectionState.PhantomActive = false
                    end)
                else
                    pcall(function()
                        attemptAutoParry(closestBall, flags.AutoParryType, false, true, getPing(), flags.ParryAccuracy)
                    end)
                    root.CFrame = CFrame.new(unexecuteFunction(closestBall))
                    task.delay(0.5, function()
                        flyteBBState.DetectionState.PhantomActive = false
                    end)
                end
            end)
        end

        flyteBBState.Connections.DetectionPlayerAttrs = LP.AttributeChanged:Connect(function(attr)
            if attr == "TimeHoleActivate" or attr == "CurrentlyEquippedAbility" then
                flyteBBState.TimeHole = LP:GetAttribute("TimeHoleActivate") ~= nil
                refreshForcefieldDetection()
            end
        end)
    end)

    local function bindCharacter(character)
        if not character then return end

        local conn = character.AttributeChanged:Connect(function(name)
            if name == "AbilityActive" or name == "CurrentlyEquippedAbility" then
                refreshForcefieldDetection()
            end

            if name == "FuryCatch" then
                flyteBBState.DetectionState.FuryCatch = character:GetAttribute("FuryCatch") ~= nil
                flyteBBState.FuryCatch = flyteBBState.DetectionState.FuryCatch
            elseif name == "AbilityActive" then
                local active = character:GetAttribute("AbilityActive") == true
                local equipped = LP:GetAttribute("CurrentlyEquippedAbility") or character:GetAttribute("CurrentlyEquippedAbility")
                flyteBBState.DetectionState.FuryActive =
                    active and type(equipped) == "string" and equipped:gsub("%s+", ""):lower() == "slashesoffury"
                flyteBBState.FuryActive = flyteBBState.DetectionState.FuryActive
            end
        end)
        flyteBBState.Connections.DetectionCharacterAttrs = conn
        refreshForcefieldDetection()
    end

    if LP.Character then bindCharacter(LP.Character) end
    flyteBBState.Connections.DetectionCharacterAdded = LP.CharacterAdded:Connect(bindCharacter)

    flyteBBState.Connections.FuryLoop = RunS.PreSimulation:Connect(function()
        if not flags.FuryDetection then return end
        if not flyteBBState.DetectionState.FuryCatch then return end
        if not flyteBBState.DetectionState.FuryActive then return end

        local maxParries = math.max(1, math.floor(flyteBBState.FuryMaxParries or 36))
        local delay = math.max(0.01, tonumber(flyteBBState.FuryParryDelay or flags.FuryParryDelay or 0.05) or 0.05)

        if flyteBBState.LastFuryParryAt and os.clock() - flyteBBState.LastFuryParryAt < delay then
            return
        end

        flyteBBState.LastFuryParryAt = os.clock()
        flyteBBState.FuryParryCount = (flyteBBState.FuryParryCount or 0) + 1

        if flyteBBState.FuryParryCount <= maxParries then
            pcall(function()
                attemptAutoParry(nil, flags.AutoParryType, false, true, getPing(), flags.ParryAccuracy)
            end)
        else
            flyteBBState.FuryParryCount = 0
        end
    end)
end

local top, currentDate, elapsedTime = false, nil, 0

local function resetParryState()
    top = false
    currentDate = nil
    elapsedTime = 0
    flyteBBState.AutoBall = nil
    flyteBBState.AutoParryAt = nil
    flyteBBState.ManualBall = nil
    flyteBBState.ExtraParryCooldownUntil = nil
    local balls = playerGui or WS:FindFirstChild("Balls")
    if not balls then return end
    for _, b in balls:GetChildren() do
        if index5(b) then
            local st = index7(b)
            st.Parried = false
            st.ParryResetAt = 0
            st.AutoParryAt = nil
            st.TriggerbotParried = false
        end
    end
end

local function attemptAutoParry(ball, parryType, force, targetIsSelf, ping, accuracy)
    local char = LP.Character
    if not char or not char.PrimaryPart then return false end
    parryType = parryType or flags.AutoParryType
    ball = ball or features.Ball.GetMainBall()
    if not ball and parryType == "Remote" then return false end
    if parryType == "Remote" then
        local cf = nil
        if force then cf = features.Curve.GetCFrame(nil, nil) end
        local ok = features.Parry.Fire(cf)
        if not ok then return features.Animation.VIM() end
    else
        if not features.Animation.Input(parryType) then return false end
    end
    flyteBBState.ParryActiveUntil = os.clock() + 0.5
    return true
end

local function get_premium_parry_distance(speed, acc)
    local ping = getPing()
    local divisor = 0.5 + (math.clamp(acc or flags.ParryAccuracy, 1, 100) - 1) * 0.010101010101010102
    return math.clamp(ping / 10 / 10, 5, 17) + math.max(speed / ((2.4 + math.min(math.max(speed - 9.5, 0), 650) * 0.002) * divisor), 9.5)
end

features.Loop = {}

features.Loop.MainParryLoop = function()
    if not flags.AutoParryEnabled then return end
    if flags.TriggerbotEnabled then return end
    smallest = smallest and smallest.Parent and smallest or WS:FindFirstChild("Alive")
    local char = LP.Character
    if not char or not char.PrimaryPart then return end
    local root = char.PrimaryPart
    local balls = features.Ball.GetAllBalls()
    if #balls == 0 then return end
    local now = os.clock()
    if top and now >= elapsedTime then
        top = false
        currentDate = nil
    end
    local bestBall, bestDist = nil, math.huge
    for _, b in pairs(balls) do
        if b and b.Parent then
            local st = index7(b)
            if st.Parried and now < (st.ParryResetAt or 0) then continue end
            local target = compareFunction(b)
            if target == LP.Name or is_model_targeting_me(b) then
                local bp = unexecuteFunction(b)
                local d = (bp - root.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    bestBall = b
                end
            end
        end
    end
    if not bestBall then return end
    if features.Detection.BlocksParry(bestBall, char, root) then return end
    local vel = index4(bestBall)
    local speed = vel.Magnitude
    local dist = bestDist
    local accuracy = flags.ParryAccuracy
    if flags.RandomizedParryAccuracy then
        local mn = math.clamp(math.floor(math.min(flags.RandomAccuracyMin, flags.RandomAccuracyMax)), 1, 100)
        local mx = math.clamp(math.floor(math.max(flags.RandomAccuracyMin, flags.RandomAccuracyMax)), 1, 100)
        accuracy = math.random(mn, mx)
    end
    local threshold = get_premium_parry_distance(speed, accuracy) + flags.ParryRange
    if dist > threshold then return end
    local st = index7(bestBall)
    st.Parried = true
    st.ParryResetAt = now + 0.6
    st.AutoParryAt = now
    top = true
    currentDate = bestBall
    elapsedTime = st.ParryResetAt
    if not attemptAutoParry(bestBall, flags.AutoParryType, false, true, getPing(), accuracy) then
        st.Parried = false
        st.ParryResetAt = 0
        st.AutoParryAt = nil
        top = false
        currentDate = nil
        elapsedTime = 0
        return
    end
    flyteBBState.AutoParryAt = now
    flyteBBState.AutoBall = bestBall
end

features.Loop.AutoSpamLoop = function()
    if not flags.AutoSpamEnabled and not flags.AntiPhantomEnabled and not flags.AntiFlashCounterEnabled then return end
    local now = os.clock()
    smallest = smallest and smallest.Parent and smallest or WS:FindFirstChild("Alive")
    local char = LP.Character
    local root = char and char.PrimaryPart
    if not root then return end
    local balls = features.Ball.GetAllBalls()
    if #balls == 0 then return end
    local main = features.Ball.GetMainBall() or balls[1]
    if not main then return end
    if features.Detection.BlocksParry(main, char, root) then return end
    local dist = (root.Position - unexecuteFunction(main)).Magnitude
    if dist > 25 then return end
    flyteBBState.AutoSpamAt = now
    if flags.AutoSpamType == "Remote" then
        features.Parry.Fire(nil, true, 0)
        if flags.AutoSpamAnimFix then
            if flags.AutoSpamAnimFixType == "Click" or flags.AutoSpamAnimFixType == "Animation + Click" then
                task.spawn(features.Animation.VIM)
            end
        end
    else
        features.Animation.Input(flags.AutoSpamType, true)
    end
end

features.Loop.ManualSpamLoop = function(line, object, descendant)
    if not flags.ManualSpamEnabled then return end
    if flags.DeathSlashDetection and flyteBBState.DeathSlash then return end
    if flags.ManualSpamType == "Remote" then
        if features.Parry and features.Parry.Fire then
            local ok = features.Parry.Fire(nil, true, line, descendant)
            if ok and flags.ManualSpamAnimFix then
                if flags.ManualSpamAnimFixType == "Click" or flags.ManualSpamAnimFixType == "Animation + Click" then
                    task.spawn(features.Animation.VIM)
                end
            end
            return ok
        end
        return
    end
    return features.Animation.Input(flags.ManualSpamType, true)
end

features.Triggerbot = {}

features.Triggerbot.Fire = function(ball, state)
    local char = LP.Character
    if not char or not char.PrimaryPart then return false end
    local now = os.clock()
    if flyteBBState.ExtraParryCooldownUntil and now < flyteBBState.ExtraParryCooldownUntil then return false end
    local token = {}
    state.TriggerbotParried = token
    state.AutoParryAt = now
    flyteBBState.AutoParryAt = now
    local ok = attemptAutoParry(ball, flags.TriggerbotType, true, true)
    if state.TriggerbotParried == token then state.TriggerbotParried = ok end
    if not ok then
        if state.AutoParryAt == now then state.AutoParryAt = nil end
        if flyteBBState.AutoParryAt == now then flyteBBState.AutoParryAt = nil end
    end
    return ok
end

features.Triggerbot.TryParry = function(ball, state, target)
    if not flags.TriggerbotEnabled or not ball or not ball.Parent then return end
    target = target or compareFunction(ball)
    if state.TriggerbotTarget ~= target then
        state.TriggerbotTarget = target
        state.TriggerbotParried = false
    end
    if target ~= LP.Name and not is_model_targeting_me(ball) then return end
    if state.TriggerbotParried then return end
    if flags.TriggerbotIgnoreSpawn then
        local from = ball:GetAttribute("from")
        if not from or from == "" then return end
    end
    if features.Detection.BlocksParry(ball, LP.Character) then return end
    local delay = flags.TriggerbotDelay
    if flags.TriggerbotRandomize then
        local mn = math.min(flags.TriggerbotDelayMin, flags.TriggerbotDelayMax)
        local mx = math.max(flags.TriggerbotDelayMin, flags.TriggerbotDelayMax)
        delay = math.random(mn, mx)
    end
    if delay <= 0 then
        features.Triggerbot.Fire(ball, state)
        return
    end
    local token = {}
    state.TriggerbotParried = token
    task.delay(delay / 1000, function()
        if state.TriggerbotParried ~= token then return end
        if not flags.TriggerbotEnabled or not ball.Parent then
            state.TriggerbotParried = false
            return
        end
        state.TriggerbotParried = false
        features.Triggerbot.Fire(ball, state)
    end)
end

features.Triggerbot.Update = function()
    if not flags.TriggerbotEnabled then return end
    for _, b in features.Ball.GetAllBalls() do
        features.Triggerbot.TryParry(b, index7(b))
    end
end

local function bindBall(ball, list)
    if not ball or not ball.Parent then return end
    local st = index7(ball)
    st.Parried = false
    st.ParryResetAt = 0
    st.Target = compareFunction(ball)
    st.LoopTarget = st.Target
    local function updateMembership()
        local isBall = index5(ball)
        local idx = table.find(list, ball)
        if isBall and not idx then
            table.insert(list, ball)
            if flyteBBState.Loaded and flags.TriggerbotEnabled then
                features.Triggerbot.TryParry(ball, st)
            end
        elseif not isBall and idx then
            table.remove(list, idx)
        end
    end
    updateMembership()
    ball.ChildAdded:Connect(function(c)
        if c.Name == "zoomies" then st.Zoomies = c end
        updateMembership()
    end)
    ball.ChildRemoved:Connect(function(c)
        if c == st.Zoomies then st.Zoomies = nil end
        updateMembership()
    end)
    ball:GetAttributeChangedSignal("target"):Connect(function()
        st.Parried = false
        st.ParryResetAt = 0
        local newTarget = compareFunction(ball)
        st.Target = newTarget
        if flags.TriggerbotEnabled then features.Triggerbot.TryParry(ball, st) end
        if flags.AutoParryEnabled then task.spawn(features.Loop.MainParryLoop) end
    end)
    ball:GetAttributeChangedSignal("realBall"):Connect(updateMembership)
    local zoomies = ball:FindFirstChild("zoomies")
    if zoomies then st.Zoomies = zoomies end
end

flyteBBState.Connections["BallsWatcher"] = task.spawn(function()
    local ballsFolder = WS:WaitForChild("Balls", 30)
    if ballsFolder then
        for _, c in ballsFolder:GetChildren() do bindBall(c, features.Ball.List) end
        ballsFolder.ChildAdded:Connect(function(c) bindBall(c, features.Ball.List) end)
        ballsFolder.ChildRemoved:Connect(function(c)
            local i = table.find(features.Ball.List, c)
            if i then table.remove(features.Ball.List, i) end
            managerObject[c] = nil
            managerInstance[c] = nil
        end)
    end
    local function watchTraining(folder)
        for _, c in folder:GetChildren() do bindBall(c, features.Ball.TrainingList) end
        folder.ChildAdded:Connect(function(c) bindBall(c, features.Ball.TrainingList) end)
        folder.ChildRemoved:Connect(function(c)
            local i = table.find(features.Ball.TrainingList, c)
            if i then table.remove(features.Ball.TrainingList, i) end
        end)
    end
    local tb = WS:FindFirstChild("TrainingBalls")
    if tb then watchTraining(tb) end
    WS.ChildAdded:Connect(function(c)
        if c.Name == "TrainingBalls" then watchTraining(c) end
    end)
end)

flyteBBState.Connections["PositionUpdater"] = task.spawn(function()
    local net = RS.Packages._Index["sleitnick_net@0.1.0"].net
    for _, pkg in ipairs(net:GetChildren()) do
        if pkg:IsA("UnreliableRemoteEvent") and pkg.Name ~= "URE/ReplicateBallPosition" then
            pkg.OnClientEvent:Connect(function(key, pos)
                if typeof(key) == "Instance" and typeof(pos) == "Vector3" then
                    if key.Parent == playerGui or (TrainingGui and key.Parent == TrainingGui) then
                        local st = managerInstance[key]
                        if not st then
                            st = {}
                            managerInstance[key] = st
                        end
                        st.Position = pos
                        st.UpdatedAt = os.clock()
                    end
                end
            end)
        end
    end
end)

flyteBBState.Connections.Character = LP.CharacterAdded:Connect(function()
    features.Animation.Reset()
    flyteBBState.InfinityActive = false
    flyteBBState.InfinityParried = false
    flyteBBState.TimeHole = false
    flyteBBState.FuryCatch = false
    flyteBBState.FuryActive = false
    flyteBBState.DeathSlash = false
    flyteBBState.DetectionState.ForcefieldActive = false
    flyteBBState.DetectionState.PhantomActive = false
    flyteBBState.DetectionState.FuryActive = false
    flyteBBState.DetectionState.FuryCatch = false
    flyteBBState.DetectionState.Dribble.phase = "Idle"
    flyteBBState.DetectionState.Dribble.ball = nil
    flyteBBState.DetectionState.Dribble.firedAt = 0
    table.clear(flyteBBState.DetectionState.DribbleParry.pending)
    flyteBBState.FuryParryCount = 0
    resetParryState()
end)

pcall(features.Detection.Start)

flyteBBState.Connections["Detection Dribble Loop"] = RunS.PreSimulation:Connect(function()
    pcall(features.Detection.ProcessDribble)
end)

flyteBBState.Connections["Main Parry Loop"] = RunS.PreSimulation:Connect(function()
    pcall(features.Loop.MainParryLoop)
end)
flyteBBState.Connections["Auto Spam Loop"] = RunS.PreSimulation:Connect(function()
    pcall(features.Loop.AutoSpamLoop)
end)
flyteBBState.Connections["Triggerbot Loop"] = RunS.PreSimulation:Connect(function()
    pcall(features.Triggerbot.Update)
end)

local manualSpamConn
local function startManualSpam()
    if manualSpamConn then return end
    manualSpamConn = RunS.PreSimulation:Connect(function()
        pcall(features.Loop.ManualSpamLoop)
    end)
end
local function stopManualSpam()
    if manualSpamConn then
        manualSpamConn:Disconnect()
        manualSpamConn = nil
    end
end


local ImmortalBallState = {
    Enabled = false,
    Distance = 50,
    Height = 15,
    Speed = 100,
    Connection = nil,
    Angle = 0
}

local function getImmortalBall()
    local balls = WS:FindFirstChild("Balls")
    if not balls then return nil end
    for _, ball in ipairs(balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            pcall(function() ball.CanCollide = false end)
            return ball
        end
    end
    return nil
end

local immortalBackgroundOrbitInitialized = false
local immortalBackgroundOrbitState = { Enabled = false }
local immortalBackgroundOrbitHRP = nil
local immortalBackgroundOrbitCharacterConnection = nil

local function startBackgroundOrbit()
    immortalBackgroundOrbitState.Enabled = true

    if immortalBackgroundOrbitInitialized then
        return
    end

    immortalBackgroundOrbitInitialized = true

    local function onCharacter(char)
        immortalBackgroundOrbitHRP = char:WaitForChild("HumanoidRootPart", 5)
    end

    immortalBackgroundOrbitCharacterConnection =
        LP.CharacterAdded:Connect(onCharacter)

    if LP.Character then
        onCharacter(LP.Character)
    end

    local DesyncTypes = {}
    local oldIndexCFrame

    if hookmetamethod and newcclosure then
        oldIndexCFrame = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not immortalBackgroundOrbitState.Enabled or checkcaller() then
                return oldIndexCFrame(self, key)
            end

            if key == "CFrame" and immortalBackgroundOrbitHRP and self == immortalBackgroundOrbitHRP then
                return DesyncTypes[1] or oldIndexCFrame(self, key)
            end

            return oldIndexCFrame(self, key)
        end))
    end

    flyteBBState.Connections["Immortal Orbit"] =
        RunS.Heartbeat:Connect(function()
            if not immortalBackgroundOrbitState.Enabled or not immortalBackgroundOrbitHRP then
                return
            end

            if not immortalBackgroundOrbitHRP.Parent then
                immortalBackgroundOrbitHRP = LP.Character
                    and LP.Character:FindFirstChild("HumanoidRootPart")

                if not immortalBackgroundOrbitHRP then
                    return
                end
            end

            DesyncTypes[1] = immortalBackgroundOrbitHRP.CFrame
            DesyncTypes[2] = immortalBackgroundOrbitHRP.AssemblyLinearVelocity

            local orbitRadius = 20
            local angleMultiplier = 20
            local rotAngle = tick() * math.pi * 2 * angleMultiplier / 5

            local pos = Vector3.new(
                math.cos(rotAngle) * orbitRadius,
                0,
                math.sin(rotAngle) * orbitRadius
            )

            immortalBackgroundOrbitHRP.CFrame = DesyncTypes[1] + pos
            immortalBackgroundOrbitHRP.AssemblyLinearVelocity = Vector3.zero

            RunS.RenderStepped:Wait()

            if immortalBackgroundOrbitState.Enabled and immortalBackgroundOrbitHRP then
                immortalBackgroundOrbitHRP.CFrame = DesyncTypes[1]
                immortalBackgroundOrbitHRP.AssemblyLinearVelocity = DesyncTypes[2]
            end
        end)

    flyteBBState.Connections["Immortal Offset"] =
        RunS.Heartbeat:Connect(function()
            if not immortalBackgroundOrbitState.Enabled then
                return
            end

            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 0.01, 0)
            end
        end)
end

local function stopBackgroundOrbit()
    immortalBackgroundOrbitState.Enabled = false
end

local function stopOrbitBall()
    ImmortalBallState.Enabled = false

    if ImmortalBallState.Connection then
        ImmortalBallState.Connection:Disconnect()
        ImmortalBallState.Connection = nil
    end
end

local function startOrbitBall()
    stopOrbitBall()
    ImmortalBallState.Enabled = true
    ImmortalBallState.Angle = 0

    ImmortalBallState.Connection = RunS.Heartbeat:Connect(function(dt)
        if not ImmortalBallState.Enabled then
            return
        end

        local ball = getImmortalBall()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not ball or not hrp then
            return
        end

        ImmortalBallState.Angle += ImmortalBallState.Speed * dt * 0.2
        local angle = math.rad(ImmortalBallState.Angle)

        local targetPos = ball.Position + Vector3.new(
            math.cos(angle) * ImmortalBallState.Distance,
            ImmortalBallState.Height,
            math.sin(angle) * ImmortalBallState.Distance
        )

        hrp.CFrame = CFrame.lookAt(targetPos, ball.Position)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end)
end

local __KTL_UI_BUILDING = true
local __KTL_HotkeyFeatures = {}
local __KTL_HotkeyByKey = {}
local __KTL_CaptureFeature = nil

local function __KTL_NotifyFeature(name, enabled)
    pcall(function()
        if Window and Window.Notify then
            Window:Notify({
                Title = name,
                Content = enabled and "Enabled" or "Disabled",
                Type = enabled and "Success" or "Info",
                Duration = 1.5
            })
        end
    end)
end

local function __KTL_RegisterFeature(name, callback, state)
    local item = __KTL_HotkeyFeatures[name]
    if not item then
        item = {
            Name = name,
            Callback = callback,
            State = state == true,
            Key = nil,
        }
        __KTL_HotkeyFeatures[name] = item
        table.insert(__KTL_HotkeyFeatures, item)
    else
        item.Callback = callback
        item.State = state == true
    end
    return item
end

local __KTL_OriginalCreateTab = Window.CreateTab
Window.CreateTab = function(self, config)
    local tab = __KTL_OriginalCreateTab(self, config)
    if tab and tab.Toggle then
        local originalToggle = tab.Toggle
        tab.Toggle = function(selfTab, options)
            if type(options) ~= "table" or type(options.Callback) ~= "function" then
                return originalToggle(selfTab, options)
            end
            local originalCallback = options.Callback
            local featureName = tostring(options.Name or "Toggle")
            local wrapped = {}
            for k, v in pairs(options) do
                wrapped[k] = v
            end
            wrapped.Callback = function(v, ...)
                local item = __KTL_RegisterFeature(featureName, originalCallback, v)
                local result = {originalCallback(v, ...)}
                item.State = v == true
                if not __KTL_UI_BUILDING then
                    __KTL_NotifyFeature(featureName, item.State)
                end
                return table.unpack(result)
            end
            local control = originalToggle(selfTab, wrapped)
            local item = __KTL_RegisterFeature(featureName, originalCallback, options.Default == true)
            item.Control = control
            return control
        end
    end
    return tab
end

local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "swords",
    Desc = "Parry / Spam / Triggerbot"
})

CombatTab:Section("Auto Parry")
CombatTab:Toggle({Name = "Auto Parry", Default = false, Flag = "flyte_auto_parry", Callback = function(v)
    flags.AutoParryEnabled = v
    if v then resetParryState() end
end})
CombatTab:Dropdown({Name = "Parry Type", Options = {"Remote", "VIM", "Mouse Click"}, Default = "Remote", Flag = "flyte_parry_type", Callback = function(v) flags.AutoParryType = v end})
CombatTab:Dropdown({Name = "Curve Type", Options = {"Randomized Backwards", "Backwards", "BB Camera", "Camera", "Straight", "Dot", "High", "Random", "Stop"}, Default = "Camera", Flag = "flyte_curve_type", Callback = function(v) flags.SelectedParryType = v end})
CombatTab:Dropdown({Name = "Parry Loop", Options = {"PreSimulation", "PreRender"}, Default = "PreSimulation", Flag = "flyte_parry_loop", Callback = function(v)
    flags.ParryLoopType = v
    if flyteBBState.Connections["Main Parry Loop"] then
        flyteBBState.Connections["Main Parry Loop"]:Disconnect()
    end
    flyteBBState.Connections["Main Parry Loop"] = (v == "PreRender" and RunS.PreRender or RunS.PreSimulation):Connect(function()
        pcall(features.Loop.MainParryLoop)
    end)
end})
CombatTab:Slider({Name = "Accuracy", Min = 1, Max = 100, Step = 1, Default = 80, Flag = "flyte_parry_accuracy", Callback = function(v) flags.ParryAccuracy = v end})
CombatTab:Slider({Name = "Parry Range", Min = 0, Max = 10, Step = 1, Default = 0, Flag = "flyte_parry_range", Callback = function(v) flags.ParryRange = v end})
CombatTab:Toggle({Name = "Randomize Accuracy", Default = false, Flag = "flyte_randomize_acc", Callback = function(v) flags.RandomizedParryAccuracy = v end})
CombatTab:RangeSlider({Name = "Accuracy Range", Min = 1, Max = 100, Step = 1, Default = {1, 100}, Flag = "flyte_acc_range", Callback = function(lo, hi) flags.RandomAccuracyMin = lo flags.RandomAccuracyMax = hi end})
CombatTab:Toggle({Name = "Anticurve", Default = true, Flag = "flyte_anticurve", Callback = function(v) flags.AntiCurveEnabled = v end})
CombatTab:Toggle({Name = "Backwards Anticurve", Default = true, Flag = "flyte_backwards_anticurve", Callback = function(v) flags.BackwardsAntiCurveEnabled = v end})
CombatTab:Toggle({Name = "Cooldown Protection", Default = false, Flag = "flyte_cooldown_prot", Callback = function(v) flags.CooldownProtectionEnabled = v end})
CombatTab:Toggle({Name = "Auto Ability", Default = false, Flag = "flyte_auto_ability", Callback = function(v) flags.AutoAbilityEnabled = v end})


local manualSpamUI
local triggerUI

local function createControlUI(name, buttonText, yOffset, onStateChanged)
    local playerGui = LP:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild(name)
    if old then old:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999
    screenGui.Parent = playerGui

    local NORMAL_W, NORMAL_H = 200, 80
    local SMALL_W, SMALL_H = 160, 64
    local TARGET_POS = UDim2.new(1, -NORMAL_W/2 - 20, 0.5, yOffset)
    local START_POS = UDim2.new(1, NORMAL_W, 0.5, yOffset)

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = START_POS
    frame.Size = UDim2.new(0, NORMAL_W, 0, NORMAL_H)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.Active = false
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 2
    stroke.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 240, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
    })
    gradient.Rotation = 90
    gradient.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Name = "ActionButton"
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.new(0.5, 0, 0.5, 0)
    btn.Size = UDim2.new(0, 150, 0, 56)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BorderSizePixel = 0
    btn.Text = buttonText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 26
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.Active = true
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 16)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(255, 255, 255)
    btnStroke.Thickness = 1.5
    btnStroke.Parent = btn

    local dragThickness = 12
    local function makeDragZone(name2, size, pos)
        local zone = Instance.new("Frame")
        zone.Name = name2
        zone.BackgroundTransparency = 1
        zone.Size = size
        zone.Position = pos
        zone.Active = true
        zone.Parent = frame
        return zone
    end

    local topZone = makeDragZone("TopZone", UDim2.new(1, 0, 0, dragThickness), UDim2.new(0, 0, 0, 0))
    local bottomZone = makeDragZone("BottomZone", UDim2.new(1, 0, 0, dragThickness), UDim2.new(0, 0, 1, -dragThickness))
    local leftZone = makeDragZone("LeftZone", UDim2.new(0, dragThickness, 1, -dragThickness * 2), UDim2.new(0, 0, 0, dragThickness))
    local rightZone = makeDragZone("RightZone", UDim2.new(0, dragThickness, 1, -dragThickness * 2), UDim2.new(1, -dragThickness, 0, dragThickness))

    T:Create(frame, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = TARGET_POS
    }):Play()

    local isSmall = false
    local normalSize = UDim2.new(0, NORMAL_W, 0, NORMAL_H)
    local smallSize = UDim2.new(0, SMALL_W, 0, SMALL_H)
    local btnNormalSize = UDim2.new(0, 150, 0, 56)
    local btnSmallSize = UDim2.new(0, 120, 0, 44)

    local function updateDragZones()
        local t = dragThickness
        topZone.Size = UDim2.new(1, 0, 0, t)
        topZone.Position = UDim2.new(0, 0, 0, 0)
        bottomZone.Size = UDim2.new(1, 0, 0, t)
        bottomZone.Position = UDim2.new(0, 0, 1, -t)
        leftZone.Size = UDim2.new(0, t, 1, -t * 2)
        leftZone.Position = UDim2.new(0, 0, 0, t)
        rightZone.Size = UDim2.new(0, t, 1, -t * 2)
        rightZone.Position = UDim2.new(1, -t, 0, t)
    end

    local function setActive(active)
        isSmall = active
        if active then
            T:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = smallSize
            }):Play()
            T:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = btnSmallSize,
                TextSize = 20,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                TextColor3 = Color3.fromRGB(0, 0, 0)
            }):Play()
            btn.Text = "Off"
        else
            T:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = normalSize
            }):Play()
            T:Create(btn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = btnNormalSize,
                TextSize = 26,
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            btn.Text = buttonText
        end
        updateDragZones()
        onStateChanged(active)
    end

    btn.MouseButton1Click:Connect(function()
        setActive(not isSmall)
    end)

    btn.MouseEnter:Connect(function()
        if not isSmall then
            T:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            }):Play()
        end
    end)

    btn.MouseLeave:Connect(function()
        if not isSmall then
            T:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            }):Play()
        end
    end)

    local dragging = false
    local dragStart
    local startPos

    local function hookDrag(zone)
        zone.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
    end

    hookDrag(topZone)
    hookDrag(bottomZone)
    hookDrag(leftZone)
    hookDrag(rightZone)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    updateDragZones()

    return {
        Gui = screenGui,
        SetActive = setActive,
        IsActive = function() return isSmall end
    }
end

local function showManualSpamUI()
    if manualSpamUI and manualSpamUI.Gui and manualSpamUI.Gui.Parent then return end
    manualSpamUI = createControlUI("SpamCatUI", "Spam", 58, function(active)
        flags.ManualSpamEnabled = active
        if active then
            startManualSpam()
        else
            stopManualSpam()
        end
    end)
end

local function hideManualSpamUI()
    if manualSpamUI and manualSpamUI.Gui then
        manualSpamUI.Gui:Destroy()
    end
    manualSpamUI = nil
    flags.ManualSpamEnabled = false
    stopManualSpam()
end

local function showTriggerUI()
    if triggerUI and triggerUI.Gui and triggerUI.Gui.Parent then return end
    triggerUI = createControlUI("TriggerCatUI", "Trigger", -58, function(active)
        flags.TriggerbotEnabled = active
    end)
end

local function hideTriggerUI()
    if triggerUI and triggerUI.Gui then
        triggerUI.Gui:Destroy()
    end
    triggerUI = nil
    flags.TriggerbotEnabled = false
end

CombatTab:Section("Auto Spam")
CombatTab:Toggle({Name = "Auto Spam", Default = false, Flag = "flyte_auto_spam", Callback = function(v) flags.AutoSpamEnabled = v end})
CombatTab:Dropdown({Name = "Spam Type", Options = {"Remote", "VIM", "Mouse Click"}, Default = "Remote", Flag = "flyte_auto_spam_type", Callback = function(v) flags.AutoSpamType = v end})
CombatTab:Toggle({Name = "Animation Fix", Default = true, Flag = "flyte_auto_spam_animfix", Callback = function(v) flags.AutoSpamAnimFix = v end})
CombatTab:Dropdown({Name = "Anim Fix Type", Options = {"Animation + Click", "Animation", "Click"}, Default = "Animation", Flag = "flyte_auto_spam_animfix_type", Callback = function(v) flags.AutoSpamAnimFixType = v end})
CombatTab:Toggle({Name = "Dynamic Threshold", Default = false, Flag = "flyte_dynamic_threshold", Callback = function(v) flags.DynamicSpamThreshold = v end})
CombatTab:Slider({Name = "Threshold", Min = 1, Max = 4, Step = 1, Default = 2, Flag = "flyte_spam_threshold", Callback = function(v) flags.AutoSpamThreshold = math.round(v) end})

CombatTab:Section("Manual Spam")
CombatTab:Toggle({Name = "Manual Spam", Default = false, Flag = "flyte_manual_spam", Callback = function(v)
    if v then
        showManualSpamUI()
    else
        hideManualSpamUI()
    end
end})
CombatTab:Dropdown({Name = "Manual Type", Options = {"Remote", "VIM", "Mouse Click"}, Default = "Remote", Flag = "flyte_manual_type", Callback = function(v) flags.ManualSpamType = v end})
CombatTab:Toggle({Name = "Manual Animation Fix", Default = true, Flag = "flyte_manual_animfix", Callback = function(v) flags.ManualSpamAnimFix = v end})
CombatTab:Dropdown({Name = "Manual Anim Fix Type", Options = {"Animation + Click", "Animation", "Click"}, Default = "Animation", Flag = "flyte_manual_animfix_type", Callback = function(v) flags.ManualSpamAnimFixType = v end})

CombatTab:Section("Triggerbot")
CombatTab:Toggle({Name = "Triggerbot", Default = false, Flag = "flyte_triggerbot", Callback = function(v)
    if v then
        showTriggerUI()
    else
        hideTriggerUI()
    end
end})
CombatTab:Dropdown({Name = "Triggerbot Type", Options = {"Remote", "VIM", "Mouse Click"}, Default = "Remote", Flag = "flyte_triggerbot_type", Callback = function(v) flags.TriggerbotType = v end})
CombatTab:Slider({Name = "Delay (MS)", Min = 0, Max = 200, Step = 1, Default = 0, Flag = "flyte_triggerbot_ms", Callback = function(v) flags.TriggerbotDelay = v end})
CombatTab:Toggle({Name = "Randomize Delay", Default = false, Flag = "flyte_triggerbot_random", Callback = function(v) flags.TriggerbotRandomize = v end})
CombatTab:RangeSlider({Name = "Delay Range", Min = 0, Max = 200, Step = 1, Default = {0, 200}, Flag = "flyte_triggerbot_range", Callback = function(lo, hi) flags.TriggerbotDelayMin = lo flags.TriggerbotDelayMax = hi end})
CombatTab:Toggle({Name = "Don't Parry On Ball Spawn", Default = false, Flag = "flyte_triggerbot_nospawn", Callback = function(v) flags.TriggerbotIgnoreSpawn = v end})

CombatTab:Section("Auto Pre-Click")
CombatTab:Toggle({Name = "Auto Preclick", Default = false, Flag = "flyte_auto_preclick", Callback = function(v) flags.AutoPreclickEnabled = v end})
CombatTab:Toggle({Name = "Preclick For All", Default = false, Flag = "flyte_preclick_all", Callback = function(v) flags.PreclickForAll = v end})
CombatTab:Slider({Name = "Preclick Delay (MS)", Min = 0, Max = 150, Step = 1, Default = 135, Suffix = "ms", Flag = "flyte_preclick_delay", Callback = function(v) flags.PreclickDelay = v end})
CombatTab:Slider({Name = "Preclick After Velocity", Min = 0, Max = 1000, Step = 1, Default = 0, Flag = "flyte_preclick_vel", Callback = function(v) flags.PreclickAfterVelocity = v end})

flyteBBState.Loaded = true

local DetectionsTab = Window:CreateTab({Name = "Detections", Icon = "shield", Desc = "Detection / Counter Features"})

DetectionsTab:Section("Detections")

DetectionsTab:Toggle({Name = "Infinity Detection", Default = false, Flag = "ktl_detect_infinity", Callback = function(v)
    flags.InfinityDetection = v
end})

DetectionsTab:Toggle({Name = "Death Slash Detection", Default = false, Flag = "ktl_detect_deathslash", Callback = function(v)
    flags.DeathSlashDetection = v
end})

DetectionsTab:Toggle({Name = "Slashes of Fury Detection", Default = false, Flag = "ktl_detect_slashesoffury", Callback = function(v)
    flags.FuryDetection = v
    if not v then flyteBBState.FuryParryCount = 0 end
end})

DetectionsTab:Slider({Name = "Max Parries", Min = 1, Max = 36, Step = 1, Default = 36, Flag = "ktl_slashesoffury_max_parries", Callback = function(v)
    flyteBBState.FuryMaxParries = v
end})

DetectionsTab:Slider({Name = "Parry Delay", Min = 0.05, Max = 0.35, Step = 0.01, Default = 0.05, Flag = "ktl_slashesoffury_parry_delay", Callback = function(v)
    flyteBBState.FuryParryDelay = v
end})

DetectionsTab:Toggle({Name = "Forcefield Detection", Default = false, Flag = "ktl_detect_forcefield", Callback = function(v)
    flags.ForcefieldDetection = v
    if not v then
        flyteBBState.DetectionState.ForcefieldActive = false
    else
        refreshForcefieldDetection()
    end
end})

DetectionsTab:Toggle({Name = "Time Hole Detection", Default = false, Flag = "ktl_detect_timehole", Callback = function(v)
    flags.TimeHoleDetection = v
end})

DetectionsTab:Toggle({Name = "Anti-Phantom", Default = false, Flag = "ktl_anti_phantom", Callback = function(v)
    flags.AntiPhantomEnabled = v
    if not v then flyteBBState.DetectionState.PhantomActive = false end
end})

DetectionsTab:Dropdown({Name = "Anti-Phantom Mode", Options = {"Ability", "Teleport"}, Default = "Ability", Flag = "ktl_anti_phantom_mode", Callback = function(v)
    flags.AntiPhantomType = v
end})

DetectionsTab:Toggle({Name = "Anti-Hellhook", Default = false, Flag = "ktl_anti_hellhook", Callback = function(v)
    local remotes = RS:FindFirstChild("Remotes")
    local remote = remotes and remotes:FindFirstChild("PlrHellHooked")
    if not remote or type(getconnections) ~= "function" then return end
    pcall(function()
        for _, connection in getconnections(remote.OnClientEvent) do
            if v then connection:Disable() else connection:Enable() end
        end
    end)
end})

DetectionsTab:Toggle({Name = "Dribble Detection", Default = false, Flag = "ktl_detect_dribble", Callback = function(v)
    flags.DribbleDetection = v
    if not v then
        local dr = flyteBBState.DetectionState.Dribble
        dr.phase, dr.ball, dr.firedAt = "Idle", nil, 0
    end
end})

DetectionsTab:Toggle({Name = "Parry on Dribble", Default = false, Flag = "ktl_parry_on_dribble", Callback = function(v)
    flags.ParryOnDribble = v
    if not v then table.clear(flyteBBState.DetectionState.DribbleParry.pending) end
end})

DetectionsTab:Slider({Name = "Dribble Parry Delay", Min = 0, Max = 2, Step = 0.01, Default = 0, Flag = "ktl_parry_on_dribble_delay", Callback = function(v)
    flyteBBState.DribbleParryDelay = v
end})

local VisualsTab = Window:CreateTab({Name = "Visuals", Icon = "eye", Desc = "Visual Features"})

do
    local DEFAULT_COLOR = Color3.fromRGB(255, 0, 0)
    local FOLDER_KIND = {ParticleShine = "shield", ParryFX = "slash"}
    local TINT = {
        ParticleEmitter = {"Color", true}, Beam = {"Color", true}, Trail = {"Color", true},
        Decal = {"Color", false}, Texture = {"Color", false}, Highlight = {"FillColor", false},
        PointLight = {"Color", false}, SpotLight = {"Color", false}, SurfaceLight = {"Color", false},
        ImageLabel = {"ImageColor3", false}, ImageButton = {"ImageColor3", false}
    }
    local Cfgs = {
        shield = {Kind = "shield", Enabled = false, Color = DEFAULT_COLOR, Seq = ColorSequence.new(DEFAULT_COLOR)},
        slash = {Kind = "slash", Enabled = false, Color = DEFAULT_COLOR, Seq = ColorSequence.new(DEFAULT_COLOR)}
    }
    local Original = setmetatable({}, {__mode = "k"})
    local Conns = {}
    local BoundChar, Monitoring

    local function Disconnect(name)
        if Conns[name] then Conns[name]:Disconnect() Conns[name] = nil end
    end
    local function BindConn(name, conn)
        Disconnect(name) Conns[name] = conn
    end
    local function GetFXKind(inst)
        local c = inst
        while c and c ~= WS do
            if FOLDER_KIND[c.Name] then return FOLDER_KIND[c.Name] end
            c = c.Parent
        end
    end
    local function Untrack(i, restore)
        local r = Original[i]
        if not r then return end
        if r.PropConn then r.PropConn:Disconnect() end
        if r.DestroyConn then r.DestroyConn:Disconnect() end
        if restore and i.Parent then pcall(function() i[r.Prop] = r.Value end) end
        Original[i] = nil
    end
    local function UntrackKind(k)
        for i, r in pairs(Original) do if r.Kind == k then Untrack(i, true) end end
    end
    local function ApplyTint(i, rec)
        local cfg = Cfgs[rec.Kind]
        if not (cfg and cfg.Enabled) then return end
        rec.Applying = true
        pcall(function() i[rec.Prop] = rec.IsSeq and cfg.Seq or cfg.Color end)
        rec.Applying = false
    end
    local function Track(i, kind)
        if Original[i] then return end
        local tint = TINT[i.ClassName]
        if not tint then return end
        kind = kind or GetFXKind(i)
        local cfg = kind and Cfgs[kind]
        if not (cfg and cfg.Enabled) then return end
        local prop, isSeq = tint[1], tint[2]
        local ok, orig = pcall(function() return i[prop] end)
        if not ok then return end
        local rec = {Prop = prop, Value = orig, Kind = kind, IsSeq = isSeq, Applying = false}
        Original[i] = rec
        rec.PropConn = i:GetPropertyChangedSignal(prop):Connect(function()
            if not rec.Applying and i.Parent then ApplyTint(i, rec) end
        end)
        rec.DestroyConn = i.Destroying:Connect(function() Untrack(i, false) end)
        ApplyTint(i, rec)
    end
    local function ScanTree(root, forcedKind)
        if not root then return end
        if forcedKind then
            if TINT[root.ClassName] then Track(root, forcedKind) end
            for _, d in root:GetDescendants() do
                if TINT[d.ClassName] then Track(d, forcedKind) end
            end
        else
            if TINT[root.ClassName] then Track(root) end
            for _, d in root:GetDescendants() do
                local k = FOLDER_KIND[d.Name]
                if k then ScanTree(d, k) elseif TINT[d.ClassName] then Track(d) end
            end
        end
    end
    local function CommitColor(cfg, color)
        cfg.Color = color
        cfg.Seq = ColorSequence.new(color)
        if cfg.Enabled then
            for i, rec in pairs(Original) do
                if rec.Kind == cfg.Kind and i.Parent then ApplyTint(i, rec) end
            end
        end
    end
    local function BindChar(char)
        if BoundChar ~= char then
            BoundChar = char
            BindConn("FX_CharDesc", char and char.DescendantAdded:Connect(function(d)
                local k = FOLDER_KIND[d.Name]
                if k then ScanTree(d, k) elseif TINT[d.ClassName] then Track(d) end
            end))
        end
        if char then ScanTree(char) end
    end
    local function BindRuntime()
        if Conns.FX_Runtime then return end
        local runtime = WS:FindFirstChild("Runtime")
        if not runtime then return end
        BindConn("FX_Runtime", runtime.ChildAdded:Connect(function(c)
            local k = FOLDER_KIND[c.Name]
            if k then ScanTree(c, k) end
        end))
        for _, c in runtime:GetChildren() do
            local k = FOLDER_KIND[c.Name]
            if k then ScanTree(c, k) end
        end
    end
    local function StartMonitor()
        if not Monitoring then
            Monitoring = true
            BindConn("FX_Respawn", LP.CharacterAdded:Connect(BindChar))
            BindRuntime()
        end
        BindChar(LP.Character)
    end
    local function StopMonitorIfIdle()
        if Cfgs.shield.Enabled or Cfgs.slash.Enabled then return end
        Monitoring = false
        BoundChar = nil
        Disconnect("FX_CharDesc")
        Disconnect("FX_Runtime")
        Disconnect("FX_Respawn")
        for i in pairs(Original) do Untrack(i, true) end
    end
    local function SetEnabled(cfg, state)
        cfg.Enabled = state
        if state then StartMonitor() else UntrackKind(cfg.Kind) StopMonitorIfIdle() end
    end

    VisualsTab:Section("Shield & Slash FX")
    VisualsTab:Toggle({Name = "Shield Changer", Default = false, Flag = "fx_shield", Callback = function(v) SetEnabled(Cfgs.shield, v == true) end})
    VisualsTab:ColorPicker({Name = "Shield Color", Default = DEFAULT_COLOR, Flag = "fx_shield_color", Callback = function(v) CommitColor(Cfgs.shield, v) end})
    VisualsTab:Toggle({Name = "Slash Changer", Default = false, Flag = "fx_slash", Callback = function(v) SetEnabled(Cfgs.slash, v == true) end})
    VisualsTab:ColorPicker({Name = "Slash Color", Default = DEFAULT_COLOR, Flag = "fx_slash_color", Callback = function(v) CommitColor(Cfgs.slash, v) end})
end

local spoofed = {}

local function spoofText(keys, value)
    value = tostring(value or "")
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local n = (obj.Name .. " " .. obj.Text):lower()
            for _, key in ipairs(keys) do
                if n:find(key:lower(), 1, true) then
                    if spoofed[obj] == nil then spoofed[obj] = obj.Text end
                    obj.Text = value
                    break
                end
            end
        end
    end
end

local function restoreSpoof()
    for obj, text in pairs(spoofed) do
        if obj and obj.Parent then pcall(function() obj.Text = text end) end
    end
    table.clear(spoofed)
end

VisualsTab:Section("ELO Spoofer")
local eloConn = nil
VisualsTab:Toggle({Name = "ELO Spoofer", Default = false, Flag = "elo_spoofer", Callback = function(v)
    if eloConn then eloConn:Disconnect() eloConn = nil end
    if v then
        local function apply()
            spoofText({"elo", "rating", "rank"}, flyteBBState.EloValue or 8000)
        end
        apply()
        eloConn = RunS.Heartbeat:Connect(function()
            if math.floor(os.clock() * 2) % 2 == 0 then apply() end
        end)
    else
        restoreSpoof()
    end
end})
VisualsTab:Input({Name = "ELO Value", Placeholder = "8000", Default = "8000", Flag = "elo_spoofer_value", Callback = function(v) flyteBBState.EloValue = tonumber(v) or 8000 end})

VisualsTab:Section("Currency Spoofer")
local currencyConn = nil
VisualsTab:Toggle({Name = "Currency Spoofer", Default = false, Flag = "currency_spoofer", Callback = function(v)
    if currencyConn then currencyConn:Disconnect() currencyConn = nil end
    if v then
        local function apply()
            spoofText({"coins"}, flyteBBState.CurrencyValue or 999999)
            spoofText({"tokens"}, flyteBBState.TokenValue or 999999)
        end
        apply()
        currencyConn = RunS.Heartbeat:Connect(function()
            if math.floor(os.clock() * 2) % 2 == 0 then apply() end
        end)
    else
        restoreSpoof()
    end
end})
VisualsTab:Input({Name = "Coins", Placeholder = "999999", Default = "999999", Flag = "currency_spoofer_coins", Callback = function(v) flyteBBState.CurrencyValue = tonumber(v) or 999999 end})
VisualsTab:Input({Name = "Tokens", Placeholder = "999999", Default = "999999", Flag = "currency_spoofer_tokens", Callback = function(v) flyteBBState.TokenValue = tonumber(v) or 999999 end})

local BallTrail = {active = false, color = Color3.fromRGB(0, 255, 255), num_trails = 8, attachments = {}, connection = nil}

local function getBall()
    return features.Ball.GetFirstBall()
end

local function buildTrailColor()
    local r0 = BallTrail.color
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, r0),
        ColorSequenceKeypoint.new(0.5, Color3.new(math.min(r0.R * 1.3, 1), math.min(r0.G * 1.3, 1), math.min(r0.B * 1.3, 1))),
        ColorSequenceKeypoint.new(1, r0)
    })
end

local function detachTrail()
    for _, r2 in ipairs(BallTrail.attachments) do
        if r2.a0 and r2.a0.Parent then r2.a0:Destroy() end
        if r2.a1 and r2.a1.Parent then r2.a1:Destroy() end
        if r2.trail and r2.trail.Parent then r2.trail:Destroy() end
    end
    BallTrail.attachments = {}
end

local function attachTrail(r0)
    detachTrail()
    local r9 = BallTrail.num_trails
    for r1 = 1, r9 do
        local r10 = r1 / r9 * math.pi * 2
        local r17 = math.random(150, 250) / 100
        local r3 = math.random(-150, 150) / 100
        local r18 = Instance.new("Attachment")
        r18.Position = Vector3.new(math.cos(r10) * r17, r3, math.sin(r10) * r17)
        r18.Parent = r0
        local r2 = Instance.new("Attachment")
        r2.Position = Vector3.new(math.cos(r10 + math.pi * 0.7) * r17 * 1.3, -r3, math.sin(r10 + math.pi * 0.7) * r17 * 1.3)
        r2.Parent = r0
        local r19 = Instance.new("Trail")
        r19.Attachment0 = r18
        r19.Attachment1 = r2
        r19.Lifetime = 0.6
        r19.FaceCamera = true
        r19.LightEmission = 1
        r19.Texture = "rbxassetid://5029929719"
        r19.Color = buildTrailColor()
        r19.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.3, 0), NumberSequenceKeypoint.new(0.7, 0.3), NumberSequenceKeypoint.new(1, 1)})
        r19.WidthScale = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(0.3, 0.25), NumberSequenceKeypoint.new(0.7, 0.15), NumberSequenceKeypoint.new(1, 0.02)})
        r19.Parent = r0
        table.insert(BallTrail.attachments, {
            a0 = r18, a1 = r2, trail = r19,
            baseAngle = r10, angle = 0,
            speed = math.random(15, 30) / 10,
            spiralSpeed = math.random(25, 45) / 10,
            radiusMultiplier = math.random(80, 120) / 100,
            pulseOffset = math.random() * math.pi * 2,
            baseRadius = r17, baseHeight = r3,
            chaosSpeed = math.random(10, 20) / 10
        })
    end
end

VisualsTab:Section("Ball Trail")
VisualsTab:Toggle({Name = "Ball Trail", Default = false, Flag = "ball_trail", Callback = function(v)
    if v then
        if BallTrail.active then return end
        BallTrail.active = true
        local r0 = getBall()
        if r0 then attachTrail(r0) end
        BallTrail.connection = RunS.Heartbeat:Connect(function(dt)
            if not BallTrail.active then return end
            local v2 = getBall()
            if not v2 then detachTrail() return end
            if #BallTrail.attachments == 0 then attachTrail(v2) end
            local v2t = tick()
            for _, v4 in ipairs(BallTrail.attachments) do
                if v4.a0.Parent then
                    v4.angle = v4.angle + v4.speed * dt
                    local v5 = v4.angle * v4.spiralSpeed
                    local v6 = math.sin(v2t * 4 + v4.pulseOffset) * 0.4 + 1
                    local v7 = math.sin(v4.angle * 3) * 0.7
                    local v8 = math.sin(v2t * v4.chaosSpeed + v4.pulseOffset) * 0.5
                    local v9 = v4.baseRadius * v4.radiusMultiplier * v6
                    local v10 = v4.baseRadius * 1.3 * v4.radiusMultiplier * v6
                    v4.a0.Position = Vector3.new(math.cos(v4.baseAngle + v4.angle) * v9 + math.cos(v5) * 0.6, v4.baseHeight + math.sin((v4.baseAngle + v4.angle) * 3) * 0.8 + v7 + v8 + math.sin(v5 * 2) * 0.6, math.sin(v4.baseAngle + v4.angle) * v9 + math.sin(v5) * 0.6)
                    v4.a1.Position = Vector3.new(math.cos(v4.baseAngle + v4.angle + math.pi * 0.7) * v10 + math.sin(v5 * 1.3) * 0.5, -v4.baseHeight + math.cos((v4.baseAngle + v4.angle) * 2.5) * 0.8 - v7 - v8 + math.cos(v5 * 1.7) * 0.5, math.sin(v4.baseAngle + v4.angle + math.pi * 0.7) * v10 + math.cos(v5 * 1.1) * 0.5)
                    v4.trail.LightEmission = math.sin(v2t * 5 + v4.pulseOffset) * 0.4 + 0.6
                end
            end
        end)
    else
        if not BallTrail.active then return end
        BallTrail.active = false
        if BallTrail.connection then BallTrail.connection:Disconnect() BallTrail.connection = nil end
        detachTrail()
    end
end})
VisualsTab:Slider({Name = "Trail Count", Min = 1, Max = 16, Step = 1, Default = 8, Flag = "ball_trail_count", Callback = function(v) BallTrail.num_trails = v end})
VisualsTab:ColorPicker({Name = "Trail Color", Default = Color3.fromRGB(0, 255, 255), Flag = "ball_trail_color", Callback = function(v)
    BallTrail.color = v
    for _, r3 in ipairs(BallTrail.attachments) do
        if r3.trail and r3.trail.Parent then r3.trail.Color = buildTrailColor() end
    end
end})

local ParryVisualizer = {active = false, color = Color3.fromRGB(0, 200, 255), parts = {}, connection = nil, char_conn = nil, current_radius = 1}

local RayParams = nil
local function getGroundPos(root)
    if not RayParams then
        RayParams = RaycastParams.new()
        RayParams.FilterType = Enum.RaycastFilterType.Exclude
    end
    RayParams.FilterDescendantsInstances = {root.Parent}
    local result = WS:Raycast(root.Position, Vector3.new(0, -50, 0), RayParams)
    if result then return result.Position + Vector3.new(0, 0.03, 0) end
    return root.Position - Vector3.new(0, 3, 0)
end

local function getParryRadius()
    local maxVelocity = 0
    for _, entry in ipairs(features.Ball.GetAllBalls()) do
        if entry and entry.Parent then
            local velocity = index4(entry)
            if velocity and velocity.Magnitude > maxVelocity then maxVelocity = velocity.Magnitude end
        end
    end
    return math.clamp(get_premium_parry_distance(maxVelocity, flags.ParryAccuracy), 4, 60)
end

local function rebuildRing()
    for _, part in ipairs(ParryVisualizer.parts) do
        if part and part.Parent then part:Destroy() end
    end
    ParryVisualizer.parts = {}
    for _ = 1, 160 do
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CastShadow = false
        part.Material = Enum.Material.Neon
        part.Color = ParryVisualizer.color
        part.Size = Vector3.new(0.25, 0.1, 0.1)
        part.Parent = WS
        table.insert(ParryVisualizer.parts, part)
    end
end

local function updateRing(center, radius)
    local parts = ParryVisualizer.parts
    local segments = #parts
    if segments == 0 then return end
    local arc = 2 * math.pi * radius / segments
    for index, part in ipairs(parts) do
        local angle = (index - 1) / segments * math.pi * 2
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        local a = center + Vector3.new(x, 0, z)
        local b = center + Vector3.new(x - math.sin(angle), 0, z + math.cos(angle))
        part.Size = Vector3.new(0.25, 0.1, arc + 0.02)
        part.CFrame = CFrame.new(a, b)
    end
end

VisualsTab:Section("Parry Visualizer")
VisualsTab:Toggle({Name = "Parry Visualizer", Default = false, Flag = "parry_visualizer", Callback = function(v)
    if v then
        if ParryVisualizer.active then return end
        ParryVisualizer.active = true
        ParryVisualizer.current_radius = 1
        rebuildRing()
        ParryVisualizer.char_conn = LP.CharacterAdded:Connect(function()
            task.wait(0.5)
            if ParryVisualizer.active then rebuildRing() end
        end)
        ParryVisualizer.connection = RunS.Heartbeat:Connect(function()
            if not ParryVisualizer.active then return end
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if #ParryVisualizer.parts == 0 then rebuildRing() return end
            if not root then return end
            local center = getGroundPos(root)
            local targetRadius = getParryRadius()
            ParryVisualizer.current_radius += (targetRadius - ParryVisualizer.current_radius) * 0.15
            updateRing(center, ParryVisualizer.current_radius)
        end)
    else
        if not ParryVisualizer.active then return end
        ParryVisualizer.active = false
        if ParryVisualizer.connection then ParryVisualizer.connection:Disconnect() ParryVisualizer.connection = nil end
        if ParryVisualizer.char_conn then ParryVisualizer.char_conn:Disconnect() ParryVisualizer.char_conn = nil end
        for _, part in ipairs(ParryVisualizer.parts) do
            if part and part.Parent then part:Destroy() end
        end
        ParryVisualizer.parts = {}
    end
end})
VisualsTab:ColorPicker({Name = "Visualizer Color", Default = Color3.fromRGB(0, 200, 255), Flag = "parry_visualizer_color", Callback = function(v)
    ParryVisualizer.color = v
    for _, part in ipairs(ParryVisualizer.parts) do
        if part and part.Parent then part.Color = v end
    end
end})

local WinStreak = {enabled = false, streak = "1", conn = nil, enabled_conn = nil, char_conn = nil, original_text = nil, original_icon = nil, original_enabled = nil}

local function winStreakUpdate()
    if not WinStreak.enabled then
        if WinStreak.conn then WinStreak.conn:Disconnect() WinStreak.conn = nil end
        if WinStreak.enabled_conn then WinStreak.enabled_conn:Disconnect() WinStreak.enabled_conn = nil end
        return
    end
    local v1 = LP.Character
    if not v1 then return end
    local v2 = v1:FindFirstChild("WinStreakDisplay")
    if not v2 then v2 = v1:WaitForChild("WinStreakDisplay", 5) end
    if not v2 then return end
    v1 = v2:FindFirstChild("Main")
    if not v1 then return end
    local v3, v4 = v1:FindFirstChild("Icon"), v1:FindFirstChild("Value")
    if not v3 or not v4 then return end
    if WinStreak.original_enabled == nil then WinStreak.original_enabled = v2.Enabled end
    if not WinStreak.original_text or WinStreak.original_text == "" then WinStreak.original_text = v4.Text end
    if not WinStreak.original_icon or WinStreak.original_icon == "" then WinStreak.original_icon = v3.Image end
    local v5 = WinStreak.streak or "1"
    v1 = string.format("<b><stroke color='rgb(0, 0, 0)' thickness='2'>%s</stroke></b>", tostring(v5))
    local v6 = tonumber(v5)
    v5 = v6 and v6 >= 10
    if WinStreak.conn then WinStreak.conn:Disconnect() WinStreak.conn = nil end
    if WinStreak.enabled_conn then WinStreak.enabled_conn:Disconnect() WinStreak.enabled_conn = nil end
    local v7 = false
    v3.Image = v5 and "rbxassetid://75598166115655" or "rbxassetid://89658127170771"
    v4.Text = v1
    v2.Enabled = true
    WinStreak.conn = v4:GetPropertyChangedSignal("Text"):Connect(function()
        if v7 then return end
        WinStreak.original_text = v4.Text
        v7 = true
        local v8 = WinStreak.streak or "1"
        local v9 = tonumber(v8)
        v3.Image = (v9 and v9 >= 10) and "rbxassetid://75598166115655" or "rbxassetid://89658127170771"
        v4.Text = string.format("<b><stroke color='rgb(0, 0, 0)' thickness='2'>%s</stroke></b>", tostring(v8))
        v7 = false
    end)
    WinStreak.enabled_conn = v2:GetPropertyChangedSignal("Enabled"):Connect(function()
        if v7 then return end
        WinStreak.original_enabled = v2.Enabled
        v7 = true
        v2.Enabled = true
        v7 = false
    end)
end

local function winStreakStart()
    WinStreak.enabled = true
    if not WinStreak.char_conn then
        WinStreak.char_conn = LP.CharacterAdded:Connect(function()
            WinStreak.original_text = nil
            WinStreak.original_icon = nil
            WinStreak.original_enabled = nil
            task.wait(1.5)
            pcall(winStreakUpdate)
        end)
    end
    pcall(winStreakUpdate)
end

local function winStreakStop()
    WinStreak.enabled = false
    if WinStreak.char_conn then WinStreak.char_conn:Disconnect() WinStreak.char_conn = nil end
    if WinStreak.conn then WinStreak.conn:Disconnect() WinStreak.conn = nil end
    if WinStreak.enabled_conn then WinStreak.enabled_conn:Disconnect() WinStreak.enabled_conn = nil end
    local char = LP.Character
    if char then
        local display = char:FindFirstChild("WinStreakDisplay")
        if display then
            local main = display:FindFirstChild("Main")
            if main then
                local icon, value = main:FindFirstChild("Icon"), main:FindFirstChild("Value")
                if icon and value then
                    if WinStreak.original_text and WinStreak.original_text ~= "" then value.Text = WinStreak.original_text end
                    if WinStreak.original_icon and WinStreak.original_icon ~= "" then icon.Image = WinStreak.original_icon end
                end
            end
            if WinStreak.original_enabled ~= nil then display.Enabled = WinStreak.original_enabled end
        end
    end
    WinStreak.original_text = nil
    WinStreak.original_icon = nil
    WinStreak.original_enabled = nil
end

VisualsTab:Section("Custom WinStreak")
VisualsTab:Toggle({Name = "Custom WinStreak", Default = false, Flag = "custom_winstreak", Callback = function(v)
    if v then winStreakStart() else winStreakStop() end
end})
VisualsTab:Input({Name = "Streak Amount", Placeholder = "999", Flag = "custom_winstreak_amount", Callback = function(v)
    WinStreak.streak = v
    if WinStreak.enabled then pcall(winStreakUpdate) end
end})

local CustomWin = {enabled = false, win_message = "KTL", kill_message = "KTL", connections = {}}

local function customWinUpdate()
    if not CustomWin.enabled then return end
    local v1 = LP:FindFirstChild("PlayerGui")
    if not v1 then return end
    local v2 = v1:FindFirstChild("announcer")
    if not v2 then return end
    if CustomWin.kill_message and CustomWin.kill_message ~= "" then
        local v3 = v2:FindFirstChild("Killed")
        if v3 and (v3:IsA("TextLabel") or v3:IsA("TextBox")) then
            if v3.Text ~= CustomWin.kill_message then v3.Text = CustomWin.kill_message end
        end
    end
    if CustomWin.win_message and CustomWin.win_message ~= "" then
        local v4 = v2:FindFirstChild("Winner")
        if v4 and (v4:IsA("TextLabel") or v4:IsA("TextBox")) then
            if v4.Text ~= CustomWin.win_message then v4.Text = CustomWin.win_message end
        end
    end
end

local function customWinStart()
    for _, c in ipairs(CustomWin.connections) do pcall(function() c:Disconnect() end) end
    table.clear(CustomWin.connections)
    CustomWin.enabled = true
    local pg = LP:WaitForChild("PlayerGui", 10)
    if not pg then return end
    local ann = pg:WaitForChild("announcer", 10)
    if not ann then return end
    local function hook(label, getter)
        if not label then return end
        table.insert(CustomWin.connections, label.Changed:Connect(function(prop)
            if prop ~= "Text" or not CustomWin.enabled then return end
            local val = getter()
            if val and val ~= "" and label.Text ~= val then label.Text = val end
        end))
        local val = getter()
        if val and val ~= "" and label.Text ~= val then label.Text = val end
    end
    hook(ann:WaitForChild("Killed", 10), function() return CustomWin.kill_message end)
    hook(ann:FindFirstChild("Winner"), function() return CustomWin.win_message end)
    table.insert(CustomWin.connections, ann.ChildAdded:Connect(function(c)
        if c.Name == "Winner" then hook(c, function() return CustomWin.win_message end) end
        if c.Name == "Killed" then hook(c, function() return CustomWin.kill_message end) end
    end))
end

local function customWinStop()
    CustomWin.enabled = false
    for _, c in ipairs(CustomWin.connections) do pcall(function() c:Disconnect() end) end
    table.clear(CustomWin.connections)
end

VisualsTab:Section("Custom Win Message")
VisualsTab:Toggle({Name = "Custom Win Message", Default = false, Flag = "custom_win_enabled", Callback = function(v)
    if v then customWinStart() else customWinStop() end
end})
VisualsTab:Input({Name = "Win Message", Placeholder = "KTL", Flag = "custom_win_win_text", Callback = function(v)
    CustomWin.win_message = v
    if CustomWin.enabled then customWinUpdate() end
end})
VisualsTab:Input({Name = "Kill Message", Placeholder = "KTL", Flag = "custom_win_kill_text", Callback = function(v)
    CustomWin.kill_message = v
    if CustomWin.enabled then customWinUpdate() end
end})

local AbilityESP = {
    active = false,
    drawings = {},
    connection = nil,
    mode = "Text",
    show_name = false,
    name_mode = "Display Name",
    name_size = 18,
    name_color = Color3.fromRGB(255, 255, 255),
    ability_size = 16,
    ability_color = Color3.fromRGB(120, 200, 255),
    show_cd = true,
    cd_size = 15,
    cd_color = Color3.fromRGB(180, 180, 180),
    show_timer = true,
    active_size = 15,
    active_color = Color3.fromRGB(255, 200, 80)
}

local function getAbilityIcon(name)
    if not name or name == "" then return "" end
    local shared = RS:FindFirstChild("Shared")
    local abilities = shared and shared:FindFirstChild("Abilities")
    local module = abilities and abilities:FindFirstChild(name)
    if not module then return "" end
    local ok, data = pcall(require, module)
    if ok and type(data) == "table" and type(data.iconId) == "string" then return data.iconId end
    return ""
end

local function getAbilityUpgrades(player, name)
    if not name or name == "" then return 0 end
    local ok, val = pcall(function() return player.Upgrades[name].Value end)
    return ok and val or 0
end

local function getAbilityLine(name, player)
    if not name or name == "" then return nil end
    return name .. " V" .. getAbilityUpgrades(player, name) + 1
end

local function hideAllESP(state)
    state.nameDraw.Visible = false
    state.abilityDraw.Visible = false
    state.timerDraw.Visible = false
    state.cdDraw.Visible = false
    state.usesDraw.Visible = false
    for _, d in ipairs(state.cdDrawings) do d.Visible = false end
    if state.billboard then
        state.billboard.Enabled = false
        state.billboard.Adornee = nil
    end
end

local function getBillboard(state, adornee)
    if not state.billboard or not state.billboard.Parent then
        if not AbilityESP._holder or not AbilityESP._holder.Parent then
            AbilityESP._holder = Instance.new("ScreenGui")
            AbilityESP._holder.ResetOnSpawn = false
            AbilityESP._holder.IgnoreGuiInset = true
            AbilityESP._holder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            AbilityESP._holder.Parent = CoreGui
        end
        local bb = Instance.new("BillboardGui")
        bb.AlwaysOnTop = true
        bb.Enabled = false
        bb.Parent = AbilityESP._holder
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        img.Parent = bb
        local lvl = Instance.new("TextLabel")
        lvl.BackgroundTransparency = 1
        lvl.TextStrokeTransparency = 0
        lvl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lvl.Font = Enum.Font.GothamBold
        lvl.Parent = bb
        state.billboard = bb
        state.billboardImg = img
        state.billboardLvl = lvl
    end
    local size = AbilityESP.ability_size * 3
    state.billboard.Size = UDim2.new(0, size, 0, size)
    state.billboard.StudsOffset = Vector3.new(0, 4, 0)
    if state.billboardLvl then
        local s = AbilityESP.ability_size
        state.billboardLvl.Size = UDim2.new(0, s * 2, 0, s + 4)
        state.billboardLvl.Position = UDim2.new(1, -s, 0, 0)
        state.billboardLvl.TextSize = s
        state.billboardLvl.TextColor3 = AbilityESP.ability_color
    end
    state.billboard.Adornee = adornee
    return state.billboard, state.billboardImg, state.billboardLvl
end

local function createDrawing(player)
    if AbilityESP.drawings[player] then
        AbilityESP.removeDrawing(player)
    end
    local function newText(size, color)
        local d = Drawing.new("Text")
        d.Visible = false
        d.Center = true
        d.Outline = true
        d.OutlineColor = Color3.new(0, 0, 0)
        d.Color = color
        d.Size = size
        d.Font = Drawing.Fonts.UI
        return d
    end
    AbilityESP.drawings[player] = {
        nameDraw = newText(AbilityESP.name_size, AbilityESP.name_color),
        abilityDraw = newText(AbilityESP.ability_size, AbilityESP.ability_color),
        timerDraw = newText(AbilityESP.active_size, AbilityESP.active_color),
        cdDraw = newText(AbilityESP.cd_size, AbilityESP.cd_color),
        usesDraw = newText(AbilityESP.active_size, Color3.fromRGB(100, 255, 150)),
        cdDrawings = {},
        charConns = {}
    }
end

local function removeDrawing(player)
    local state = AbilityESP.drawings[player]
    if not state then return end
    state.nameDraw:Remove()
    state.abilityDraw:Remove()
    state.timerDraw:Remove()
    state.cdDraw:Remove()
    state.usesDraw:Remove()
    for _, d in ipairs(state.cdDrawings) do d:Remove() end
    if state.billboard then state.billboard:Destroy() end
    for _, c in ipairs(state.charConns) do pcall(function() c:Disconnect() end) end
    AbilityESP.drawings[player] = nil
end

local function trackPlayer(player)
    createDrawing(player)
    local function onChar(char)
        local state = AbilityESP.drawings[player]
        if not state then return end
        for _, c in ipairs(state.charConns) do pcall(function() c:Disconnect() end) end
        table.clear(state.charConns)
        state.activeStart = nil
        state.activeDur = nil
        state.cdStart = nil
        state.cdLen = nil
        state.cdQueue = {}
        state.curUses = nil
        state.maxUses = nil
        for _, d in ipairs(state.cdDrawings) do d.Visible = false end
        if state.billboard then
            state.billboard.Adornee = nil
            state.billboard.Enabled = false
        end
        local ability = player:GetAttribute("CurrentlyEquippedAbility")
        if ability and ability ~= "" then
            state.abilityName = ability
            state.abilityLine = getAbilityLine(ability, player)
            state.iconId = getAbilityIcon(ability)
            if ability == "Dribble" then
                state.maxUses = 2 + getAbilityUpgrades(player, "Dribble")
                state.curUses = state.maxUses
            end
        end
        table.insert(state.charConns, char.AttributeChanged:Connect(function(attr)
            local s = AbilityESP.drawings[player]
            if not s then return end
            if attr == "AbilityActive" then
                local active = char:GetAttribute("AbilityActive")
                local dur = player:GetAttribute("AbilityDuration")
                if active == true and dur and dur > 0 then
                    s.activeStart = tick()
                    s.activeDur = dur
                else
                    s.activeStart = nil
                    s.activeDur = nil
                end
            end
        end))
        table.insert(state.charConns, player.AttributeChanged:Connect(function(attr)
            local s = AbilityESP.drawings[player]
            if not s then return end
            if attr == "CurrentlyEquippedAbility" then
                local a = player:GetAttribute("CurrentlyEquippedAbility")
                s.abilityName = a
                s.abilityLine = getAbilityLine(a, player)
                s.cdStart = nil
                s.cdLen = nil
                s.cdQueue = {}
                for _, d in ipairs(s.cdDrawings) do d.Visible = false end
                s.iconId = getAbilityIcon(a)
                if a == "Dribble" then
                    s.maxUses = 2 + getAbilityUpgrades(player, "Dribble")
                    s.curUses = s.maxUses
                else
                    s.maxUses = nil
                    s.curUses = nil
                end
            end
        end))
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
    player.CharacterRemoving:Connect(function()
        local state = AbilityESP.drawings[player]
        if not state then return end
        hideAllESP(state)
        state.activeStart = nil
        state.activeDur = nil
        state.cdStart = nil
        state.cdLen = nil
        state.cdQueue = {}
        state.curUses = nil
        state.maxUses = nil
    end)
end

local function updateESP()
    local now = tick()
    for player, state in pairs(AbilityESP.drawings) do
        if not player or not player.Parent then
            removeDrawing(player)
            continue
        end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then hideAllESP(state) continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.5, 0))
        if not onScreen or screenPos.Z < 0 then hideAllESP(state) continue end
        local pos = Vector2.new(screenPos.X, screenPos.Y)
        local yOffset = 0
        if AbilityESP.show_name then
            local name = AbilityESP.name_mode == "Username" and player.Name or player.DisplayName
            state.nameDraw.Position = pos + Vector2.new(0, -(AbilityESP.name_size - 9))
            state.nameDraw.Text = name
            state.nameDraw.Size = AbilityESP.name_size
            state.nameDraw.Color = AbilityESP.name_color
            state.nameDraw.Visible = true
        else
            state.nameDraw.Visible = false
        end
        if AbilityESP.mode == "Image" then
            state.abilityDraw.Visible = false
            if state.iconId and state.iconId ~= "" and state.iconId ~= "rbxassetid://0" then
                local bb, img, lvl = getBillboard(state, root)
                img.Image = state.iconId
                if lvl then lvl.Text = "V" .. getAbilityUpgrades(player, state.abilityName) + 1 end
                bb.Enabled = true
            elseif state.billboard then
                state.billboard.Enabled = false
            end
            yOffset += AbilityESP.ability_size + 4
        else
            if state.billboard then state.billboard.Enabled = false end
            if state.abilityLine then
                state.abilityDraw.Position = pos + Vector2.new(0, yOffset)
                state.abilityDraw.Text = state.abilityLine
                state.abilityDraw.Size = AbilityESP.ability_size
                state.abilityDraw.Color = AbilityESP.ability_color
                state.abilityDraw.Visible = true
                yOffset += AbilityESP.ability_size + 4
            else
                state.abilityDraw.Visible = false
            end
        end
        if AbilityESP.show_timer and state.activeStart and state.activeDur then
            local remaining = math.max(0, state.activeDur - (now - state.activeStart))
            if remaining > 0 then
                state.timerDraw.Size = AbilityESP.active_size
                state.timerDraw.Color = AbilityESP.active_color
                state.timerDraw.Position = pos + Vector2.new(0, yOffset)
                state.timerDraw.Text = string.format("active  %.1fs", remaining)
                state.timerDraw.Visible = true
            else
                state.timerDraw.Visible = false
                state.activeStart = nil
                state.activeDur = nil
            end
        else
            state.timerDraw.Visible = false
        end
    end
end

VisualsTab:Section("Ability ESP")
VisualsTab:Toggle({Name = "Ability ESP", Default = false, Flag = "ability_esp", Callback = function(v)
    if v then
        if AbilityESP.active then return end
        AbilityESP.active = true
        pcall(function() require(RS.Shared.Abilities) end)
        for _, player in ipairs(PlayersService:GetPlayers()) do
            if player ~= LP then trackPlayer(player) end
        end
        PlayersService.PlayerAdded:Connect(function(p)
            if AbilityESP.active and p ~= LP then trackPlayer(p) end
        end)
        PlayersService.PlayerRemoving:Connect(function(p) removeDrawing(p) end)
        AbilityESP.connection = RunS.RenderStepped:Connect(updateESP)
    else
        if not AbilityESP.active then return end
        AbilityESP.active = false
        if AbilityESP.connection then AbilityESP.connection:Disconnect() AbilityESP.connection = nil end
        for player in pairs(AbilityESP.drawings) do removeDrawing(player) end
    end
end})
VisualsTab:Dropdown({Name = "Display Mode", Options = {"Text", "Image"}, Default = "Text", Flag = "esp_display_mode", Callback = function(v) AbilityESP.mode = v end})
VisualsTab:Toggle({Name = "Show Name", Default = false, Flag = "esp_show_name", Callback = function(v) AbilityESP.show_name = v end})
VisualsTab:Dropdown({Name = "Name Type", Options = {"Display Name", "Username"}, Default = "Display Name", Flag = "esp_name_mode", Callback = function(v) AbilityESP.name_mode = v end})
VisualsTab:Slider({Name = "Name Size", Min = 8, Max = 36, Step = 1, Default = 18, Flag = "esp_name_size", Callback = function(v)
    AbilityESP.name_size = v
    for _, s in pairs(AbilityESP.drawings) do if s.nameDraw then s.nameDraw.Size = v end end
end})
VisualsTab:ColorPicker({Name = "Name Color", Default = Color3.fromRGB(255, 255, 255), Flag = "esp_name_color", Callback = function(v)
    AbilityESP.name_color = v
    for _, s in pairs(AbilityESP.drawings) do if s.nameDraw then s.nameDraw.Color = v end end
end})
VisualsTab:Slider({Name = "Ability Size", Min = 8, Max = 36, Step = 1, Default = 16, Flag = "esp_ability_size", Callback = function(v)
    AbilityESP.ability_size = v
    for _, s in pairs(AbilityESP.drawings) do if s.abilityDraw then s.abilityDraw.Size = v end end
end})
VisualsTab:ColorPicker({Name = "Ability Color", Default = Color3.fromRGB(120, 200, 255), Flag = "esp_ability_color", Callback = function(v)
    AbilityESP.ability_color = v
    for _, s in pairs(AbilityESP.drawings) do if s.abilityDraw then s.abilityDraw.Color = v end end
end})

local BallVelocity = {active = false, gui = nil, peak = {}, connection = nil}

VisualsTab:Section("Ball Velocity")
VisualsTab:Toggle({Name = "Ball Velocity", Default = false, Flag = "ball_velocity", Callback = function(v)
    if v then
        if BallVelocity.active then return end
        BallVelocity.active = true
        BallVelocity.peak = {}
        local gui = Instance.new("ScreenGui")
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = CoreGui
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 230, 0, 130)
        frame.Position = UDim2.new(0, 20, 0, 150)
        frame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        frame.BorderSizePixel = 0
        frame.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(105, 105, 105)
        stroke.Parent = frame
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 34)
        header.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
        header.BorderSizePixel = 0
        header.Parent = frame
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 12)
        headerCorner.Parent = header
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -16, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = "Ball Stats"
        title.TextColor3 = Color3.fromRGB(245, 245, 245)
        title.TextSize = 13
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = header
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -24, 1, -44)
        holder.Position = UDim2.new(0, 12, 0, 40)
        holder.BackgroundTransparency = 1
        holder.Parent = frame
        local function makeRow(label, offset)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 38)
            row.Position = UDim2.new(0, 0, 0, offset)
            row.BackgroundTransparency = 1
            row.Parent = holder
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 14)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = Color3.fromRGB(175, 175, 175)
            lbl.TextSize = 11
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row
            local val = Instance.new("TextLabel")
            val.Size = UDim2.new(1, 0, 0, 22)
            val.Position = UDim2.new(0, 0, 0, 15)
            val.BackgroundTransparency = 1
            val.Text = "0.0"
            val.TextColor3 = Color3.fromRGB(225, 225, 225)
            val.TextSize = 18
            val.Font = Enum.Font.GothamBold
            val.TextXAlignment = Enum.TextXAlignment.Left
            val.Parent = row
            return val
        end
        local currentVel = makeRow("Current Velocity", 0)
        local peakVel = makeRow("Peak Velocity", 42)
        local dragging, dragStart, frameStart = false, nil, nil
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                frameStart = frame.Position
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        BallVelocity.gui = gui
        local elapsed = 0
        BallVelocity.connection = RunS.Heartbeat:Connect(function(dt)
            if not BallVelocity.active then return end
            elapsed += dt
            if elapsed < 0.05 then return end
            elapsed = 0
            local ball = features.Ball.GetFirstBall()
            if not ball then
                currentVel.Text = "0.0"
                peakVel.Text = "0.0"
                return
            end
            local zoomies = ball:FindFirstChild("zoomies")
            if not zoomies then currentVel.Text = "0.0" return end
            local speed = zoomies.VectorVelocity.Magnitude
            local peak = BallVelocity.peak[ball] or 0
            if speed > peak then
                peak = speed
                BallVelocity.peak[ball] = peak
            end
            currentVel.Text = string.format("%.1f", speed)
            peakVel.Text = string.format("%.1f", peak)
        end)
    else
        if not BallVelocity.active then return end
        BallVelocity.active = false
        if BallVelocity.connection then BallVelocity.connection:Disconnect() BallVelocity.connection = nil end
        if BallVelocity.gui then BallVelocity.gui:Destroy() BallVelocity.gui = nil end
        BallVelocity.peak = {}
    end
end})

local BallIndicator = {active = false, gui = nil, img = nil, position = Vector2.new(0, 0), rotation = 0, connection = nil, color = Color3.fromRGB(255, 255, 255)}

VisualsTab:Section("Ball Indicator")
VisualsTab:ColorPicker({Name = "Arrow Color", Default = Color3.fromRGB(255, 255, 255), Flag = "ball_indicator_color", Callback = function(v)
    BallIndicator.color = v
    if BallIndicator.img and BallIndicator.img.Parent then
        BallIndicator.img.ImageColor3 = v
    end
end})
VisualsTab:Toggle({Name = "Ball Indicator", Default = false, Flag = "ball_indicator", Callback = function(v)
    if v then
        if BallIndicator.active then return end
        BallIndicator.active = true
        BallIndicator.position = Vector2.new(0, 0)
        BallIndicator.rotation = 0
        local gui = Instance.new("ScreenGui")
        gui.Name = "KTL_BallIndicator"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.DisplayOrder = 999
        gui.Parent = CoreGui
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(0, 50, 0, 50)
        holder.Position = UDim2.new(0.5, 0, 0.5, 0)
        holder.AnchorPoint = Vector2.new(0.5, 0.5)
        holder.BackgroundTransparency = 1
        holder.Parent = gui
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(1, 0, 1, 0)
        img.Position = UDim2.new(0.5, 0, 0.5, 0)
        img.AnchorPoint = Vector2.new(0.5, 0.5)
        img.Image = "rbxassetid://18604510750"
        img.ImageColor3 = BallIndicator.color
        img.ScaleType = Enum.ScaleType.Fit
        img.Parent = holder
        BallIndicator.gui = gui
        BallIndicator.img = img
        BallIndicator.connection = RunS.RenderStepped:Connect(function(dt)
            if not BallIndicator.active then return end
            local camera = WS.CurrentCamera
            if not camera then return end
            local char = LP.Character
            local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))
            local ball = features.Ball.GetFirstBall()
            if not ball or not root then
                img.Visible = false
                return
            end
            img.Visible = true
            local diff = ball.Position - root.Position
            local mag = diff.Magnitude
            if mag < 0.001 then return end
            local dir = diff.Unit
            local angle = math.atan2(dir:Dot(camera.CFrame.RightVector), dir:Dot(camera.CFrame.LookVector))
            local distance = math.clamp(mag / 50 * 90, 0, 90)
            local target = Vector2.new(math.sin(angle) * distance, -math.cos(angle) * distance)
            BallIndicator.position = BallIndicator.position:Lerp(target, math.min(12 * dt, 1))
            holder.Position = UDim2.new(0.5, BallIndicator.position.X, 0.5, BallIndicator.position.Y)
            local targetRot = math.deg(angle)
            local delta = (targetRot - BallIndicator.rotation + 180) % 360 - 180
            BallIndicator.rotation = BallIndicator.rotation + delta * math.min(8 * dt, 1)
            img.Rotation = BallIndicator.rotation
        end)
    else
        if not BallIndicator.active then return end
        BallIndicator.active = false
        if BallIndicator.connection then
            BallIndicator.connection:Disconnect()
            BallIndicator.connection = nil
        end
        if BallIndicator.gui then
            BallIndicator.gui:Destroy()
            BallIndicator.gui = nil
        end
        BallIndicator.img = nil
    end
end})

local NoRender = {active = false, connection = nil}

VisualsTab:Section("No Render")
VisualsTab:Toggle({Name = "No Render", Default = false, Flag = "no_render", Callback = function(v)
    if v then
        if NoRender.active then return end
        NoRender.active = true
        pcall(function() LP.PlayerScripts.EffectScripts.ClientFX.Disabled = true end)
        if newRoot then
            NoRender.connection = newRoot.ChildAdded:Connect(function(obj)
                if NoRender.active then game:GetService("Debris"):AddItem(obj, 0) end
            end)
        end
    else
        if not NoRender.active then return end
        NoRender.active = false
        pcall(function() LP.PlayerScripts.EffectScripts.ClientFX.Disabled = false end)
        if NoRender.connection then NoRender.connection:Disconnect() NoRender.connection = nil end
    end
end})

local Plushies = {
    active = false,
    active_types = {},
    folder = nil,
    connection = nil,
    loaded_models = {},
    models = {
        Reimu = "rbxassetid://17657672380",
        Youmou = "rbxassetid://13242826151",
        Shion = "rbxassetid://12124164278",
        Yuuka = "rbxassetid://12181667428",
        Flandre = "rbxassetid://12136125365",
        Ayanami = "rbxassetid://11965563704",
        Padoru = "rbxassetid://11905337091"
    },
    scales = {Reimu = 1.5, Youmou = 2.3, Shion = 2.3, Yuuka = 1.5, Flandre = 3.3, Ayanami = 1.5, Padoru = 1.5},
    rotations = {
        Reimu = CFrame.Angles(0, math.rad(0), 0),
        Youmou = CFrame.Angles(0, math.rad(-90), 0),
        Shion = CFrame.Angles(math.rad(110), 0, math.rad(90)),
        Yuuka = CFrame.Angles(math.rad(-90), math.rad(180), 0),
        Flandre = CFrame.Angles(0, math.rad(-40), 0),
        Ayanami = CFrame.Angles(0, 0, 0),
        Padoru = CFrame.Angles(0, 0, 0)
    },
    positions = {
        Vector3.new(2.5, 2, 0),
        Vector3.new(-2.5, 2, 0),
        Vector3.new(0, 4, 2.5),
        Vector3.new(0, 4, -2.5),
        Vector3.new(2.5, 2, 2.5),
        Vector3.new(-2.5, 2, 2.5),
        Vector3.new(2.5, 2, -2.5)
    }
}

local function createPlushie(name)
    local asset = Plushies.models[name]
    if not asset then return nil end
    if not Plushies.loaded_models[name] then
        local ok, obj = pcall(function() return game:GetObjects(asset)[1] end)
        if not ok or not obj then return nil end
        Plushies.loaded_models[name] = obj
    end
    local clone = Plushies.loaded_models[name]:Clone()
    clone.Name = name
    local scale = Plushies.scales[name] or 1.5
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            part.CanCollide = false
            part.Anchored = false
            part.Size = part.Size * scale
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then mesh.Scale = mesh.Scale * scale end
        end
    end
    local primary = clone:FindFirstChildOfClass("BasePart") or clone:FindFirstChildOfClass("MeshPart")
    if primary then clone.PrimaryPart = primary end
    return clone
end

local function updatePlushies()
    if not Plushies.active then return end
    local char = LP.Character
    if not char or not char.PrimaryPart or not Plushies.folder then return end
    local index = 1
    for name in pairs(Plushies.active_types) do
        local offset = Plushies.positions[(index - 1) % #Plushies.positions + 1]
        local model = Plushies.folder:FindFirstChild(name)
        if not model then
            local newModel = createPlushie(name)
            if newModel then
                newModel.Parent = Plushies.folder
                newModel:SetPrimaryPartCFrame(CFrame.new(char.PrimaryPart.Position + offset))
                model = newModel
            end
        end
        if model and model.PrimaryPart then
            local primary = model.PrimaryPart
            local bob = Vector3.new(0, math.sin(tick() * 2) * 0.3, 0)
            local target = char.PrimaryPart.CFrame * CFrame.new(offset + bob) * (Plushies.rotations[name] or CFrame.new())
            local bp = primary:FindFirstChild("PlushieBP")
            if not bp then
                bp = Instance.new("BodyPosition")
                bp.Name = "PlushieBP"
                bp.MaxForce = Vector3.new(40000, 40000, 40000)
                bp.P = 10000
                bp.D = 1000
                bp.Parent = primary
            end
            bp.Position = target.Position
            primary.CFrame = CFrame.new(primary.Position) * target.Rotation
        end
        index += 1
    end
    for _, child in ipairs(Plushies.folder:GetChildren()) do
        if not Plushies.active_types[child.Name] then child:Destroy() end
    end
end

VisualsTab:Section("Plushies")
VisualsTab:Toggle({Name = "Plushies", Default = false, Flag = "plushies", Callback = function(v)
    if v then
        if Plushies.active then return end
        Plushies.active = true
        Plushies.folder = Instance.new("Folder")
        Plushies.folder.Name = "Plushies_Temp"
        Plushies.folder.Parent = WS
        Plushies.connection = RunS.RenderStepped:Connect(updatePlushies)
    else
        if not Plushies.active then return end
        Plushies.active = false
        if Plushies.connection then Plushies.connection:Disconnect() Plushies.connection = nil end
        if Plushies.folder then Plushies.folder:Destroy() Plushies.folder = nil end
    end
end})
VisualsTab:Dropdown({Name = "Plushie Type", Options = {"Reimu", "Youmou", "Shion", "Yuuka", "Flandre", "Ayanami", "Padoru"}, Multi = true, Default = {}, Flag = "plushie_type", Callback = function(values)
    Plushies.active_types = {}
    for _, name in ipairs(values) do
        Plushies.active_types[name] = true
    end
end})


-- ============================================================
-- KTL PLAYER + CHANGER PORT
-- Source logic: KTll Player / Sword / Avatar sections.
-- UI is adapted to text10's Kittylol CreateTab API.
-- ============================================================

local u796 = game
local u797 = WS
local u798 = getgenv
local u819 = CFrame
local u824 = Enum
local u850 = {new = Instance.new}
local u1054 = PlayersService
local u1055 = RunS
local u1056 = UIS
local u1057 = RS
local u1058 = WS
local u1061 = LP
local u1062 = Camera
local u1063 = RunS.Heartbeat
local function u1077(name)
    local id = tonumber(name)
    if id then return id end
    local ok, result = pcall(function()
        return u1054:GetUserIdFromNameAsync(tostring(name))
    end)
    return ok and result or nil
end
local u1064 = RunS.RenderStepped
local u1065 = RunS.PreSimulation
local __S = {}
local u808 = pcall
local u809 = type
local u1059 = Stats
local u1066 = os.clock

local u1070 = {
    player_mods = {
        fov_enabled = false, fov = 70,
        speed_enabled = false, speed = 16,
        gravity_enabled = false, gravity = 196.2,
        jump_power_enabled = false, jump_power = 50,
        infinite_jump_enabled = false,
        infinite_jump_conn = nil,
        speed_conn = nil,
        jump_conn = nil
    },
    avatar_changer = {
        applying = false,
        applied_id = nil,
        cache = {},
        original_desc = nil,
        enabled = false,
        target = "",
        respawn_token = 0,
        expected_accessories = 0,
        saving_original = false
    },
    avatar = {
        korblox_enabled = false,
        headless_enabled = false,
        korblox_conn = nil,
        headless_conn = nil
    },
    emotes = {
        storage = {},
        current = nil,
        trove = nil,
        enabled = false,
        auto_stop = false,
        paused = false,
        _replay_t = 0,
        _loop_t = 0,
        connection = nil
    },
    cache = {
        emotes_shared = nil,
        trove_module = nil
    }
}

-- Original KTll Emotes logic.
__S[3] = function()
    local r0 = u1057:FindFirstChild("Misc")

    if not r0 then
        return
    end

    local r4 = r0:FindFirstChild("Emotes")

    if not r4 then
        return
    end

    local r292 = r4:GetChildren()

    for r1, r2 in pairs(r292) do
        if r2:IsA("Animation") and r2:GetAttribute("EmoteName") then
            local r3 = r2:GetAttribute("EmoteName")
            u1070.emotes.storage[r3] = r2
        end
    end
end

u1070.emotes.load_animations = __S[3]

__S[3] = function()
    local r3 = {}

    for r1, r2 in pairs(u1070.emotes.storage) do
        table.insert(r3, r1)
    end

    table.sort(r3)
    return r3
end

u1070.emotes.get_emotes_list = __S[3]

__S[6] = function()
    if u1070.cache.emotes_shared ~= nil then
        return u1070.cache.emotes_shared or nil
    end

    local v1 = u1057:FindFirstChild("Shared")
    local v2 = v1 and (v1:FindFirstChild("EmotesShared"))

    if not v2 then
        u1070.cache.emotes_shared = false
        return nil
    end

    v1 = getthreadidentity()
    setthreadidentity(6)
    local v3, v4 = u808(require, v2)
    setthreadidentity(v1)

    if v3 and u809(v4) == "table" and u809(v4.Play) == "function" then
        u1070.cache.emotes_shared = v4
    end

    if not (v3 and u809(v4) == "table" and u809(v4.Play) == "function") then
        u1070.cache.emotes_shared = false
    end

    return u1070.cache.emotes_shared or nil
end --[[ LPH_NO_VIRTUALIZE ]]

u1070.emotes.get_shared = __S[6]

__S[6] = function()
    if u1070.cache.trove_module ~= nil then
        return u1070.cache.trove_module or nil
    end

    local v1 = u1057:FindFirstChild("Packages")
    local v2 = v1 and (v1:FindFirstChild("Trove"))

    if not v2 then
        u1070.cache.trove_module = false
        return nil
    end

    local v3, v4 = u808(require, v2)

    if v3 and u809(v4) == "table" and u809(v4.new) == "function" then
        u1070.cache.trove_module = v4
    end

    if not (v3 and u809(v4) == "table" and u809(v4.new) == "function") then
        u1070.cache.trove_module = false
    end

    return u1070.cache.trove_module or nil
end --[[ LPH_NO_VIRTUALIZE ]]

u1070.emotes.get_trove_module = __S[6]

__S[3] = function(r0)
    local u1072 = u1070.emotes

    if u1072.trove then
        pcall(function()
            u1072.trove:Destroy()
        end)

        u1072.trove = nil
    end

    if not r0 then
        u1072.current = nil
        u1072.paused = false
    end
end

u1070.emotes._stop_track = __S[3]

__S[6] = function(v1)
    local v2 = u1070.emotes.storage[v1]

    if not v2 then
        return false
    end

    local v3 = u1061.Character

    if not v3 or not v3.PrimaryPart then
        return false
    end

    if not v3:FindFirstChildWhichIsA("Humanoid") then
        return false
    end

    local v4, v5 = u1070.emotes.get_shared(), u1070.emotes.get_trove_module()

    if not v4 or not v5 then
        return false
    end

    u1070.emotes._stop_track(false)
    u1070.emotes.paused = false
    u1070.emotes.trove = v5.new()
    u1070.emotes.current = v1

    if not u808(function()
        v4:Play(v3, u1070.emotes.trove, v2.Name, true, u1058:GetServerTimeNow(), nil)
    end) then
        u1070.emotes._stop_track(false)
        return false
    end

    return true
end --[[ LPH_NO_VIRTUALIZE ]]

u1070.emotes.play = __S[6]

__S[6] = function(v1)
    if u809(v1) ~= "string" or v1 == "" then
        return false
    end

    local v2 = u1061.Character

    if not v2 or not v2.PrimaryPart then
        return false
    end

    if not v2:FindFirstChildWhichIsA("Humanoid") then
        return false
    end

    local v3, v4 = u1070.emotes.get_shared(), u1070.emotes.get_trove_module()

    if not v3 or not v4 then
        return false
    end

    u1070.emotes._stop_track(false)
    u1070.emotes.paused = false
    u1070.emotes.trove = v4.new()
    u1070.emotes.current = v1

    if not u808(function()
        v3:Play(v2, u1070.emotes.trove, v1, true, u1058:GetServerTimeNow(), nil)
    end) then
        u1070.emotes._stop_track(false)
        return false
    end

    return true
end --[[ LPH_NO_VIRTUALIZE ]]

u1070.emotes.play_internal = __S[6]

__S[3] = function()
    u1070.emotes._stop_track(false)
end

u1070.emotes.stop = __S[3]

__S[6] = function()
    local v1 = u1070.emotes

    if not v1.enabled or not v1.current then
        return
    end

    local v2 = u1066()

    if v2 - v1._loop_t < 0.08 then
        return
    end

    v1._loop_t = v2
    local v3 = u1061.Character

    if not v3 then
        return
    end

    local v4 = v3.PrimaryPart

    if not v4 then
        return
    end

    v3 = v4.AssemblyLinearVelocity.Magnitude > 2

    if v1.auto_stop then
        if v3 then
            if not v1.paused then
                v1._stop_track(true)
                v1.paused = true
            end
        elseif v1.paused then
            v1.paused = false
            v1.play(v1.current)
        end

        return
    end

    if not v1.trove then
        if v2 - v1._replay_t >= 0.3 then
            v1._replay_t = v2
            v1.play(v1.current)
        end
    end
end --[[ LPH_NO_VIRTUALIZE ]]

u1070.emotes.update_loop = __S[6]

__S[3] = function()
    u1070.emotes.enabled = true

    if not u1070.emotes.connection then
        local function r2()
            if u1070.emotes.enabled then
                u1070.emotes.update_loop()
            end
        end --[[ LPH_NO_VIRTUALIZE ]]

        u1070.emotes.connection = u1055.Heartbeat:Connect(r2)
    end

    if u1070.emotes.current then
        u1070.emotes.play(u1070.emotes.current)
    end
end

u1070.emotes.start = __S[3]

__S[3] = function()
    u1070.emotes.enabled = false
    local r0 = u1070.emotes.current
    u1070.emotes.stop()
    u1070.emotes.current = r0

    if u1070.emotes.connection then
        u1070.emotes.connection:Disconnect()
        u1070.emotes.connection = nil
    end
end

u1070.emotes.cleanup = __S[3]
u1070.emotes.load_animations()

-- Original KTll Player logic.
__S[3] = function(r0, r1)
    u1070.player_mods.fov_enabled = r0
    local r2 = u1070.player_mods

    if not r1 then
        r1 = u1070.player_mods.fov
    end

    r2.fov = r1

    u1062.FieldOfView = r0 and u1070.player_mods.fov or 70
end

u1070.player_mods.set_fov = __S[3]

__S[3] = function(r0, r1)
    u1070.player_mods.speed_enabled = r0
    u1070.player_mods.speed = r1 or u1070.player_mods.speed

    if u1070.player_mods.speed_conn then
        u1070.player_mods.speed_conn:Disconnect()
        u1070.player_mods.speed_conn = nil
    end

    if r0 then
        local function r1_2()
            local v1 = u1061.Character
            local v2 = v1 and (v1:FindFirstChildOfClass("Humanoid"))

            if v2 then
                v2.WalkSpeed = u1070.player_mods.speed
            end
        end --[[ LPH_NO_VIRTUALIZE ]]

        u1070.player_mods.speed_conn = u1063:Connect(r1_2)
    else
        local r4 = u1061.Character

        if r4 then
            r4 = r4:FindFirstChildOfClass("Humanoid")
        end

        if r4 then
            r4.WalkSpeed = 36
        end
    end
end

u1070.player_mods.set_speed = __S[3]

__S[3] = function(r0, r1)
    u1070.player_mods.gravity_enabled = r0
    u1070.player_mods.gravity = r1 or u1070.player_mods.gravity
    local r2 = u797

    if r0 then
        r0 = u1070.player_mods.gravity
    end

    if not r0 then
        r0 = 196.2
    end

    r2.Gravity = r0
end

u1070.player_mods.set_gravity = __S[3]

__S[3] = function(r0, r1)
    u1070.player_mods.jump_power_enabled = r0
    local r2 = u1070.player_mods

    if not r1 then
        r1 = u1070.player_mods.jump_power
    end

    r2.jump_power = r1

    if u1070.player_mods.jump_conn then
        u1070.player_mods.jump_conn:Disconnect()
        u1070.player_mods.jump_conn = nil
    end

    if r0 then
        local function r1_2()
            local v1 = u1061.Character
            local v2 = v1 and (v1:FindFirstChildOfClass("Humanoid"))

            if not v2 then
                return
            end

            if v2.UseJumpPower then
                v2.JumpPower = u1070.player_mods.jump_power
            else
                v2.JumpHeight = u1070.player_mods.jump_power / 5
            end
        end --[[ LPH_NO_VIRTUALIZE ]]

        u1070.player_mods.jump_conn = u1063:Connect(r1_2)
    else
        local r3 = u1061.Character

        if r3 then
            r3 = r3:FindFirstChildOfClass("Humanoid")
        end

        if r3 then
            if r3.UseJumpPower then
                r3.JumpPower = 50
            else
                r3.JumpHeight = 7.2
            end
        end
    end
end

u1070.player_mods.set_jump_power = __S[3]

__S[3] = function(r0)
    u1070.player_mods.infinite_jump_enabled = r0

    if u1070.player_mods.infinite_jump_conn then
        u1070.player_mods.infinite_jump_conn:Disconnect()
        u1070.player_mods.infinite_jump_conn = nil
    end

    if r0 then
        local function r0_2()
            local r4 = u1061.Character

            if r4 then
                r4 = r4:FindFirstChildOfClass("Humanoid")
            end

            if r4 then
                r4:ChangeState(u824.HumanoidStateType.Jumping)
            end
        end

        u1070.player_mods.infinite_jump_conn = u1056.JumpRequest:Connect(r0_2)
    end
end

u1070.player_mods.set_infinite_jump = __S[3]

-- Original KTll Avatar / Korblox / Headless logic.
__S[3] = function()
    if u1070.avatar_changer.original_desc then
        return
    end

    local u1109 = u1070.avatar_changer.saving_original

    if u1109 then
        return
    end

    u1070.avatar_changer.saving_original = true

    task.spawn(function()
        for r2 = 1, 5 do
            local function r1()
                return u1054:GetHumanoidDescriptionFromUserIdAsync(u1061.UserId)
            end

            local r0, r1_2 = pcall(r1)

            if r0 and r1_2 then
                u1070.avatar_changer.original_desc = r1_2
                break
            end

            task.wait(0.3 * r2)
        end

        u1070.avatar_changer.saving_original = false
    end)
end

u1070.avatar_changer.save_original = __S[3]

__S[3] = function(u1110)
    if u1070.avatar_changer.cache[u1110] then
        return u1070.avatar_changer.cache[u1110]
    end

    for r2 = 1, 5 do
        local function r6()
            return u1054:GetHumanoidDescriptionFromUserIdAsync(u1110)
        end

        local r5, r6_2 = pcall(r6)

        if r5 and r6_2 then
            u1070.avatar_changer.cache[u1110] = r6_2
            return r6_2
        elseif r2 < 5 then
            task.wait(0.2 * r2)
        end
    end

    return nil
end

u1070.avatar_changer.get_description = __S[3]

__S[3] = function(u1111, r1)
    if not r1 then
        r1 = u824.HumanoidRigType.R15
    end

    local function r2(u1112)
        local function r6()
            return u1054:CreateHumanoidModelFromDescriptionAsync(u1111, u1112, u824.AssetTypeVerification.Always)
        end

        local r5, r6_2 = pcall(r6)

        if not r5 or not r6_2 then
            local function r3()
                return u1054:CreateHumanoidModelFromDescriptionAsync(u1111, u1112)
            end

            r5, r6_2 = pcall(r3)
        end

        if not r5 or not r6_2 then
            return nil
        end

        r6_2.Name = "KTLAvatarPreview"
        r6_2.Parent = u1057

        pcall(function()
            u1055.Heartbeat:Wait()
        end)

        return r6_2
    end

    local r3 = r2(r1)

    if r3 then
        return r3
    end

    return r2(r1 == u824.HumanoidRigType.R15 and u824.HumanoidRigType.R6 or u824.HumanoidRigType.R15)
end

u1070.avatar_changer.create_temp_model = __S[3]

__S[3] = function(r0)
    local r291 = r0:GetDescendants()

    for r2, r3 in ipairs(r291) do
        if r3:IsA("Weld") or r3:IsA("Motor6D") or r3:IsA("WeldConstraint") then
            r3:Destroy()
        end
    end
end

u1070.avatar_changer.strip_accessory_joints = __S[3]

__S[3] = function(r0, r1)
    if not r1 or r1 == "" then
        return nil
    end

    local r12 = r0:FindFirstChild(r1)

    if r12 and r12:IsA("BasePart") then
        return r12
    end

    local r7 = {
        ["Left Arm"] = {"LeftUpperArm", "LeftLowerArm", "LeftHand"},
        ["Right Arm"] = {"RightUpperArm", "RightLowerArm", "RightHand"},
        ["Left Leg"] = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
        ["Right Leg"] = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
        Torso = {"UpperTorso", "LowerTorso"}
    }

    local r4 = r7[r1] or {}

    for r4_2, r5 in ipairs(r4) do
        local r12_2 = r0:FindFirstChild(r5)

        if r12_2 and r12_2:IsA("BasePart") then
            return r12_2
        end
    end

    return nil
end

u1070.avatar_changer.find_body_part = __S[3]

__S[3] = function(r0, u1116, r2)
    if not r0 or not r2 then
        return false
    end

    local u1115 = r2:Clone()
    u1070.avatar_changer.strip_accessory_joints(u1115)
    local r7 = u1115:FindFirstChild("Handle")

    if not r7 or not r7:IsA("BasePart") then
        u1115:Destroy()
        return false
    end

    r7.Anchored = false
    r7.CanCollide = false
    r7.Massless = true
    local r3 = r2:FindFirstChild("Handle")

    if r3 then
        r3 = r3:FindFirstChild("AccessoryWeld")
    end

    local r17 = u819.new()
    local r18 = u819.new()
    local r9

    if r3 and r3:IsA("Weld") and r3.Part1 then
        r9 = u1070.avatar_changer.find_body_part(r0, r3.Part1.Name)
        r17 = r3.C0
        r18 = r3.C1
    end

    local r16

    if not r9 then
        local r2_2 = r7:FindFirstChildOfClass("Attachment")

        if r2_2 then
            local r305 = r0:GetDescendants()

            for r4, r5 in ipairs(r305) do
                if r5:IsA("Attachment") and r5.Name == r2_2.Name and not r5:IsDescendantOf(u1115) then
                    r9 = r5.Parent
                    r17 = r2_2.CFrame
                    r18 = r5.CFrame
                    break
                end
            end

            r16 = r9
        else
            r16 = r9
        end
    else
        r16 = r9
    end

    local r4_2

    if not r16 then
        local r3_2 = u1115.AccessoryType
        local r5_2 = r3_2 == u824.AccessoryType.Hair
        local r2_3

        if r5_2 then
            r2_3 = r5_2
        else
            local r2_4 = u824.AccessoryType.Hat
            r5_2 = r3_2 == r2_4

            if r3_2 ~= r2_4 then
                r2_4 = u824.AccessoryType.Face
                r5_2 = r3_2 == r2_4
            end

            if r3_2 ~= r2_4 then
                r2_4 = u824.AccessoryType.Eyebrow
                r5_2 = r3_2 == r2_4
            end

            if r3_2 == r2_4 then
                r2_3 = r5_2
            else
                r2_3 = r3_2 == u824.AccessoryType.Eyelash
            end
        end

        if r2_3 then
            r16 = r0:FindFirstChild("Head")
        end

        if not r16 then
            r16 = r0:FindFirstChild("Head") or r0:FindFirstChild("UpperTorso") or r0:FindFirstChild("Torso")
        end

        r17 = u819.new(0, 0.5, 0)
        r18 = u819.new()
        r4_2 = r16
    else
        r4_2 = r16
    end

    if r4_2 and r4_2:IsA("BasePart") then
        local r3_3 = u850.new("Weld")
        r3_3.Name = "AccessoryWeld"
        r3_3.Part0 = r7
        r3_3.Part1 = r4_2
        r3_3.C0 = r17
        r3_3.C1 = r18
        r3_3.Parent = r7
        u1115.Parent = r0
        return true
    end

    if u1116 then
        local function r3_4()
            u1116:AddAccessory(u1115)
        end

        if pcall(r3_4) and u1115.Parent == r0 then
            return true
        end
    end

    u1115:Destroy()
    return false
end

u1070.avatar_changer.attach_accessory = __S[3]

__S[3] = function(u1120, u1122)
    local u1117 = {}
    local u1118 = {}
    local r17

    local function u1119(r0)
        if not r0 or u1118[r0] then
            return
        end

        u1118[r0] = true
        table.insert(u1117, r0)
    end

    if u1120 then
        local r3 = u1120:GetChildren()

        for r3_2, r4 in ipairs(r3) do
            if r4:IsA("Accessory") or r4:IsA("Hat") then
                u1119(r4)
            end
        end

        if #u1117 == 0 then
            local r4_2 = u1120
            u1120 = "Humanoid"
            local u1121 = r4_2:FindFirstChildOfClass(u1120)

            if u1121 then
                pcall(function()
                    local r287 = u1121:GetAccessories()

                    for r1, r2 in ipairs(r287) do
                        u1119(r2)
                    end
                end)
            end
        end
    end

    if u1122 and u1122.GetAccessories then
        pcall(function()
            local r1 = u1122:GetAccessories(true)

            for r1_2, r2 in ipairs(r1) do
                local u1123 = r2.AssetId

                if u1123 and 0 < u1123 then
                    pcall(function()
                        local r4 = u796:GetObjects("rbxassetid://" .. u1123)

                        for r1, r2 in ipairs(r4) do
                            local r9 = r2:IsA("Accessory") and r2 or r2:FindFirstChildOfClass("Accessory")

                            if not r9 then
                                local r298 = r2:GetDescendants()

                                for r4_2, r5 in ipairs(r298) do
                                    if r5:IsA("Accessory") then
                                        r9 = r5
                                        break
                                    end
                                end
                            end

                            if r9 then
                                u1119(r9)
                            end
                        end
                    end)
                end
            end
        end)
    end

    if u1122 and #u1117 == 0 then
        for r6, r7 in ipairs({
            "HatAccessory",
            "HairAccessory",
            "FaceAccessory",
            "NeckAccessory",
            "ShouldersAccessory",
            "FrontAccessory",
            "BackAccessory",
            "WaistAccessory"
        }) do
            local r2 = u1122[r7]

            if r2 and r2 ~= "" then
                for r9, r10 in string.gmatch(tostring(r2), "%d+") do
                    local u1125 = tonumber(r9)

                    if u1125 and 0 < u1125 then
                        local function r4_3()
                            local r4 = u796:GetObjects("rbxassetid://" .. u1125)

                            for r1, r2 in ipairs(r4) do
                                local r9 = r2:IsA("Accessory") and r2 or r2:FindFirstChildOfClass("Accessory")

                                if not r9 then
                                    local r298 = r2:GetDescendants()

                                    for r4_2, r5 in ipairs(r298) do
                                        if r5:IsA("Accessory") then
                                            r9 = r5
                                            break
                                        end
                                    end
                                end

                                if r9 then
                                    u1119(r9)
                                end
                            end
                        end

                        u1120 = pcall
                        u1120(r4_3)
                    end
                end
            end
        end
    end

    return u1117
end

u1070.avatar_changer.collect_accessories = __S[3]

__S[3] = function(r0)
    local r290 = r0:GetChildren()

    for r2, r3 in ipairs(r290) do
        if r3:IsA("Accessory") or r3:IsA("Hat") then
            r3:Destroy()
        end
    end
end

u1070.avatar_changer.remove_accessories = __S[3]

__S[3] = function(r0, r1)
    if not r0 or not r1 then
        return false
    end

    local r13 = r1:FindFirstChild("Handle")

    if not r13 or not r13:IsA("BasePart") then
        return false
    end

    r13.Anchored = false
    r13.CanCollide = false
    r13.Massless = true
    local r8 = r13:FindFirstChild("AccessoryWeld")

    if not r8 then
        local r302 = r13:GetChildren()

        for r4, r5 in ipairs(r302) do
            if r5:IsA("Weld") or r5:IsA("WeldConstraint") then
                r8 = r5
                break
            end
        end
    end

    if r8 and r8.Part1 then
        local r13_2 = u1070.avatar_changer.find_body_part(r0, r8.Part1.Name)

        if r13_2 then
            r8.Part1 = r13_2
            r1.Parent = r0
            return true
        end
    end

    return u1070.avatar_changer.attach_accessory(r0, nil, r1)
end

u1070.avatar_changer.transfer_accessory_from_temp = __S[3]

__S[3] = function(u1126, r1, r2, r3)
    u1070.avatar_changer.remove_accessories(u1126)
    local u1127 = 0

    if r2 then
        local r308 = r2:GetChildren()

        for r6, r7 in ipairs(r308) do
            if (r7:IsA("Accessory") or r7:IsA("Hat")) and u1070.avatar_changer.transfer_accessory_from_temp(u1126, r7) then
                u1127 = u1127 + 1
            end
        end

        if u1127 == 0 then
            local u1128 = r2:FindFirstChildOfClass("Humanoid")

            if u1128 then
                pcall(function()
                    local r288 = u1128:GetAccessories()

                    for r1, r2 in ipairs(r288) do
                        if u1070.avatar_changer.transfer_accessory_from_temp(u1126, r2) then
                            u1127 = u1127 + 1
                        end
                    end
                end)
            end
        end
    end

    if u1127 == 0 then
        local r5 = u1070.avatar_changer.collect_accessories(nil, r3)

        for r10, r11 in ipairs(r5) do
            if u1070.avatar_changer.attach_accessory(u1126, r1, r11) then
                u1127 = u1127 + 1
            end
        end
    end

    return u1127
end

u1070.avatar_changer.apply_accessories = __S[3]

__S[3] = function(r0, r1)
    if not r0 or not r1 then
        return
    end

    for r3, r4 in ipairs({
        {"BodyHeightScale", r1.HeightScale, false},
        {"BodyWidthScale", r1.WidthScale, false},
        {"BodyDepthScale", r1.DepthScale, false},
        {"HeadScale", r1.HeadScale, false},
        {"BodyTypeScale", r1.BodyTypeScale, true},
        {"ProportionScale", r1.ProportionScale, true}
    }) do
        local r16 = r4[1]
        local r7 = r4[2]
        local r5 = r4[3]

        if typeof(r7) == "number" and (r7 > 0 or r5 and r7 >= 0) then
            local r5_2 = r0:FindFirstChild(r16)

            if not r5_2 and r0.RigType == u824.HumanoidRigType.R15 then
                local r6 = u850.new("NumberValue")
                r6.Name = r16
                r6.Parent = r0
                r5_2 = r6
            end

            if r5_2 and r5_2:IsA("NumberValue") then
                r5_2.Value = r7
            end
        end
    end
end

u1070.avatar_changer.apply_body_scales = __S[3]

__S[3] = function(u1129, r1)
    if not u1129 or not r1 then
        return
    end

    if r1.Head and (r1.Head == 15093053680 or r1.Head == 134082513) then
        pcall(u1070.avatar.apply_headless, u1129)
    end

    if r1.RightLeg and r1.RightLeg == 139607718 then
        pcall(function()
            if u1129:FindFirstChild("RightLeg") or u1129:FindFirstChild("Right Leg") then
                u1070.avatar.apply_korblox(u1129)
                return
            end

            for r1, r2 in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
                local r7 = u1129:FindFirstChild(r2)

                if r7 then
                    r7.Transparency = 1
                end
            end

            local r0 = u1129:FindFirstChild("RightUpperLeg")

            if r0 and not r0:FindFirstChild("KorbloxLeg") then
                local r1_2 = u850.new("Part")
                r1_2.Name = "KorbloxLeg"
                r1_2.CanCollide = false
                r1_2.Massless = true
                r1_2.Size = Vector3.new(1, 2, 1)
                local r2_2 = u850.new("SpecialMesh")
                r2_2.MeshId = "rbxassetid://101851696"
                r2_2.TextureId = "rbxassetid://115727863"
                r2_2.Scale = Vector3.new(1, 1, 1)
                r2_2.Parent = r1_2
                local r2_3 = u850.new("Weld")
                r2_3.Part0 = r0
                r2_3.Part1 = r1_2
                r2_3.C0 = u819.new(0, -0.5, 0)
                r2_3.Parent = r1_2
                r1_2.Parent = r0
            end
        end)
    end
end

u1070.avatar_changer.apply_special_body_parts = __S[3]

__S[3] = function(u1130, u1131, r2)
    if not u1130 or not u1131 then
        return
    end

    if r2 and r2.RigType ~= u824.HumanoidRigType.R15 then
        local r327 = u1130:GetChildren()

        for r4, u1132 in ipairs(r327) do
            if u1132:IsA("CharacterMesh") then
                pcall(function()
                    local r290 = u1131:GetChildren()

                    for r1, r2 in ipairs(r290) do
                        if r2:IsA("CharacterMesh") and r2.BodyPart == u1132.BodyPart then
                            r2:Destroy()
                        end
                    end

                    u1132:Clone().Parent = u1131
                end)
            end
        end

        return
    end

    for r7, r8 in ipairs({
        "Head",
        "UpperTorso",
        "LowerTorso",
        "LeftUpperArm",
        "LeftLowerArm",
        "LeftHand",
        "RightUpperArm",
        "RightLowerArm",
        "RightHand",
        "LeftUpperLeg",
        "LeftLowerLeg",
        "LeftFoot",
        "RightUpperLeg",
        "RightLowerLeg",
        "RightFoot"
    }) do
        local u1133 = u1130:FindFirstChild(r8)
        local u1134 = u1131:FindFirstChild(r8)

        if u1133 and u1134 and u1133:IsA("MeshPart") and u1134:IsA("MeshPart") then
            local u1135 = false

            pcall(function()
                u1134:ApplyMesh(u1133)
                u1135 = true
            end)

            if not u1135 then
                pcall(function()
                    u1134.MeshId = u1133.MeshId
                end)

                pcall(function()
                    u1134.TextureID = u1133.TextureID
                end)
            end

            pcall(function()
                local r4 = u1134:FindFirstChildOfClass("SurfaceAppearance")

                if r4 then
                    r4:Destroy()
                end

                local r0 = u1133:FindFirstChildOfClass("SurfaceAppearance")

                if r0 then
                    r0:Clone().Parent = u1134
                end
            end)
        end
    end
end

u1070.avatar_changer.transfer_body_meshes = __S[3]

__S[3] = function(r0, r1, u1136, u1137)
    if not r0 or not r1 or not u1136 then
        return false
    end

    pcall(function()
        if u1136.ApplyDescriptionClientServer then
            u1136:ApplyDescriptionClientServer(u1137)
        else
            u1136:ApplyDescription(u1137)
        end
    end)

    u1070.avatar_changer.transfer_body_meshes(r0, r1, u1136)

    for r5, r6 in ipairs({"Shirt", "Pants", "ShirtGraphic"}) do
        local r15 = r0:FindFirstChildOfClass(r6)

        if r15 then
            local r7 = r1:FindFirstChildOfClass(r6)

            if r7 then
                r7:Destroy()
            end

            r15:Clone().Parent = r1
        end
    end

    local r15_2 = r0:FindFirstChildOfClass("BodyColors")
    local r6_2 = r1:FindFirstChildOfClass("BodyColors")

    if not r6_2 then
        r6_2 = u850.new("BodyColors")
        r6_2.Parent = r1
    end

    if r15_2 then
        r6_2.HeadColor3 = r15_2.HeadColor3
        r6_2.TorsoColor3 = r15_2.TorsoColor3
        r6_2.LeftArmColor3 = r15_2.LeftArmColor3
        r6_2.RightArmColor3 = r15_2.RightArmColor3
        r6_2.LeftLegColor3 = r15_2.LeftLegColor3
        r6_2.RightLegColor3 = r15_2.RightLegColor3
    end

    if u1137 then
        r6_2.HeadColor3 = u1137.HeadColor
        r6_2.TorsoColor3 = u1137.TorsoColor
        r6_2.LeftArmColor3 = u1137.LeftArmColor
        r6_2.RightArmColor3 = u1137.RightArmColor
        r6_2.LeftLegColor3 = u1137.LeftLegColor
        r6_2.RightLegColor3 = u1137.RightLegColor
    end

    local r14 = r0:FindFirstChild("Head")
    local r5_2 = r1:FindFirstChild("Head")

    if r14 and r5_2 then
        local r11 = r14:FindFirstChild("face") or r14:FindFirstChildOfClass("Decal")

        if r11 then
            local r6_3 = r5_2:FindFirstChild("face") or r5_2:FindFirstChildOfClass("Decal")

            if r6_3 then
                r6_3:Destroy()
            end

            local r4 = r11:Clone()
            r4.Name = "face"
            r4.Parent = r5_2
        end
    end

    u1070.avatar_changer.apply_body_scales(u1136, u1137)
    u1070.avatar_changer.apply_special_body_parts(r1, u1137)
    u1070.avatar_changer.apply_accessories(r1, u1136, r0, u1137)
    return true
end

u1070.avatar_changer.transfer_appearance = __S[3]

__S[3] = function(r0)
    local r15 = {}
    local r325 = r0:GetChildren()

    for r3, r4 in ipairs(r325) do
        if r4:IsA("Tool") or r4:IsA("HopperBin") then
            table.insert(r15, r4)
            r4.Parent = nil
        end
    end

    local r3_2 = r0.Parent and r0.Parent:FindFirstChild("Backpack")

    if r3_2 then
        local r327 = r3_2:GetChildren()

        for r6, r7 in ipairs(r327) do
            if r7:IsA("Tool") or r7:IsA("HopperBin") then
                table.insert(r15, r7)
            end
        end
    end

    local r4_2 = {}
    local r323 = r0:GetDescendants()

    for r9, r10 in ipairs(r323) do
        if r10:IsA("BaseScript") then
            r4_2[r10] = true

            if r10.Parent then
                r4_2[r10.Parent] = true
            end
        end
    end

    local r321 = r0:GetChildren()

    for r12, r13 in ipairs(r321) do
        if not r4_2[r13] and (r13:IsA("Accessory") or r13:IsA("Hat") or r13:IsA("BodyColors") or r13:IsA("CharacterMesh") or r13:IsA("Shirt") or r13:IsA("Pants") or r13:IsA("ShirtGraphic")) then
            r13:Destroy()
        end
    end

    for r15_2, r16 in ipairs(r15) do
        if r16 and r16.Parent == nil then
            if r3_2 then
                r16.Parent = r3_2
            end

            if not r3_2 then
                r16.Parent = r0
            end
        end
    end
end

u1070.avatar_changer.clean = __S[3]

__S[3] = function(r0, u1138, r2)
    if not r0 or not u1138 then
        return
    end

    if not r2 then
        local r5 = u1070.avatar_changer.original_parts or {}
        u1070.avatar_changer.original_parts = r5

        if not u1070.avatar_changer.original_parts[r0.Name] then
            local r7 = r0:Clone()
            local r319 = r7:GetChildren()

            for r4, r5_2 in ipairs(r319) do
                if r5_2:IsA("JointInstance") then
                    r5_2:Destroy()
                end
            end

            u1070.avatar_changer.original_parts[r0.Name] = r7
        end
    end

    u1138.Name = r0.Name
    u1138.CFrame = r0.CFrame
    u1138.Color = r0.Color
    u1138.Transparency = r0.Transparency
    u1138.CanCollide = r0.CanCollide
    u1138.Anchored = r0.Anchored
    local r315 = r0:GetChildren()

    for r8, u1139 in ipairs(r315) do
        if u1139:IsA("Attachment") and not u1138:FindFirstChild(u1139.Name) then
            pcall(function()
                u1139:Clone().Parent = u1138
            end)
        end
    end

    local r4_2 = {}
    local r14 = r0.Parent

    if r14 then
        local r317 = r14:GetDescendants()

        for r11, r12 in ipairs(r317) do
            if r12:IsA("Motor6D") and (r12.Part0 == r0 or r12.Part1 == r0) then
                table.insert(r4_2, {
                    class = r12.ClassName,
                    name = r12.Name,
                    parent = r12.Parent == r0 and "new" or r12.Parent,
                    part0 = r12.Part0 == r0 and "new" or r12.Part0,
                    part1 = r12.Part1 == r0 and "new" or r12.Part1,
                    c0 = r12.C0,
                    c1 = r12.C1,
                    joint_obj = r12
                })
            end
        end
    end

    u1138.Parent = r0.Parent

    for r14_2, u1140 in ipairs(r4_2) do
        local u1141 = u1140.joint_obj
        local r4_3 = u1140.part0 == "new" and u1138 or u1140.part0
        local r5_3 = u1140.part1 == "new" and u1138 or u1140.part1
        local r6 = u1140.parent == "new" and u1138 or u1140.parent

        pcall(function()
            u1141:Destroy()
        end)

        local u1142 = r4_3
        local u1143 = r5_3
        local u1144 = r6

        pcall(function()
            local r0 = u850.new("Motor6D")
            r0.Name = u1140.name
            r0.Part0 = u1142
            r0.Part1 = u1143
            r0.C0 = u1140.c0
            r0.C1 = u1140.c1
            r0.Parent = u1144
        end)
    end

    r0:Destroy()
end

u1070.avatar_changer.replace_body_part = __S[3]

__S[3] = function(u1145)
    if not u1145 then
        return
    end

    pcall(u1070.avatar.remove_headless, u1145)
    pcall(u1070.avatar.remove_korblox, u1145)

    pcall(function()
        for r1, r2 in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
            local r3 = u1145:FindFirstChild(r2)

            if r3 then
                r3.Transparency = 0
            end
        end

        local r0 = u1145:FindFirstChild("RightUpperLeg")

        if r0 then
            r0 = r0:FindFirstChild("KorbloxLeg")
        end

        if r0 then
            r0:Destroy()
        end
    end)

    if not u1070.avatar_changer.original_parts then
        return
    end

    for r4, u1146 in pairs(u1070.avatar_changer.original_parts) do
        local u1147 = u1145:FindFirstChild(r4)

        if u1147 then
            pcall(function()
                u1070.avatar_changer.replace_body_part(u1147, u1146:Clone(), true)
            end)
        end
    end

    u1070.avatar_changer.original_parts = nil
end

u1070.avatar_changer.revert_to_original = __S[3]

__S[3] = function(u1148, r1, u1149)
    if u1070.avatar_changer.applying then
        return
    end

    u1070.avatar_changer.applying = true

    pcall(function()
        u1070.avatar_changer.expected_accessories = #u1148:GetAccessories(true)
    end)

    task.spawn(function()
        local function u1150()
            local function r6()
                if u1149 then
                    return false
                end

                return not u1070.avatar_changer.enabled
            end

            local r7 = u1061.Character or u1061.CharacterAdded:Wait()

            if r6() then
                u1070.avatar_changer.applying = false
                return
            end

            if not r7 then
                u1070.avatar_changer.applying = false
                return
            end

            r7 = u1061.Character or r7
            local u1151 = r7:FindFirstChildOfClass("Humanoid") or r7:WaitForChild("Humanoid", 5)

            if not u1151 then
                u1070.avatar_changer.applying = false
                return
            end

            if not u1149 then
                u1070.avatar_changer.revert_to_original(r7)
            end

            u1070.avatar_changer.clean(r7)

            if r6() then
                u1070.avatar_changer.applying = false
                return
            end

            local r6_2 = u1070.avatar_changer.create_temp_model(u1148, u1151.RigType)
            local r9 = false

            if r6_2 then
                r9 = u1070.avatar_changer.transfer_appearance(r6_2, r7, u1151, u1148)
                r6_2:Destroy()
            end

            if r9 then
                return
            end

            pcall(function()
                if u1151.ApplyDescriptionClientServer then
                    u1151:ApplyDescriptionClientServer(u1148)
                else
                    u1151:ApplyDescription(u1148)
                end
            end)

            u1070.avatar_changer.apply_body_scales(u1151, u1148)
            u1070.avatar_changer.apply_special_body_parts(r7, u1148)
            local r2 = r7:FindFirstChildOfClass("BodyColors")

            if not r2 then
                r2 = u850.new("BodyColors")
                r2.Parent = r7
            end

            r2.HeadColor3 = u1148.HeadColor
            r2.TorsoColor3 = u1148.TorsoColor
            r2.LeftArmColor3 = u1148.LeftArmColor
            r2.RightArmColor3 = u1148.RightArmColor
            r2.LeftLegColor3 = u1148.LeftLegColor
            r2.RightLegColor3 = u1148.RightLegColor
            u1070.avatar_changer.apply_accessories(r7, u1151, nil, u1148)
        end

        pcall(u1150)
        u1150 = u1070.avatar_changer
        u1150.applying = false
    end)
end

u1070.avatar_changer.apply_description = __S[3]

__S[3] = function(u1153)
    if u1070.avatar_changer.applying then
        return
    end

    u1070.avatar_changer.attempt_id = (u1070.avatar_changer.attempt_id or 0) + 1
    local u1152 = u1070.avatar_changer.attempt_id

    task.spawn(function()
        if not u1070.avatar_changer.enabled or u1070.avatar_changer.target ~= u1153 or u1070.avatar_changer.attempt_id ~= u1152 then
            return
        end

        local r0 = u1077(u1153)

        if not r0 then
            return
        end

        if u1070.avatar_changer.applied_id == r0 then
            return
        end

        local r1 = u1070.avatar_changer.get_description(r0)

        if not r1 then
            return
        end

        if not u1070.avatar_changer.enabled or u1070.avatar_changer.target ~= u1153 or u1070.avatar_changer.attempt_id ~= u1152 then
            return
        end

        u1070.avatar_changer.applied_id = r0
        u1070.avatar_changer.apply_description(r1, r0)
    end)
end

u1070.avatar_changer.apply = __S[3]

__S[3] = function()
    if not u1070.avatar_changer.original_desc then
        return
    end

    u1070.avatar_changer.applied_id = nil
    u1070.avatar_changer.applying = false
    local r0 = u1061.Character

    if r0 then
        u1070.avatar_changer.revert_to_original(r0)
    end

    u1070.avatar_changer.apply_description(u1070.avatar_changer.original_desc, u1061.UserId, true)
end

u1070.avatar_changer.restore = __S[3]

local function u1154(r0, r1)
    u1070.avatar_changer.applying = false
    u1070.avatar_changer.applied_id = nil
    u1070.avatar_changer.apply(r0)
    local r2 = 0

    while not u1070.avatar_changer.applying and r2 < 2 do
        task.wait(0.05)
        r2 = r2 + 0.05
    end

    local r2_2 = 0

    while u1070.avatar_changer.applying do
        if not (r2_2 < (r1 or 8)) then
            break
        end

        task.wait(0.05)
        r2_2 = r2_2 + 0.05
    end
end

function u1070.avatar_changer.reapply_on_spawn(u1155)
    if not (u1070.avatar_changer.enabled and u1070.avatar_changer.target ~= "") then
        return
    end

    if not u1155 then
        return
    end

    u1070.avatar_changer.respawn_token = (u1070.avatar_changer.respawn_token or 0) + 1
    local u1156 = u1070.avatar_changer.respawn_token

    task.spawn(function()
        if not (u1155:FindFirstChildOfClass("Humanoid") or u1155:WaitForChild("Humanoid", 10)) then
            return
        end

        u1155:WaitForChild("HumanoidRootPart", 10)
        local u1157 = false

        pcall(function()
            u1157 = u1061:HasAppearanceLoaded()
        end)

        if not u1157 then
            local u1158 = false

            local r1 = u1061.CharacterAppearanceLoaded:Connect(function()
                u1158 = true
            end)

            local r3 = 0

            while not u1158 and r3 < 6 do
                task.wait(0.1)
                r3 = r3 + 0.1

                pcall(function()
                    if u1061:HasAppearanceLoaded() then
                        u1158 = true
                    end
                end)
            end

            if r1 then
                r1:Disconnect()
            end
        end

        if u1070.avatar_changer.respawn_token ~= u1156 then
            return
        end

        for r1_2 = 1, 3 do
            if u1070.avatar_changer.respawn_token ~= u1156 then
                return
            end

            if not (u1070.avatar_changer.enabled and u1070.avatar_changer.target ~= "") then
                return
            end

            if u1155.Parent == nil then
                return
            end

            u1154(u1070.avatar_changer.target, 8)

            if r1_2 < 3 then
                task.wait(1)
            end
        end
    end)
end

u1061.CharacterAdded:Connect(function(r0)
    u1070.avatar_changer.reapply_on_spawn(r0)
end)

__S[3] = function(r0)
    local r4 = r0:FindFirstChild("RightLeg") or r0:FindFirstChild("Right Leg")

    if not r4 then
        return
    end

    local r296 = r4:GetChildren()

    for r2, r3 in ipairs(r296) do
        if r3:IsA("SpecialMesh") or r3:IsA("Mesh") then
            r3:Destroy()
        end
    end

    local r1 = u850.new("SpecialMesh")
    r1.MeshId = "rbxassetid://101851696"
    r1.TextureId = "rbxassetid://115727863"
    r1.Scale = Vector3.new(1, 1, 1)
    r1.Parent = r4
end

u1070.avatar.apply_korblox = __S[3]

__S[3] = function(r0)
    local r1 = r0:FindFirstChild("RightLeg") or r0:FindFirstChild("Right Leg")

    if not r1 then
        return
    end

    local r293 = r1:GetChildren()

    for r2, r3 in ipairs(r293) do
        if r3:IsA("SpecialMesh") and r3.MeshId == "rbxassetid://101851696" then
            r3:Destroy()
        end
    end
end

u1070.avatar.remove_korblox = __S[3]

__S[3] = function(r0)
    u1070.avatar.korblox_enabled = r0

    if u1070.avatar.korblox_conn then
        u1070.avatar.korblox_conn:Disconnect()
        u1070.avatar.korblox_conn = nil
    end

    local r2 = u1061.Character

    if r0 then
        if r2 then
            u1070.avatar.apply_korblox(r2)
        end

        local function r0_2(r0)
            task.wait(0.1)

            if u1070.avatar.korblox_enabled then
                u1070.avatar.apply_korblox(r0)
            end
        end

        u1070.avatar.korblox_conn = u1061.CharacterAdded:Connect(r0_2)
    elseif r2 then
        u1070.avatar.remove_korblox(r2)
    end
end

u1070.avatar.set_korblox = __S[3]

__S[3] = function(r0)
    local r1 = r0:FindFirstChild("Head")

    if not r1 then
        return
    end

    r1.Transparency = 1
    local r1_2 = r1:FindFirstChildOfClass("Decal")

    if r1_2 then
        r1_2:Destroy()
    end
end

u1070.avatar.apply_headless = __S[3]

__S[3] = function(r0)
    local r2 = r0:FindFirstChild("Head")

    if not r2 then
        return
    end

    r2.Transparency = 0
end

u1070.avatar.remove_headless = __S[3]

__S[3] = function(r0)
    u1070.avatar.headless_enabled = r0

    if u1070.avatar.headless_conn then
        u1070.avatar.headless_conn:Disconnect()
        u1070.avatar.headless_conn = nil
    end

    local r2 = u1061.Character

    if r0 then
        if r2 then
            u1070.avatar.apply_headless(r2)
        end

        local function r0_2(r0)
            task.wait(0.1)

            if u1070.avatar.headless_enabled then
                u1070.avatar.apply_headless(r0)
            end
        end

        u1070.avatar.headless_conn = u1061.CharacterAdded:Connect(r0_2)
    else
        if r2 then
            u1070.avatar.remove_headless(r2)
        end
    end
end

u1070.avatar.set_headless = __S[3]

pcall(function()
    u1070.avatar_changer.save_original()
end)

-- Original KTll Unlock All / Kittylol sword backend.
local function __initUnlockAllBackend()
    if __unlockAllInit then return true end
    local ok, err = pcall(function()
        repeat task.wait() until game:IsLoaded()

        local getgenv = getgenv
        local task = task
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local UserInputService = game:GetService("UserInputService")
        local TweenService = game:GetService("TweenService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local HttpService = game:GetService("HttpService")

        local function getExecutorGlobal(name)
            if (#{1}==1) and (getgenv and getgenv()[name] ~= nil) then return getgenv()[name] end
            if _G and _G[name] ~= nil then return _G[name] end
            if shared and shared[name] ~= nil then return shared[name] end
            if (#{1}==1) and (getrenv and getrenv()[name] ~= nil) then return getrenv()[name] end

            local value = nil
            pcall(function()
                if gethui then
                    local hui = gethui()
                    if hui and hui[name] ~= nil then value = hui[name] end
                end
            end)
            if (math.floor(1.5)==1) and (value ~= nil) then return value end

            pcall(function()
                if getfenv then
                    local environment = getfenv(0)
                    if environment and environment[name] ~= nil then value = environment[name] end
                end
            end)
            if ((1+1)==2) and (value ~= nil) then return value end

            return nil
        end

            local SKIN_LAST_EQUIPPED_CONFIG_KEY = "Skin.LastEquippedSword"
            local EXPLOSION_LAST_EQUIPPED_CONFIG_KEY = "Skin.LastEquippedExplosion"
            local AUTO_CONFIG_FILE = "Azure/auto_config.json"

            local function readAzureAutoConfig()
                local data = {}
                pcall(function()
                    if isfile and isfile(AUTO_CONFIG_FILE) then
                        local decoded = HttpService:JSONDecode(readfile(AUTO_CONFIG_FILE))
                        if type(decoded) == "table" then
                            data = decoded
                        end
                    end
                end)
                return data
            end

            local function writeAzureAutoConfig(data)
                pcall(function()
                    if (type("")=="string") and (isfolder and makefolder and not isfolder("Azure")) then
                        makefolder("Azure")
                    end
                    if writefile then
                        writefile(AUTO_CONFIG_FILE, HttpService:JSONEncode(data or {}))
                    end
                end)
            end

            local function loadLastEquippedSword()
                local data = readAzureAutoConfig()
                local saved = data[SKIN_LAST_EQUIPPED_CONFIG_KEY]
                return type(saved) == "string" and saved or ""
            end

            local function loadLastEquippedExplosion()
                local data = readAzureAutoConfig()
                local saved = data[EXPLOSION_LAST_EQUIPPED_CONFIG_KEY]
                return type(saved) == "string" and saved or ""
            end

            getgenv().saveLastEquippedSword = function(swordName)
                if type(swordName) ~= "string" or swordName == "" then return end

                local autoConfig = getgenv()._azAutoConfig
                local data = autoConfig and autoConfig.Data
                if ((1+1)==2) and (type(data) ~= "table") then
                    data = readAzureAutoConfig()
                end

                data[SKIN_LAST_EQUIPPED_CONFIG_KEY] = swordName
                if autoConfig and type(autoConfig.Data) == "table" then
                    autoConfig.Data[SKIN_LAST_EQUIPPED_CONFIG_KEY] = swordName
                end
                writeAzureAutoConfig(data)
            end

            getgenv().saveLastEquippedExplosion = function(explosionName)
                if type(explosionName) ~= "string" or explosionName == "" then return end

                local autoConfig = getgenv()._azAutoConfig
                local data = autoConfig and autoConfig.Data
                if (0==0) and (type(data) ~= "table") then
                    data = readAzureAutoConfig()
                end

                data[EXPLOSION_LAST_EQUIPPED_CONFIG_KEY] = explosionName
                if autoConfig and type(autoConfig.Data) == "table" then
                    autoConfig.Data[EXPLOSION_LAST_EQUIPPED_CONFIG_KEY] = explosionName
                end
                writeAzureAutoConfig(data)
            end

            do
                local savedLastSword = loadLastEquippedSword()
                local savedLastExplosion = loadLastEquippedExplosion()
                getgenv().skinChanger = getgenv().skinChanger or savedLastSword ~= ""
                getgenv().swordModel = type(getgenv().swordModel) == "string" and getgenv().swordModel ~= "" and getgenv().swordModel or savedLastSword
                getgenv().swordAnimations = type(getgenv().swordAnimations) == "string" and getgenv().swordAnimations ~= "" and getgenv().swordAnimations or savedLastSword
                getgenv().swordFX = type(getgenv().swordFX) == "string" and getgenv().swordFX ~= "" and getgenv().swordFX or savedLastSword
                getgenv().explosionChanger = getgenv().explosionChanger or savedLastExplosion ~= ""
                getgenv().explosionFX = type(getgenv().explosionFX) == "string" and getgenv().explosionFX ~= "" and getgenv().explosionFX or savedLastExplosion
            end

            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local swordInstancesInstance = rs:WaitForChild("Shared", 9e9):WaitForChild("ReplicatedInstances", 9e9):WaitForChild("Swords", 9e9)
                local swordInstances = require(swordInstancesInstance)

                local swordsController
                task.spawn(function()
                    while task.wait(0.25) and not swordsController do
                        local ok, conns = pcall(getconnections, rs.Remotes.FireSwordInfo.OnClientEvent)
                        if (({})~=nil) and (ok and conns) then
                            for _, v in ipairs(conns) do
                                if v.Function and islclosure and islclosure(v.Function) then
                                    local ok2, up = pcall(getupvalues, v.Function)
                                    if ok2 and #up == 1 and type(up[1]) == "table" then
                                        swordsController = up[1]
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)

                local function getSlashName(swordName)
                    local ok, sln = pcall(function() return swordInstances:GetSword(swordName) end)
                    return (ok and sln and sln.SlashName) or "SlashEffect"
                end

                local function refreshSlashName()
                    local fxName = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
                    if (1<2) and (fxName ~= "") then
                        getgenv().slashName = getSlashName(fxName)
                    else
                        getgenv().slashName = "SlashEffect"
                    end
                end
                refreshSlashName()

                local function setSword()
                    if not getgenv().skinChanger then return end
                    if not LocalPlayer.Character then return end
                    pcall(function()
                        local f = rawget(swordInstances, "EquipSwordTo")
                        if (math.floor(1.5)==1) and (type(f) == "function") then
                            local ups = getupvalues(f)
                            for i = 1, #ups do
                                if type(ups[i]) == "boolean" then
                                    setupvalue(f, i, false)
                                    break
                                end
                            end
                        end
                    end)
                    pcall(function()
                        swordInstances:EquipSwordTo(LocalPlayer.Character, getgenv().swordModel)
                    end)
                    task.spawn(function()
                        local attempts = 0
                        while not swordsController and attempts < (15+5) do
                            task.wait(0.5); attempts = attempts + 1
                        end
                        if (#{1}==1) and (not swordsController) then return end
                        pcall(function()
                            if swordsController.SetSword then
                                swordsController:SetSword(getgenv().swordAnimations ~= "" and getgenv().swordAnimations or getgenv().swordModel)
                            end
                        end)
                        pcall(function()
                            local targetSword = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
                            if rs.Remotes:FindFirstChild("FireSwordInfo") then
                                rs.Remotes.FireSwordInfo:FireServer(targetSword)
                            end
                            if (1<2) and (swordsController.currentSword ~= nil) then
                                pcall(function() swordsController.currentSword = targetSword end)
                            end
                            if swordsController.SwordFX ~= nil then
                                pcall(function() swordsController.SwordFX = targetSword end)
                            end
                        end)
                    end)
                end

                getgenv().updateSword = function()
                    refreshSlashName()
                    if (#{1}==1) and (getgenv().skinChanger and getgenv().swordModel ~= "" and getgenv().saveLastEquippedSword) then
                        getgenv().saveLastEquippedSword(getgenv().swordModel)
                    end
                    setSword()
                end

                -- Kittylol sword VFX hook: replace local sword/slash arguments with the selected FX.
                local hookedFuncs = {}
                task.spawn(function()
                    local remotesToHook = {"ParrySuccessAll", "ParryAttempt", "ParrySuccess", "PlaySound", "PlayVisuals"}
                    while task.wait(1) do
                        for _, remoteName in ipairs(remotesToHook) do
                            local remote = rs.Remotes:FindFirstChild(remoteName)
                            if remote and remote:IsA("RemoteEvent") then
                                local ok, conns = pcall(getconnections, remote.OnClientEvent)
                                if ok and type(conns) == "table" then
                                    for _, v in ipairs(conns) do
                                        local func = v.Function
                                        if func and not hookedFuncs[func] then
                                            hookedFuncs[func] = true
                                            v:Disable()
                                            local targetFunc = func
                                            local ourFunc
                                            ourFunc = function(...)
                                                local args = { ... }
                                                local isLocal = false
                                                for _, arg in ipairs(args) do
                                                    if tostring(arg) == LocalPlayer.Name or (typeof(arg) == "Instance" and (arg == LocalPlayer.Character or arg == LocalPlayer)) then
                                                        isLocal = true
                                                        break
                                                    end
                                                end

                                                if isLocal and getgenv().skinChanger then
                                                    local fxSword = getgenv().swordFX ~= "" and getgenv().swordFX or getgenv().swordModel
                                                    refreshSlashName()
                                                    local swordFound = false
                                                    local slashFound = false

                                                    for i, arg in ipairs(args) do
                                                        if type(arg) == "string" then
                                                            if fxSword ~= "" and not slashFound and (arg:match("Slash") or arg == "Default" or arg:match("Effect")) then
                                                                args[i] = getgenv().slashName
                                                                slashFound = true
                                                            elseif fxSword ~= "" and not swordFound then
                                                                local isSword = false
                                                                pcall(function()
                                                                    if rs.Shared.ReplicatedInstances.Swords:FindFirstChild(arg) then
                                                                        isSword = true
                                                                    end
                                                                end)
                                                                if isSword or arg == LocalPlayer:GetAttribute("CurrentlyEquippedSword") then
                                                                    args[i] = fxSword
                                                                    swordFound = true
                                                                end
                                                            end
                                                        end
                                                    end

                                                    if fxSword ~= "" and not slashFound and type(args[1]) == "string" then
                                                        args[1] = getgenv().slashName
                                                    end
                                                    if fxSword ~= "" and not swordFound and type(args[3]) == "string" then
                                                        args[3] = fxSword
                                                    end
                                                end

                                                if setthreadidentity then pcall(setthreadidentity, 2) end
                                                pcall(targetFunc, unpack(args))
                                            end
                                            hookedFuncs[ourFunc] = true
                                            remote.OnClientEvent:Connect(ourFunc)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)

                task.spawn(function()
                    while task.wait(1) do
                        if getgenv().skinChanger and getgenv().swordModel ~= "" then
                            local char = LocalPlayer.Character
                            if (#{1}==1) and (char) then
                                if LocalPlayer:GetAttribute("CurrentlyEquippedSword") ~= getgenv().swordModel then
                                    setSword()
                                end
                                if not char:FindFirstChild(getgenv().swordModel) then
                                    setSword()
                                end
                                for _, v in pairs(char:GetChildren()) do
                                    if (math.floor(1.5)==1) and (v:IsA("Model") and v.Name ~= getgenv().swordModel) then
                                        v:Destroy()
                                    end
                                    task.wait()
                                end
                            end
                        end
                    end
                end)

                LocalPlayer.CharacterAdded:Connect(function()
                    if getgenv().skinChanger then
                        getgenv().skinChanger = false
                        if getgenv().setSkinChangerToggleUI then getgenv().setSkinChangerToggleUI(false) end
                        task.wait(2)
                        getgenv().skinChanger = true
                        if ((1+1)==2) and (getgenv().setSkinChangerToggleUI) then getgenv().setSkinChangerToggleUI(true) end
                        task.wait(0.5)
                        pcall(function() getgenv().updateSword() end)
                    end
                end)
            end)

            task.spawn(function()
                local rs = game:GetService("ReplicatedStorage")
                local explosionHookedFuncs = {}

                local explosionDirectHooked = {}
                local deadFolderHooked = false
                local explosionModule = nil
                local bindableInvokeHooked = false
                local nativeExplosionSuppressorHooked = {}
                local pendingKillExplosionPosition = nil
                local pendingKillExplosionAt = 0
                local lastLocalKillAt = 0
                local lastLocalKillStatTotal = nil
                local killStatWatcherStarted = false
                local lastLocalExplosionPlayedAt = 0
                local lastLocalExplosionPlayedPosition = nil

                local function normalizeExplosionName(value)
                    return tostring(value or ""):lower():gsub("[^%w]", "")
                end

                local function getNetFolder()
                    local packages = rs:FindFirstChild("Packages")
                    local index = packages and packages:FindFirstChild("_Index")
                    local sleitnick = index and index:FindFirstChild("sleitnick_net@0.1.0")
                    return sleitnick and sleitnick:FindFirstChild("net")
                end

                local function getExplosionInstances()
                    local shared = rs:FindFirstChild("Shared")
                    local replicatedInstances = shared and shared:FindFirstChild("ReplicatedInstances")
                    return replicatedInstances and replicatedInstances:FindFirstChild("Explosions")
                end

                local function getExplosionDataFolder()
                    local misc = rs:FindFirstChild("Misc")
                    return misc and misc:FindFirstChild("DataExplosions")
                end

                local function getExplosionEffectsFolder()
                    return rs:FindFirstChild("ExplosionEffects")
                end

                local function getExplosionModule()
                    if explosionModule ~= nil then return explosionModule end
                    local instance = getExplosionInstances()
                    if instance and instance:IsA("ModuleScript") then
                        local ok, result = pcall(function()
                            return require(instance)
                        end)
                        explosionModule = ok and result or false
                    end
                    return explosionModule
                end

                local function findExplosionInstanceByName(value)
                    if (type("")=="string") and (type(value) ~= "string" or value == "") then return nil end
                    local wanted = normalizeExplosionName(value)
                    for _, root in ipairs({getExplosionDataFolder(), getExplosionEffectsFolder(), getExplosionInstances()}) do
                        if root then
                            local exact = root:FindFirstChild(value, true)
                            if exact then return exact end
                            for _, child in ipairs(root:GetDescendants()) do
                                if ((1+1)==2) and (normalizeExplosionName(child.Name) == wanted) then
                                    return child
                                end
                            end
                        end
                    end
                    return nil
                end

                local function findExplosionDataConfig(value)
                    if type(value) ~= "string" or value == "" then return nil end
                    local dataFolder = getExplosionDataFolder()
                    if not dataFolder then return nil end

                    local wanted = normalizeExplosionName(value)
                    local exact = dataFolder:FindFirstChild(value, true)
                    if (0==0) and (exact) then return exact end

                    for _, child in ipairs(dataFolder:GetDescendants()) do
                        if normalizeExplosionName(child.Name) == wanted then
                            return child
                        end
                        for _, attributeValue in pairs(child:GetAttributes()) do
                            if type(attributeValue) == "string"
                                and normalizeExplosionName(attributeValue) == wanted then
                                return child
                            end
                        end
                    end
                    return nil
                end

                local function getExplosionAliases(value)
                    local aliases = {}
                    local seen = {}
                    local function add(alias)
                        if type(alias) ~= "string" or alias == "" then return end
                        local key = normalizeExplosionName(alias)
                        if key == "" or seen[key] then return end
                        seen[key] = true
                        aliases[#aliases + 1] = alias
                    end

                    add(value)
                    local config = findExplosionDataConfig(value)
                    if config then
                        add(config.Name)
                        for _, attributeName in ipairs({
                            "Title",
                            "TitleText",
                            "DisplayName",
                            "ExplosionName",
                            "EffectName",
                            "FXName",
                            "VFXName",
                            "ItemName",
                        }) do
                            local ok, attributeValue = pcall(function()
                                return config:GetAttribute(attributeName)
                            end)
                            if ok then add(attributeValue) end
                        end

                        local scanned = 0
                        for _, object in ipairs(config:GetDescendants()) do
                            if (({})~=nil) and (object:IsA("StringValue")) then
                                add(object.Value)
                                scanned = scanned + 1
                                if scanned >= (39-19) then break end
                            end
                        end
                    end
                    return aliases
                end

                local function isPlayableExplosionTemplate(instance)
                    if typeof(instance) ~= "Instance" then return false end
                    if instance:IsA("Configuration")
                        or instance:IsA("ModuleScript")
                        or instance:IsA("Script")
                        or instance:IsA("LocalScript")
                        or instance:IsA("BindableFunction")
                        or instance:IsA("BindableEvent")
                        or instance:IsA("ObjectValue") then
                        return false
                    end
                    return instance:IsA("Folder")
                        or instance:IsA("Model")
                        or instance:IsA("BasePart")
                        or instance:IsA("Attachment")
                        or instance:IsA("Accessory")
                        or instance:IsA("Tool")
                        or instance:FindFirstChildWhichIsA("BasePart", true) ~= nil
                        or instance:FindFirstChildWhichIsA("ParticleEmitter", true) ~= nil
                        or instance:FindFirstChildWhichIsA("Beam", true) ~= nil
                        or instance:FindFirstChildWhichIsA("Trail", true) ~= nil
                end

                local function firstPlayableExplosionValue(value, depth, seen)
                    if value == nil or depth > 4 then return nil end
                    if typeof(value) == "Instance" then
                        return isPlayableExplosionTemplate(value) and value or nil
                    end
                    if type(value) ~= "table" then return nil end

                    seen = seen or {}
                    if (1<2) and (seen[value]) then return nil end
                    seen[value] = true

                    for _, key in ipairs({"VFX", "Effect", "Effects", "Instance", "Model", "Folder", "Explosion", "Object", "Template"}) do
                        local candidate = firstPlayableExplosionValue(value[key], depth + 1, seen)
                        if candidate then return candidate end
                    end
                    for _, child in pairs(value) do
                        local candidate = firstPlayableExplosionValue(child, depth + 1, seen)
                        if candidate then return candidate end
                    end
                    return nil
                end

                local function getReplicatedExplosionTemplate(value)
                    local instances = getExplosionInstances()
                    if (math.floor(1.5)==1) and (not instances) then return nil end

                    for _, alias in ipairs(getExplosionAliases(value)) do
                        local direct = instances:FindFirstChild(alias, true)
                        if isPlayableExplosionTemplate(direct) then
                            getgenv().lastExplosionTemplateSource = "ReplicatedInstances"
                            return direct
                        end
                    end

                    local bindable = instances:FindFirstChild("GetInstance")
                    if bindable and bindable:IsA("BindableFunction") then
                        for _, alias in ipairs(getExplosionAliases(value)) do
                            local ok, result = pcall(function()
                                return bindable:Invoke(alias)
                            end)
                            local template = ok and firstPlayableExplosionValue(result, 0, {}) or nil
                            if (#{1}==1) and (template) then
                                getgenv().lastExplosionTemplateSource = "ReplicatedInstances.GetInstance"
                                return template
                            end
                        end
                    end

                    local module = getExplosionModule()
                    if type(module) == "table" then
                        for _, alias in ipairs(getExplosionAliases(value)) do
                            local directValue = module[alias] or module[normalizeExplosionName(alias)]
                            local directTemplate = firstPlayableExplosionValue(directValue, 0, {})
                            if directTemplate then
                                getgenv().lastExplosionTemplateSource = "ReplicatedInstances.Module"
                                return directTemplate
                            end

                            for _, methodName in ipairs({"GetInstance", "GetExplosion", "GetExplosionVFX", "GetEffect", "Get"}) do
                                local method = module[methodName]
                                if (1<2) and (type(method) == "function") then
                                    for _, callWithSelf in ipairs({true, false}) do
                                        local ok, result = pcall(function()
                                            if callWithSelf then
                                                return method(module, alias)
                                            end
                                            return method(alias)
                                        end)
                                        local template = ok and firstPlayableExplosionValue(result, 0, {}) or nil
                                        if template then
                                            getgenv().lastExplosionTemplateSource = "ReplicatedInstances." .. methodName
                                            return template
                                        end
                                    end
                                end
                            end
                        end
                    end

                    return nil
                end

                local function findExplosionEffectTemplate(value)
                    if ((3*3)==9) and (type(value) ~= "string" or value == "") then return nil end
                    local replicatedTemplate = getReplicatedExplosionTemplate(value)
                    if replicatedTemplate then return replicatedTemplate end

                    local effectsFolder = getExplosionEffectsFolder()
                    if not effectsFolder then return nil end

                    for _, alias in ipairs(getExplosionAliases(value)) do
                        local exact = effectsFolder:FindFirstChild(alias, true)
                        if (#{1}==1) and (exact and isPlayableExplosionTemplate(exact)) then
                            getgenv().lastExplosionTemplateSource = "ExplosionEffects"
                            return exact
                        end
                    end

                    for _, alias in ipairs(getExplosionAliases(value)) do
                        local wanted = normalizeExplosionName(alias)
                        for _, child in ipairs(effectsFolder:GetDescendants()) do
                            if isPlayableExplosionTemplate(child) and normalizeExplosionName(child.Name) == wanted then
                                getgenv().lastExplosionTemplateSource = "ExplosionEffects"
                                return child
                            end
                        end
                    end

                    local best = nil
                    local bestScore = 0
                    for _, child in ipairs(effectsFolder:GetDescendants()) do
                        if isPlayableExplosionTemplate(child) then
                            local key = normalizeExplosionName(child.Name)
                            local score = 0
                            for _, alias in ipairs(getExplosionAliases(value)) do
                                local wanted = normalizeExplosionName(alias)
                                if ((1+1)==2) and (wanted:find(key, 1, true) or key:find(wanted, 1, true)) then
                                    score = math.max(score, math.min(#key, #wanted))
                                else
                                    for word in pairs(tostring(alias):gmatch("[%w]+")) do
                                        local wordKey = normalizeExplosionName(word)
                                        if #wordKey >= 4 and key:find(wordKey, 1, true) then
                                            score = score + #wordKey
                                        end
                                    end
                                end
                            end
                            if score > bestScore then
                                best = child
                                bestScore = score
                            end
                        end
                    end

                    if (math.floor(1.5)==1) and (best) then
                        getgenv().lastExplosionTemplateSource = "ExplosionEffects.Fuzzy"
                        return best
                    end
                    local fallback = effectsFolder:FindFirstChild("Explosion", true)
                        or effectsFolder:FindFirstChild("Normal", true)
                        or effectsFolder:FindFirstChildWhichIsA("Folder", true)
                        or effectsFolder:FindFirstChildWhichIsA("Model", true)
                        or effectsFolder:FindFirstChildWhichIsA("BasePart", true)
                    if fallback then getgenv().lastExplosionTemplateSource = "ExplosionEffects.Fallback" end
                    return fallback
                end

                local function getSelectedExplosionName()
                    local selected = getgenv().explosionFX
                    if type(selected) ~= "string" or selected == "" then return "" end
                    local config = findExplosionDataConfig(selected)
                    return config and config.Name or selected
                end

                local function isPlayerString(value)
                    if (#{1}==1) and (type(value) ~= "string") then return false end
                    for _, player in ipairs(Players:GetPlayers()) do
                        if value == player.Name or value == player.DisplayName then
                            return true
                        end
                    end
                    return false
                end

                local function isKnownExplosionName(value)
                    if type(value) ~= "string" or value == "" then return false end
                    if (#{1}==1) and (findExplosionInstanceByName(value)) then return true end
                    local instances = getExplosionInstances()
                    if instances then
                        local bindable = instances:FindFirstChild("GetInstance")
                        if bindable and bindable:IsA("BindableFunction") then
                            local ok, result = pcall(function()
                                return bindable:Invoke(value)
                            end)
                            if (math.floor(1.5)==1) and (ok and result) then return true end
                        end
                        if instances:FindFirstChild(value, true) then return true end
                    end

                    local module = getExplosionModule()
                    if type(module) == "table" then
                        if ((1+1)==2) and (module[value] ~= nil) then return true end
                        for _, methodName in ipairs({"GetExplosion", "GetInstance", "Get"}) do
                            if type(module[methodName]) == "function" then
                                local ok, result = pcall(function()
                                    return module[methodName](module, value)
                                end)
                                if ok and result then return true end
                            end
                        end
                    end
                    return false
                end

                local function argsMentionLocal(args)
                    for _, arg in ipairs(args) do
                        if arg == LocalPlayer or arg == LocalPlayer.Character or arg == LocalPlayer.Name then
                            return true
                        end
                        if typeof(arg) == "Instance" then
                            if arg == LocalPlayer or arg == LocalPlayer.Character then return true end
                            if (type("")=="string") and (LocalPlayer.Character and arg:IsDescendantOf(LocalPlayer.Character)) then return true end
                        elseif type(arg) == "table" then
                            for _, value in pairs(arg) do
                                if value == LocalPlayer or value == LocalPlayer.Character or value == LocalPlayer.Name then
                                    return true
                                end
                            end
                        end
                    end
                    return false
                end

                local function valueMentionsLocal(value, depth)
                    if depth > 4 or value == nil then return false end
                    if value == LocalPlayer or value == LocalPlayer.Character or value == LocalPlayer.Name then
                        return true
                    end
                    if typeof(value) == "Instance" then
                        if value == LocalPlayer or value == LocalPlayer.Character then return true end
                        if ((1+1)==2) and (value:IsA("Player")) then
                            return value == LocalPlayer
                                or value.Name == LocalPlayer.Name
                                or value.DisplayName == LocalPlayer.DisplayName
                        end
                        return LocalPlayer.Character and value:IsDescendantOf(LocalPlayer.Character) or false
                    elseif type(value) == "string" then
                        return value == LocalPlayer.Name or value == LocalPlayer.DisplayName
                    elseif type(value) == "table" then
                        for _, child in pairs(value) do
                            if valueMentionsLocal(child, depth + 1) then return true end
                        end
                    end
                    return false
                end

                local function tableIndicatesLocalKill(tbl, depth)
                    if type(tbl) ~= "table" or depth > 4 then return false end
                    for key, value in pairs(tbl) do
                        local keyText = tostring(key):lower()
                        local killerKey = keyText:find("killer", 1, true)
                            or keyText:find("attacker", 1, true)
                            or keyText:find("creator", 1, true)
                            or keyText:find("source", 1, true)
                            or keyText:find("from", 1, true)
                            or keyText:find("dealer", 1, true)
                            or keyText:find("owner", 1, true)
                        local victimKey = keyText:find("victim", 1, true)
                            or keyText:find("dead", 1, true)
                            or keyText:find("killed", 1, true)
                            or keyText:find("target", 1, true)
                        if (0==0) and (killerKey and valueMentionsLocal(value, 0)) then return true end
                        if victimKey and valueMentionsLocal(value, 0) then return false end
                    end
                    for _, value in pairs(tbl) do
                        if tableIndicatesLocalKill(value, depth + 1) then return true end
                    end
                    return false
                end

                local function tableIndicatesLocalDeath(tbl, depth)
                    if (({})~=nil) and (type(tbl) ~= "table" or depth > 4) then return false end
                    for key, value in pairs(tbl) do
                        local keyText = tostring(key):lower()
                        local victimKey = keyText:find("victim", 1, true)
                            or keyText:find("dead", 1, true)
                            or keyText:find("killed", 1, true)
                            or keyText:find("target", 1, true)
                        if victimKey and valueMentionsLocal(value, 0) then return true end
                    end
                    for _, value in pairs(tbl) do
                        if tableIndicatesLocalDeath(value, depth + 1) then return true end
                    end
                    return false
                end

                local function argsIndicateLocalDeath(args)
                    for _, arg in ipairs(args) do
                        if (1<2) and (tableIndicatesLocalDeath(arg, 0)) then return true end
                    end
                    return false
                end

                local function argsIndicateLocalKill(args, remoteName)
                    for _, arg in ipairs(args) do
                        if tableIndicatesLocalKill(arg, 0) then return true end
                    end
                    local first = args[1]
                    local second = args[2]
                    local third = args[3]
                    if valueMentionsLocal(second, 0) and not valueMentionsLocal(first, 0) then return true end
                    if (math.floor(1.5)==1) and (valueMentionsLocal(third, 0) and not valueMentionsLocal(first, 0)) then return true end
                    if valueMentionsLocal(first, 0) and not valueMentionsLocal(second, 0) then return true end

                    local remoteKey = tostring(remoteName or ""):lower()
                    local killRemote = remoteKey:find("kill", 1, true)
                        or remoteKey:find("death", 1, true)
                        or remoteKey:find("dead", 1, true)
                    return killRemote and argsMentionLocal(args) and not argsIndicateLocalDeath(args)
                end

                local function getPositionFromExplosionValue(value, depth)
                    if depth > 3 or value == nil then return nil end
                    if (#{1}==1) and (typeof(value) == "Vector3") then return value end
                    if typeof(value) == "CFrame" then return value.Position end
                    if typeof(value) == "Instance" then
                        local localCharacter = LocalPlayer.Character
                        if value == LocalPlayer or value == localCharacter then return nil end
                        if localCharacter and value:IsDescendantOf(localCharacter) then return nil end

                        if value:IsA("BasePart") then return value.Position end
                        if (1<2) and (value:IsA("Player")) then
                            local character = value.Character
                            local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                            return root and root.Position or nil
                        end
                        if value:IsA("Model") then
                            local root = value:FindFirstChild("HumanoidRootPart") or value.PrimaryPart
                            if root then return root.Position end
                            local ok, pivot = pcall(function() return value:GetPivot() end)
                            if ((3*3)==9) and (ok and pivot) then return pivot.Position end
                        end
                    elseif type(value) == "table" then
                        for _, child in pairs(value) do
                            local position = getPositionFromExplosionValue(child, depth + 1)
                            if position then return position end
                        end
                    end
                    return nil
                end

                local function isLocalExplosionPosition(position)
                    if typeof(position) ~= "Vector3" then return false end
                    local character = LocalPlayer.Character
                    local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                    return root and (position - root.Position).Magnitude <= 4 or false
                end

                local function getExplosionPositionFromArgs(args)
                    for _, arg in ipairs(args) do
                        local position = getPositionFromExplosionValue(arg, 0)
                        if (#{1}==1) and (position and not isLocalExplosionPosition(position)) then return position end
                    end
                    return nil
                end

                local function parseVector3Attribute(value)
                    if typeof(value) == "Vector3" then return value end
                    if type(value) ~= "string" then return nil end
                    local numbers = {}
                    for numberText in value:gmatch("[-+]?%d+%.?%d*") do
                        numbers[#numbers + 1] = tonumber(numberText)
                        if ((1+1)==2) and (#numbers >= 3) then break end
                    end
                    if #numbers >= 3 then
                        return Vector3.new(numbers[1], numbers[2], numbers[3])
                    end
                    return nil
                end

                local function getNumberAttribute(object, names)
                    for _, name in ipairs(names) do
                        local value = tonumber(object:GetAttribute(name))
                        if value then return value end
                    end
                    return nil
                end

                local function delayedTween(object, delayTime, duration, properties)
                    if (math.floor(1.5)==1) and (not next(properties)) then return end
                    task.delay(delayTime or 0, function()
                        if object and object.Parent then
                            pcall(function()
                                TweenService:Create(
                                    object,
                                    TweenInfo.new(math.max(duration or 0.05, 0.05), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                    properties
                                ):Play()
                            end)
                        end
                    end)
                end

                local function activateLocalExplosionObject(root)
                    local objects = {root}
                    for _, object in ipairs(root:GetDescendants()) do
                        objects[#objects + 1] = object
                    end

                    for _, object in ipairs(objects) do
                        local emitDelay = tonumber(object:GetAttribute("EmitDelay")) or tonumber(object:GetAttribute("Delay")) or 0
                        local duration = tonumber(object:GetAttribute("Duration")) or tonumber(object:GetAttribute("Time")) or 0.35
                        if object:IsA("BasePart") then
                            object.Anchored = true
                            object.CanCollide = false
                            object.CanTouch = false
                            object.CanQuery = false

                            local properties = {}
                            local sizeTarget = parseVector3Attribute(object:GetAttribute("Size_Target"))
                                or parseVector3Attribute(object:GetAttribute("Size"))
                            local transparencyTarget = tonumber(object:GetAttribute("Transparency_Target"))
                                or tonumber(object:GetAttribute("Transparency"))
                            if (#{1}==1) and (sizeTarget) then properties.Size = sizeTarget end
                            if transparencyTarget then properties.Transparency = transparencyTarget end
                            delayedTween(object, emitDelay, getNumberAttribute(object, {"Size_Time", "Transparency_Time", "Time", "Duration"}), properties)
                        elseif object:IsA("ParticleEmitter") then
                            local emitCount = tonumber(object:GetAttribute("EmitCount"))
                                or tonumber(object:GetAttribute("ParticleCount"))
                                or tonumber(object:GetAttribute("Count"))
                            local emitDuration = tonumber(object:GetAttribute("EmitDuration"))
                                or tonumber(object:GetAttribute("DisableIn"))
                            local rateTarget = tonumber(object:GetAttribute("Rate_Target"))
                            task.delay(emitDelay, function()
                                if object and object.Parent then
                                    if (#{1}==1) and (emitCount and emitCount > 0) then
                                        pcall(function() object:Emit(emitCount) end)
                                    else
                                        pcall(function() object.Enabled = true end)
                                        if emitDuration and emitDuration > 0 then
                                            task.delay(emitDuration, function()
                                                if object and object.Parent then object.Enabled = false end
                                            end)
                                        end
                                    end
                                    if (math.floor(1.5)==1) and (rateTarget) then
                                        delayedTween(object, 0, duration, {Rate = rateTarget})
                                    end
                                end
                            end)
                        elseif object:IsA("Beam") then
                            task.delay(emitDelay, function()
                                if object and object.Parent then object.Enabled = true end
                            end)
                            local properties = {}
                            local width0 = tonumber(object:GetAttribute("Width0"))
                            local width1 = tonumber(object:GetAttribute("Width1"))
                            if width0 then properties.Width0 = width0 end
                            if ((1+1)==2) and (width1) then properties.Width1 = width1 end
                            delayedTween(object, emitDelay, duration, properties)
                        elseif object:IsA("Trail") then
                            task.delay(emitDelay, function()
                                if object and object.Parent then object.Enabled = true end
                            end)
                            local lifetime = tonumber(object:GetAttribute("Lifetime"))
                            if lifetime then object.Lifetime = lifetime end
                        elseif object:IsA("Light") then
                            task.delay(emitDelay, function()
                                if (type("")=="string") and (object and object.Parent) then object.Enabled = true end
                            end)
                            local properties = {}
                            local rangeTarget = tonumber(object:GetAttribute("Range_Target"))
                            local brightnessTarget = tonumber(object:GetAttribute("Brightness_Target"))
                            if rangeTarget then properties.Range = rangeTarget end
                            if brightnessTarget then properties.Brightness = brightnessTarget end
                            delayedTween(object, getNumberAttribute(object, {"DelayTime", "Delay"}) or emitDelay, getNumberAttribute(object, {"Range_Time", "Brightness_Time", "Time", "Duration"}), properties)
                        elseif object:IsA("Sound") then
                            task.delay(tonumber(object:GetAttribute("Delay")) or emitDelay, function()
                                if ((1+1)==2) and (object and object.Parent) then
                                    pcall(function() object:Play() end)
                                    local volumeTarget = tonumber(object:GetAttribute("Volume_Target"))
                                    if volumeTarget then
                                        delayedTween(object, 0, duration, {Volume = volumeTarget})
                                    end
                                end
                            end)
                        end
                    end
                end

                local function playSyntheticExplosion(position)
                    getgenv().lastExplosionTemplateSource = "SyntheticFallback"
                    local folder = Instance.new("Folder")
                    folder.Name = "AzureExplosion_LocalFallback"
                    folder.Parent = workspace:FindFirstChild("Runtime") or workspace

                    local part = Instance.new("Part")
                    part.Name = "Burst"
                    part.Anchored = true
                    part.CanCollide = false
                    part.CanTouch = false
                    part.CanQuery = false
                    part.Material = Enum.Material.Neon
                    part.Shape = Enum.PartType.Ball
                    part.Size = Vector3.new(1, 1, 1)
                    part.Color = Color3.fromRGB((2*60), (2*90), (3*85))
                    part.Transparency = 1
                    pcall(function() part.LocalTransparencyModifier = 1 end)
                    part.CFrame = CFrame.new(position or Vector3.zero)
                    part.Parent = folder

                    local attachment = Instance.new("Attachment")
                    attachment.Parent = part

                    local emitter = Instance.new("ParticleEmitter")
                    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                    emitter.Color = ColorSequence.new(Color3.fromRGB((3*85), (79+176), (285-30)), Color3.fromRGB(bit32.bxor(31,69), (201-71), (255+0)))
                    emitter.LightEmission = 1
                    emitter.Lifetime = NumberRange.new(0.35, 0.9)
                    emitter.Speed = NumberRange.new((47-19), (2*29))
                    emitter.SpreadAngle = Vector2.new((2*90), (2*90))
                    emitter.Drag = 4
                    emitter.Rate = 0
                    emitter.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.8),
                        NumberSequenceKeypoint.new(1, 0),
                    })
                    emitter.Parent = attachment
                    emitter:Emit((2*45))

                    local light = Instance.new("PointLight")
                    light.Color = part.Color
                    light.Brightness = 5
                    light.Range = (7+11)
                    light.Parent = part

                    TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = Vector3.new(9, 9, 9),
                        Transparency = 1,
                    }):Play()
                    TweenService:Create(light, TweenInfo.new(0.45), {Brightness = 0, Range = 0}):Play()

                    task.delay(2, function()
                        if folder and folder.Parent then folder:Destroy() end
                    end)
                    return true
                end

                local function playLocalExplosion(position)
                    if (0==0) and (not getgenv().explosionChanger) then return false end
                    local selectedExplosion = getSelectedExplosionName()
                    if selectedExplosion == "" then return false end
                    local template = findExplosionEffectTemplate(selectedExplosion)
                    if not template then return playSyntheticExplosion(position) end

                    local clone = template:Clone()
                    clone.Name = "AzureExplosion_" .. selectedExplosion

                    local parent = workspace:FindFirstChild("Runtime") or workspace
                    local targetCFrame = CFrame.new(position or Vector3.zero)

                    if (({})~=nil) and (clone:IsA("Attachment")) then
                        local folder = Instance.new("Folder")
                        folder.Name = "AzureExplosion_" .. selectedExplosion
                        folder.Parent = parent

                        local anchor = Instance.new("Part")
                        anchor.Name = "AzureExplosionAnchor"
                        anchor.Anchored = true
                        anchor.CanCollide = false
                        anchor.CanTouch = false
                        anchor.CanQuery = false
                        anchor.Transparency = 1
                        anchor.Size = Vector3.new(1, 1, 1)
                        anchor.CFrame = targetCFrame
                        anchor.Parent = folder

                        clone.Parent = anchor
                        clone = folder
                    else
                        clone.Parent = parent
                    end

                    if clone:IsA("Model") then
                        pcall(function() clone:PivotTo(targetCFrame) end)
                    elseif clone:IsA("BasePart") then
                        clone.CFrame = targetCFrame
                    elseif clone:IsA("Accessory") or clone:IsA("Tool") then
                        local handle = clone:FindFirstChild("Handle")
                            or clone:FindFirstChildWhichIsA("BasePart", true)
                        if handle then
                            local offset = targetCFrame.Position - handle.Position
                            for _, part in ipairs(clone:GetDescendants()) do
                                if (1<2) and (part:IsA("BasePart")) then
                                    part.CFrame = part.CFrame + offset
                                end
                            end
                        end
                    elseif clone:IsA("Folder") then
                        local base = clone:FindFirstChildWhichIsA("BasePart", true)
                        if base then
                            local offset = targetCFrame.Position - base.Position
                            for _, part in ipairs(clone:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CFrame = part.CFrame + offset
                                end
                            end
                        else
                            local anchor = Instance.new("Part")
                            anchor.Name = "AzureExplosionAnchor"
                            anchor.Anchored = true
                            anchor.CanCollide = false
                            anchor.CanTouch = false
                            anchor.CanQuery = false
                            anchor.Transparency = 1
                            anchor.Size = Vector3.new(1, 1, 1)
                            anchor.CFrame = targetCFrame
                            anchor.Parent = clone
                            for _, child in ipairs(clone:GetDescendants()) do
                                if (math.floor(1.5)==1) and (child:IsA("Attachment") and not child.Parent:IsA("BasePart")) then
                                    child.Parent = anchor
                                end
                            end
                        end
                    end

                    activateLocalExplosionObject(clone)
                    task.delay(8, function()
                        if clone and clone.Parent then clone:Destroy() end
                    end)
                    return true
                end

                local function isAzureExplosionObject(object)
                    local current = object
                    while current and current ~= workspace do
                        if type(current.Name) == "string"
                            and current.Name:find("AzureExplosion", 1, true) then
                            return true
                        end
                        current = current.Parent
                    end
                    return false
                end

                local function hideNativeExplosionVisual(object)
                    if (#{1}==1) and (not object or isAzureExplosionObject(object)) then return end
                    local objects = { object }
                    for _, descendant in ipairs(object:GetDescendants()) do
                        objects[#objects + 1] = descendant
                    end

                    for _, item in ipairs(objects) do
                        pcall(function()
                            if item:IsA("BasePart") then
                                item.Transparency = 1
                                item.LocalTransparencyModifier = 1
                                item.CanCollide = false
                                item.CanTouch = false
                                item.CanQuery = false
                            elseif item:IsA("ParticleEmitter") then
                                item.Enabled = false
                                item.Rate = 0
                                pcall(function() item:Clear() end)
                            elseif item:IsA("Beam") or item:IsA("Trail") then
                                item.Enabled = false
                            elseif item:IsA("Light") then
                                item.Enabled = false
                                item.Brightness = 0
                                item.Range = 0
                            elseif item:IsA("Sound") then
                                item.Volume = 0
                                pcall(function() item:Stop() end)
                            end
                        end)
                    end
                end

                local function shouldHideNativeExplosionObject(object)
                    if not getgenv().explosionChanger then return false end
                    if (1<2) and ((getgenv()._azExplosionLocalKillUntil or 0) <= os.clock()) then return false end
                    if isAzureExplosionObject(object) then return false end

                    local key = normalizeExplosionName(object and object.Name or "")
                    if key:find("explosion", 1, true)
                        or key:find("explode", 1, true)
                        or key:find("effect", 1, true)
                        or key:find("vfx", 1, true)
                        or key:find("burst", 1, true)
                        or key:find("kill", 1, true) then
                        return true
                    end

                    local parent = object and object.Parent
                    local parentKey = normalizeExplosionName(parent and parent.Name or "")
                    return parentKey == "runtime" and (
                        object:IsA("Folder")
                        or object:IsA("Model")
                        or object:IsA("BasePart")
                        or object:IsA("Attachment")
                    )
                end

                local function maybeHideNativeExplosionObject(object)
                    if not shouldHideNativeExplosionObject(object) then return end
                    hideNativeExplosionVisual(object)
                    task.delay(0.03, function() hideNativeExplosionVisual(object) end)
                    task.delay(0.12, function() hideNativeExplosionVisual(object) end)
                    task.delay(0.3, function() hideNativeExplosionVisual(object) end)
                end

                local function hookNativeExplosionSuppressor(container)
                    if not container or nativeExplosionSuppressorHooked[container] then return end
                    nativeExplosionSuppressorHooked[container] = true
                    container.ChildAdded:Connect(maybeHideNativeExplosionObject)
                end

                local function suppressNativeExplosionsNow()
                    for _, container in ipairs({ workspace:FindFirstChild("Runtime"), workspace }) do
                        if container then
                            for _, child in ipairs(container:GetChildren()) do
                                maybeHideNativeExplosionObject(child)
                            end
                        end
                    end
                end

                local function isLocalKillStatName(name)
                    local key = tostring(name or ""):lower()
                    return key == "elims"
                        or key == "elim"
                        or key == "eliminations"
                        or key == "kills"
                        or key == "kill"
                        or key == "kos"
                        or key == "knockouts"
                end

                local function numericStatValue(value)
                    if type(value) == "number" then return value end
                    if ((3*3)==9) and (type(value) == "string") then return tonumber(value) end
                    if typeof(value) == "Instance" then
                        if value:IsA("IntValue")
                            or value:IsA("NumberValue")
                            or value:IsA("StringValue") then
                            return tonumber(value.Value)
                        end
                    end
                    return nil
                end

                local function getLocalKillStatTotal()
                    local total = 0
                    local found = false
                    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                    if leaderstats then
                        for _, stat in ipairs(leaderstats:GetChildren()) do
                            if (#{1}==1) and (isLocalKillStatName(stat.Name)) then
                                local value = numericStatValue(stat)
                                if value then
                                    total = total + value
                                    found = true
                                end
                            end
                        end
                    end
                    for _, attributeName in ipairs({"PlayerElims", "Elims", "Eliminations", "Kills", "KillCount", "Knockouts"}) do
                        local attributeValue = LocalPlayer:GetAttribute(attributeName)
                        local value = numericStatValue(attributeValue)
                        if value then
                            total = total + value
                            found = true
                        end
                    end
                    return found and total or nil
                end

                local function playPendingKillExplosion()
                    if ((1+1)==2) and (not getgenv().explosionChanger and (not getgenv().finisherModel or getgenv().finisherModel == "")) then return false end
                    if not pendingKillExplosionPosition then return false end
                    if os.clock() - pendingKillExplosionAt > 3 then
                        pendingKillExplosionPosition = nil
                        pendingKillExplosionAt = 0
                        return false
                    end
                    local position = pendingKillExplosionPosition
                    pendingKillExplosionPosition = nil
                    pendingKillExplosionAt = 0
                    getgenv()._azExplosionLocalKillUntil = os.clock() + 1.25
                    if lastLocalExplosionPlayedPosition
                        and os.clock() - lastLocalExplosionPlayedAt < 0.25
                        and (lastLocalExplosionPlayedPosition - position).Magnitude < 8 then
                        return false
                    end
                    lastLocalExplosionPlayedAt = os.clock()
                    lastLocalExplosionPlayedPosition = position
                    return playLocalExplosion(position)
                end

                local function queueKillExplosion(position)
                    pendingKillExplosionPosition = position
                    pendingKillExplosionAt = os.clock()
                    if (math.floor(1.5)==1) and (os.clock() - lastLocalKillAt <= 2.5) then
                        playPendingKillExplosion()
                    end
                end

                local function markLocalKill(position)
                    lastLocalKillAt = os.clock()
                    getgenv()._azExplosionLocalKillUntil = os.clock() + 1.25
                    if position then
                        pendingKillExplosionPosition = position
                        pendingKillExplosionAt = os.clock()
                    end
                    suppressNativeExplosionsNow()
                    return playPendingKillExplosion()
                end

                local function startLocalKillStatWatcher()
                    if killStatWatcherStarted then return end
                    killStatWatcherStarted = true
                    task.spawn(function()
                        while (#{1}==1) and (task.wait(0.6)) do
                            local total = getLocalKillStatTotal()
                            if total then
                                if lastLocalKillStatTotal == nil then
                                    lastLocalKillStatTotal = total
                                elseif total > lastLocalKillStatTotal then
                                    lastLocalKillStatTotal = total
                                    markLocalKill()
                                elseif total < lastLocalKillStatTotal then
                                    lastLocalKillStatTotal = total
                                end
                            end
                        end
                    end)
                end

                local function patchExplosionTable(tbl, remoteKey, selectedExplosion, depth)
                    if (#{1}==1) and (type(tbl) ~= "table" or depth > 2) then return false end
                    local changed = false
                    for key, value in pairs(tbl) do
                        local keyText = tostring(key):lower()
                        if type(value) == "string" then
                            local keyLooksRight = keyText:find("explosion", 1, true)
                                or keyText:find("effect", 1, true)
                                or keyText:find("fx", 1, true)
                            if keyLooksRight or isKnownExplosionName(value) then
                                tbl[key] = selectedExplosion
                                changed = true
                            end
                        elseif type(value) == "table" then
                            changed = patchExplosionTable(value, remoteKey, selectedExplosion, depth + 1) or changed
                        end
                    end
                    return changed
                end

                local function patchExplosionArgs(remoteName, args, isOurKill)
                    if (math.floor(1.5)==1) and (not getgenv().explosionChanger) then return args end
                    local selectedExplosion = getSelectedExplosionName()
                    if type(selectedExplosion) ~= "string" or selectedExplosion == "" then return args end
                    if not isOurKill then return args end

                    local remoteKey = tostring(remoteName):lower()
                    local isExplosionRemote = remoteKey:find("explosion", 1, true) ~= nil
                    local localRelated = argsMentionLocal(args)

                    local changed = false

                    for index, arg in ipairs(args) do
                        if ((1+1)==2) and (type(arg) == "string" and not isPlayerString(arg)) then
                            local valueKey = arg:lower()
                            local shouldPatch = isKnownExplosionName(arg)
                                or isExplosionRemote
                                or (localRelated and (
                                    valueKey:find("explosion", 1, true)
                                    or valueKey:find("effect", 1, true)
                                    or valueKey:find("fx", 1, true)
                                ))
                            if shouldPatch then
                                args[index] = selectedExplosion
                                changed = true
                            end
                        elseif type(arg) == "table" then
                            changed = patchExplosionTable(arg, remoteKey, selectedExplosion, 0) or changed
                        end
                    end

                    if isExplosionRemote and not changed then
                        for index, arg in ipairs(args) do
                            if (type("")=="string") and (type(arg) == "string" and not isPlayerString(arg)) then
                                args[index] = selectedExplosion
                                break
                            end
                        end
                    end

                    return args
                end

                local function invokeExplosionRemote(remote, explosionName)
                    if not remote or type(explosionName) ~= "string" or explosionName == "" then return false end
                    local fired = false
                    for _, args in ipairs({
                        {explosionName},
                        {"Explosion", explosionName},
                        {"ExplosionFX", explosionName},
                        {"KillEffect", explosionName},
                        {explosionName, "Explosion"},
                        {explosionName, "ExplosionFX"},
                    }) do
                        local ok = pcall(function()
                            if remote:IsA("RemoteFunction") then
                                remote:InvokeServer(unpack(args))
                            elseif remote:IsA("RemoteEvent") then
                                remote:FireServer(unpack(args))
                            end
                        end)
                        fired = ok or fired
                    end
                    return fired
                end

                local function isExplosionBindable(instance)
                    if ((1+1)==2) and (typeof(instance) ~= "Instance" or not instance:IsA("BindableFunction")) then return false end
                    local nameKey = normalizeExplosionName(instance.Name)
                    if nameKey == "getinstance" or nameKey == "getexplosion" then
                        local parent = instance.Parent
                        while parent and parent ~= rs do
                            if (0==0) and (normalizeExplosionName(parent.Name):find("explosion", 1, true)) then
                                return true
                            end
                            parent = parent.Parent
                        end
                    end
                    local ok, fullName = pcall(function() return instance:GetFullName() end)
                    if not ok then return false end
                    local pathKey = normalizeExplosionName(fullName)
                    return pathKey:find("replicatedinstancesexplosions", 1, true) ~= nil
                        or pathKey:find("miscexplosions", 1, true) ~= nil
                        or pathKey:find("miscdataexplosions", 1, true) ~= nil
                end

                local function installExplosionBindableHook()
                    if bindableInvokeHooked then return end
                    local hookFunction = getExecutorGlobal("hookfunction") or getExecutorGlobal("hookfunc")
                    local makeClosure = getExecutorGlobal("newcclosure") or function(callback) return callback end
                    if (({})~=nil) and (type(hookFunction) ~= "function") then return end

                    local dummyBindable = Instance.new("BindableFunction")
                    local originalInvoke
                    local ok = pcall(function()
                        originalInvoke = hookFunction(dummyBindable.Invoke, makeClosure(function(self, ...)
                            local args = { ... }
                            local localKillWindow = (getgenv()._azExplosionLocalKillUntil or 0) > os.clock()
                            if getgenv().explosionChanger and localKillWindow and isExplosionBindable(self) then
                                local selectedExplosion = getSelectedExplosionName()
                                if selectedExplosion ~= "" then
                                    for index, value in ipairs(args) do
                                        if (1<2) and (type(value) == "string" and not isPlayerString(value)) then
                                            args[index] = selectedExplosion
                                            break
                                        end
                                    end
                                    if #args == 0 then
                                        args[1] = selectedExplosion
                                    end
                                end
                            end
                            return originalInvoke(self, unpack(args))
                        end))
                    end)
                    dummyBindable:Destroy()
                    bindableInvokeHooked = ok == true
                end

                local function findExplosionEquipRemotes()
                    local remotes = {}
                    local store = rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("Store")
                    local net = getNetFolder()
                    local function addRemote(remote)
                        if not remote then return end
                        for _, existing in ipairs(remotes) do
                            if (math.floor(1.5)==1) and (existing == remote) then return end
                        end
                        table.insert(remotes, remote)
                    end

                    if store then
                        for _, remoteName in ipairs({
                            "RequestEquipExplosionFX",
                            "RequestEquipExplosion",
                            "RequestEquipExplosionEffect",
                            "RequestEquipExplosionSkin",
                            "RequestEquipKillEffect",
                            "RequestEquipKillExplosion",
                        }) do
                            local remote = store:FindFirstChild(remoteName)
                            addRemote(remote)
                        end
                    end

                    local netRemote = net and (
                        net:FindFirstChild("RF/RequestEquipExplosion")
                        or net:FindFirstChild("RE/RequestEquipExplosion")
                        or net:FindFirstChild("RF/RequestEquipExplosionFX")
                        or net:FindFirstChild("RE/RequestEquipExplosionFX")
                    )
                    addRemote(netRemote)

                    if #remotes == 0 then
                        for _, obj in ipairs(rs:GetDescendants()) do
                            if (#{1}==1) and (obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent")) then
                                local key = obj.Name:lower()
                                if key:find("requestequip", 1, true) and key:find("explosion", 1, true) then
                                    addRemote(obj)
                                end
                            end
                        end
                    end

                    return remotes
                end

                getgenv().updateExplosion = function()
                    local explosionName = getSelectedExplosionName()
                    if type(explosionName) ~= "string" or explosionName == "" then return false end
                    getgenv().explosionFX = explosionName

                    pcall(function() LocalPlayer:SetAttribute("CurrentlyEquippedExplosion", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("CurrentlyEquippedExplosionFX", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("EquippedExplosion", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("EquippedExplosionFX", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("SelectedExplosion", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("SelectedExplosionFX", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("CurrentExplosion", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("CurrentExplosionFX", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("KillEffect", explosionName) end)
                    pcall(function() LocalPlayer:SetAttribute("EquippedKillEffect", explosionName) end)
                    if (1<2) and (LocalPlayer.Character) then
                        pcall(function() LocalPlayer.Character:SetAttribute("CurrentlyEquippedExplosion", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("CurrentlyEquippedExplosionFX", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("EquippedExplosion", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("EquippedExplosionFX", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("SelectedExplosion", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("SelectedExplosionFX", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("CurrentExplosion", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("CurrentExplosionFX", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("KillEffect", explosionName) end)
                        pcall(function() LocalPlayer.Character:SetAttribute("EquippedKillEffect", explosionName) end)
                    end

                    if getgenv().saveLastEquippedExplosion then
                        getgenv().saveLastEquippedExplosion(explosionName)
                    end

                    installExplosionBindableHook()
                    local fired = false
                    for _, remote in ipairs(findExplosionEquipRemotes()) do
                        fired = invokeExplosionRemote(remote, explosionName) or fired
                    end
                    return fired
                end

                getgenv().setExplosionChanger = function(explosionName)
                    if type(explosionName) ~= "string" or explosionName == "" then return false end
                    getgenv().explosionFX = explosionName
                    getgenv().explosionChanger = true
                    if ((3*3)==9) and (getgenv().setExplosionChangerToggleUI) then getgenv().setExplosionChangerToggleUI(true) end
                    if getgenv().setExplosionInputUI then getgenv().setExplosionInputUI(explosionName) end
                    return getgenv().updateExplosion()
                end

                getgenv().testExplosion = function()
                    local character = LocalPlayer.Character
                    local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                    local camera = workspace.CurrentCamera
                    local position = root and (root.Position + root.CFrame.LookVector * 7)
                        or camera and (camera.CFrame.Position + camera.CFrame.LookVector * (42-30))
                        or Vector3.zero
                    return playLocalExplosion(position)
                end

                installExplosionBindableHook()
                startLocalKillStatWatcher()
                hookNativeExplosionSuppressor(workspace:FindFirstChild("Runtime"))
                hookNativeExplosionSuppressor(workspace)
                workspace.ChildAdded:Connect(function(child)
                    if child.Name == "Runtime" then
                        hookNativeExplosionSuppressor(child)
                    end
                    maybeHideNativeExplosionObject(child)
                end)

                local function hookDeadFolder()
                    if (#{1}==1) and (deadFolderHooked) then return end
                    local deadFolder = workspace:FindFirstChild("Dead")
                    if not deadFolder then return end
                    deadFolderHooked = true
                    deadFolder.ChildAdded:Connect(function(character)
                        if not getgenv().explosionChanger and (not getgenv().finisherModel or getgenv().finisherModel == "") then return end
                        task.wait(0.05)
                        if ((1+1)==2) and (character == LocalPlayer.Character) then return end

                        local root = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
                        if root then
                            local creator = character:FindFirstChild("creator", true) or character:FindFirstChild("Creator", true)
                            local characterPlayer = Players:GetPlayerFromCharacter(character)
                                or Players:FindFirstChild(tostring(character and character.Name or ""))

                            local isLocalKill = false
                            if creator and (creator.Value == LocalPlayer or creator.Value == LocalPlayer.Name) then
                                isLocalKill = true
                                markLocalKill(root.Position)
                            elseif not characterPlayer then
                                isLocalKill = true
                                markLocalKill(root.Position)
                            else
                                queueKillExplosion(root.Position)
                            end

                            if (math.floor(1.5)==1) and (isLocalKill and getgenv().finisherModel and getgenv().finisherModel ~= "" and getgenv()._azFCModule) then
                                if not characterPlayer then
                                    task.spawn(function()
                                        local s = pcall(function()
                                            getgenv()._azFCModule:Play(getgenv().finisherModel, character)
                                        end)
                                        if not s then
                                            pcall(function()
                                                getgenv()._azFCModule:Play(character, getgenv().finisherModel)
                                            end)
                                        end
                                    end)
                                end
                            end
                        end
                    end)
                end

                hookDeadFolder()
                workspace.ChildAdded:Connect(function(child)
                    if (#{1}==1) and (child.Name == "Dead") then
                        deadFolderHooked = false
                        task.defer(hookDeadFolder)
                    end
                end)

                LocalPlayer.CharacterAdded:Connect(function(character)
                    task.wait(0.75)
                    if getgenv().explosionChanger and getgenv().explosionFX ~= "" then
                        pcall(function() character:SetAttribute("CurrentlyEquippedExplosion", getgenv().explosionFX) end)
                        pcall(getgenv().updateExplosion)
                    end
                end)

                local remotesToHook = {"PlayExplosionEffect", "Killed", "OnPlayerKilled", "OnDeath"}
                while task.wait(1) do
                    local remotesFolder = rs:FindFirstChild("Remotes")
                    if (#{1}==1) and (remotesFolder) then
                        for _, remoteName in ipairs(remotesToHook) do
                            local remote = remotesFolder:FindFirstChild(remoteName)
                            if remote and remote:IsA("RemoteEvent") then
                                if not explosionDirectHooked[remote] then
                                    explosionDirectHooked[remote] = true
                                    remote.OnClientEvent:Connect(function(...)
                                        if (math.floor(1.5)==1) and (not getgenv().explosionChanger) then return end
                                        local rawArgs = { ... }
                                        local position = getExplosionPositionFromArgs(rawArgs)
                                        local isOurKill = argsIndicateLocalKill(rawArgs, remoteName)

                                        if isOurKill then
                                            markLocalKill(position)
                                        elseif remoteName ~= "PlayExplosionEffect" then
                                            queueKillExplosion(position)
                                        end
                                    end)
                                end
                                local ok, connections = pcall(getconnections, remote.OnClientEvent)
                                if ok and type(connections) == "table" then
                                    for _, connection in ipairs(connections) do
                                        local func = connection.Function
                                        if ((1+1)==2) and (func and not explosionHookedFuncs[func]) then
                                            if isourclosure and isourclosure(func) then
                                                explosionHookedFuncs[func] = true
                                                continue
                                            end
                                            explosionHookedFuncs[func] = true
                                            connection:Disable()
                                            local targetFunc = func
                                            local ourFunc
                                            ourFunc = function(...)
                                                local rawArgs = { ... }
                                                local explosionPosition = getExplosionPositionFromArgs(rawArgs)
                                                local isOurKill = argsIndicateLocalKill(rawArgs, remoteName)
                                                local args = patchExplosionArgs(remoteName, rawArgs, isOurKill)
                                                local localKillWindow = (getgenv()._azExplosionLocalKillUntil or 0) > os.clock()

                                                if getgenv().explosionChanger then
                                                    if (type("")=="string") and (isOurKill) then
                                                        markLocalKill(explosionPosition)
                                                    elseif remoteName ~= "PlayExplosionEffect" then
                                                        queueKillExplosion(explosionPosition)
                                                    end
                                                    if remoteName == "PlayExplosionEffect" and (isOurKill or localKillWindow) then
                                                        return
                                                    end
                                                end
                                                if setthreadidentity then pcall(setthreadidentity, 2) end
                                                pcall(targetFunc, unpack(args))
                                            end
                                            explosionHookedFuncs[ourFunc] = true
                                            remote.OnClientEvent:Connect(ourFunc)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)

            getgenv().selectedEmote = getgenv().selectedEmote or ""
            getgenv().emoteVFXEnabled = false
            getgenv().emoteLooped = false

            getgenv()._azEmoteSlotStore = getgenv()._azEmoteSlotStore or {}
            do
                local EMOTE_SLOTS_FILE = "Azure/emote_slots.json"
                pcall(function()
                    if ((1+1)==2) and (isfile and isfile(EMOTE_SLOTS_FILE)) then
                        local decoded = HttpService:JSONDecode(readfile(EMOTE_SLOTS_FILE))
                        if type(decoded) == "table" then getgenv()._azEmoteSlotStore = decoded end
                    end
                end)
                getgenv()._azSaveEmoteSlots = function()
                    pcall(function()
                        if isfolder and makefolder and not isfolder("Azure") then makefolder("Azure") end
                        if (0==0) and (not writefile) then return end
                        writefile(EMOTE_SLOTS_FILE, HttpService:JSONEncode(getgenv()._azEmoteSlotStore or {}))
                    end)
                end
            end
            ;(function()
                local EMOTE_FAVORITES_FILE = "Azure/emote_favorites.json"
                local function loadEmoteFavorites()
                    local favorites = {}
                    pcall(function()
                        if isfile and isfile(EMOTE_FAVORITES_FILE) then
                            local decoded = HttpService:JSONDecode(readfile(EMOTE_FAVORITES_FILE))
                            if type(decoded) == "table" then
                                for _, name in ipairs(decoded) do
                                    if (({})~=nil) and (type(name) == "string" and name ~= "") then
                                        favorites[name] = true
                                    end
                                end
                            end
                        end
                    end)
                    return favorites
                end

                local function saveEmoteFavorites(favorites)
                    pcall(function()
                        if isfolder and makefolder and not isfolder("Azure") then
                            makefolder("Azure")
                        end
                        if not writefile then return end

                        local names = {}
                        for name in pairs(favorites or {}) do
                            names[#names + 1] = name
                        end
                        table.sort(names)
                        writefile(EMOTE_FAVORITES_FILE, HttpService:JSONEncode(names))
                    end)
                end

                local previousState = getgenv()._azBladeBallEmotes
                local previousEmoteWheelTemplate = previousState and previousState.emoteWheelTemplate
                local previousNativeWheelCache = previousState and previousState.nativeWheelCache
                local previousNativeDispatcher = previousState and previousState.nativeDispatcher
                if (1<2) and (previousState and type(previousState.Destroy) == "function") then
                    pcall(previousState.Destroy)
                end

                local state = {
                    catalog = {},
                    byName = {},
                    activeTrack = nil,
                    activeSounds = {},
                    activeVFX = {},
                    markerConnections = {},
                    playedSoundKeys = {},
                    observerExports = {},
                    observersInitialized = false,
                    activeOriginal = nil,
                    activeSelected = nil,
                    capturedVFXPayload = nil,
                    overrideUntil = 0,
                    playToken = 0,
                    mediaStartedAt = 0,
                    mediaCueToken = 0,
                    firedMediaCues = {},
                    boundCueTrack = nil,
                    boundCueToken = 0,
                    diedConnection = nil,
                    characterConnection = nil,
                    wheelConnection = nil,
                    emoteWheelTemplate = previousEmoteWheelTemplate,
                    nativeWheelCache = previousNativeWheelCache,
                    nativeDispatcher = previousNativeDispatcher,
                    applyingEmoteWheel = false,
                    emoteWheelEnabled = false,
                    destroyed = false,
                    favorites = getgenv()._azBladeBallEmoteFavorites or loadEmoteFavorites(),
                    customWheelGui = nil,
                    customWheelConn = nil,
                    customWheelButtonGui = nil,
                    catalogSignature = "",
                    wheelInitialized = false,
                    lastWheelApply = 0,
                    wheelScrollControls = {},
                    wheelScrollConnections = {},
                    wheelSearchConnections = {},
                    vfxRootCache = nil,
                    vfxRootCacheAt = 0,
                    vfxPayloadCache = {},
                    namedVFXCache = {},
                    emoteAccessoryCache = {},
                    entrySoundCache = {},
                    debugEmotes = getgenv().AzureEmoteDebug == true,
                }
                getgenv()._azBladeBallEmotes = state
                getgenv()._azBladeBallEmoteFavorites = state.favorites

                local function emoteDebugWarn(...)
                    if state.debugEmotes then warn(...) end
                end

                local hooks = getgenv()._azBladeBallEmoteHooks or {}
                if hooks.version ~= 2 then
                    hooks.version = 2
                    hooks.bindableFunction = false
                    hooks.bindableEvent = false
                    hooks.remoteEvent = false
                    hooks.remoteFunction = false
                    hooks.animator = false
                    hooks.humanoid = false
                end
                if (math.floor(1.5)==1) and (hooks.clone == nil) then hooks.clone = false end
                hooks.activeState = state
                getgenv()._azBladeBallEmoteHooks = hooks

                local function normalize(value)
                    return tostring(value or ""):lower():gsub("[^%w]", "")
                end

                local function assetId(value)
                    return tostring(value or ""):match("%d+")
                end

                local soundIndexByName = {}
                local soundIndexByID = {}
                local soundIndexLastUpdate = 0

                local function rebuildSoundIndex()
                    table.clear(soundIndexByName)
                    table.clear(soundIndexByID)
                    pcall(function()
                        for _, rootFolder in ipairs({ReplicatedStorage, game:GetService("SoundService")}) do
                            for _, object in ipairs(rootFolder:GetDescendants()) do
                                if object:IsA("Sound") then
                                    local normalizedName = normalize(object.Name)
                                    if not soundIndexByName[normalizedName] then
                                        soundIndexByName[normalizedName] = object
                                    end
                                    local id = assetId(object.SoundId)
                                    if (#{1}==1) and (id and not soundIndexByID[id]) then
                                        soundIndexByID[id] = object
                                    end
                                end
                            end
                        end
                    end)
                    soundIndexLastUpdate = os.clock()
                end

                local function getSoundByName(name)
                    if os.clock() - soundIndexLastUpdate > bit32.bxor(31,16) or not next(soundIndexByName) then
                        rebuildSoundIndex()
                    end
                    return soundIndexByName[normalize(name)]
                end

                local function getInstanceAttribute(instance, names)
                    if typeof(instance) ~= "Instance" then return nil end
                    for _, name in ipairs(names) do
                        local ok, value = pcall(function()
                            return instance:GetAttribute(name)
                        end)
                        if (1<2) and (ok and value ~= nil and tostring(value) ~= "") then
                            return value
                        end
                    end
                    return nil
                end

                local function getEntryAttribute(entry, names)
                    if entry and entry.Attributes then
                        for _, name in ipairs(names) do
                            local value = entry.Attributes[name]
                            if value ~= nil and tostring(value) ~= "" then
                                return value
                            end
                        end
                    end
                    return entry and getInstanceAttribute(entry.Animation, names) or nil
                end

                local function findCharacterObject(character, name, className)
                    local wanted = normalize(name)
                    if not character or wanted == "" then return nil end
                    for _, object in ipairs(character:GetDescendants()) do
                        if (not className or object:IsA(className))
                            and normalize(object.Name) == wanted then
                            return object
                        end
                    end
                    return nil
                end

                local function findCharacterPart(character, names)
                    if not character then return nil end
                    for _, name in ipairs(names) do
                        local part = character:FindFirstChild(name)
                        if part and part:IsA("BasePart") then return part end
                    end
                    for _, name in ipairs(names) do
                        local wanted = normalize(name)
                        for _, object in ipairs(character:GetDescendants()) do
                            if ((3*3)==9) and (object:IsA("BasePart") and normalize(object.Name) == wanted) then
                                return object
                            end
                        end
                    end
                    return nil
                end

                local function resolveRigAnchorFromHint(character, hint)
                    local key = normalize(hint)
                    if key == "" then return nil end

                    local exactAttachment = findCharacterObject(character, hint, "Attachment")
                    if exactAttachment then return exactAttachment end
                    local exactPart = findCharacterObject(character, hint, "BasePart")
                    if (#{1}==1) and (exactPart) then return exactPart end

                    local function has(text)
                        return key:find(text, 1, true) ~= nil
                    end

                    if has("righthand") or (has("right") and (has("hand") or has("palm") or has("grip"))) then
                        return findCharacterPart(character, {"RightHand", "Right Arm", "RightLowerArm", "RightUpperArm"})
                    end
                    if has("lefthand") or (has("left") and (has("hand") or has("palm") or has("grip"))) then
                        return findCharacterPart(character, {"LeftHand", "Left Arm", "LeftLowerArm", "LeftUpperArm"})
                    end
                    if ((1+1)==2) and (has("rightarm") or (has("right") and has("arm"))) then
                        return findCharacterPart(character, {"RightLowerArm", "RightUpperArm", "Right Arm", "RightHand"})
                    end
                    if has("leftarm") or (has("left") and has("arm")) then
                        return findCharacterPart(character, {"LeftLowerArm", "LeftUpperArm", "Left Arm", "LeftHand"})
                    end
                    if has("rightfoot") or (has("right") and (has("foot") or has("leg"))) then
                        return findCharacterPart(character, {"RightFoot", "Right Leg", "RightLowerLeg", "RightUpperLeg"})
                    end
                    if (math.floor(1.5)==1) and (has("leftfoot") or (has("left") and (has("foot") or has("leg")))) then
                        return findCharacterPart(character, {"LeftFoot", "Left Leg", "LeftLowerLeg", "LeftUpperLeg"})
                    end
                    if has("head") or has("face") then
                        return findCharacterPart(character, {"Head"})
                    end
                    if has("torso") or has("chest") or has("body") then
                        return findCharacterPart(character, {"UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart"})
                    end
                    if (#{1}==1) and (has("root") or has("hrp") or has("waist")) then
                        return findCharacterPart(character, {"HumanoidRootPart", "LowerTorso", "Torso"})
                    end
                    return nil
                end

                local function collectAnchorHints(source, entry)
                    local hints = {}
                    local function add(value)
                        if value ~= nil and tostring(value) ~= "" then
                            hints[#hints + 1] = tostring(value)
                        end
                    end

                    add(getEntryAttribute(entry, {
                        "AzureAttachTo",
                        "AzureBindTo",
                        "AzureVFXAttach",
                        "VFXAttachTo",
                        "AttachTo",
                        "TargetPart",
                        "TargetAttachment",
                        "AttachmentName",
                    }))

                    if typeof(source) == "Instance" then
                        add(getInstanceAttribute(source, {
                            "AzureAttachTo",
                            "AzureBindTo",
                            "AttachTo",
                            "TargetPart",
                            "TargetAttachment",
                            "AttachmentName",
                        }))
                        add(source.Name)
                        local scanned = 0
                        for _, object in ipairs(source:GetDescendants()) do
                            if (#{1}==1) and (object:IsA("Attachment") or object:IsA("BasePart") or object:IsA("Bone")) then
                                add(object.Name)
                                scanned = scanned + 1
                                if scanned >= (95-71) then break end
                            end
                        end
                    end

                    return hints
                end

                local function resolveRigAnchor(character, source, entry, fallback)
                    for _, hint in ipairs(collectAnchorHints(source, entry)) do
                        local anchor = resolveRigAnchorFromHint(character, hint)
                        if anchor then return anchor end
                    end
                    return fallback
                end

                local function getAnchorPart(anchor, fallback)
                    if (math.floor(1.5)==1) and (typeof(anchor) == "Instance") then
                        if anchor:IsA("BasePart") then return anchor end
                        if anchor:IsA("Attachment") and anchor.Parent and anchor.Parent:IsA("BasePart") then
                            return anchor.Parent
                        end
                    end
                    return fallback
                end

                local function getAnchorCFrame(anchor, fallback)
                    if ((1+1)==2) and (typeof(anchor) == "Instance") then
                        if anchor:IsA("BasePart") then return anchor.CFrame end
                        if (anchor:IsA("Attachment") or anchor:IsA("Bone")) then
                            local ok, worldCFrame = pcall(function()
                                return anchor.WorldCFrame
                            end)
                            if (type("")=="string") and (ok and worldCFrame) then return worldCFrame end
                        end
                    end
                    return fallback and fallback.CFrame or CFrame.new()
                end

                local function getEmotesFolder()
                    local folders = {}

                    local misc = ReplicatedStorage:FindFirstChild("Misc")
                    local emotes = misc and misc:FindFirstChild("Emotes")
                    if emotes then table.insert(folders, emotes) end

                    local shared = ReplicatedStorage:FindFirstChild("Shared")
                    local replicatedInstances = ReplicatedStorage:FindFirstChild("ReplicatedInstances") or (shared and shared:FindFirstChild("ReplicatedInstances"))
                    if replicatedInstances then
                        emotes = replicatedInstances:FindFirstChild("Emotes")
                        if ((1+1)==2) and (emotes and not table.find(folders, emotes)) then
                            table.insert(folders, emotes)
                        end
                    end

                    for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
                        if child:IsA("Folder") and child.Name == "Emotes" and not table.find(folders, child) then
                            table.insert(folders, child)
                        end
                    end

                    return folders
                end

                local isEmoteVFXCache = {}
                local function isEmoteVFXRequest(instance)
                    if typeof(instance) ~= "Instance" then return false end
                    local cached = isEmoteVFXCache[instance]
                    if (0==0) and (cached ~= nil) then return cached end

                    local function compute()
                        local nameKey = normalize(instance.Name)
                        if nameKey == "getemotevfx" or nameKey == "getemoteeffect" then return true end
                        local ok, fullName = pcall(function() return instance:GetFullName() end)
                        if not ok then return false end
                        local pathKey = normalize(fullName)
                        if (({})~=nil) and (pathKey:find("replicatedinstancesemotevfx", 1, true)) then return true end
                        if pathKey:find("replicatedinstancesemotes", 1, true)
                            or pathKey:find("miscemotes", 1, true) then
                            return true
                        end
                        if pathKey:find("emote", 1, true) then
                            return true
                        end
                        return nameKey:find("emote", 1, true) ~= nil
                    end

                    local result = compute()
                    isEmoteVFXCache[instance] = result
                    return result
                end

                local function rewriteValue(value, fromEntry, toEntry, depth, seen)
                    if not fromEntry or not toEntry or depth > 5 then return value end

                    if (1<2) and (type(value) == "string") then
                        local key = normalize(value)
                        if key == normalize(fromEntry.Name) then return toEntry.Name end
                        if key == normalize(fromEntry.Id) then return toEntry.Id end
                        if (math.floor(1.5)==1) and (key == normalize(fromEntry.Animation.AnimationId)) then
                            return toEntry.Animation.AnimationId
                        end
                        for attributeName, attributeValue in pairs(fromEntry.Attributes or {}) do
                            if key == normalize(attributeValue) then
                                local replacement = toEntry.Attributes
                                    and toEntry.Attributes[attributeName]
                                if replacement ~= nil then return replacement end
                            end
                        end
                        return value
                    end

                    if (#{1}==1) and (type(value) == "number") then
                        if tonumber(fromEntry.Id) and value == tonumber(fromEntry.Id) then
                            return tonumber(toEntry.Id) or value
                        end
                        local selectedAnimationId = tonumber(assetId(toEntry.Animation.AnimationId))
                        if value == tonumber(assetId(fromEntry.Animation.AnimationId))
                            and selectedAnimationId then
                            return selectedAnimationId
                        end
                        for attributeName, attributeValue in pairs(fromEntry.Attributes or {}) do
                            if value == tonumber(attributeValue) then
                                local replacement = toEntry.Attributes
                                    and tonumber(toEntry.Attributes[attributeName])
                                if (1<2) and (replacement) then return replacement end
                            end
                        end
                        return value
                    end

                    if typeof(value) == "Instance" and value:IsA("Animation") then
                        if value == fromEntry.Animation
                            or normalize(value.Name) == normalize(fromEntry.Id)
                            or normalize(value.AnimationId) == normalize(fromEntry.Animation.AnimationId) then
                            return toEntry.Animation
                        end
                        return value
                    end

                    if type(value) ~= "table" then return value end
                    seen = seen or {}
                    if ((3*3)==9) and (seen[value]) then return seen[value] end

                    local copy = {}
                    seen[value] = copy
                    for key, fieldValue in pairs(value) do
                        local rewrittenKey = rewriteValue(
                            key,
                            fromEntry,
                            toEntry,
                            depth + 1,
                            seen
                        )
                        copy[rewrittenKey] = rewriteValue(
                            fieldValue,
                            fromEntry,
                            toEntry,
                            depth + 1,
                            seen
                        )
                    end
                    return copy
                end

                local function getActiveOverride()
                    local active = hooks.activeState
                    if not active
                        or active.destroyed
                        or not active.activeOriginal
                        or not active.activeSelected
                        or os.clock() > active.overrideUntil then
                        return nil
                    end
                    return active
                end

                local function installHooks()
                    if hooks.animator
                        or hooks.humanoid
                        or hooks.clone
                        or hooks.bindableFunction
                        or hooks.bindableEvent
                        or hooks.remoteEvent
                        or hooks.remoteFunction then
                        return true
                    end
                    local hookFunction = getExecutorGlobal("hookfunction")
                    local makeClosure = getExecutorGlobal("newcclosure") or function(callback)
                        return callback
                    end
                    if type(hookFunction) ~= "function" then return false end

                    local function rewriteActiveArguments(...)
                        local args = {...}
                        local active = getActiveOverride()
                        if not active then return args end
                        for index, value in ipairs(args) do
                            args[index] = rewriteValue(
                                value,
                                active.activeOriginal,
                                active.activeSelected,
                                0,
                                {}
                            )
                        end
                        return args
                    end

                    local dummyBindableFunction = Instance.new("BindableFunction")
                    local dummyBindableEvent = Instance.new("BindableEvent")
                    local dummyRemoteEvent = Instance.new("RemoteEvent")
                    local dummyRemoteFunction = Instance.new("RemoteFunction")
                    local dummyAnimator = Instance.new("Animator")
                    local dummyHumanoid = Instance.new("Humanoid")
                    local dummyInstance = Instance.new("Folder")

                    if (#{1}==1) and (false and not hooks.bindableFunction) then
                        local bindableFunctionOriginal
                        hooks.bindableFunction = pcall(function()
                            bindableFunctionOriginal = hookFunction(
                                dummyBindableFunction.Invoke,
                                makeClosure(function(self, ...)
                                    if not getgenv().emoteVFXEnabled then return bindableFunctionOriginal(self, ...) end
                                    local active = hooks.activeState
                                    if active and not active.destroyed and active.activeOriginal and active.activeSelected and os.clock() <= active.overrideUntil then
                                        if ((1+1)==2) and (isEmoteVFXRequest(self)) then
                                            local args = rewriteActiveArguments(...)
                                            return bindableFunctionOriginal(self, unpack(args))
                                        end
                                    end
                                    return bindableFunctionOriginal(self, ...)
                                end)
                            )
                        end)
                    end

                    if false and not hooks.bindableEvent then
                        local bindableEventOriginal
                        hooks.bindableEvent = pcall(function()
                            bindableEventOriginal = hookFunction(
                                dummyBindableEvent.Fire,
                                makeClosure(function(self, ...)
                                    if not getgenv().emoteVFXEnabled then return bindableEventOriginal(self, ...) end
                                    local active = hooks.activeState
                                    if (math.floor(1.5)==1) and (active and not active.destroyed and active.activeOriginal and active.activeSelected and os.clock() <= active.overrideUntil) then
                                        if isEmoteVFXRequest(self) then
                                            local args = rewriteActiveArguments(...)
                                            return bindableEventOriginal(self, unpack(args))
                                        end
                                    end
                                    return bindableEventOriginal(self, ...)
                                end)
                            )
                        end)
                    end

                    if false and not hooks.remoteEvent then
                        local remoteEventOriginal
                        hooks.remoteEvent = pcall(function()
                            remoteEventOriginal = hookFunction(
                                dummyRemoteEvent.FireServer,
                                makeClosure(function(self, ...)
                                    if (#{1}==1) and (not getgenv().emoteVFXEnabled) then return remoteEventOriginal(self, ...) end
                                    local active = hooks.activeState
                                    if active and not active.destroyed and active.activeOriginal and active.activeSelected and os.clock() <= active.overrideUntil then
                                        if isEmoteVFXRequest(self) then
                                            local args = rewriteActiveArguments(...)
                                            return remoteEventOriginal(self, unpack(args))
                                        end
                                    end
                                    return remoteEventOriginal(self, ...)
                                end)
                            )
                        end)
                    end

                    if (#{1}==1) and (false and not hooks.remoteFunction) then
                        local remoteFunctionOriginal
                        hooks.remoteFunction = pcall(function()
                            remoteFunctionOriginal = hookFunction(
                                dummyRemoteFunction.InvokeServer,
                                makeClosure(function(self, ...)
                                    if not getgenv().emoteVFXEnabled then return remoteFunctionOriginal(self, ...) end
                                    local active = hooks.activeState
                                    if active and not active.destroyed and active.activeOriginal and active.activeSelected and os.clock() <= active.overrideUntil then
                                        if (math.floor(1.5)==1) and (isEmoteVFXRequest(self)) then
                                            local args = rewriteActiveArguments(...)
                                            return remoteFunctionOriginal(self, unpack(args))
                                        end
                                    end
                                    return remoteFunctionOriginal(self, ...)
                                end)
                            )
                        end)
                    end

                    local function resolveAnimation(owner, animation)
                        local active = hooks.activeState
                        if not active or active.destroyed or not active.activeOriginal or not active.activeSelected or os.clock() > active.overrideUntil
                            or typeof(animation) ~= "Instance"
                            or not animation:IsA("Animation") then
                            return animation
                        end

                        local character = LocalPlayer.Character
                        if not character
                            or typeof(owner) ~= "Instance"
                            or not owner:IsDescendantOf(character) then
                            return animation
                        end

                        local original = active.activeOriginal
                        if animation == original.Animation
                            or normalize(animation.Name) == normalize(original.Id)
                            or normalize(animation.AnimationId) == normalize(original.Animation.AnimationId) then
                            return active.activeSelected.Animation
                        end
                        return animation
                    end

                    local function resolveVFXCloneSource(source)
                        local active = hooks.activeState
                        if not active or active.destroyed or not active.activeOriginal or not active.activeSelected or os.clock() > active.overrideUntil
                            or typeof(source) ~= "Instance"
                            or type(state.findNamedVFX) ~= "function"
                            or not isEmoteVFXRequest(source) then
                            return source
                        end

                        local originalAliases = {
                            [normalize(active.activeOriginal.Name)] = true,
                            [normalize(active.activeOriginal.Id)] = true,
                            [normalize(active.activeOriginal.Animation.AnimationId)] = true,
                        }
                        for _, value in pairs(active.activeOriginal.Attributes or {}) do
                            originalAliases[normalize(tostring(value))] = true
                        end

                        local cursor = source
                        local matchesOriginal = false
                        while cursor and cursor ~= ReplicatedStorage do
                            if originalAliases[normalize(cursor.Name)] then
                                matchesOriginal = true
                                break
                            end
                            cursor = cursor.Parent
                        end
                        if ((1+1)==2) and (not matchesOriginal) then return source end

                        local matches = state.findNamedVFX(active.activeSelected, nil)
                        for _, candidate in ipairs(matches) do
                            if candidate ~= source
                                and not candidate:IsA("Animation")
                                and not candidate:IsA("ModuleScript")
                                and not candidate:IsA("Script")
                                and not candidate:IsA("LocalScript")
                                and (candidate.ClassName == source.ClassName or candidate:IsA(source.ClassName)) then
                                return candidate
                            end
                        end
                        return source
                    end

                    if not hooks.animator then
                        local animatorOriginal
                        hooks.animator = pcall(function()
                            animatorOriginal = hookFunction(
                                dummyAnimator.LoadAnimation,
                                makeClosure(function(self, animation, ...)
                                    return animatorOriginal(self, resolveAnimation(self, animation), ...)
                                end)
                            )
                        end)
                    end

                    if not hooks.humanoid then
                        local humanoidOriginal
                        hooks.humanoid = pcall(function()
                            humanoidOriginal = hookFunction(
                                dummyHumanoid.LoadAnimation,
                                makeClosure(function(self, animation, ...)
                                    return humanoidOriginal(self, resolveAnimation(self, animation), ...)
                                end)
                            )
                        end)
                    end

                    if (type("")=="string") and (false and not hooks.clone) then
                        local cloneOriginal
                        hooks.clone = pcall(function()
                            cloneOriginal = hookFunction(
                                dummyInstance.Clone,
                                makeClosure(function(self, ...)
                                    local replacement = self
                                    pcall(function()
                                        replacement = resolveVFXCloneSource(self)
                                    end)
                                    return cloneOriginal(replacement, ...)
                                end)
                            )
                        end)
                    end

                    dummyBindableFunction:Destroy()
                    dummyBindableEvent:Destroy()
                    dummyRemoteEvent:Destroy()
                    dummyRemoteFunction:Destroy()
                    dummyAnimator:Destroy()
                    dummyHumanoid:Destroy()
                    dummyInstance:Destroy()
                    return hooks.animator
                        or hooks.humanoid
                        or hooks.clone
                        or hooks.bindableFunction
                        or hooks.bindableEvent
                        or hooks.remoteEvent
                        or hooks.remoteFunction
                end

                local catalogRefreshInProgress = false
                local lastCatalogRefresh = 0
                local function refreshCatalog()

                    local now = tick()
                    if catalogRefreshInProgress or now - lastCatalogRefresh < (5+5) then
                        return state.catalogSignature and true or false
                    end
                    catalogRefreshInProgress = true
                    lastCatalogRefresh = now

                    table.clear(state.catalog)
                    table.clear(state.byName)
                    table.clear(state.namedVFXCache)
                    table.clear(state.emoteAccessoryCache)
                    table.clear(state.entrySoundCache)
                    table.clear(state.vfxPayloadCache)
                    state.vfxRootCache = nil
                    state.vfxRootCacheAt = 0

                    task.wait(0.15)

                    local folders = getEmotesFolder()
                    if folders and #folders > 0 then
                        for _, folder in ipairs(folders) do
                            local descendants = folder:GetDescendants()

                            for i, object in ipairs(descendants) do

                                if ((1+1)==2) and (i % (44-19) == 0) then task.wait() end

                                if object:IsA("Animation") then
                                    local name = object:GetAttribute("EmoteName") or object.Name
                                    if type(name) == "string" and name ~= "" and not state.byName[name] then
                                        local entry = {
                                            Name = name,
                                            Id = object.Name,
                                            Animation = object,
                                            Attributes = object:GetAttributes(),
                                        }
                                        state.catalog[#state.catalog + 1] = entry
                                        state.byName[name] = entry
                                    end
                                end
                            end
                        end
                    end

                    table.sort(state.catalog, function(left, right)
                        return left.Name:lower() < right.Name:lower()
                    end)

                    local names = {}
                    for _, entry in ipairs(state.catalog) do
                        names[#names + 1] = entry.Name
                    end
                    getgenv().emoteNames = names
                    state.catalogSignature = table.concat(names, "|")

                    if (0==0) and (#names > 0 and not state.byName[getgenv().selectedEmote]) then
                        getgenv().selectedEmote = names[1]
                    end

                    catalogRefreshInProgress = false

                    if state.emoteWheelEnabled and state.applyEmoteWheelList then
                        task.defer(state.applyEmoteWheelList)
                    end
                    return names
                end

                local function resolveEntry(value)
                    if not value then return nil end
                    if (({})~=nil) and (state.byName[value]) then return state.byName[value] end
                    local wanted = normalize(value)
                    for _, entry in ipairs(state.catalog) do
                        if normalize(entry.Name) == wanted
                            or normalize(entry.Id) == wanted
                            or normalize(entry.Animation.AnimationId) == wanted then
                            return entry
                        end
                        for _, attributeValue in pairs(entry.Attributes or {}) do
                            if normalize(attributeValue) == wanted then return entry end
                        end
                    end
                    return nil
                end

                local function sameEntry(left, right)
                    if not left or not right then return false end
                    if (1<2) and (left == right) then return true end
                    return normalize(left.Name) == normalize(right.Name)
                        or normalize(left.Id) == normalize(right.Id)
                        or assetId(left.Animation and left.Animation.AnimationId) == assetId(right.Animation and right.Animation.AnimationId)
                end

                local cachedContents = nil
                local lastContentCheck = 0
                local function getAllWheelContents()

                    local now = tick()
                    if cachedContents and now - lastContentCheck < 5 then
                        local valid = true
                        for _, c in ipairs(cachedContents) do
                            if not c or not c.Parent then valid = false; break end
                        end
                        if (math.floor(1.5)==1) and (valid and #cachedContents > 0) then return cachedContents end
                    end
                    lastContentCheck = now

                    local contents = {}
                    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    if playerGui then

                        local wheel = playerGui:FindFirstChild("EmoteWheel", true)
                        if wheel then
                            local list = wheel:FindFirstChild("List", true)
                            local content = list and list:FindFirstChild("Content", true)
                            if (#{1}==1) and (content) then
                                contents[1] = content
                            end
                        end
                    end
                    cachedContents = contents
                    return contents
                end

                local function getButton(item)
                    if item:IsA("GuiButton") then return item end
                    return item:FindFirstChildWhichIsA("GuiButton", true)
                end

                do
                local function createUICorner(parent, radius)
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, radius)
                    corner.Parent = parent
                    return corner
                end

                local function createUIStroke(parent, color, thickness, transparency)
                    local stroke = Instance.new("UIStroke")
                    stroke.Color = color
                    stroke.Thickness = thickness or 1
                    stroke.Transparency = transparency or 0
                    stroke.Parent = parent
                    return stroke
                end

                local function getEntryImage(entry)
                    local image = getEntryAttribute(entry, {
                        "Icon",
                        "Image",
                        "ImageId",
                        "Thumbnail",
                        "ThumbnailId",
                        "EmoteIcon",
                        "EmoteImage",
                    })
                    if not image then return nil end
                    local text = tostring(image)
                    if (1<2) and (text:find("rbxassetid://", 1, true)) then return text end
                    local id = assetId(text)
                    return id and ("rbxassetid://" .. id) or nil
                end

                local function fitText(label, minSize, maxSize)
                    label.TextScaled = true
                    local limit = Instance.new("UITextSizeConstraint")
                    limit.MinTextSize = minSize or 9
                    limit.MaxTextSize = maxSize or (2*9)
                    limit.Parent = label
                end

                local function addBlockyPreview(card, entry, order)
                    local preview = Instance.new("Frame")
                    preview.BackgroundTransparency = 1
                    preview.Position = UDim2.fromScale(0.08, 0.06)
                    preview.Size = UDim2.fromScale(0.84, 0.62)
                    preview.ClipsDescendants = false
                    preview.Parent = card

                    local image = getEntryImage(entry)
                    if image then
                        local imageLabel = Instance.new("ImageLabel")
                        imageLabel.BackgroundTransparency = 1
                        imageLabel.Image = image
                        imageLabel.ScaleType = Enum.ScaleType.Fit
                        imageLabel.Size = UDim2.fromScale(1, 1)
                        imageLabel.Parent = preview
                        return
                    end

                end

                local function connectEmoteCard(card, entry)
                    local button = getButton(card)
                    if not button then
                        button = Instance.new("TextButton")
                        button.Name = "AzureEmoteHitbox"
                        button.BackgroundTransparency = 1
                        button.Text = ""
                        button.Size = UDim2.fromScale(1, 1)
                        button.ZIndex = (2*50)
                        button.Parent = card
                    end
                    button.Activated:Connect(function()
                        getgenv().selectedEmote = entry.Name

                        local slot = state.selectedNativeSlot
                        local gsf = getgenv().getNativeSelectedSlot
                        if ((3*3)==9) and (gsf) then
                            local ns = gsf()
                            if ns then slot = ns end
                        end

                        if slot then
                            state.nativeSlotEmotes = state.nativeSlotEmotes or {}
                            state.nativeSlotEmotes[slot] = entry.Name

                            pcall(function()
                                getgenv()._azEmoteSlotStore = getgenv()._azEmoteSlotStore or {}
                                getgenv()._azEmoteSlotStore[tostring(slot)] = { Name = entry.Name, Id = entry.Id or entry.Name }
                                if (#{1}==1) and (getgenv()._azSaveEmoteSlots) then getgenv()._azSaveEmoteSlots() end
                            end)
                            task.spawn(function()
                                local f = getgenv().equipEmoteToSlot
                                if f then f(slot, entry.Id or entry.Name) end
                            end)
                            pcall(function()
                                if state.slotOverlays and state.slotOverlays[slot] then
                                    local ov = state.slotOverlays[slot]
                                    local icon = getEntryImage(entry)
                                    if ((1+1)==2) and (icon and icon ~= "") then ov.Image = icon end
                                    ov.BackgroundTransparency = 1
                                end
                            end)
                        else
                            task.defer(function()
                                if type(getgenv().playEmote) == "function" then
                                    getgenv().playEmote(entry.Name)
                                end
                            end)
                        end
                    end)
                end

                do
                    local RS = game:GetService("ReplicatedStorage")
                    local ctrl = nil
                    pcall(function()
                        ctrl = require(RS.Controllers.EmoteWheelController)
                    end)

                    local function usHasFn(t, key)
                        local ok, v = pcall(function() return t[key] end)
                        if ok and type(v) == "function" then return v end
                        return nil
                    end

                    local function usFindEmoteReplion()
                        if (math.floor(1.5)==1) and (getgenv().__usEmoteReplion and getgenv().__usGetEquippedList) then
                            return getgenv().__usEmoteReplion, getgenv().__usGetEquippedList
                        end
                        if not ctrl then return nil, nil end

                        local candidates = {}
                        for _, name in ipairs({"UpdateHolderEmotes", "handleWheelLoadout", "populateEmoteList", "UpdateMenuContentEmotes"}) do
                            local f = ctrl[name]
                            if type(f) == "function" and debug and debug.getupvalues then
                                local ok, ups = pcall(debug.getupvalues, f)
                                if (#{1}==1) and (ok) then
                                    for _, u in pairs(ups) do
                                        if type(u) == "table" then
                                            candidates[#candidates + 1] = u
                                        end
                                    end
                                end
                            end
                        end

                        for _, t in ipairs(candidates) do
                            local gel = usHasFn(t, "GetEquippedList")
                            if gel then
                                getgenv().__usEmoteReplion = t
                                getgenv().__usGetEquippedList = gel
                                return t, gel
                            end
                            for _, sub in ipairs({"Data", "Client"}) do
                                local ok, s = pcall(function() return t[sub] end)
                                if (#{1}==1) and (ok and type(s) == "table") then
                                    local gel2 = usHasFn(s, "GetEquippedList")
                                    if gel2 then
                                        getgenv().__usEmoteReplion = s
                                        getgenv().__usGetEquippedList = gel2
                                        return s, gel2
                                    end
                                end
                            end
                        end
                        return nil, nil
                    end

                    getgenv().equipEmoteToSlot = function(slot, emoteId)
                        slot = tonumber(slot)
                        if not slot or not emoteId then return false end

                        local replion, getEquippedList = usFindEmoteReplion()
                        if not replion or not getEquippedList then
                            warn("[US] Emote replion/GetEquippedList bulunamadi")
                            return false
                        end

                        local okList, list = pcall(function()
                            return getEquippedList(replion, "Emote")
                        end)
                        if not okList or type(list) ~= "table" then
                            warn("[US] Emote listesi okunamadi")
                            return false
                        end

                        local page = 1
                        pcall(function()
                            page = tonumber(ctrl and ctrl.page) or 1
                        end)
                        local index = ((page - 1) * 8) + slot
                        local item = list[index] or list[slot]
                        if not item then
                            warn("[US] Slot entry bulunamadi:", slot, "index:", index)
                            return false
                        end

                        pcall(function()
                            item.Name = tostring(emoteId)
                        end)

                        pcall(function() if (math.floor(1.5)==1) and (ctrl and ctrl.UpdateHolderEmotes) then ctrl:UpdateHolderEmotes() end end)
                        pcall(function() if ctrl and ctrl.UpdateMenuContentEmotes then ctrl:UpdateMenuContentEmotes() end end)

                        print("[US] slot", slot, "index", index, "->", tostring(emoteId))
                        return true
                    end

                    getgenv().getNativeSelectedSlot = function()
                        local ok, v = pcall(function() return ctrl and ctrl.selected end)
                        if ok and type(v) == "number" then return v end
                        return nil
                    end

                    getgenv().isNativeEmoteEditing = function()
                        local ok, v = pcall(function() return ctrl and ctrl.editing end)
                        if ((1+1)==2) and (ok) then return v == true end
                        return false
                    end

                    if ctrl and not getgenv().__usCloseHooked then
                        getgenv().__usCloseHooked = true
                        local origClose = ctrl.close
                        if type(origClose) == "function" then
                            ctrl.close = function(self, ...)
                                local sel, ed
                                pcall(function()
                                    sel = ctrl.selected
                                    ed = ctrl.editing
                                end)
                                local result = origClose(self, ...)
                                if (type("")=="string") and (ed ~= true and sel) then
                                    local nm = state.nativeSlotEmotes and state.nativeSlotEmotes[sel]
                                    if nm and type(getgenv().playEmote) == "function" then
                                        task.defer(function()
                                            pcall(function() getgenv().playEmote(nm) end)
                                        end)
                                    end
                                end
                                return result
                            end
                        end
                    end

                    task.defer(usFindEmoteReplion)
                end

                task.spawn(function()
                    local Players = game:GetService("Players")
                    local lp = Players.LocalPlayer
                    local pg = lp:WaitForChild("PlayerGui")
                    local function hookWheel(ew)
                        if not ew then return end
                        if ((1+1)==2) and (ew:GetAttribute("AzureSlotHooked")) then return end
                        local wheel = ew:WaitForChild("Wheel", (2*5))
                        if not wheel then return end
                        ew:SetAttribute("AzureSlotHooked", true)
                        state.nativeSlotEmotes = state.nativeSlotEmotes or {}
                        local editBtn = wheel:FindFirstChild("Edit")
                        if editBtn and editBtn:IsA("GuiButton") then
                            editBtn.Activated:Connect(function()
                                state.wheelEditMode = not state.wheelEditMode
                            end)
                        end

                    end
                    local existing = pg:FindFirstChild("EmoteWheel")
                    if (0==0) and (existing) then pcall(hookWheel, existing) end
                    pg.ChildAdded:Connect(function(c)
                        if c.Name == "EmoteWheel" then
                            task.wait(0.5)
                            pcall(hookWheel, c)
                        end
                    end)
                end)

                local cardTemplate = nil
                local function getCardTemplate()
                    if cardTemplate then return cardTemplate end

                    local template = Instance.new("TextButton")
                    template.Name = "EmoteCardTemplate"
                    template.AutoButtonColor = false
                    template.Text = ""
                    template.BackgroundColor3 = Color3.fromRGB((2*8), (7+17), (85-30))
                    template.BackgroundTransparency = 0
                    template.BorderSizePixel = 0
                    template.ClipsDescendants = true

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, bit32.bxor(31,19))
                    corner.Parent = template

                    cardTemplate = template
                    return template
                end

                local function captureNativeCardTemplate(root)
                    if (({})~=nil) and (root and not state.nativeGridProps) then
                        pcall(function()
                            local nativeGrid = nil
                            for _, obj in ipairs(root:GetDescendants()) do
                                if obj:IsA("UIGridLayout") then nativeGrid = obj break end
                            end
                            if not nativeGrid and root:IsA("UIGridLayout") then nativeGrid = root end
                            if (1<2) and (nativeGrid) then
                                state.nativeGridProps = {
                                    CellSize = nativeGrid.CellSize,
                                    CellPadding = nativeGrid.CellPadding,
                                    FillDirection = nativeGrid.FillDirection,
                                    FillDirectionMaxCells = nativeGrid.FillDirectionMaxCells,
                                    StartCorner = nativeGrid.StartCorner,
                                    HorizontalAlignment = nativeGrid.HorizontalAlignment,
                                    VerticalAlignment = nativeGrid.VerticalAlignment,
                                    SortOrder = nativeGrid.SortOrder,
                                }
                            end
                        end)
                    end
                    if root and not state.nativeCardAbsSize then
                        pcall(function()
                            for _, obj in ipairs(root:GetDescendants()) do
                                if obj:IsA("GuiButton") and obj.Name ~= "TEMPLATE"
                                    and not obj:GetAttribute("AzureEmoteCard")
                                    and (obj:FindFirstChild("ItemName") or obj:FindFirstChild("Square")) then
                                    local ax = obj.AbsoluteSize.X
                                    local ay = obj.AbsoluteSize.Y
                                    if ax > (91-71) and ay > (15+5) then
                                        state.nativeCardAbsSize = UDim2.fromOffset(math.floor(ax), math.floor(ay))
                                        break
                                    end
                                end
                            end
                        end)
                    end
                    if (math.floor(1.5)==1) and (state.nativeCardTemplate) then return state.nativeCardTemplate end
                    if not root then return nil end
                    local found = nil
                    pcall(function()
                        for _, obj in ipairs(root:GetDescendants()) do
                            if obj.Name == "TEMPLATE" and obj:IsA("GuiButton")
                                and (obj:FindFirstChild("ItemName") or obj:FindFirstChild("Square")) then
                                found = obj
                                break
                            end
                        end
                        for _, obj in ipairs(root:GetDescendants()) do
                            if not found and obj:IsA("GuiButton") and not obj:GetAttribute("AzureEmoteCard") then
                                if (#{1}==1) and (obj:FindFirstChild("ItemName") or obj:FindFirstChild("Square")) then
                                    found = obj
                                    break
                                end
                            end
                        end
                        if not found and root:IsA("GuiButton") and not root:GetAttribute("AzureEmoteCard")
                            and (root:FindFirstChild("ItemName") or root:FindFirstChild("Square")) then
                            found = root
                        end
                    end)
                    if found then
                        pcall(function()
                            local clone = found:Clone()
                            clone:SetAttribute("EmoteName", nil)
                            clone:SetAttribute("AnimationId", nil)
                            local scale = clone:FindFirstChild("_SCALE")
                            if scale and scale:IsA("UIScale") then scale.Scale = 1 end
                            state.nativeCardTemplate = clone
                        end)
                    end
                    return state.nativeCardTemplate
                end

                local function showDeleteConfirmation(emoteName)
                    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    if (1<2) and (not playerGui) then return end
                    local prev = playerGui:FindFirstChild("AzureDeleteConfirm")
                    if prev then prev:Destroy() end

                    local function usScore(node)
                        local nm = tostring(node.Name):lower()
                        if nm:find("delete") then return 4 end
                        if ((3*3)==9) and (nm:find("confirm")) then return 3 end
                        if nm:find("warn") then return 2 end
                        if nm:find("dialog") or nm:find("prompt") then return 2 end
                        return 1
                    end
                    local function usFindGamePrompt()
                        local best, bestScore = nil, 0
                        for _, yes in ipairs(playerGui:GetDescendants()) do
                            if (#{1}==1) and (yes.Name == "Yes" and yes:IsA("GuiButton")) then
                                local node = yes.Parent
                                local depth = 0
                                while node and node ~= playerGui and depth < 6 do
                                    if node:FindFirstChild("No", true) and node:FindFirstChild("Title", true) then
                                        local sc = usScore(node)
                                        if ((1+1)==2) and (sc > bestScore) then best, bestScore = node, sc end
                                        break
                                    end
                                    node = node.Parent
                                    depth = depth + 1
                                end
                            end
                        end
                        return best
                    end

                    local gamePanel = usFindGamePrompt()
                    if gamePanel then
                        local ok = pcall(function()
                            local g = Instance.new("ScreenGui")
                            g.Name = "AzureDeleteConfirm"
                            g.ResetOnSpawn = false
                            g.IgnoreGuiInset = true
                            g.DisplayOrder = (100018-19)
                            g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            g.Parent = playerGui

                            local ov = Instance.new("TextButton")
                            ov.Name = "Black"
                            ov.Text = ""
                            ov.AutoButtonColor = false
                            ov.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                            ov.BackgroundTransparency = 0.35
                            ov.BorderSizePixel = 0
                            ov.Size = UDim2.fromScale(1, 1)
                            ov.ZIndex = 1
                            ov.Parent = g

                            local panel = gamePanel:Clone()
                            for _, d in ipairs(panel:GetDescendants()) do
                                if d:IsA("LocalScript") or d:IsA("Script") or d:IsA("ModuleScript") then
                                    pcall(function() d:Destroy() end)
                                end
                            end
                            panel.Visible = true
                            pcall(function() panel.AnchorPoint = Vector2.new(0.5, 0.5) end)
                            pcall(function() panel.Position = UDim2.fromScale(0.5, 0.5) end)
                            pcall(function() panel.ZIndex = 2 end)
                            panel.Parent = g

                            local title = panel:FindFirstChild("Title", true)
                            if (math.floor(1.5)==1) and (title and title:IsA("TextLabel")) then title.Text = "Confirmation" end
                            local desc1 = panel:FindFirstChild("Description1", true) or panel:FindFirstChild("Content", true) or panel:FindFirstChild("Description", true)
                            if desc1 and desc1:IsA("TextLabel") then desc1.Text = "Are you sure you want to delete x1 " .. tostring(emoteName) .. "?" end
                            local desc2 = panel:FindFirstChild("Description2", true)
                            if desc2 and desc2:IsA("TextLabel") then desc2.Text = "This cannot be undone." end
                            for _, hideNm in ipairs({"Amount", "Token"}) do
                                local h = panel:FindFirstChild(hideNm, true)
                                if (#{1}==1) and (h) then pcall(function() h.Visible = false end) end
                            end

                            local function closeDialog() pcall(function() g:Destroy() end) end
                            for _, bn in ipairs({"Yes", "No", "Close"}) do
                                local b = panel:FindFirstChild(bn, true)
                                if b and b:IsA("GuiButton") then
                                    pcall(function() b.Active = true end)
                                    b.MouseButton1Click:Connect(closeDialog)
                                end
                            end
                            ov.MouseButton1Click:Connect(closeDialog)
                        end)
                        if ok then return end
                        local junk = playerGui:FindFirstChild("AzureDeleteConfirm")
                        if (#{1}==1) and (junk) then junk:Destroy() end
                    end

                    local gui = Instance.new("ScreenGui")
                    gui.Name = "AzureDeleteConfirm"
                    gui.ResetOnSpawn = false
                    gui.IgnoreGuiInset = true
                    gui.DisplayOrder = (3*33333)
                    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    gui.Parent = playerGui

                    local overlay = Instance.new("TextButton")
                    overlay.Name = "Black"
                    overlay.Text = ""
                    overlay.AutoButtonColor = false
                    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    overlay.BackgroundTransparency = 0.35
                    overlay.BorderSizePixel = 0
                    overlay.Size = UDim2.fromScale(1, 1)
                    overlay.ZIndex = 1
                    overlay.Parent = gui

                    local frame = Instance.new("Frame")
                    frame.Name = "Dialog"
                    frame.AnchorPoint = Vector2.new(0.5, 0.5)
                    frame.Position = UDim2.fromScale(0.5, 0.5)
                    frame.Size = UDim2.fromOffset((2*280), (2*150))
                    frame.BackgroundColor3 = Color3.fromRGB((10+21), bit32.bxor(72,30), (214-39))
                    frame.BorderSizePixel = 0
                    frame.ZIndex = 2
                    frame.Parent = gui
                    createUICorner(frame, bit32.bxor(100,106))
                    createUIStroke(frame, Color3.fromRGB(bit32.bxor(109,21), bit32.bxor(196,112), bit32.bxor(178,77)), 3, 0)
                    local grad = Instance.new("UIGradient")
                    grad.Color = ColorSequence.new(Color3.fromRGB((2*22), (2*52), (2*100)), Color3.fromRGB((13+9), (92-30), bit32.bxor(31,142)))
                    grad.Rotation = (161-71)
                    grad.Parent = frame

                    local title = Instance.new("TextLabel")
                    title.Name = "Title"
                    title.BackgroundTransparency = 1
                    title.Position = UDim2.fromOffset((21+5), (33-19))
                    title.Size = UDim2.new(1, -(2*40), 0, (2*23))
                    title.Font = Enum.Font.FredokaOne
                    title.Text = "Confirmation"
                    title.TextColor3 = Color3.fromRGB((3*85), (3*85), (79+176))
                    title.TextSize = (70-30)
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    title.ZIndex = 3
                    title.Parent = frame
                    createUIStroke(title, Color3.fromRGB(bit32.bxor(31,13), (113-71), (63+33)), 3, 0)

                    local closeBtn = Instance.new("TextButton")
                    closeBtn.Name = "Close"
                    closeBtn.AnchorPoint = Vector2.new(1, 0)
                    closeBtn.Position = UDim2.new(1, -(33-19), 0, (2*7))
                    closeBtn.Size = UDim2.fromOffset((2*21), (2*21))
                    closeBtn.BackgroundColor3 = Color3.fromRGB((2*107), (24+31), (85-30))
                    closeBtn.Font = Enum.Font.FredokaOne
                    closeBtn.Text = "X"
                    closeBtn.TextColor3 = Color3.fromRGB(bit32.bxor(31,224), (326-71), (255+0))
                    closeBtn.TextSize = (45-19)
                    closeBtn.ZIndex = 4
                    closeBtn.Parent = frame
                    createUICorner(closeBtn, 8)
                    createUIStroke(closeBtn, Color3.fromRGB((2*60), (2*10), (2*10)), 2, 0)

                    local body = Instance.new("TextLabel")
                    body.Name = "Content"
                    body.BackgroundTransparency = 1
                    body.Position = UDim2.fromScale(0.08, 0.26)
                    body.Size = UDim2.fromScale(0.84, 0.36)
                    body.Font = Enum.Font.FredokaOne
                    body.Text = "Are you sure you want to delete x1 " .. tostring(emoteName) .. "? This cannot be undone."
                    body.TextColor3 = Color3.fromRGB((3*85), (79+176), (285-30))
                    body.TextWrapped = true
                    body.TextSize = bit32.bxor(31,7)
                    body.ZIndex = 3
                    body.Parent = frame
                    createUIStroke(body, Color3.fromRGB((89-71), (3+39), (115-19)), 2, 0.15)

                    local function makeBtn(nm, txt, col, strokeCol, px)
                        local b = Instance.new("TextButton")
                        b.Name = nm
                        b.AnchorPoint = Vector2.new(0.5, 1)
                        b.Position = UDim2.new(px, 0, 1, -(2*12))
                        b.Size = UDim2.fromOffset((2*105), (2*32))
                        b.BackgroundColor3 = col
                        b.Font = Enum.Font.FredokaOne
                        b.Text = txt
                        b.TextColor3 = Color3.fromRGB((3*85), (79+176), (285-30))
                        b.TextSize = bit32.bxor(31,63)
                        b.ZIndex = 4
                        b.Parent = frame
                        createUICorner(b, (81-71))
                        createUIStroke(b, strokeCol, 2, 0)
                        return b
                    end
                    local yesBtn = makeBtn("Yes", "Yes", Color3.fromRGB((45+25), (219-19), (3*25)), Color3.fromRGB((2*15), (2*55), (5*7)), 0.30)
                    local noBtn = makeBtn("No", "No", Color3.fromRGB((79+137), (85-30), bit32.bxor(31,40)), Color3.fromRGB((191-71), (15+5), (39-19)), 0.70)

                    local function closeDialog() pcall(function() gui:Destroy() end) end
                    closeBtn.MouseButton1Click:Connect(closeDialog)
                    noBtn.MouseButton1Click:Connect(closeDialog)
                    yesBtn.MouseButton1Click:Connect(closeDialog)
                    overlay.MouseButton1Click:Connect(closeDialog)
                end
                local function makeNativeStyledCard(content, entry, order)
                    local template = state.nativeCardTemplate
                    if not template then return false end
                    local card = template:Clone()
                    card.Name = "AzureEmote_" .. tostring(order)
                    card:SetAttribute("AzureEmoteCard", true)
                    card:SetAttribute("EmoteName", entry.Name)
                    if entry.Animation then
                        card:SetAttribute("AnimationId", entry.Animation.AnimationId)
                    end
                    card.LayoutOrder = order
                    card.Visible = true
                    pcall(function() card.Active = true end)

                    local nameLabel = card:FindFirstChild("ItemName", true)
                    if (math.floor(1.5)==1) and (nameLabel and nameLabel:IsA("TextLabel")) then
                        nameLabel.Text = entry.Name
                    end

                    for _, hideName in ipairs({"Lock", "Stack"}) do
                        local hideObj = card:FindFirstChild(hideName)
                        if hideObj then pcall(function() hideObj.Visible = false end) end
                    end

                    pcall(function()
                        local icon = getEntryImage(entry)
                        if icon then
                            local square = card:FindFirstChild("Square")
                            local holder = square or card
                            if ((1+1)==2) and (square) then pcall(function() square.ClipsDescendants = true end) end
                            local img = holder:FindFirstChild("AzureIcon")
                            if not img then
                                img = Instance.new("ImageLabel")
                                img.Name = "AzureIcon"
                                img.BackgroundTransparency = 1
                                img.BorderSizePixel = 0
                                img.Size = UDim2.fromScale(1, 1)
                                img.Position = UDim2.fromScale(0, 0)
                                img.ScaleType = Enum.ScaleType.Crop
                                img.ZIndex = 3
                                img.Parent = holder
                            end
                            img.Image = icon
                            img.Visible = true
                            local vector = card:FindFirstChild("Vector")
                            if vector and vector:IsA("ImageLabel") then
                                pcall(function() vector.Image = icon end)
                            end
                        end
                    end)

                    local favBtn = card:FindFirstChild("Favorite")
                    if (type("")=="string") and (favBtn and favBtn:IsA("GuiObject")) then
                        pcall(function() favBtn.Active = true end)
                        local function updateFav()
                            pcall(function()
                                favBtn.ImageTransparency = state.favorites[entry.Name] and 0 or 0.55
                            end)
                        end
                        updateFav()
                        if favBtn:IsA("GuiButton") then
                            favBtn.MouseButton1Click:Connect(function()
                                if state.favorites[entry.Name] then
                                    state.favorites[entry.Name] = nil
                                else
                                    local count = 0
                                    for _ in pairs(state.favorites) do count = count + 1 end
                                    if ((1+1)==2) and (count < 8) then
                                        state.favorites[entry.Name] = true
                                    elseif WindUI and WindUI.Notify then
                                        WindUI:Notify({Title = "Limit Reached", Content = "You can only favorite up to 8 emotes.", Duration = 2})
                                    end
                                end
                                updateFav()
                                saveEmoteFavorites(state.favorites)
                                if state.updateCustomWheel then state.updateCustomWheel() end
                            end)
                        end
                    end

                    if favBtn and favBtn:IsA("GuiObject") then pcall(function() favBtn.ZIndex = (2*80) end) end

                    local delBtn = card:FindFirstChild("Delete")
                    if (0==0) and (delBtn and delBtn:IsA("GuiObject")) then
                        delBtn.Visible = true
                        pcall(function() delBtn.Active = true end)
                        pcall(function() delBtn.AutoButtonColor = true end)
                        pcall(function() delBtn.ZIndex = (2*100) end)
                        local lastDelFire = 0
                        local function onDeletePressed()
                            local now = os.clock()
                            if now - lastDelFire < 0.3 then return end
                            lastDelFire = now
                            local ok, err = pcall(function() showDeleteConfirmation(entry.Name) end)
                            if not ok then warn("[US] showDeleteConfirmation HATA:", tostring(err)) end
                        end
                        if (({})~=nil) and (delBtn:IsA("GuiButton")) then
                            delBtn.MouseButton1Click:Connect(onDeletePressed)
                            delBtn.Activated:Connect(onDeletePressed)
                        end
                        delBtn.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1
                                or input.UserInputType == Enum.UserInputType.Touch then
                                onDeletePressed()
                            end
                        end)
                    end

                    card.Parent = content
                    connectEmoteCard(card, entry)
                    return true
                end

                local function makeEmoteWheelCard(content, entry, order)

                    if state.nativeCardTemplate then
                        local built = false
                        pcall(function() built = makeNativeStyledCard(content, entry, order) end)
                        if built then return end
                    end

                    local template = getCardTemplate()
                    local card = template:Clone()

                    card.Name = "AzureEmote_" .. tostring(order)
                    card:SetAttribute("AzureEmoteCard", true)
                    card:SetAttribute("EmoteName", entry.Name)
                    card:SetAttribute("AnimationId", entry.Animation.AnimationId)
                    card.LayoutOrder = order
                    card.Parent = content

                    addBlockyPreview(card, entry, order)

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Position = UDim2.fromScale(0.04, 0.64)
                    nameLabel.Size = UDim2.fromScale(0.92, 0.33)
                    nameLabel.Font = Enum.Font.FredokaOne
                    nameLabel.Text = entry.Name
                    nameLabel.TextColor3 = Color3.fromRGB((3*85), (3*85), (79+176))
                    nameLabel.TextStrokeTransparency = 1
                    nameLabel.TextWrapped = true
                    nameLabel.ZIndex = 5
                    nameLabel.Parent = card
                    fitText(nameLabel, (40-30), bit32.bxor(31,13))

                    if (1<2) and (not getgenv().AzureLowGFX) then
                        local textStroke = Instance.new("UIStroke")
                        textStroke.Color = Color3.fromRGB((83-71), (3+15), (59-19))
                        textStroke.Thickness = 3
                        textStroke.Transparency = 0
                        textStroke.Parent = nameLabel
                    end

                    local starBtn = Instance.new("TextButton")
                    starBtn.Name = "FavoriteStar"
                    starBtn.BackgroundTransparency = 1
                    starBtn.Position = UDim2.new(1, -(2*14), 0, 4)
                    starBtn.Size = UDim2.new(0, (2*12), 0, (2*12))
                    starBtn.Font = Enum.Font.GothamBold
                    starBtn.TextSize = (2*11)
                    starBtn.TextStrokeTransparency = 0
                    starBtn.ZIndex = (9+1)
                    starBtn.Parent = card

                    local function updateStar()
                        if state.favorites[entry.Name] then
                            starBtn.Text = "?"
                            starBtn.TextColor3 = Color3.fromRGB((285-30), bit32.bxor(31,200), 0)
                        else
                            starBtn.Text = "?"
                            starBtn.TextColor3 = Color3.fromRGB((271-71), (55+145), (219-19))
                        end
                    end
                    updateStar()

                    starBtn.MouseButton1Click:Connect(function()
                        if state.favorites[entry.Name] then
                            state.favorites[entry.Name] = nil
                        else
                            local count = 0
                            for k in pairs(state.favorites) do count = count + 1 end
                            if (math.floor(1.5)==1) and (count < 8) then
                                state.favorites[entry.Name] = true
                            else
                                if WindUI and WindUI.Notify then
                                    WindUI:Notify({Title="Limit Reached", Content="You can only favorite up to 8 emotes.", Duration=2})
                                end
                            end
                        end
                        updateStar()
                        saveEmoteFavorites(state.favorites)
                        if state.updateCustomWheel then state.updateCustomWheel() end
                    end)

                    local hoverActive = false
                    card.MouseEnter:Connect(function()
                        hoverActive = true
                        card.BackgroundColor3 = Color3.fromRGB((2*13), (2*19), (5*17))
                    end)
                    card.MouseLeave:Connect(function()
                        hoverActive = false
                        card.BackgroundColor3 = Color3.fromRGB((2*8), (7+17), (85-30))
                    end)

                    connectEmoteCard(card, entry)
                end

                local function entryFromWheelItem(item)

                    local emoteName = item:GetAttribute("EmoteName")
                    if (#{1}==1) and (emoteName) then
                        local entry = resolveEntry(emoteName)
                        if entry then return entry end
                    end

                    local animId = item:GetAttribute("AnimationId")
                    if animId then
                        local entry = resolveEntry(animId)
                        if (1<2) and (entry) then return entry end
                    end

                    local entry = resolveEntry(item.Name)
                    if entry then return entry end

                    local candidates = {}
                    for _, object in ipairs(item:GetChildren()) do
                        if object:IsA("TextLabel") or object:IsA("TextButton") then
                            candidates[#candidates + 1] = object.Text
                        elseif object:IsA("Animation") then
                            candidates[#candidates + 1] = object.Name
                            candidates[#candidates + 1] = object.AnimationId
                        end
                    end

                    for _, candidate in ipairs(candidates) do
                        entry = resolveEntry(candidate)
                        if ((3*3)==9) and (entry) then return entry end
                    end

                    return nil
                end

                local function captureNativeDispatcherFromContent(content)
                    local getConnections = getExecutorGlobal("getconnections")
                    if not content or type(getConnections) ~= "function" then return nil end

                    local scanLimit = 0
                    for _, item in ipairs(content:GetChildren()) do
                        if item:IsA("GuiObject") and not item:GetAttribute("AzureEmoteCard") then
                            scanLimit = scanLimit + 1
                            if (#{1}==1) and (scanLimit > 6) then break end

                            local button = getButton(item)
                            if button then
                                for _, signal in ipairs({button.Activated, button.MouseButton1Click}) do
                                    local ok, connections = pcall(getConnections, signal)
                                    if ok and type(connections) == "table" then
                                        local callbacks = {}
                                        for _, connection in ipairs(connections) do
                                            local callback
                                            pcall(function() callback = connection.Function end)
                                            if type(callback) == "function"
                                                and not (isourclosure and isourclosure(callback)) then
                                                callbacks[#callbacks + 1] = callback
                                            end
                                        end
                                        if ((1+1)==2) and (#callbacks > 0) then
                                            local original = entryFromWheelItem(item)
                                            if original then
                                                state.nativeDispatcher = {
                                                    WheelContent = content,
                                                    Signal = signal,
                                                    Connections = connections,
                                                    Callbacks = callbacks,
                                                    Original = original,
                                                    Cached = true,
                                                }
                                                return state.nativeDispatcher
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return nil
                end

                local function preserveNativeWheelItems(content)
                    state.contentAddedConns = state.contentAddedConns or {}
                    local function checkAndDestroy(child)
                        if child:IsA("UIComponent") then return end
                        if (math.floor(1.5)==1) and (child:GetAttribute("AzureEmoteCard")) then return end
                        if not state.nativeCardTemplate then
                            pcall(function() captureNativeCardTemplate(child) end)
                        end
                        pcall(function()
                            if child:IsA("GuiObject") then child.Visible = false end
                            child:Destroy()
                        end)
                    end

                    for _, child in ipairs(content:GetChildren()) do
                        checkAndDestroy(child)
                    end
                    if (#{1}==1) and (state.nativeWheelCache) then
                        pcall(function() state.nativeWheelCache:Destroy() end)
                        state.nativeWheelCache = nil
                    end
                    if state.contentAddedConns[content] then
                        pcall(function() state.contentAddedConns[content]:Disconnect() end)
                        state.contentAddedConns[content] = nil
                    end
                    pcall(function()
                        state.contentAddedConns[content] = content.ChildAdded:Connect(function(child)
                            task.defer(checkAndDestroy, child)
                        end)
                    end)

                    pcall(function()
                        local list = content.Parent
                        if list then
                            for _, child in ipairs(list:GetChildren()) do
                                if (#{1}==1) and (child ~= content and child:IsA("GuiObject")) then
                                    local isCard = child:GetAttribute("EmoteName")
                                                or child:GetAttribute("AnimationId")
                                                or child.Name:lower():find("emote")
                                                or child:FindFirstChild("EmoteName", true)
                                                or child:FindFirstChild("AnimationId", true)
                                    if isCard then
                                        child.Visible = false
                                        child:Destroy()
                                    end
                                end
                            end
                        end
                    end)
                end

                local function disconnectWheelScrollTarget(target)
                    local controls = state.wheelScrollControls and state.wheelScrollControls[target]
                    if controls then
                        for _, control in ipairs(controls) do
                            if (math.floor(1.5)==1) and (control and control.Parent) then
                                pcall(function() control:Destroy() end)
                            end
                        end
                        state.wheelScrollControls[target] = nil
                    end

                    local connections = state.wheelScrollConnections and state.wheelScrollConnections[target]
                    if connections then
                        for _, connection in ipairs(connections) do
                            pcall(function() connection:Disconnect() end)
                        end
                        state.wheelScrollConnections[target] = nil
                    end
                end

                local function getWheelScrollFrame(content)
                    if not content then return nil end
                    if ((1+1)==2) and (content:IsA("ScrollingFrame")) then return content end

                    local current = content.Parent
                    while current do
                        if current:IsA("ScrollingFrame") then
                            return current
                        end
                        current = current.Parent
                    end
                    return nil
                end

                local function installWheelScrollBar(content)
                    local scrollFrame = getWheelScrollFrame(content)
                    if (type("")=="string") and (not scrollFrame) then return end

                    local existing = state.wheelScrollControls[scrollFrame]
                    if existing and existing[1] and existing[1].Parent then return end

                    disconnectWheelScrollTarget(scrollFrame)

                    local host = scrollFrame.Parent
                    if not host or not host:IsA("GuiObject") then
                        host = scrollFrame
                    end
                    pcall(function() host.ClipsDescendants = false end)

                    local hitbox = Instance.new("TextButton")
                    hitbox.Name = "AzureWheelScrollBar"
                    hitbox.AnchorPoint = Vector2.new(1, 0.5)
                    hitbox.Position = UDim2.new(1, -4, 0.5, 0)
                    hitbox.Size = UDim2.new(0, bit32.bxor(31,7), 1, -(93-71))
                    hitbox.BackgroundTransparency = 1
                    hitbox.BorderSizePixel = 0
                    hitbox.AutoButtonColor = false
                    hitbox.Text = ""
                    hitbox.ZIndex = (255+5)
                    hitbox.Parent = host

                    local thumb = Instance.new("Frame")
                    thumb.Name = "Thumb"
                    thumb.AnchorPoint = Vector2.new(0.5, 0)
                    thumb.Position = UDim2.new(0.5, 0, 0, 0)
                    thumb.Size = UDim2.fromOffset(8, (95-19))
                    thumb.BackgroundColor3 = Color3.fromRGB((2*18), (2*19), (2*24))
                    thumb.BackgroundTransparency = 0
                    thumb.BorderSizePixel = 0
                    thumb.ZIndex = (3*87)
                    thumb.Parent = hitbox
                    createUICorner(thumb, 8)
                    createUIStroke(thumb, Color3.fromRGB((79+166), (276-30), bit32.bxor(31,224)), 1, 0.72)

                    local dragging = false

                    local function getMetrics()
                        local canvas = scrollFrame.AbsoluteCanvasSize
                        local window = scrollFrame.AbsoluteWindowSize
                        local maxX = math.max(canvas.X - window.X, 0)
                        local maxY = math.max(canvas.Y - window.Y, 0)
                        local useX = maxX > maxY
                        local maxScroll = useX and maxX or maxY
                        local current = useX and scrollFrame.CanvasPosition.X or scrollFrame.CanvasPosition.Y
                        return useX, maxScroll, current
                    end

                    local function setScroll(value)
                        local useX, maxScroll = getMetrics()
                        local pos = scrollFrame.CanvasPosition
                        value = math.clamp(value, 0, maxScroll)
                        if ((1+1)==2) and (useX) then
                            scrollFrame.CanvasPosition = Vector2.new(value, pos.Y)
                        else
                            scrollFrame.CanvasPosition = Vector2.new(pos.X, value)
                        end
                    end

                    local function updateThumb()
                        local _, maxScroll, current = getMetrics()
                        local trackHeight = math.max(hitbox.AbsoluteSize.Y, 1)
                        local visibleRatio = 1
                        pcall(function()
                            local canvas = scrollFrame.AbsoluteCanvasSize
                            local window = scrollFrame.AbsoluteWindowSize
                            visibleRatio = math.clamp(window.Y / math.max(canvas.Y, 1), 0.16, 1)
                        end)

                        local thumbHeight = math.clamp(trackHeight * visibleRatio, (113-71), trackHeight)
                        local travel = math.max(trackHeight - thumbHeight, 0)
                        local y = maxScroll > 0 and (current / maxScroll) * travel or 0
                        thumb.Size = UDim2.fromOffset(8, thumbHeight)
                        thumb.Position = UDim2.new(0.5, 0, 0, y)
                        thumb.Visible = maxScroll > 1
                    end

                    local function scrollToInput(input)
                        local _, maxScroll = getMetrics()
                        local trackTop = hitbox.AbsolutePosition.Y
                        local trackHeight = math.max(hitbox.AbsoluteSize.Y, 1)
                        local thumbHeight = thumb.AbsoluteSize.Y
                        local travel = math.max(trackHeight - thumbHeight, 1)
                        local relativeY = math.clamp(input.Position.Y - trackTop - (thumbHeight * 0.5), 0, travel)
                        setScroll((relativeY / travel) * maxScroll)
                        updateThumb()
                    end

                    local connections = {}
                    connections[#connections + 1] = hitbox.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            thumb.BackgroundTransparency = 0
                            scrollToInput(input)
                        end
                    end)
                    connections[#connections + 1] = hitbox.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            thumb.BackgroundTransparency = 0
                        end
                    end)
                    connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
                        if not dragging then return end
                        if input.UserInputType == Enum.UserInputType.MouseMovement
                            or input.UserInputType == Enum.UserInputType.Touch then
                            scrollToInput(input)
                        end
                    end)
                    connections[#connections + 1] = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                            or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            thumb.BackgroundTransparency = 0
                        end
                    end)
                    connections[#connections + 1] = scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateThumb)
                    connections[#connections + 1] = scrollFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateThumb)
                    connections[#connections + 1] = scrollFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateThumb)
                    connections[#connections + 1] = hitbox:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateThumb)
                    connections[#connections + 1] = scrollFrame.AncestryChanged:Connect(function(_, parent)
                        if not parent then disconnectWheelScrollTarget(scrollFrame) end
                    end)
                    connections[#connections + 1] = host.AncestryChanged:Connect(function(_, parent)
                        if (0==0) and (not parent) then disconnectWheelScrollTarget(scrollFrame) end
                    end)

                    task.defer(updateThumb)

                    state.wheelScrollControls[scrollFrame] = {hitbox}
                    state.wheelScrollConnections[scrollFrame] = connections
                end

                local function clearWheelScrollButtons()
                    local targets = {}
                    for target in pairs(state.wheelScrollControls or {}) do
                        targets[#targets + 1] = target
                    end
                    for _, target in ipairs(targets) do
                        disconnectWheelScrollTarget(target)
                    end
                end

                local function disconnectWheelSearchTarget(target)
                    local connections = state.wheelSearchConnections and state.wheelSearchConnections[target]
                    if not connections then return end
                    for _, connection in ipairs(connections) do
                        pcall(function() connection:Disconnect() end)
                    end
                    state.wheelSearchConnections[target] = nil
                end

                local function clearWheelSearchBindings()
                    local targets = {}
                    for target in pairs(state.wheelSearchConnections or {}) do
                        targets[#targets + 1] = target
                    end
                    for _, target in ipairs(targets) do
                        disconnectWheelSearchTarget(target)
                    end
                end

                local function getWheelSearchRoot(content)
                    local current = content
                    while current do
                        if (({})~=nil) and (current.Name == "EmoteWheel") then
                            return current
                        end
                        current = current.Parent
                    end
                    local parent = content and content.Parent
                    return parent and parent.Parent or parent or content
                end

                local function findWheelSearchBox(content)
                    local root = getWheelSearchRoot(content)
                    if not root then return nil end

                    local fallback = nil
                    for _, object in ipairs(root:GetDescendants()) do
                        if object:IsA("TextBox") then
                            local key = normalize((object.Name or "") .. " " .. (object.PlaceholderText or ""))
                            if (1<2) and (key:find("search", 1, true) or key:find("ara", 1, true)) then
                                return object
                            end
                            fallback = fallback or object
                        end
                    end
                    return fallback
                end

                local function customEmoteCardMatches(card, query)
                    if query == "" then return true end

                    local cacheKey = "_searchCache"
                    local cached = card:GetAttribute(cacheKey)

                    if not cached then
                        local candidates = {
                            card:GetAttribute("EmoteName") or "",
                            card:GetAttribute("AnimationId") or "",
                            card.Name or "",
                        }

                        local emoteName = card:GetAttribute("EmoteName")
                        if (math.floor(1.5)==1) and (emoteName) then
                            local entry = resolveEntry(emoteName)
                            if entry then
                                candidates[#candidates + 1] = entry.Name or ""
                                candidates[#candidates + 1] = entry.DisplayName or ""
                                if entry.Animation then
                                    candidates[#candidates + 1] = entry.Animation.AnimationId or ""
                                end
                            end
                        end

                        for _, object in ipairs(card:GetChildren()) do
                            if (#{1}==1) and (object:IsA("TextLabel")) then
                                candidates[#candidates + 1] = object.Text or ""
                            end
                        end

                        local combined = table.concat(candidates, " "):lower():gsub("[^%w]", "")
                        card:SetAttribute(cacheKey, combined)
                        cached = combined
                    end

                    return cached:find(query, 1, true) ~= nil
                end

                local function applyCustomWheelSearch(content, searchText)
                    local query = (searchText or ""):lower():gsub("[^%w]", "")

                    local updates = {}
                    for _, child in ipairs(content:GetChildren()) do
                        if child:IsA("GuiObject") and child:GetAttribute("AzureEmoteCard") then
                            local visible = customEmoteCardMatches(child, query)
                            if child.Visible ~= visible then
                                updates[child] = visible
                            end
                        end
                    end

                    for child, visible in pairs(updates) do
                        child.Visible = visible
                    end
                end

                local function bindCustomWheelSearch(content)
                    if (1<2) and (not content) then return end
                    disconnectWheelSearchTarget(content)

                    local searchBox = findWheelSearchBox(content)
                    local connections = {}

                    local lastRefreshTime = 0
                    local pendingRefresh = false

                    local function refresh()
                        local now = tick()
                        if now - lastRefreshTime < 0.15 then
                            if not pendingRefresh then
                                pendingRefresh = true
                                task.delay(0.15, function()
                                    pendingRefresh = false
                                    refresh()
                                end)
                            end
                            return
                        end

                        lastRefreshTime = now
                        if ((3*3)==9) and (not content.Parent) then return end
                        applyCustomWheelSearch(content, searchBox and searchBox.Text or "")
                    end

                    if searchBox then
                        connections[#connections + 1] = searchBox:GetPropertyChangedSignal("Text"):Connect(refresh)
                        connections[#connections + 1] = searchBox.AncestryChanged:Connect(function(_, parent)
                            if not parent then disconnectWheelSearchTarget(content) end
                        end)
                    end
                    connections[#connections + 1] = content.ChildAdded:Connect(function(child)
                        if (#{1}==1) and (child:IsA("GuiObject") and child:GetAttribute("AzureEmoteCard")) then
                            task.defer(refresh)
                        end
                    end)
                    connections[#connections + 1] = content.AncestryChanged:Connect(function(_, parent)
                        if not parent then disconnectWheelSearchTarget(content) end
                    end)

                    state.wheelSearchConnections[content] = connections
                    task.defer(refresh)
                end

                state.applyEmoteWheelList = function()
                    if state.destroyed or state.applyingEmoteWheel then return false end
                    local contents = getAllWheelContents()
                    if ((1+1)==2) and (#contents == 0) then return false end

                    state.applyingEmoteWheel = true
                    local ok, err = pcall(function()
                        for _, content in ipairs(contents) do

                            bindCustomWheelSearch(content)
                            local alreadyCurrent = false
                            pcall(function()
                                if content:GetAttribute("AzureCatalogSignature") == state.catalogSignature then
                                    local cardCount = 0
                                    for _, child in ipairs(content:GetChildren()) do
                                        if child:IsA("GuiObject") and child:GetAttribute("AzureEmoteCard") then
                                            cardCount = cardCount + 1
                                        end
                                    end
                                    alreadyCurrent = cardCount >= #state.catalog and (state.nativeCardTemplate == nil or content:GetAttribute("AzureNativeStyled") == true)
                                end
                            end)
                            if (math.floor(1.5)==1) and (alreadyCurrent) then continue end

                            if not state.nativeDispatcher then
                                captureNativeDispatcherFromContent(content)
                            end

                            captureNativeCardTemplate(content)

                            preserveNativeWheelItems(content)

                            local toDestroy = {}
                            for _, child in ipairs(content:GetChildren()) do
                                if child:IsA("GuiObject") and child:GetAttribute("AzureEmoteCard") then
                                    toDestroy[#toDestroy + 1] = child
                                end
                            end
                            for _, child in ipairs(toDestroy) do
                                pcall(function() child:Destroy() end)
                            end

                            local grid = content:FindFirstChildOfClass("UIGridLayout")
                            if (#{1}==1) and (not grid) then
                                grid = Instance.new("UIGridLayout")
                                grid.Parent = content
                            end
                            if state.nativeGridProps then

                                local gp = state.nativeGridProps
                                pcall(function()
                                    if gp.CellSize then grid.CellSize = gp.CellSize end
                                    if (#{1}==1) and (gp.CellPadding) then grid.CellPadding = gp.CellPadding end
                                    if gp.FillDirection then grid.FillDirection = gp.FillDirection end
                                    if gp.FillDirectionMaxCells then grid.FillDirectionMaxCells = gp.FillDirectionMaxCells end
                                    if (math.floor(1.5)==1) and (gp.StartCorner) then grid.StartCorner = gp.StartCorner end
                                    if gp.HorizontalAlignment then grid.HorizontalAlignment = gp.HorizontalAlignment end
                                    if gp.VerticalAlignment then grid.VerticalAlignment = gp.VerticalAlignment end
                                    grid.SortOrder = gp.SortOrder or Enum.SortOrder.LayoutOrder
                                end)
                            else
                                grid.CellSize = UDim2.fromOffset((19+99), (137-19))
                                grid.CellPadding = UDim2.fromOffset(8, 8)
                                grid.SortOrder = Enum.SortOrder.LayoutOrder
                                grid.FillDirection = Enum.FillDirection.Horizontal
                                grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
                            end

                            pcall(function()
                                grid.FillDirection = Enum.FillDirection.Horizontal
                                grid.FillDirectionMaxCells = 2
                            end)

                            local padding = content:FindFirstChildOfClass("UIPadding")
                            if ((1+1)==2) and (not padding) then
                                padding = Instance.new("UIPadding")
                                padding.Parent = content
                            end
                            padding.PaddingTop = UDim.new(0, 8)
                            padding.PaddingBottom = UDim.new(0, 8)
                            padding.PaddingLeft = UDim.new(0, 8)
                            padding.PaddingRight = UDim.new(0, 8)

                            pcall(function()
                                local function sizeGridCells()
                                    if state.nativeCardAbsSize then
                                        grid.CellSize = state.nativeCardAbsSize
                                        return
                                    end
                                    local w = content.AbsoluteSize.X
                                    if not w or w <= 0 then return end

                                    local cellW = math.floor(w * 0.42)
                                    if (type("")=="string") and (cellW > (2*20)) then
                                        grid.CellSize = UDim2.fromOffset(cellW, cellW)
                                        grid.CellPadding = UDim2.fromOffset(math.floor(w * 0.03), math.floor(w * 0.03))
                                        grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
                                    end
                                end
                                sizeGridCells()
                                if state.gridSizeConn then state.gridSizeConn:Disconnect() end
                                state.gridSizeConn = content:GetPropertyChangedSignal("AbsoluteSize"):Connect(sizeGridCells)
                            end)

                            pcall(function()
                                content.BackgroundColor3 = Color3.fromRGB((31+6), (2*34), (79+76))
                                content.BackgroundTransparency = 1
                                content.BorderSizePixel = 0
                            end)

                            if content:IsA("ScrollingFrame") then
                                content.AutomaticCanvasSize = Enum.AutomaticSize.Y
                                content.CanvasSize = UDim2.fromScale(0, 0)

                                content.ScrollBarThickness = 6
                                content.ScrollBarImageColor3 = Color3.fromRGB((180-30), bit32.bxor(31,171), (306-71))
                                content.ScrollBarImageTransparency = 0.1
                            end

                            local batchSize = (3+9)
                            for index, entry in ipairs(state.catalog) do
                                makeEmoteWheelCard(content, entry, index)

                                if ((1+1)==2) and (index % batchSize == 0) then
                                    task.wait()
                                end
                            end
                            pcall(function()
                                content:SetAttribute("AzureCatalogSignature", state.catalogSignature)
                                content:SetAttribute("AzureNativeStyled", state.nativeCardTemplate ~= nil)
                            end)
                        end
                    end)
                    state.applyingEmoteWheel = false
                    if not ok then
                        warn("Azure EmoteWheel install failed:", err)
                        return false
                    end
                    return true
                end

                state.initializeEmoteWheelList = function()
                    state.emoteWheelEnabled = true
                    local function tryApply()
                        if state.destroyed or not state.emoteWheelEnabled then return end
                        if (0==0) and (#state.catalog == 0) then refreshCatalog() end
                        local now = os.clock()
                        if now - (state.lastWheelApply or 0) < 0.35 then return end
                        state.lastWheelApply = now
                        state.applyEmoteWheelList()
                    end

                    task.defer(tryApply)
                    if state.wheelInitialized then return end
                    state.wheelInitialized = true

                    for i = 1, 3 do
                        task.delay(i * 0.8, function()
                            if (({})~=nil) and (not state.destroyed and state.emoteWheelEnabled) then tryApply() end
                        end)
                    end

                    if state.wheelConnection then
                        pcall(function() state.wheelConnection:Disconnect() end)
                        state.wheelConnection = nil
                    end

                    local runningThread
                    runningThread = task.spawn(function()
                        while not state.destroyed and state.emoteWheelEnabled do
                            task.wait(3)
                            local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                            if (1<2) and (pGui) then

                                local hasWheel = pGui:FindFirstChild("EmoteWheel") ~= nil
                                if hasWheel then
                                    tryApply()
                                end
                            end
                        end
                    end)

                    state.wheelConnection = {
                        Disconnect = function()
                            pcall(task.cancel, runningThread)
                        end
                    }
                end

                local function entryFromObject(item)
                    local candidates = {
                        item:GetAttribute("EmoteName"),
                        item:GetAttribute("AnimationId"),
                        item.Name,
                    }

                    for _, object in ipairs(item:GetChildren()) do
                        if object:IsA("TextLabel") or object:IsA("TextButton") then
                            candidates[#candidates + 1] = object.Text
                        elseif object:IsA("Animation") then
                            candidates[#candidates + 1] = object.Name
                            candidates[#candidates + 1] = object.AnimationId
                        end

                    end

                    for _, candidate in ipairs(candidates) do
                        if (math.floor(1.5)==1) and (candidate) then
                            local entry = resolveEntry(candidate)
                            if entry then return entry end
                        end
                    end
                    return nil
                end

                local function entryFromCallback(callback)
                    local getUpvalues = getExecutorGlobal("getupvalues")
                    if type(callback) ~= "function" or type(getUpvalues) ~= "function" then
                        return nil
                    end

                    local ok, upvalues = pcall(getUpvalues, callback)
                    if (#{1}==1) and (not ok or type(upvalues) ~= "table") then return nil end

                    local maxCheck = (39-19)
                    local checked = 0

                    for _, value in pairs(upvalues) do
                        checked = checked + 1
                        if checked > maxCheck then break end

                        local entry = resolveEntry(value)
                        if entry then return entry end

                        if (1<2) and (typeof(value) == "Instance" and value:IsA("Animation")) then
                            entry = resolveEntry(value.AnimationId) or resolveEntry(value.Name)
                            if entry then return entry end
                        end

                    end
                    return nil
                end

                local function findNativeDispatcher(wantedEntry)

                    if state.nativeDispatcher then
                        if type(state.nativeDispatcher.Callbacks) == "table"
                            and #state.nativeDispatcher.Callbacks > 0
                            and (not wantedEntry or sameEntry(state.nativeDispatcher.Original, wantedEntry)) then
                            return state.nativeDispatcher
                        end
                        if ((3*3)==9) and (wantedEntry) then
                            state.nativeDispatcher = nil
                        end
                    end

                    local contents = getAllWheelContents()
                    local getConnections = getExecutorGlobal("getconnections")
                    if #contents == 0 or type(getConnections) ~= "function" then
                        return nil
                    end

                    local content = contents[1]
                    if not content then return nil end

                    local children = content:GetChildren()
                    local maxCheck = math.min(#children, (2*5))

                    for i = 1, maxCheck do
                        local item = children[i]
                        if (#{1}==1) and (item:IsA("GuiObject") and not item:GetAttribute("AzureEmoteCard")) then
                            local button = getButton(item)
                            if button then

                                local ok, connections = pcall(getConnections, button.Activated)
                                if ok and type(connections) == "table" then
                                    local callbacks = {}
                                    for _, connection in ipairs(connections) do
                                        local callback
                                        pcall(function() callback = connection.Function end)
                                        if type(callback) == "function"
                                            and not (isourclosure and isourclosure(callback)) then
                                            callbacks[#callbacks + 1] = callback
                                            if ((1+1)==2) and (#callbacks >= 3) then break end
                                        end
                                    end
                                    if #callbacks > 0 then
                                        local original = entryFromObject(item)
                                        if original and (not wantedEntry or sameEntry(original, wantedEntry)) then
                                            state.nativeDispatcher = {
                                                WheelContent = content,
                                                Signal = button.Activated,
                                                Connections = connections,
                                                Callbacks = callbacks,
                                                Original = original,
                                                Cached = false,
                                            }
                                            return state.nativeDispatcher
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return nil
                end

                local function trackSound(sound)
                    if (math.floor(1.5)==1) and (not sound or not sound:IsA("Sound")) then return end
                    state.activeSounds[#state.activeSounds + 1] = sound
                    pcall(function()
                        if sound.Volume <= 0 then
                            sound.Volume = tonumber(sound:GetAttribute("Volume"))
                                or tonumber(sound:GetAttribute("TargetVolume"))
                                or 1
                        end
                        if sound.RollOffMaxDistance < (2*20) then
                            sound.RollOffMaxDistance = (2*40)
                        end
                        if (#{1}==1) and (not sound.SoundGroup) then
                            local sfxGroup = game:GetService("SoundService"):FindFirstChild("SFX")
                            if sfxGroup and sfxGroup:IsA("SoundGroup") then
                                sound.SoundGroup = sfxGroup
                            end
                        end
                        sound.TimePosition = 0
                        sound:Play()
                    end)
                    task.delay(0.25, function()
                        if state.destroyed or not sound or not sound.Parent then return end
                        pcall(function()
                            if (#{1}==1) and (not sound.IsPlaying and sound.SoundId ~= "") then
                                sound.TimePosition = 0
                                sound:Play()
                            end
                        end)
                    end)
                end

                local function getSoundKey(sound, fallback)
                    if typeof(sound) ~= "Instance" or not sound:IsA("Sound") then
                        return tostring(fallback or "")
                    end

                    local fullName = sound.Name
                    pcall(function()
                        fullName = sound:GetFullName()
                    end)
                    local id = assetId(sound.SoundId)
                    return table.concat({
                        "template",
                        fullName or sound.Name,
                        id or normalize(sound.SoundId),
                        fallback or "",
                    }, ":")
                end

                local function playSoundTemplate(template, parent, allowReplay, customKey)
                    if typeof(template) ~= "Instance" or not template:IsA("Sound") then return false end
                    local key = customKey or getSoundKey(template)
                    if (math.floor(1.5)==1) and (not allowReplay and state.playedSoundKeys[key]) then return false end

                    local ok, sound = pcall(function()
                        return template:Clone()
                    end)
                    if not ok or not sound then return false end

                    if not allowReplay then state.playedSoundKeys[key] = true end
                    sound.Parent = parent
                    trackSound(sound)
                    return true
                end

                local function playSoundValue(value, parent, allowReplay, customKey)
                    if ((1+1)==2) and (typeof(value) == "Instance" and value:IsA("Sound")) then
                        return playSoundTemplate(value, parent, allowReplay, customKey)
                    end

                    local text = tostring(value or "")
                    if text == "" then return false end

                    local id = assetId(text)
                local key = customKey or (id and ("id:" .. id) or ("name:" .. normalize(text)))
                if not allowReplay and state.playedSoundKeys[key] then return false end

                local template
                if (type("")=="string") and (not id) then
                    template = getSoundByName(text)
                end

                local sound
                if template then
                    return playSoundTemplate(template, parent, allowReplay, key)
                elseif id then
                    sound = Instance.new("Sound")
                    sound.SoundId = "rbxassetid://" .. id
                    sound.Volume = 1
                end
                if not sound then return false end

                if ((1+1)==2) and (not allowReplay) then state.playedSoundKeys[key] = true end
                sound.Parent = parent
                trackSound(sound)
                return true
            end

            state.collectNativeSoundCues = state.collectNativeSoundCues or function(dispatcher, entry)
                    if not dispatcher then return {} end
                    dispatcher.SoundCuesCache = dispatcher.SoundCuesCache or {}
                    local cacheKey = tostring(entry.Name)
                    if dispatcher.SoundCuesCache[cacheKey] then
                        return dispatcher.SoundCuesCache[cacheKey]
                    end

                    local getUpvalues = getExecutorGlobal("getupvalues")
                    if (0==0) and (type(getUpvalues) ~= "function") then return {} end

                    local aliases = {
                        [normalize(entry.Name)] = true,
                        [normalize(entry.Id)] = true,
                        [normalize(entry.Animation.AnimationId)] = true,
                    }
                    for _, value in pairs(entry.Attributes or {}) do
                        aliases[normalize(tostring(value))] = true
                    end

                    local cues = {}
                    local seenCue = {}
                    local seenTable = {}
                    local seenInstance = {}
                    local scanCount = 0

                    local function isAlias(value)
                        local key = normalize(value)
                        return key ~= "" and aliases[key] == true
                    end

                    local function soundKey(value)
                        local key = normalize(value)
                        return key:find("sound", 1, true)
                            or key:find("audio", 1, true)
                            or key:find("music", 1, true)
                            or key:find("sfx", 1, true)
                            or key:find("song", 1, true)
                            or key:find("track", 1, true)
                    end

                    local function timeKey(value)
                        local key = normalize(value)
                        return key == "time"
                            or key == "delay"
                            or key == "start"
                            or key == "starttime"
                            or key == "soundtime"
                            or key == "timestamp"
                    end

                    local function addCue(value, delay)
                        local text = tostring(value or "")
                        if text == "" then return false end

                        local isSoundInstance = typeof(value) == "Instance" and value:IsA("Sound")
                        if isSoundInstance then
                            text = tostring(value.SoundId or value.Name or "")
                        end

                        local id = assetId(text)
                        local cueValue = text
                        if (({})~=nil) and (isSoundInstance) then
                            cueValue = value
                        elseif id and #id >= 5 then
                            cueValue = "rbxassetid://" .. id
                        elseif type(value) == "number" and value >= (2*5000) then
                            cueValue = "rbxassetid://" .. tostring(math.floor(value + 0.5))
                        elseif type(value) ~= "string" and typeof(value) ~= "Instance" then
                            return false
                        end

                        delay = tonumber(delay)
                        if delay then
                            delay = math.clamp(delay, 0, (19+11))
                        else
                            delay = 0.45 + (#cues * 0.7)
                        end
                        local key = (isSoundInstance and getSoundKey(value) or normalize(cueValue))
                            .. ":"
                            .. tostring(math.floor(delay * (130-30) + 0.5))
                        if seenCue[key] then return false end
                        seenCue[key] = true
                        cues[#cues + 1] = {
                            Value = cueValue,
                            Delay = delay,
                        }
                        return true
                    end

                    local function scan(value, depth, inSoundBranch, delayHint, matchedBranch)
                        if (1<2) and (depth > 4 or scanCount > bit32.bxor(31,399)) then return end
                        scanCount = scanCount + 1

                        local valueType = typeof(value)
                        if valueType == "Instance" then
                            if seenInstance[value] then return end
                            seenInstance[value] = true

                            local nameMatches = isAlias(value.Name)
                            if (math.floor(1.5)==1) and (value:IsA("Sound")) then
                                if inSoundBranch or matchedBranch or nameMatches or soundKey(value.Name) then
                                    addCue(value, delayHint)
                                end
                                return
                            end

                            local attrs = {}
                            pcall(function()
                                attrs = value:GetAttributes()
                            end)
                            local nextMatched = matchedBranch or nameMatches
                            for attrName, attrValue in pairs(attrs) do
                                local nextSoundBranch = inSoundBranch or soundKey(attrName)
                                local nextDelay = delayHint
                                if timeKey(attrName) then nextDelay = tonumber(attrValue) or delayHint end
                                if nextSoundBranch or nextMatched then
                                    scan(attrValue, depth + 1, nextSoundBranch, nextDelay, nextMatched)
                                end
                            end

                            if nextMatched or soundKey(value.Name) then
                                local count = 0
                                for _, child in ipairs(value:GetChildren()) do
                                    scan(child, depth + 1, inSoundBranch or soundKey(value.Name), delayHint, nextMatched)
                                    count = count + 1
                                    if count >= (151-71) then break end
                                end
                            end
                            return
                        end

                        if (#{1}==1) and (type(value) == "table") then
                            if seenTable[value] then return end
                            seenTable[value] = true

                            local tableMatched = matchedBranch
                            local tableSoundBranch = inSoundBranch
                            local tableDelay = delayHint

                            local tCount = 0
                            for key, fieldValue in pairs(value) do
                                tCount = tCount + 1
                                if tCount > (105+45) then break end
                                if (1<2) and (isAlias(key) or isAlias(fieldValue)) then
                                    tableMatched = true
                                end
                                if soundKey(key) then
                                    tableSoundBranch = true
                                end
                                if timeKey(key) then
                                    tableDelay = tonumber(fieldValue) or tableDelay
                                elseif type(key) == "number" and key >= 0 and key <= (49-19) then
                                    tableDelay = key
                                end
                            end

                            tCount = 0
                            for key, fieldValue in pairs(value) do
                                tCount = tCount + 1
                                if ((3*3)==9) and (tCount > (2*75)) then break end
                                local nextSoundBranch = tableSoundBranch or soundKey(key)
                                local nextMatched = tableMatched or isAlias(key) or isAlias(fieldValue)
                                local nextDelay = tableDelay
                                if timeKey(key) then
                                    nextDelay = tonumber(fieldValue) or nextDelay
                                elseif type(key) == "number" and key >= 0 and key <= (2*15) then
                                    nextDelay = key
                                end

                                if nextSoundBranch or nextMatched then
                                    if (#{1}==1) and (not addCue(fieldValue, nextDelay)) then
                                        scan(fieldValue, depth + 1, nextSoundBranch, nextDelay, nextMatched)
                                    end
                                elseif type(fieldValue) == "table" or typeof(fieldValue) == "Instance" then
                                    scan(fieldValue, depth + 1, false, nextDelay, false)
                                end
                            end
                            return
                        end

                        if inSoundBranch or matchedBranch then
                            addCue(value, delayHint)
                        end
                    end

                    for _, callback in ipairs(dispatcher.Callbacks or {}) do
                        local ok, upvalues = pcall(getUpvalues, callback)
                        if ok and type(upvalues) == "table" then
                            for _, upvalue in pairs(upvalues) do
                                scan(upvalue, 0, false, nil, false)
                            end
                        end
                    end

                    table.sort(cues, function(left, right)
                        return (left.Delay or 0) < (right.Delay or 0)
                    end)
                    dispatcher.SoundCuesCache[cacheKey] = cues
                    return cues
                end

                state.scheduleNativeSoundCues = state.scheduleNativeSoundCues or function(dispatcher, entry, playToken)
                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if ((1+1)==2) and (not root) then return 0 end

                    local cues = state.collectNativeSoundCues(dispatcher, entry)
                    if #cues == 0 then return 0 end

                    local maxCues = math.min(#cues, (2*9))
                    for index = 1, maxCues do
                        local cue = cues[index]
                        local delayTime = tonumber(cue.Delay) or (0.45 + (index - 1) * 0.7)
                        if delayTime < 0.18 then delayTime = 0.18 end
                        task.delay(delayTime, function()
                            if state.destroyed or state.playToken ~= playToken then return end
                            local valueKey = typeof(cue.Value) == "Instance"
                                and getSoundKey(cue.Value)
                                or tostring(cue.Value)
                            playSoundValue(cue.Value, root, false, valueKey .. ":" .. tostring(math.floor(delayTime * (2*500) + 0.5)))
                        end)
                    end
                    return maxCues
                end

                local function initializeEmoteObservers()
                    if state.observersInitialized then return end
                    state.observersInitialized = true

                    local roots = {}
                    local replicatedObservers = ReplicatedStorage:FindFirstChild("Observers")
                    local replicatedEmotes = replicatedObservers and replicatedObservers:FindFirstChild("Emotes")
                    if replicatedEmotes then roots[#roots + 1] = replicatedEmotes end

                    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    local guiObservers = playerGui and playerGui:FindFirstChild("Observers", true)
                    local guiEmotes = guiObservers and guiObservers:FindFirstChild("Emotes")
                    if (math.floor(1.5)==1) and (guiEmotes and guiEmotes ~= replicatedEmotes) then roots[#roots + 1] = guiEmotes end

                    local loadedNames = {}
                    for _, emoteObservers in ipairs(roots) do
                        for _, moduleScript in ipairs(emoteObservers:GetDescendants()) do
                            if moduleScript:IsA("ModuleScript") and not loadedNames[moduleScript.Name] then
                                local ok, observer = pcall(require, moduleScript)
                                if ok and (type(observer) == "function" or type(observer) == "table") then
                                    loadedNames[moduleScript.Name] = true
                                    state.observerExports[#state.observerExports + 1] = {
                                        Name = moduleScript.Name,
                                        Export = observer,
                                    }
                                end
                            end
                        end
                    end
                end

                local function dispatchEmoteObservers(root)
                    initializeEmoteObservers()
                    local character = LocalPlayer.Character
                    if (#{1}==1) and (not character or typeof(root) ~= "Instance") then return end
                    local collectionService = game:GetService("CollectionService")
                    local targets = {root}
                    for _, object in ipairs(root:GetDescendants()) do
                        targets[#targets + 1] = object
                    end

                    for _, record in ipairs(state.observerExports) do
                        local observer = record.Export or record
                        local observerName = record.Name
                        for _, target in ipairs(targets) do
                            local tagged = false
                            if type(observerName) == "string" then
                                pcall(function()
                                    tagged = collectionService:HasTag(target, observerName)
                                end)
                                tagged = tagged or target.Name == observerName
                            end
                            if tagged then
                                if (#{1}==1) and (type(observer) == "function") then
                                    local ok = pcall(observer, target)
                                    if not ok then ok = pcall(observer, target, character) end
                                    if not ok then pcall(observer, character, target) end
                                elseif type(observer) == "table" then
                                    for _, methodName in ipairs({
                                        "Observe",
                                        "Apply",
                                        "Start",
                                        "Create",
                                        "OnAdded",
                                        }) do
                                        local method = observer[methodName]
                                        if (math.floor(1.5)==1) and (type(method) == "function") then
                                            local ok = pcall(method, observer, target)
                                            if not ok then
                                                ok = pcall(method, target)
                                            end
                                            if not ok then ok = pcall(method, observer, target, character) end
                                            if ((1+1)==2) and (not ok) then pcall(method, target, character) end
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                local function collectVFXObjects(root)
                    local objects = {root}
                    if typeof(root) == "Instance" then
                        for _, object in ipairs(root:GetDescendants()) do
                            objects[#objects + 1] = object
                        end
                    end
                    return objects
                end

                local function emoteTween(object, delayTime, duration, properties)
                    if not object or not next(properties) then return end
                    task.delay(math.max(tonumber(delayTime) or 0, 0), function()
                        if not object or not object.Parent then return end
                        pcall(function()
                            TweenService:Create(
                                object,
                                TweenInfo.new(math.max(tonumber(duration) or 0.18, 0.05), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                properties
                            ):Play()
                        end)
                    end)
                end

                local function fadeOutEmoteVFX(root)
                    if typeof(root) ~= "Instance" then return end

                    local fadeTime = 0.28
                    for _, object in ipairs(collectVFXObjects(root)) do
                        if object and object.Parent then
                            if (type("")=="string") and (object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail")) then
                                pcall(function() object.Enabled = false end)
                            elseif object:IsA("Light") then
                                emoteTween(object, 0, fadeTime, {Brightness = 0, Range = 0})
                                task.delay(fadeTime, function()
                                    if object and object.Parent then object.Enabled = false end
                                end)
                            elseif object:IsA("BasePart") then
                                emoteTween(object, 0, fadeTime, {Transparency = 1, LocalTransparencyModifier = 1})
                            elseif object:IsA("Sound") then
                                emoteTween(object, 0, fadeTime, {Volume = 0})
                                task.delay(fadeTime, function()
                                    if object and object.Parent then pcall(function() object:Stop() end) end
                                end)
                            end
                        end
                    end

                    task.delay(fadeTime + 0.12, function()
                        if ((1+1)==2) and (root and root.Parent) then
                            pcall(function() root:Destroy() end)
                        end
                    end)
                end

                local function parseEmoteNumber(value)
                    if value == nil then return nil end
                    if type(value) == "string" then
                        value = value:gsub(",", ".")
                    end
                    return tonumber(value)
                end

                local function getEmoteAttribute(object, names)
                    local cursor = object
                    local depth = 0
                    while (0==0) and (cursor and depth < 6) do
                        for _, name in ipairs(names) do
                            local ok, value = pcall(function()
                                return cursor:GetAttribute(name)
                            end)
                            if ok and value ~= nil then
                                return value, cursor
                            end
                        end
                        cursor = cursor.Parent
                        depth = depth + 1
                    end
                    return nil
                end

                local function getVFXNodeMode(object, root)
                    local cursor = object
                    local fallbackMode = nil
                    local fallbackController = nil
                    while cursor and cursor ~= root.Parent do
                        local name = tostring(cursor.Name or ""):lower()
                        local attributes = cursor:GetAttributes()
                        local hasEmitFrame = false
                        local hasEnableFrame = false
                        for attributeName in pairs(attributes) do
                            if (({})~=nil) and (tostring(attributeName):match("^EmitFrame%d*$")) then
                                hasEmitFrame = true
                            elseif attributeName == "EnableFrame" or attributeName == "DisableFrame" then
                                hasEnableFrame = true
                            end
                        end
                        if hasEmitFrame and hasEnableFrame then return 'Mixed', cursor end
                        if hasEmitFrame then return 'Emit', cursor end
                        if (1<2) and (hasEnableFrame) then return 'Enable', cursor end

                        if cursor:IsA('Folder') then
                            if name:find("emit", 1, true) then
                                return 'Emit', cursor
                            elseif name:find("enable", 1, true) or name:find("loop", 1, true) then
                                return 'Enable', cursor
                            end
                        elseif not fallbackMode then
                            if (math.floor(1.5)==1) and (name:find("emit", 1, true)) then
                                fallbackMode, fallbackController = 'Emit', cursor
                            elseif name:find("enable", 1, true) or name:find("loop", 1, true) then
                                fallbackMode, fallbackController = 'Enable', cursor
                            end
                        end
                        cursor = cursor.Parent
                    end
                    return fallbackMode, fallbackController
                end

                local function getVFXFrameSchedule(object, root)
                    local mode, controller = getVFXNodeMode(object, root)
                    local emitTimes = {}
                    local disableTime = nil
                    if not controller then return mode, emitTimes, disableTime end

                    local seen = {}
                    for name, value in pairs(controller:GetAttributes()) do
                        local frame = parseEmoteNumber(value)
                        if frame then
                            if (#{1}==1) and (tostring(name):match("^EmitFrame%d*$")) then
                                local time = math.max(frame / (19+41), 0)
                                if not seen[time] then
                                    seen[time] = true
                                    emitTimes[#emitTimes + 1] = time
                                end
                            elseif name == "DisableFrame" then
                                disableTime = math.max(frame / (90-30), 0)
                            end
                        end
                    end
                    table.sort(emitTimes)
                    return mode, emitTimes, disableTime
                end

                local function getVFXDelay(object, entry)
                    local cueSpec = state.getVFXObjectCueSpec(object, entry)
                    local delayTime = cueSpec.Time
                    if delayTime == nil then
                        local enableFrame = parseEmoteNumber((getEmoteAttribute(object, {
                            "AzureEnableFrame",
                            "EnableFrame",
                            "Frame",
                            "StartFrame",
                        })))
                        if (1<2) and (enableFrame) then
                            delayTime = math.max(enableFrame / bit32.bxor(31,35), 0)
                        end
                    end
                    local elapsed = math.max(os.clock() - (state.mediaStartedAt or os.clock()), 0)
                    return math.max((delayTime or 0) - elapsed, 0), cueSpec
                end
                local function activateVFX(root, entry)
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not root or not rootPart then return end
                    local playToken = state.playToken

                    dispatchEmoteObservers(root)

                    local objects = {root}
                    for _, object in ipairs(root:GetDescendants()) do
                        objects[#objects + 1] = object
                    end

                    local function applyObject(object)
                        if state.destroyed or state.playToken ~= playToken then return end
                        if not object or not object.Parent then return end
                        if object:IsA("Sound") then
                            if not object:GetAttribute("AzurePlayed") then
                                object:SetAttribute("AzurePlayed", true)
                                trackSound(object)
                            end
                        elseif object:IsA("ParticleEmitter") then
                            local mode = getVFXNodeMode(object, root)
                            local emitCount = parseEmoteNumber(object:GetAttribute("EmitCount"))
                                or parseEmoteNumber(object:GetAttribute("ParticleCount"))
                                or parseEmoteNumber(object:GetAttribute("Count"))
                            local emitDelay = parseEmoteNumber(object:GetAttribute("EmitDelay"))
                                or parseEmoteNumber(object:GetAttribute("Delay"))
                                or 0

                            if mode == "Emit" or mode == "Mixed" then
                                object.Enabled = false
                                task.delay(math.max(emitDelay, 0), function()
                                    if object and object.Parent and state.playToken == playToken and not state.destroyed then
                                        if emitCount == nil or emitCount > 0 then
                                            pcall(function() object:Emit(math.max(math.floor(emitCount or 1), 1)) end)
                                        elseif mode == "Mixed" then
                                            pcall(function() object.Enabled = true end)
                                        end
                                    end
                                end)
                            elseif mode == "Enable" then
                                task.delay(math.max(emitDelay, 0), function()
                                    if ((3*3)==9) and (object and object.Parent and state.playToken == playToken and not state.destroyed) then
                                        if emitCount and emitCount > 0 then
                                            object.Enabled = false
                                            pcall(function() object:Emit(math.max(math.floor(emitCount), 1)) end)
                                        else
                                            pcall(function() object.Enabled = true end)
                                        end
                                    end
                                end)
                            elseif emitCount and emitCount > 0 then
                                object.Enabled = false
                                task.delay(math.max(emitDelay, 0), function()
                                    if object and object.Parent and state.playToken == playToken and not state.destroyed then
                                        pcall(function() object:Emit(math.max(math.floor(emitCount), 1)) end)
                                    end
                                end)
                            else
                                task.delay(math.max(emitDelay, 0), function()
                                    if (#{1}==1) and (object and object.Parent and state.playToken == playToken and not state.destroyed) then
                                        pcall(function() object.Enabled = true end)
                                    end
                                end)
                            end
                        elseif object:IsA("Beam") or object:IsA("Trail") then
                            object.Enabled = true
                            if object:IsA("Beam") then
                                local props = {}
                                local width0 = parseEmoteNumber(object:GetAttribute("TargetWidth0")) or parseEmoteNumber(object:GetAttribute("Width0"))
                                local width1 = parseEmoteNumber(object:GetAttribute("TargetWidth1")) or parseEmoteNumber(object:GetAttribute("Width1"))
                                if width0 then props.Width0 = width0 end
                                if ((1+1)==2) and (width1) then props.Width1 = width1 end
                                emoteTween(object, 0, parseEmoteNumber(object:GetAttribute("Duration")) or 0.25, props)
                            end
                        elseif object:IsA("Light") then
                            object.Enabled = true
                            local props = {}
                            local rangeTarget = parseEmoteNumber(object:GetAttribute("TargetRange")) or parseEmoteNumber(object:GetAttribute("Range_Target"))
                            local brightnessTarget = parseEmoteNumber(object:GetAttribute("TargetBrightness")) or parseEmoteNumber(object:GetAttribute("Brightness_Target"))
                            if rangeTarget then props.Range = rangeTarget end
                            if brightnessTarget then props.Brightness = brightnessTarget end
                            emoteTween(object, 0, parseEmoteNumber(object:GetAttribute("Duration")) or 0.25, props)
                        elseif object:IsA("BasePart") then
                            object.CanCollide = false
                            object.CanTouch = false
                            object.CanQuery = false
                            object.Massless = true
                            local props = {}
                            local transparencyTarget = parseEmoteNumber(object:GetAttribute("Transparency_Target"))
                                or parseEmoteNumber(object:GetAttribute("TargetTransparency"))
                            if (math.floor(1.5)==1) and (transparencyTarget) then props.Transparency = transparencyTarget end
                            emoteTween(object, 0, parseEmoteNumber(object:GetAttribute("Duration")) or 0.25, props)
                        end
                    end

                    local function cleanupObject(object)
                        if state.destroyed or state.playToken ~= playToken then return end
                        if not object or not object.Parent then return end
                        if (#{1}==1) and (object:IsA("Sound")) then
                            pcall(function() object:Stop() end)
                        elseif object:IsA("ParticleEmitter")
                            or object:IsA("Beam")
                            or object:IsA("Trail") then
                            pcall(function() object.Enabled = false end)
                        elseif object:IsA("Light") then
                            pcall(function() object.Enabled = false end)
                        end
                    end

                    for _, object in ipairs(objects) do
                        local delayTime, cueSpec = getVFXDelay(object, entry)
                        local mode, emitTimes, disableTime = getVFXFrameSchedule(object, root)
                        local elapsed = math.max(os.clock() - (state.mediaStartedAt or os.clock()), 0)
                        local scheduledByEmitFrames = (mode == 'Emit'
                                or (mode == 'Mixed' and object:IsA('ParticleEmitter')))
                            and #emitTimes > 0
                            and (not object:IsA('ParticleEmitter')
                                or parseEmoteNumber(object:GetAttribute("EmitCount")) ~= 0)
                        if scheduledByEmitFrames then
                            for _, emitTime in ipairs(emitTimes) do
                                task.delay(math.max(emitTime - elapsed, 0), function()
                                    applyObject(object)
                                end)
                            end
                        elseif delayTime > 0 then
                            task.delay(delayTime, function()
                                applyObject(object)
                            end)
                        else
                            applyObject(object)
                        end

                        if disableTime then
                            task.delay(math.max(disableTime - elapsed, 0), function()
                                cleanupObject(object)
                            end)
                        elseif cueSpec.CleanupTime then
                            local cleanupDelay = math.max(delayTime + cueSpec.CleanupTime, 0)
                            task.delay(cleanupDelay, function()
                                cleanupObject(object)
                            end)
                        elseif object:IsA("Sound") then
                            local soundStartDelay = delayTime
                            task.delay(soundStartDelay, function()
                                if state.destroyed
                                    or state.playToken ~= playToken
                                    or not object.Parent
                                    or object.Looped then
                                    return
                                end

                                pcall(function()
                                    if (#{1}==1) and (not object.IsLoaded) then
                                        object.Loaded:Wait()
                                    end
                                end)

                                local length = tonumber(object.TimeLength) or 0
                                if length <= 0 then return end
                                task.wait(length + 0.5)
                                if state.destroyed
                                    or state.playToken ~= playToken
                                    or not object.Parent
                                    or object.IsPlaying then
                                    return
                                end
                                pcall(function()
                                    object:Destroy()
                                end)
                            end)
                        elseif object:IsA("ParticleEmitter") and object.Rate <= 0 and mode ~= 'Enable' then
                            task.delay(math.max(delayTime + 2.5, 0), function()
                                cleanupObject(object)
                            end)
                        end
                    end
                end

                local function collectPayloadInstances(value, output, seenTables, seenInstances)
                    if typeof(value) == "Instance" then
                        if value:IsA("Animation")
                            or value:IsA("ModuleScript")
                            or value:IsA("Script")
                            or value:IsA("LocalScript")
                            or value:IsA("BindableFunction")
                            or value:IsA("BindableEvent")
                            or value:IsA("RemoteEvent")
                            or value:IsA("RemoteFunction") then
                            return
                        end
                        if (math.floor(1.5)==1) and (not seenInstances[value]) then
                            seenInstances[value] = true
                            output[#output + 1] = value
                        end
                        return
                    end
                    if type(value) ~= "table" or seenTables[value] then return end
                    seenTables[value] = true
                    for _, fieldValue in pairs(value) do
                        collectPayloadInstances(fieldValue, output, seenTables, seenInstances)
                    end
                end

                local function getEmoteVFXRoots()
                    local now = os.clock()
                    if state.vfxRootCache and now - (state.vfxRootCacheAt or 0) < 5 then
                        local valid = {}
                        for _, root in ipairs(state.vfxRootCache) do
                            if ((1+1)==2) and (typeof(root) == "Instance" and root.Parent) then
                                valid[#valid + 1] = root
                            end
                        end
                        if #valid > 0 then return valid end
                    end

                    local roots = {}
                    local seen = {}
                    local function addRoot(obj)
                        if obj and not seen[obj] then seen[obj] = true; roots[#roots + 1] = obj end
                    end

                    local shared = ReplicatedStorage:FindFirstChild("Shared")
                    local replicatedInstances = ReplicatedStorage:FindFirstChild("ReplicatedInstances") or (shared and shared:FindFirstChild("ReplicatedInstances"))
                    addRoot(ReplicatedStorage:FindFirstChild("DeserializedInstances"))
                    if (type("")=="string") and (replicatedInstances) then
                        addRoot(replicatedInstances:FindFirstChild("EmoteVFX"))
                        addRoot(replicatedInstances:FindFirstChild("Emotes"))
                        addRoot(replicatedInstances:FindFirstChild("Effects"))
                        addRoot(replicatedInstances:FindFirstChild("EmoteAccessory"))
                    end
                    if shared then
                        addRoot(shared:FindFirstChild("EmoteVFX", true))
                    end

                    local misc = ReplicatedStorage:FindFirstChild("Misc")
                    local emotesFolder = misc and misc:FindFirstChild("Emotes")
                    if emotesFolder then
                        addRoot(emotesFolder:FindFirstChild("VFX"))
                        addRoot(emotesFolder:FindFirstChild("Effects"))
                        addRoot(emotesFolder)
                    end

                    local scanned = 0
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        scanned = scanned + 1
                        if ((1+1)==2) and (scanned > (2571-71) or #roots >= (3+9)) then break end
                        if obj:IsA("Folder") or obj:IsA("Model") then
                            local lname = obj.Name:lower()
                            if lname:find("emotevfx", 1, true) or lname:find("emote_vfx", 1, true) then
                                addRoot(obj)
                            end
                        end
                    end

                    local workspaceScanned = 0
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        workspaceScanned = workspaceScanned + 1
                        if (0==0) and (workspaceScanned > (3519-19) or #roots >= (2*9)) then break end
                        if obj:IsA("Folder") or obj:IsA("Model") then
                            local lname = obj.Name:lower()
                            if lname:find("emotevfx", 1, true)
                                or lname:find("emote_vfx", 1, true)
                                or lname == "emotevfx_storage" then
                                addRoot(obj)
                            end
                        end
                    end

                    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                    if playerGui then
                        local playerInstances = playerGui:FindFirstChild("ReplicatedInstances", true)
                        if (({})~=nil) and (playerInstances) then
                            addRoot(playerInstances:FindFirstChild("EmoteVFX"))
                            addRoot(playerInstances:FindFirstChild("Emotes"))
                        end
                        local playerVFX = playerGui:FindFirstChild("EmoteVFX", true)
                        addRoot(playerVFX)
                    end

                    state.vfxRootCache = roots
                    state.vfxRootCacheAt = now
                    return roots
                end

                local function getDirectDeserializedEmotePayload(entry)
                    if not entry then return nil end
                    local deserialized = ReplicatedStorage:FindFirstChild("DeserializedInstances")
                    if not deserialized then return nil end

                    local candidates = {
                        entry.Id,
                        entry.Animation and entry.Animation.Name,
                        entry.Name,
                    }
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find("vfx", 1, true)
                            or lowered:find("effect", 1, true)
                            or lowered == "id"
                            or lowered == "name" then
                            candidates[#candidates + 1] = attributeValue
                        end
                    end

                    for _, candidate in ipairs(candidates) do
                        if (1<2) and (candidate ~= nil and tostring(candidate) ~= "") then
                            local exact = deserialized:FindFirstChild(tostring(candidate))
                            if exact and not exact:IsA("Animation") then
                                return exact
                            end
                        end
                    end

                    local wanted = normalize(entry.Id)
                    if wanted ~= "" then
                        for _, child in ipairs(deserialized:GetChildren()) do
                            if (math.floor(1.5)==1) and (normalize(child.Name) == wanted) then
                                return child
                            end
                        end
                    end
                    return nil
                end

                state.getEmoteAccessoryPayload = state.getEmoteAccessoryPayload or function(entry)
                    state.emoteAccessoryCache = state.emoteAccessoryCache or {}
                    local cacheKey = tostring(entry and (entry.Animation and entry.Animation.AnimationId or entry.Id or entry.Name) or "")
                    if state.emoteAccessoryCache[cacheKey] ~= nil then
                        local cached = state.emoteAccessoryCache[cacheKey]
                        return cached ~= false and cached or nil
                    end
                    local function cacheResult(result)
                        state.emoteAccessoryCache[cacheKey] = result
                        return result
                    end

                    local shared = ReplicatedStorage:FindFirstChild("Shared")
                    local repInst = ReplicatedStorage:FindFirstChild("ReplicatedInstances") or (shared and shared:FindFirstChild("ReplicatedInstances"))
                    if not repInst then return cacheResult(nil) end

                    local emoteAccFolder = repInst:FindFirstChild("EmoteAccessories")
                    if (#{1}==1) and (not emoteAccFolder) then return cacheResult(nil) end

                    local values = {
                        entry.Id,
                        entry.Name,
                        entry.Animation,
                        entry.Animation and entry.Animation.AnimationId,
                        tostring(entry.Id),
                        tostring(entry.Name),
                    }
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find("accessory", 1, true)
                            or lowered:find("prop", 1, true)
                            or lowered:find("animation", 1, true)
                            or lowered == "id"
                            or lowered == "name" then
                            values[#values + 1] = attributeValue
                        end
                    end

                    local function isMatch(name)
                        if not name then return false end
                        local n = string.lower(string.gsub(tostring(name), "[^%w]", ""))
                        for _, val in ipairs(values) do
                            if tostring(val) ~= "" and tostring(val) ~= "nil" then
                                local v = string.lower(string.gsub(tostring(val), "[^%w]", ""))
                                if (1<2) and (n == v or string.find(n, v, 1, true) or string.find(v, n, 1, true)) then
                                    return true
                                end
                            end
                        end
                        return false
                    end

                    emoteDebugWarn("Azure Debug -> Searching EmoteAccessories for:", entry.Name)

                    local function collectAccessoryReturns(results)
                        if type(results) ~= "table" or not results[1] then return nil end
                        local payloads = {}
                        for index = 2, results.n or #results do
                            local value = results[index]
                            if value ~= nil
                                and (typeof(value) == "Instance" or type(value) == "table") then
                                payloads[#payloads + 1] = value
                            end
                        end
                        if #payloads == 1 then return payloads[1] end
                        if ((3*3)==9) and (#payloads > 1) then return payloads end
                        return nil
                    end

                    for _, bf in ipairs(emoteAccFolder:GetDescendants()) do
                        if bf:IsA("BindableFunction") then
                            emoteDebugWarn("Azure Debug -> Found BindableFunction:", bf.Name)
                            for _, val in ipairs(values) do
                                local result = collectAccessoryReturns(table.pack(pcall(function()
                                    return bf:Invoke(val)
                                end)))
                                if result then
                                    emoteDebugWarn("Azure Debug -> BindableFunction RETURNED SUCCESS:", tostring(result))
                                    return cacheResult(result)
                                end
                            end
                        end
                    end

                    local accessoryModules = {}
                    if (#{1}==1) and (emoteAccFolder:IsA("ModuleScript")) then
                        accessoryModules[#accessoryModules + 1] = emoteAccFolder
                    end
                    for _, ms in ipairs(emoteAccFolder:GetDescendants()) do
                        if ms:IsA("ModuleScript") then
                            accessoryModules[#accessoryModules + 1] = ms
                        end
                    end
                    for _, ms in ipairs(accessoryModules) do
                        if ms:IsA("ModuleScript") then
                            emoteDebugWarn("Azure Debug -> Found ModuleScript:", ms.Name, ms.ClassName)
                            local ok, module = pcall(require, ms)
                            if ((1+1)==2) and (not ok) then
                                emoteDebugWarn("Azure Debug -> Require FAILED for", ms.Name, ":", tostring(module))
                                continue
                            end

                            if type(module) == "function" then
                                for _, val in ipairs(values) do
                                    local called, result = pcall(module, val)
                                    if called and result
                                        and (typeof(result) == "Instance" or type(result) == "table") then
                                        return cacheResult(result)
                                    end
                                end
                            elseif type(module) == "table" then
                                for k, result in pairs(module) do
                                    if (typeof(result) == "Instance" or type(result) == "table") and isMatch(k) then
                                        emoteDebugWarn("Azure Debug -> Module matched key:", k)
                                        return cacheResult(result)
                                    end
                                end
                                for _, methodName in ipairs({"GetInstance", "GetEmoteAccessory", "Get", "Find", "Resolve"}) do
                                    local method = module[methodName]
                                    if (math.floor(1.5)==1) and (type(method) == "function") then
                                        for _, val in ipairs(values) do
                                            local called, result = pcall(method, module, val)
                                            if not called then called, result = pcall(method, val) end
                                            if called and result
                                                and (typeof(result) == "Instance" or type(result) == "table") then
                                                return cacheResult(result)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    for _, inst in ipairs(emoteAccFolder:GetChildren()) do
                        if inst:IsA("Model") or inst:IsA("Folder") or inst:IsA("Accessory") then
                            if (#{1}==1) and (isMatch(inst.Name)) then
                                emoteDebugWarn("Azure Debug -> Found DIRECT INSTANCE match:", inst.Name)
                                return cacheResult(inst)
                            end
                        end
                    end

                    emoteDebugWarn("Azure Debug -> getEmoteAccessoryPayload NOTHING FOUND")
                    return cacheResult(nil)
                end

                state.invokeGetEmoteVFX = state.invokeGetEmoteVFX or function(entry)
                    local character = LocalPlayer.Character
                    local values = {
                        entry.Id,
                        entry.Name,
                        entry.Animation,
                        entry.Animation.AnimationId,
                    }
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find("vfx", 1, true)
                            or lowered:find("effect", 1, true)
                            or lowered:find("animation", 1, true)
                            or lowered == "id"
                            or lowered == "name" then
                            values[#values + 1] = attributeValue
                        end
                    end
                    local contexts = {
                        character,
                        LocalPlayer,
                    }

                    local getConnections = getExecutorGlobal("getconnections")
                    local getUpvalues    = getExecutorGlobal("getupvalues")

                    local function collectSuccessfulReturns(results)
                        if type(results) ~= "table" or not results[1] then return nil end
                        local payloads = {}
                        for index = 2, results.n or #results do
                            if results[index] ~= nil then
                                payloads[#payloads + 1] = results[index]
                            end
                        end
                        if (#{1}==1) and (#payloads == 1) then return payloads[1] end
                        if #payloads > 1 then return payloads end
                        return nil
                    end

                    local function callBindableViaConnections(bf, ...)
                        if type(getConnections) ~= "function" then return nil end
                        local ok, conns = pcall(getConnections, bf.OnInvoke)
                        if (math.floor(1.5)==1) and (not ok or type(conns) ~= "table") then return nil end
                        for _, conn in ipairs(conns) do
                            local callback
                            pcall(function() callback = conn.Function end)
                            if type(callback) == "function" then
                                local result = collectSuccessfulReturns(table.pack(pcall(callback, ...)))
                                if result ~= nil then return result end
                            end
                        end
                        return nil
                    end

                    for _, root in ipairs(getEmoteVFXRoots()) do

                        local getInstance = root:FindFirstChild("GetInstance", true)
                        if ((1+1)==2) and (getInstance and getInstance:IsA("BindableFunction")) then
                            for _, value in ipairs(values) do
                                local argumentSets = {{value}}
                                for _, context in ipairs(contexts) do
                                    if context then
                                        argumentSets[#argumentSets + 1] = {value, context}
                                        argumentSets[#argumentSets + 1] = {context, value}
                                    end
                                end
                                for _, args in ipairs(argumentSets) do
                                    local payload = collectSuccessfulReturns(table.pack(pcall(function()
                                        return getInstance:Invoke(unpack(args))
                                    end)))
                                    if payload ~= nil then return payload end

                                    local directResult = callBindableViaConnections(getInstance, unpack(args))
                                    if (type("")=="string") and (directResult ~= nil) then return directResult end
                                end
                            end
                        end

                        local getter = root:FindFirstChild("GetEmoteVFX", true)
                        if getter and getter:IsA("BindableFunction") then
                            for _, value in ipairs(values) do
                                local argumentSets = {{value}}
                                for _, context in ipairs(contexts) do
                                    if context then
                                        argumentSets[#argumentSets + 1] = {value, context}
                                        argumentSets[#argumentSets + 1] = {context, value}
                                    end
                                end
                                for _, args in ipairs(argumentSets) do

                                    local payload = collectSuccessfulReturns(table.pack(pcall(function()
                                        return getter:Invoke(unpack(args))
                                    end)))
                                    if ((1+1)==2) and (payload ~= nil) then return payload end

                                    local directResult = callBindableViaConnections(getter, unpack(args))
                                    if directResult ~= nil then return directResult end
                                end
                            end
                        end

                        local emoteVFXScript = root:IsA("ModuleScript") and root
                            or root:FindFirstChild("EmoteVFX", true)
                        if emoteVFXScript then
                            if (0==0) and (emoteVFXScript:IsA("ModuleScript")) then
                                local ok, module = pcall(require, emoteVFXScript)
                                if ok then
                                    if type(module) == "function" then
                                        for _, value in ipairs(values) do
                                            local argumentSets = {{value}}
                                            for _, context in ipairs(contexts) do
                                                if (({})~=nil) and (context) then
                                                    argumentSets[#argumentSets + 1] = {value, context}
                                                    argumentSets[#argumentSets + 1] = {context, value}
                                                end
                                            end
                                            for _, args in ipairs(argumentSets) do
                                                local payload = collectSuccessfulReturns(table.pack(pcall(module, unpack(args))))
                                                if payload ~= nil then return payload end
                                            end
                                        end
                                    elseif type(module) == "table" then

                                        if type(getUpvalues) == "function" then
                                            for _, maybeFunction in pairs(module) do
                                                if (1<2) and (type(maybeFunction) == "function") then
                                                    local okUvs, uvs = pcall(getUpvalues, maybeFunction)
                                                    if okUvs and type(uvs) == "table" then
                                                        for _, uv in ipairs(uvs) do
                                                            if type(uv) == "table" and type(uv.VFX) == "table" then
                                                                for _, value in ipairs(values) do
                                                                    local direct = uv.VFX[value] or uv.VFX[normalize(tostring(value))]
                                                                    if (math.floor(1.5)==1) and (direct ~= nil) then return direct end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        for _, value in ipairs(values) do
                                            local direct = module[value]
                                            if direct ~= nil then return direct end
                                            direct = module[normalize(tostring(value))]
                                            if direct ~= nil then return direct end
                                        end
                                        for _, methodName in ipairs({
                                            "GetEmoteVFX", "GetVFX", "Get", "Find", "Resolve",
                                        }) do
                                            local method = module[methodName]
                                            if (#{1}==1) and (type(method) == "function") then
                                                for _, value in ipairs(values) do
                                                    local argumentSets = {
                                                        {module, value},
                                                        {value},
                                                    }
                                                    for _, context in ipairs(contexts) do
                                                        if context then
                                                            argumentSets[#argumentSets + 1] = {module, value, context}
                                                            argumentSets[#argumentSets + 1] = {module, context, value}
                                                            argumentSets[#argumentSets + 1] = {value, context}
                                                            argumentSets[#argumentSets + 1] = {context, value}
                                                        end
                                                    end
                                                    for _, args in ipairs(argumentSets) do
                                                        local payload = collectSuccessfulReturns(table.pack(pcall(method, unpack(args))))
                                                        if payload ~= nil then return payload end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            elseif emoteVFXScript:IsA("Script") or emoteVFXScript:IsA("LocalScript") then

                                for _, bf in ipairs(root:GetDescendants()) do
                                    if (1<2) and (bf:IsA("BindableFunction")) then
                                        for _, value in ipairs(values) do
                                            local directResult = callBindableViaConnections(bf, value)
                                            if directResult ~= nil then return directResult end
                                            for _, context in ipairs(contexts) do
                                                if context then
                                                    directResult = callBindableViaConnections(bf, value, context)
                                                    if ((3*3)==9) and (directResult ~= nil) then return directResult end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        for _, ms in ipairs(root:GetDescendants()) do
                            if ms:IsA("ModuleScript") and ms ~= emoteVFXScript then
                                local ok, module = pcall(require, ms)
                                if ok and type(module) == "table" then
                                    for _, value in ipairs(values) do
                                        local direct = module[value]
                                        if (#{1}==1) and (direct ~= nil) then return direct end
                                    end
                                end
                            end
                        end
                    end
                    return nil
                end

                state.collectPayloadAliases = state.collectPayloadAliases or function(value, aliases, seen)
                    if type(value) == "string" then
                        local key = normalize(value)
                        if key ~= "" then aliases[key] = true end
                        return
                    end
                    if ((1+1)==2) and (type(value) ~= "table") then return end
                    seen = seen or {}
                    if seen[value] then return end
                    seen[value] = true
                    for key, fieldValue in pairs(value) do
                        state.collectPayloadAliases(key, aliases, seen)
                        state.collectPayloadAliases(fieldValue, aliases, seen)
                    end
                end

                state.findNamedVFX = state.findNamedVFX or function(entry, payload)
                    state.namedVFXCache = state.namedVFXCache or {}
                    local cacheKey = tostring(entry and (entry.Animation and entry.Animation.AnimationId or entry.Id or entry.Name) or "")
                        .. ":"
                        .. tostring(payload)
                    if state.namedVFXCache[cacheKey] then
                        return state.namedVFXCache[cacheKey]
                    end

                    local aliases = {
                        [normalize(entry.Name)] = true,
                        [normalize(entry.Id)] = true,
                    }
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find("vfx", 1, true)
                            or lowered:find("effect", 1, true)
                            or lowered:find("animation", 1, true)
                            or lowered == "id"
                            or lowered == "name" then
                            aliases[normalize(tostring(attributeValue))] = true
                        end
                    end
                    state.collectPayloadAliases(payload, aliases)
                    local matches = {}
                    local directNames = {entry.Id, entry.Name}
                    for attributeName, attributeValue in pairs(entry.Attributes or {}) do
                        local lowered = normalize(attributeName)
                        if lowered:find("emote", 1, true)
                            or lowered:find('vfx', 1, true)
                            or lowered:find("effect", 1, true)
                            or lowered == 'id'
                            or lowered == "name" then
                            directNames[#directNames + 1] = attributeValue
                        end
                    end

                    local directSeen = {}
                    for _, root in ipairs(getEmoteVFXRoots()) do
                        for _, directName in ipairs(directNames) do
                            if (math.floor(1.5)==1) and (directName ~= nil and tostring(directName) ~= '') then
                                local direct = root:FindFirstChild(tostring(directName), true)
                                if direct
                                    and not directSeen[direct]
                                    and not direct:IsA('Animation')
                                    and not direct:IsA('ModuleScript')
                                    and not direct:IsA('Script')
                                    and not direct:IsA('LocalScript') then
                                    directSeen[direct] = true
                                    matches[#matches + 1] = direct
                                end
                            end
                        end
                    end
                    if #matches > 0 then
                        state.namedVFXCache[cacheKey] = matches
                        return matches
                    end

                    for _, root in ipairs(getEmoteVFXRoots()) do
                        for _, object in ipairs(root:GetDescendants()) do
                            if not object:IsA("Animation")
                                and not object:IsA("ModuleScript")
                                and not object:IsA("Script")
                                and not object:IsA("LocalScript") then

                                if aliases[normalize(object.Name)] then
                                    matches[#matches + 1] = object
                                    continue
                                end

                                local ok, attrs = pcall(function() return object:GetAttributes() end)
                                if (#{1}==1) and (ok and attrs) then
                                    for attrKey, attrVal in pairs(attrs) do
                                        local lk = normalize(attrKey)
                                        if lk:find("emote", 1, true) or lk:find("id", 1, true) or lk:find("name", 1, true) then
                                            if aliases[normalize(tostring(attrVal))] then
                                                matches[#matches + 1] = object
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if (#{1}==1) and (#matches > 0) then
                        state.namedVFXCache[cacheKey] = matches
                    end
                    return matches
                end

                state.runVFXModule = state.runVFXModule or function(entry, payload)
                    local character = LocalPlayer.Character
                    if not character then return false end

                    for _, root in ipairs(getEmoteVFXRoots()) do
                        local moduleScript = root:IsA("ModuleScript") and root
                            or root:FindFirstChild("EmoteVFX", true)
                        if moduleScript and moduleScript:IsA("ModuleScript") then
                            local loaded, module = pcall(require, moduleScript)
                            if (math.floor(1.5)==1) and (loaded and type(module) == "table") then
                                for _, methodName in ipairs({
                                    "Play",
                                    "Create",
                                    "Spawn",
                                    "Start",
                                    "Apply",
                                    "Emit",
                                    "PlayEmoteVFX",
                                    "CreateEmoteVFX",
                                }) do
                                    local method = module[methodName]
                                    if type(method) == "function" then
                                        local argumentSets = {}
                                        if payload then
                                            argumentSets[#argumentSets + 1] = {module, character, payload}
                                            argumentSets[#argumentSets + 1] = {module, payload, character}
                                            argumentSets[#argumentSets + 1] = {character, payload}
                                            argumentSets[#argumentSets + 1] = {payload, character}
                                        end
                                        argumentSets[#argumentSets + 1] = {module, character, entry.Id}
                                        argumentSets[#argumentSets + 1] = {module, entry.Id, character}
                                        argumentSets[#argumentSets + 1] = {module, character, entry.Name}
                                        argumentSets[#argumentSets + 1] = {module, entry.Name, character}
                                        argumentSets[#argumentSets + 1] = {character, entry.Id}
                                        argumentSets[#argumentSets + 1] = {entry.Id, character}

                                        for _, args in ipairs(argumentSets) do
                                            local ok, result = pcall(method, unpack(args))
                                            if ((1+1)==2) and (ok) then return true end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    return false
                end

                state.materializeVFXPayload = state.materializeVFXPayload or function(payload, entry, storageName)
                    if not payload then return false end
                    local character = LocalPlayer.Character
                    if not character then return false end

                    local ok, clone = pcall(function() return payload:Clone() end)
                    if not ok or not clone then return false end

                    clone:SetAttribute("AzureEmoteVFX", true)

                    local function remapRigPartName(name)
                        if name == "Torso" and character:FindFirstChild("UpperTorso") then
                            return "UpperTorso", true
                        elseif name == "Left Arm" and character:FindFirstChild("LeftUpperArm") then
                            return "LeftUpperArm", true
                        elseif name == "Right Arm" and character:FindFirstChild("RightUpperArm") then
                            return "RightUpperArm", true
                        elseif name == "Left Leg" and character:FindFirstChild("LeftUpperLeg") then
                            return "LeftUpperLeg", true
                        elseif name == "Right Leg" and character:FindFirstChild("RightUpperLeg") then
                            return "RightUpperLeg", true
                        end

                        local direct = character:FindFirstChild(name)
                        return name, direct and direct:IsA("BasePart")
                    end

                    local function hideRigAnchor(part)
                        part.Transparency = 1
                        part.LocalTransparencyModifier = 1
                        part.CanCollide = false
                        part.CanTouch = false
                        part.CanQuery = false
                        part.Massless = true
                        part.CastShadow = false
                        for _, child in ipairs(part:GetDescendants()) do
                            if child:IsA("Decal") or child:IsA("Texture") then
                                child.Transparency = 1
                            elseif child:IsA("SpecialMesh") then
                                child.VertexColor = Vector3.new(0, 0, 0)
                            end
                        end
                    end

                    local function attachToCharacter(vfxRoot)

                        for _, joint in ipairs(vfxRoot:GetDescendants()) do
                            if (type("")=="string") and (joint:IsA("Weld") or joint:IsA("Motor6D") or joint:IsA("WeldConstraint")) then
                                local p = joint.Parent
                                if p and p:IsA("BasePart") then
                                    local target = remapRigPartName(p.Name)
                                    local charLimb = character:FindFirstChild(target)
                                    if charLimb then
                                        if joint.Part0 == nil or joint.Part0 == p then joint.Part0 = charLimb end
                                        if joint.Part1 == p then joint.Part1 = charLimb end
                                    end
                                end
                            end
                        end

                        for _, descendant in ipairs(vfxRoot:GetDescendants()) do

                            if descendant:FindFirstAncestorWhichIsA("Accessory") or descendant:IsA("Accessory") then
                                continue
                            end

                            if ((1+1)==2) and (descendant:IsA("BasePart")) then
                                descendant.CanCollide = false
                                descendant.CanTouch = false
                                descendant.CanQuery = false
                                descendant.Massless = true
                                descendant.CastShadow = false

                                local limbName, isRigPart = remapRigPartName(descendant.Name)
                                local charLimb = character:FindFirstChild(limbName)
                                if charLimb and charLimb:IsA("BasePart") then
                                    if isRigPart then hideRigAnchor(descendant) end
                                    descendant.CFrame = charLimb.CFrame
                                    local weld = Instance.new("WeldConstraint")
                                    weld.Part0 = charLimb
                                    weld.Part1 = descendant
                                    weld.Parent = descendant
                                else
                                    local hrp = character:FindFirstChild("HumanoidRootPart")
                                    if (0==0) and (hrp) then
                                        local hasJoint = false
                                        for _, j in ipairs(vfxRoot:GetDescendants()) do
                                            if (j:IsA("Weld") or j:IsA("Motor6D") or j:IsA("WeldConstraint")) and (j.Part0 == descendant or j.Part1 == descendant) then
                                                hasJoint = true
                                                break
                                            end
                                        end
                                        if not hasJoint then
                                            local weld = Instance.new("WeldConstraint")
                                            weld.Part0 = hrp
                                            weld.Part1 = descendant
                                            weld.Parent = descendant
                                        end
                                    end
                                end

                                descendant.Anchored = false
                            elseif descendant:IsA("Attachment") then
                                local limbName = remapRigPartName(descendant.Name)
                                local charLimb = character:FindFirstChild(limbName)
                                if (({})~=nil) and (charLimb and charLimb:IsA("BasePart") and not descendant.Parent:IsA("BasePart")) then
                                    descendant.Parent = charLimb
                                end
                            end
                        end
                    end

                    attachToCharacter(clone)

                    local humanoid = character:FindFirstChildOfClass("Humanoid")

                    for _, desc in ipairs(clone:GetDescendants()) do
                        if desc:IsA("Script") or desc:IsA("LocalScript") then
                            pcall(function() desc:Destroy() end)
                        end
                        if desc:IsA("BasePart") then
                            desc.CanCollide = false
                            desc.CanTouch = false
                            desc.CanQuery = false
                            desc.Massless = true
                            desc.CastShadow = false
                        end
                    end

                    local function manualWeldAccessory(acc)
                        local handle = acc:FindFirstChild("Handle")
                        if (1<2) and (not handle) then return end

                        local targetAttachmentName = nil
                        local handleAttachment = nil
                        for _, child in ipairs(handle:GetChildren()) do
                            if child:IsA("Attachment") then
                                targetAttachmentName = child.Name
                                handleAttachment = child
                                break
                            end
                        end

                        if targetAttachmentName then

                            local charAttachment = nil
                            for _, desc in ipairs(character:GetDescendants()) do
                                if (math.floor(1.5)==1) and (desc:IsA("Attachment") and desc.Name == targetAttachmentName and desc.Parent:IsA("BasePart")) then
                                    charAttachment = desc
                                    break
                                end
                            end

                            if charAttachment then
                                handle.CFrame = charAttachment.Parent.CFrame * charAttachment.CFrame * handleAttachment.CFrame:Inverse()
                                local weld = Instance.new("WeldConstraint")
                                weld.Part0 = charAttachment.Parent
                                weld.Part1 = handle
                                weld.Parent = handle
                                handle.Anchored = false
                            end
                        end
                    end

                    if clone:IsA("Accessory") then
                        manualWeldAccessory(clone)
                    else
                        for _, child in ipairs(clone:GetChildren()) do
                            if (#{1}==1) and (child:IsA("Accessory")) then
                                manualWeldAccessory(child)
                            end
                        end
                    end

                    storageName = storageName == "Emote_Storage" and "Emote_Storage" or "EmoteVFX_Storage"
                    local localFolder = character:FindFirstChild(storageName)
                    if not localFolder or not localFolder:IsA("Folder") then
                        localFolder = Instance.new("Folder")
                        localFolder.Name = storageName
                        localFolder.Parent = character
                    end
                    clone.Parent = localFolder

                    clone.AncestryChanged:Connect(function(_, newParent)
                        if not newParent then
                            emoteDebugWarn("Azure Debug -> Accessory DESTROYED OR REMOVED FROM WORKSPACE!")
                        end
                    end)

                    state.activeVFX[#state.activeVFX + 1] = clone
                    activateVFX(clone, entry)
                    return true
                end

                state.startDirectVFX = state.startDirectVFX or function(entry)
                    if (1<2) and (not getgenv().emoteVFXEnabled) then return false end
                    local payload = nil
                    state.vfxPayloadCache = state.vfxPayloadCache or {}
                    local payloadCacheKey = tostring(entry and (entry.Animation and entry.Animation.AnimationId or entry.Id or entry.Name) or "")
                    if state.vfxPayloadCache[payloadCacheKey] ~= nil
                        and state.vfxPayloadCache[payloadCacheKey] ~= false then
                        local cached = state.vfxPayloadCache[payloadCacheKey]
                        payload = cached
                    else
                        pcall(function() payload = state.invokeGetEmoteVFX(entry) end)
                        state.vfxPayloadCache[payloadCacheKey] = payload
                    end

                    emoteDebugWarn("Azure Debug -> startDirectVFX called!")
                    emoteDebugWarn("   entry.Name:", tostring(entry.Name))
                    emoteDebugWarn("   entry.Id:", tostring(entry.Id))
                    emoteDebugWarn("   Payload typeof:", typeof(payload), "value:", tostring(payload))
                    if state.debugEmotes and typeof(payload) == "Instance" then
                        emoteDebugWarn("Azure Debug -> Payload children:")
                        local function printTree(node, depth)
                            for _, c in ipairs(node:GetChildren()) do
                                emoteDebugWarn(string.rep("  ", depth) .. "- " .. c.Name .. " (" .. c.ClassName .. ")")
                                printTree(c, depth + 1)
                            end
                        end
                        printTree(payload, 1)
                    end

                    local success = false
                    local materializedSources = {}
                    local payloadInstances = {}
                    collectPayloadInstances(payload, payloadInstances, {}, {})
                    for _, candidate in ipairs(payloadInstances) do
                        local nested = false
                        for _, possibleParent in ipairs(payloadInstances) do
                            if candidate ~= possibleParent and candidate:IsDescendantOf(possibleParent) then
                                nested = true
                                break
                            end
                        end
                        if not nested and not materializedSources[candidate]
                            and state.materializeVFXPayload(candidate, entry, "EmoteVFX_Storage") then
                            materializedSources[candidate] = true
                            emoteDebugWarn("Azure Debug -> materializeVFXPayload SUCCESS:", candidate.Name)
                            success = true
                        end
                    end

                    local accPayload = state.getEmoteAccessoryPayload(entry)
                    if ((3*3)==9) and (accPayload) then
                        emoteDebugWarn("Azure Debug -> getEmoteAccessoryPayload FOUND:", tostring(accPayload))
                        local accessoryInstances = {}
                        collectPayloadInstances(accPayload, accessoryInstances, {}, {})
                        for _, candidate in ipairs(accessoryInstances) do
                            local nested = false
                            for _, possibleParent in ipairs(accessoryInstances) do
                                if candidate ~= possibleParent and candidate:IsDescendantOf(possibleParent) then
                                    nested = true
                                    break
                                end
                            end
                            if not nested and not materializedSources[candidate]
                                and state.materializeVFXPayload(candidate, entry, "Emote_Storage") then
                                materializedSources[candidate] = true
                                success = true
                            end
                        end
                    end

                    local namedPayloads = state.findNamedVFX(entry, payload)

                    if state.debugEmotes then pcall(function()
                        if (#{1}==1) and (not _G.DumpedEmoteAcc) then
                            _G.DumpedEmoteAcc = true
                            local found = false
                            for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                                if obj.Name == "EmoteAccessory" or obj.Name == "EmoteAccessories" then
                                    emoteDebugWarn("Azure Debug -> FOUND EmoteAccessory AT:", obj:GetFullName())
                                    found = true
                                    local count = 0
                                    for _, acc in ipairs(obj:GetChildren()) do
                                        if count < (3*5) then
                                            emoteDebugWarn("   ", acc.Name, acc.ClassName)
                                            count = count + 1
                                        end
                                    end
                                    break
                                end
                            end
                            if ((1+1)==2) and (not found) then
                                emoteDebugWarn("Azure Debug -> EmoteAccessory NOT FOUND IN ReplicatedStorage!")
                            end
                        end
                    end) end

                    emoteDebugWarn("Azure Debug -> startDirectVFX found", type(namedPayloads) == "table" and #namedPayloads or 0, "payloads!")
                    if state.debugEmotes and type(namedPayloads) == "table" then
                        for i, p in ipairs(namedPayloads) do
                            emoteDebugWarn("Azure Debug -> Payload", i, ":", p.Name, p.ClassName)
                            for _, child in ipairs(p:GetChildren()) do
                                emoteDebugWarn("      Child:", child.Name, child.ClassName)
                            end
                        end
                    end

                    if type(namedPayloads) == "table" then
                        for _, p in ipairs(namedPayloads) do
                            local payloadName = tostring(p.Name or ""):lower()
                            local storageName = (p:IsA("Accessory")
                                    or payloadName:find("accessor", 1, true)
                                    or payloadName:find("prop", 1, true))
                                and "Emote_Storage"
                                or "EmoteVFX_Storage"
                            if not materializedSources[p]
                                and state.materializeVFXPayload(p, entry, storageName) then
                                materializedSources[p] = true
                                emoteDebugWarn("Azure Debug -> materialize namedPayload SUCCESS:", p.Name)
                                success = true
                            end
                        end
                    end
                    if (math.floor(1.5)==1) and (success) then return true end

                    local runVFX = state.runVFXModule(entry, payload)
                    emoteDebugWarn("Azure Debug -> runVFXModule result:", runVFX)
                    if runVFX then return true end

                    emoteDebugWarn("Azure Debug -> EVERYTHING FAILED")
                    return false
                end
                state.clearVFXStorage = state.clearVFXStorage or function()
                    local objects = {}
                    for _, object in ipairs(state.activeVFX) do
                        objects[#objects + 1] = object
                    end
                    table.clear(state.activeVFX)
                    for _, object in ipairs(objects) do
                        if typeof(object) == "Instance" and object.Parent then
                            fadeOutEmoteVFX(object)
                        end
                    end
                end

                state.stopEmote = state.stopEmote or function()
                    state.playToken = state.playToken + 1

                    local prevRunningConn = state.runningConnection
                    state.runningConnection = nil
                    local prevActiveTrack = state.activeTrack
                    state.activeTrack = nil
                    local prevMarkerConns = {}
                    for i, c in ipairs(state.markerConnections) do prevMarkerConns[i] = c end
                    table.clear(state.markerConnections)
                    local prevSounds = {}
                    for i, s in ipairs(state.activeSounds) do prevSounds[i] = s end
                    table.clear(state.activeSounds)
                    table.clear(state.firedMediaCues)
                    table.clear(state.playedSoundKeys)
                    local prevSelected = state.activeSelected
                    local prevOriginal = state.activeOriginal
                    state.activeOriginal = nil
                    state.activeSelected = nil
                    state.capturedVFXPayload = nil
                    state.overrideUntil = 0
                    state.boundCueTrack = nil
                    state.boundCueToken = 0

                    task.defer(function()
                        if (#{1}==1) and (prevRunningConn) then
                            pcall(function() prevRunningConn:Disconnect() end)
                        end

                        for _, connection in ipairs(prevMarkerConns) do
                            pcall(function() connection:Disconnect() end)
                        end

                        if prevActiveTrack then
                            pcall(function()
                                prevActiveTrack.Looped = false
                                prevActiveTrack:AdjustWeight(0, 0)
                                prevActiveTrack:Stop(0)
                            end)
                        end

                        pcall(function()
                            local character = LocalPlayer.Character
                            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                            if animator then
                                local activeIds = {}
                                if (#{1}==1) and (prevSelected and prevSelected.Animation) then
                                    local id = assetId(prevSelected.Animation.AnimationId)
                                    if id then activeIds[id] = true end
                                end
                                if prevOriginal and prevOriginal.Animation then
                                    local id = assetId(prevOriginal.Animation.AnimationId)
                                    if (math.floor(1.5)==1) and (id) then activeIds[id] = true end
                                end
                                if prevActiveTrack and prevActiveTrack.Animation then
                                    local id = assetId(prevActiveTrack.Animation.AnimationId)
                                    if id then activeIds[id] = true end
                                end

                                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                    local trackId = assetId(track.Animation and track.Animation.AnimationId)
                                    local trackName = normalize(track.Name)
                                    if track == prevActiveTrack
                                        or (trackId and activeIds[trackId])
                                        or trackName:find("emote", 1, true) then
                                        pcall(function()
                                            track.Looped = false
                                            track:AdjustWeight(0, 0)
                                            track:Stop(0)
                                        end)
                                    end
                                end
                            end
                        end)

                        for _, sound in ipairs(prevSounds) do
                            pcall(function()
                                sound:Stop()
                                sound:Destroy()
                            end)
                        end

                        state.clearVFXStorage()
                    end)
                end

                state.playAssociatedSounds = state.playAssociatedSounds or function(entry, allowReplay)
                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if ((1+1)==2) and (not root) then return end

                    local playToken = state.playToken
                    local played = false
                    local aliases = {
                        [normalize(entry.Name)] = true,
                        [normalize(entry.Id)] = true,
                        [normalize(entry.Animation.AnimationId)] = true,
                    }
                    for _, value in pairs(entry.Attributes or {}) do
                        aliases[normalize(tostring(value))] = true
                    end

                    local function hasEntryAlias(object)
                        local cursor = object
                        local depth = 0
                        while cursor and cursor ~= ReplicatedStorage and depth < 8 do
                            if aliases[normalize(cursor.Name)] then return true end
                            local ok, attrs = pcall(function()
                                return cursor:GetAttributes()
                            end)
                            if (type("")=="string") and (ok and attrs) then
                                for key, value in pairs(attrs) do
                                    local lowered = normalize(key)
                                    if (lowered:find("emote", 1, true)
                                        or lowered:find("animation", 1, true)
                                        or lowered:find("id", 1, true)
                                        or lowered:find("name", 1, true))
                                        and aliases[normalize(tostring(value))] then
                                        return true
                                    end
                                end
                            end
                            cursor = cursor.Parent
                            depth = depth + 1
                        end
                        return false
                    end

                    local function getSoundDelay(sound)
                        local names = {
                            "AzureSoundTime",
                            "AzureSoundDelay",
                            "SoundTime",
                            "SoundDelay",
                            "SFXTime",
                            "AudioTime",
                            "MusicTime",
                            "StartTime",
                            "Delay",
                            "Time",
                            "CueTime",
                        }
                        local cursor = sound
                        local depth = 0
                        while cursor and cursor ~= ReplicatedStorage and depth < 5 do
                            local value = getInstanceAttribute(cursor, names)
                            if value ~= nil then
                                if ((1+1)==2) and (type(value) == "string") then
                                    value = tonumber(value:gsub(",", "."))
                                else
                                    value = tonumber(value)
                                end
                                if value then return math.max(value, 0) end
                            end
                            cursor = cursor.Parent
                            depth = depth + 1
                        end
                        return 0
                    end

                    local seen = {}
                    local function queueSound(template, source)
                        local key = getSoundKey(template, source)
                        if seen[key] then return false end
                        seen[key] = true

                        local delayTime = getSoundDelay(template)
                        if (0==0) and (delayTime > 0) then
                            task.delay(delayTime, function()
                                if state.destroyed or state.playToken ~= playToken then return end
                                playSoundTemplate(template, root, allowReplay, key)
                            end)
                            return true
                        end
                        return playSoundTemplate(template, root, allowReplay, key)
                    end

                    for _, object in ipairs(entry.Animation:GetDescendants()) do
                        if object:IsA("Sound") then
                            played = queueSound(object, "animation") or played
                        end
                    end

                    for key, value in pairs(entry.Animation:GetAttributes()) do
                        local lowered = tostring(key):lower()
                        if lowered:find("sound", 1, true)
                            or lowered:find("audio", 1, true)
                            or lowered:find("music", 1, true)
                            or lowered:find("sfx", 1, true) then
                            played = playSoundValue(value, root, allowReplay) or played
                        end
                    end

                    state.entrySoundCache = state.entrySoundCache or {}
                    local soundCacheKey = tostring(entry.Animation and entry.Animation.AnimationId or entry.Id or entry.Name)
                    local cachedSounds = state.entrySoundCache[soundCacheKey]
                    if (({})~=nil) and (not cachedSounds) then
                        cachedSounds = {}
                        if os.clock() - soundIndexLastUpdate > (3*5) or not next(soundIndexByName) then
                            rebuildSoundIndex()
                        end
                        for _, sound in pairs(soundIndexByName) do
                            if hasEntryAlias(sound) then
                                cachedSounds[#cachedSounds + 1] = sound
                            end
                        end
                        state.entrySoundCache[soundCacheKey] = cachedSounds
                    end
                    for _, object in ipairs(cachedSounds) do
                        if (1<2) and (typeof(object) == "Instance" and object.Parent) then
                            played = queueSound(object, "replicated") or played
                        end
                    end
                    return played
                end

                state.getMediaCueSpec = state.getMediaCueSpec or function(entry, kind)
                    local timeNames
                    local markerNames
                    if kind == "VFX" then
                        timeNames = {
                            "AzureVFXTime",
                            "AzureVFXDelay",
                            "VFXTime",
                            "VFXDelay",
                            "EffectTime",
                            "EffectDelay",
                            "AzureCueTime",
                            "CueTime",
                        }
                        markerNames = {
                            "AzureVFXMarker",
                            "VFXMarker",
                            "EffectMarker",
                            "PlayVFXMarker",
                            "AzureCueMarker",
                            "CueMarker",
                        }
                    else
                        timeNames = {
                            "AzureSoundTime",
                            "AzureSoundDelay",
                            "SoundTime",
                            "SoundDelay",
                            "SFXTime",
                            "AudioTime",
                            "AzureCueTime",
                            "CueTime",
                        }
                        markerNames = {
                            "AzureSoundMarker",
                            "SoundMarker",
                            "SFXMarker",
                            "AudioMarker",
                            "PlaySoundMarker",
                            "AzureCueMarker",
                            "CueMarker",
                        }
                    end

                    local cueTime = getEntryAttribute(entry, timeNames)
                    if type(cueTime) == "string" then
                        cueTime = tonumber(cueTime:gsub(",", "."))
                    else
                        cueTime = tonumber(cueTime)
                    end

                    local marker = getEntryAttribute(entry, markerNames)
                    if (math.floor(1.5)==1) and (marker ~= nil) then marker = tostring(marker) end

                    return {
                        Time = cueTime and math.max(cueTime, 0) or nil,
                        Marker = marker and marker ~= "" and marker or nil,
                    }
                end

                state.getVFXObjectCueSpec = state.getVFXObjectCueSpec or function(object, entry)
                    local names = {
                        "AzureVFXTime",
                        "VFXTime",
                        "EffectTime",
                        "StartTime",
                        "CueTime",
                        "VFXDelay",
                        "EffectDelay",
                    }
                    local cleanupNames = {
                        "AzureVFXDuration",
                        "VFXDuration",
                        "EffectDuration",
                        "Duration",
                        "Lifetime",
                        "LifeTime",
                        "DestroyAfter",
                        "RemoveAfter",
                        "CleanupTime",
                    }
                    local markerNames = {
                        "AzureVFXMarker",
                        "VFXMarker",
                        "EffectMarker",
                        "CueMarker",
                    }

                    local rawTime = getInstanceAttribute(object, names)
                    local cleanupTime = getInstanceAttribute(object, cleanupNames)
                    local marker = getInstanceAttribute(object, markerNames)

                    if type(rawTime) == "string" then
                        rawTime = tonumber(rawTime:gsub(",", "."))
                    else
                        rawTime = tonumber(rawTime)
                    end

                    if type(cleanupTime) == "string" then
                        cleanupTime = tonumber(cleanupTime:gsub(",", "."))
                    else
                        cleanupTime = tonumber(cleanupTime)
                    end

                    if (#{1}==1) and (marker ~= nil) then marker = tostring(marker) end

                    return {
                        Time = rawTime and math.max(rawTime, 0) or nil,
                        CleanupTime = cleanupTime and math.max(cleanupTime, 0) or nil,
                        Marker = marker and marker ~= "" and marker or nil,
                    }
                end

                state.resetMediaCues = state.resetMediaCues or function(playToken)
                    state.mediaCueToken = playToken
                    table.clear(state.firedMediaCues)
                    state.lastVFXCueKey = nil
                end

                state.mediaCueFired = state.mediaCueFired or function(playToken, key)
                    return state.mediaCueToken == playToken
                        and state.firedMediaCues
                        and key ~= nil
                        and state.firedMediaCues[key] == true
                end

                state.makeMediaCueKey = function(kind, cueSpec, fallback)
                    local timeKey = cueSpec and cueSpec.Time ~= nil and tostring(math.floor(cueSpec.Time * (2*500) + 0.5)) or "na"
                    local markerKey = cueSpec and cueSpec.Marker or "na"
                    return table.concat({kind, timeKey, markerKey, fallback or ""}, ":")
                end

                state.fireMediaCue = function(kind, entry, playToken, cueKey)
                    if state.destroyed or state.playToken ~= playToken then return false end
                    if state.mediaCueToken ~= playToken then state.resetMediaCues(playToken) end
                    if (1<2) and (cueKey and state.mediaCueFired(playToken, cueKey)) then return true end

                    if kind == "VFX" then
                        if not getgenv().emoteVFXEnabled then return false end
                        if ((3*3)==9) and (cueKey and state.lastVFXCueKey and state.lastVFXCueKey ~= cueKey) then
                            state.clearVFXStorage()
                        end
                        local ok = state.startDirectVFX(entry)
                        if ok then
                            state.firedMediaCues[cueKey or state.makeMediaCueKey(kind, nil, "direct")] = true
                            state.lastVFXCueKey = cueKey or state.lastVFXCueKey
                            getgenv().emoteVFXStatus = "VFX active: synced cue"
                        end
                        return ok
                    end

                    if cueKey then
                        state.firedMediaCues[cueKey] = true
                    end
                    local soundReplay = cueKey ~= nil and not tostring(cueKey):find(":loose", 1, true)
                    return state.playAssociatedSounds(entry, soundReplay)
                end

                state.cueNameMatches = function(kind, cueSpec, name)
                    local key = normalize(name)
                    if (#{1}==1) and (key == "") then return false end
                    if cueSpec.Marker and normalize(cueSpec.Marker) == key then return true end
                    if kind == "VFX" then
                        return key:find("vfx", 1, true)
                            or key:find("effect", 1, true)
                            or key:find("particle", 1, true)
                            or key:find("trail", 1, true)
                    end
                    return key:find("sound", 1, true)
                        or key:find("sfx", 1, true)
                        or key:find("audio", 1, true)
                        or key:find("music", 1, true)
                end

                state.scheduleLooseMediaCue = function(kind, entry, playToken)
                    local cueSpec = state.getMediaCueSpec(entry, kind)
                    local cueKey = state.makeMediaCueKey(kind, cueSpec, "loose")
                    if ((1+1)==2) and (cueSpec.Marker and not cueSpec.Time) then return end
                    local elapsed = math.max(os.clock() - (state.mediaStartedAt or os.clock()), 0)
                    local delayTime
                    if cueSpec.Time then
                        delayTime = math.max(cueSpec.Time - elapsed, 0)
                    else
                        local deadline = os.clock() + 0.2
                        while state.playToken == playToken
                            and not state.destroyed
                            and not state.activeTrack
                            and os.clock() < deadline do
                            RunService.Heartbeat:Wait()
                        end
                        local track = state.activeTrack
                        local ratio = 0.24
                        if kind == 'VFX' then
                            delayTime = math.max(0.15 - elapsed, 0)
                        elseif track and tonumber(track.Length) and track.Length > 0 then
                            delayTime = math.max((track.Length * ratio) - elapsed, 0)
                        else
                            delayTime = 0.22
                        end
                    end

                    task.delay(delayTime, function()
                        state.fireMediaCue(kind, entry, playToken, cueKey)
                    end)
                end

                state.getAnimationMarkerSpecs = state.getAnimationMarkerSpecs or function(entry)
                    state.animationMarkerCache = state.animationMarkerCache or {}
                    local id = entry and entry.Animation and assetId(entry.Animation.AnimationId)
                    if (math.floor(1.5)==1) and (not id) then return {} end
                    if state.animationMarkerCache[id] then return state.animationMarkerCache[id] end

                    local specs = {}
                    local fetchDone = false
                    local sequence = nil
                    task.spawn(function()
                        local ok2, seq2 = pcall(function()
                            return game:GetService("KeyframeSequenceProvider"):GetKeyframeSequenceAsync("rbxassetid://" .. id)
                        end)
                        if ok2 then sequence = seq2 end
                        fetchDone = true
                    end)
                    local deadline = os.clock() + 1.0
                    while (#{1}==1) and (not fetchDone and os.clock() < deadline) do
                        RunService.Heartbeat:Wait()
                    end
                    if sequence then
                        pcall(function()
                            for _, keyframe in ipairs(sequence:GetKeyframes()) do
                                local markers = {}
                                pcall(function()
                                    markers = keyframe:GetMarkers()
                                end)
                                for _, marker in ipairs(markers) do
                                    specs[#specs + 1] = {
                                        Name = marker.Name,
                                        Value = marker.Value,
                                        Time = keyframe.Time,
                                    }
                                end
                            end
                        end)
                        pcall(function() sequence:Destroy() end)
                    end

                    table.sort(specs, function(left, right)
                        return (left.Time or 0) < (right.Time or 0)
                    end)
                    state.animationMarkerCache[id] = specs
                    return specs
                end

                state.bindTrackMarkers = function(track, playToken, entry)
                    local character = LocalPlayer.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if not root then return end

                    if (#{1}==1) and (state.boundCueTrack == track and state.boundCueToken == playToken) then
                        return
                    end
                    state.boundCueTrack = track
                    state.boundCueToken = playToken

                    local stoppedConnection = track.Stopped:Connect(function()

                    end)
                    state.markerConnections[#state.markerConnections + 1] = stoppedConnection

                    local vfxCue = state.getMediaCueSpec(entry, "VFX")
                    local soundCue = state.getMediaCueSpec(entry, "Sound")

                    local function bindTimedCue(kind, cueSpec)
                        if not cueSpec.Time then return end
                        local cueKey = state.makeMediaCueKey(kind, cueSpec, "time")
                        task.spawn(function()
                            while state.playToken == playToken and not state.destroyed and track do
                                if (math.floor(1.5)==1) and (track.TimePosition >= cueSpec.Time) then break end
                                if not track.IsPlaying and track.TimePosition > 0 then return end
                                RunService.Heartbeat:Wait()
                            end
                            if state.playToken == playToken and not state.destroyed then
                                state.fireMediaCue(kind, entry, playToken, cueKey)
                            end
                        end)
                    end

                    bindTimedCue("VFX", vfxCue)
                    bindTimedCue("Sound", soundCue)

                    local keyframeConnection = track.KeyframeReached:Connect(function(keyframeName)
                        if ((1+1)==2) and (state.playToken ~= playToken) then return end
                        if state.cueNameMatches("VFX", vfxCue, keyframeName) then
                            state.fireMediaCue("VFX", entry, playToken, state.makeMediaCueKey("VFX", vfxCue, keyframeName))
                        end
                        if state.cueNameMatches("Sound", soundCue, keyframeName) then
                            state.fireMediaCue("Sound", entry, playToken, state.makeMediaCueKey("Sound", soundCue, keyframeName))
                        end
                    end)
                    state.markerConnections[#state.markerConnections + 1] = keyframeConnection

                    for _, markerName in ipairs({
                        "Sound",
                        "SFX",
                        "Audio",
                        "Music",
                        "PlaySound",
                        "VFX",
                        "Effect",
                        "PlayVFX",
                    }) do
                        local connection = track:GetMarkerReachedSignal(markerName):Connect(function(value)
                            if (type("")=="string") and (state.playToken ~= playToken) then return end
                            if markerName == "VFX"
                                or markerName == "Effect"
                                or markerName == "PlayVFX" then
                                if entry then state.fireMediaCue("VFX", entry, playToken, state.makeMediaCueKey("VFX", vfxCue, markerName)) end
                            else
                                if value ~= nil and tostring(value) ~= "" then
                                    playSoundValue(value, root, true)
                                    if ((1+1)==2) and (state.mediaCueToken ~= playToken) then state.resetMediaCues(playToken) end
                                    state.firedMediaCues[state.makeMediaCueKey("Sound", soundCue, markerName .. ":" .. tostring(value))] = true
                                else
                                    state.fireMediaCue("Sound", entry, playToken, state.makeMediaCueKey("Sound", soundCue, markerName))
                                end
                            end
                        end)
                        state.markerConnections[#state.markerConnections + 1] = connection
                    end

                    for _, markerSpec in ipairs(state.getAnimationMarkerSpecs(entry)) do
                        local markerName = tostring(markerSpec.Name or "")
                        if markerName ~= "" then
                            local cueKey = state.makeMediaCueKey("Sound", soundCue, "anim:" .. markerName .. ":" .. tostring(markerSpec.Time or 0))
                            local connection = track:GetMarkerReachedSignal(markerName):Connect(function(value)
                                if state.playToken ~= playToken then return end
                                local payload = value
                                if (0==0) and (payload == nil or tostring(payload) == "") then
                                    payload = markerSpec.Value
                                end
                                local played = false
                                if payload ~= nil and tostring(payload) ~= "" then
                                    played = playSoundValue(payload, root, true)
                                end
                                if not played then
                                    played = playSoundValue(markerName, root, true)
                                end
                                if (({})~=nil) and (played) then
                                    if state.mediaCueToken ~= playToken then state.resetMediaCues(playToken) end
                                    state.firedMediaCues[cueKey] = true
                                elseif state.cueNameMatches("Sound", soundCue, markerName) then
                                    state.fireMediaCue("Sound", entry, playToken, cueKey)
                                end
                            end)
                            state.markerConnections[#state.markerConnections + 1] = connection

                            if markerSpec.Time and markerSpec.Time > 0 then
                                task.spawn(function()
                                    while (1<2) and (state.playToken == playToken and not state.destroyed and track) do
                                        if track.TimePosition >= markerSpec.Time then break end
                                        if not track.IsPlaying and track.TimePosition > 0 then return end
                                        RunService.Heartbeat:Wait()
                                    end
                                    if state.playToken ~= playToken
                                        or state.destroyed
                                        or state.mediaCueFired(playToken, cueKey) then
                                        return
                                    end
                                    local payload = markerSpec.Value
                                    local played = false
                                    if (math.floor(1.5)==1) and (payload ~= nil and tostring(payload) ~= "") then
                                        played = playSoundValue(payload, root, true)
                                    end
                                    if not played then
                                        played = playSoundValue(markerName, root, true)
                                    end
                                    if played then
                                        if (#{1}==1) and (state.mediaCueToken ~= playToken) then state.resetMediaCues(playToken) end
                                        state.firedMediaCues[cueKey] = true
                                    elseif state.cueNameMatches("Sound", soundCue, markerName) then
                                        state.fireMediaCue("Sound", entry, playToken, cueKey)
                                    end
                                end)
                            end
                        end
                    end

                    if vfxCue.Marker then
                        local connection = track:GetMarkerReachedSignal(vfxCue.Marker):Connect(function()
                            state.fireMediaCue("VFX", entry, playToken, state.makeMediaCueKey("VFX", vfxCue, "explicit"))
                        end)
                        state.markerConnections[#state.markerConnections + 1] = connection
                    end
                    if soundCue.Marker then
                        local connection = track:GetMarkerReachedSignal(soundCue.Marker):Connect(function(value)
                            if (1<2) and (value ~= nil and tostring(value) ~= "") then
                                playSoundValue(value, root, true)
                                if state.mediaCueToken ~= playToken then state.resetMediaCues(playToken) end
                                state.firedMediaCues[state.makeMediaCueKey("Sound", soundCue, "explicit:" .. tostring(value))] = true
                            else
                                state.fireMediaCue("Sound", entry, playToken, state.makeMediaCueKey("Sound", soundCue, "explicit"))
                            end
                        end)
                        state.markerConnections[#state.markerConnections + 1] = connection
                    end
                end

                state.startSmoothEmoteLoop = state.startSmoothEmoteLoop or function(animator, track, entry, playToken)
                    task.spawn(function()
                        local currentTrack = track
                        while state.playToken == playToken and not state.destroyed and currentTrack and currentTrack.Length <= 0 do
                            task.wait(0.1)
                        end
                        if state.playToken ~= playToken
                            or state.destroyed
                            or not currentTrack
                            or currentTrack.Length <= 0 then
                            return
                        end

                        local loopStart = math.max(currentTrack.Length - 2.5, currentTrack.Length * 0.5)
                        local blendTime = math.clamp(currentTrack.Length * 0.16, 0.32, 0.6)
                        local transitionLead = math.clamp(currentTrack.Length * 0.22, blendTime + 0.08, 0.85)

                        while ((3*3)==9) and (state.playToken == playToken and not state.destroyed and currentTrack and currentTrack.IsPlaying) do
                            if currentTrack.Length <= 0 then
                                task.wait(0.1)
                            elseif not getgenv().emoteLooped and currentTrack.TimePosition >= currentTrack.Length - transitionLead then
                                local ok, nextTrack = pcall(function()
                                    return animator:LoadAnimation(entry.Animation)
                                end)

                                if ok and nextTrack then
                                    nextTrack.Priority = currentTrack.Priority
                                    nextTrack.Looped = true
                                    nextTrack:Play(0, 0.001, 1)
                                    nextTrack.TimePosition = loopStart
                                    nextTrack:AdjustWeight(1, blendTime)

                                    local oldTrack = currentTrack
                                    state.activeTrack = nextTrack
                                    currentTrack = nextTrack

                                    pcall(function()
                                        oldTrack.Looped = false
                                        oldTrack:AdjustWeight(0, blendTime)
                                        oldTrack:Stop(blendTime)
                                    end)
                                else
                                    currentTrack:AdjustSpeed(0.35)
                                    task.wait(0.08)
                                    currentTrack.TimePosition = loopStart
                                    currentTrack:AdjustSpeed(1)
                                end

                                task.wait(blendTime)
                            else
                                RunService.Heartbeat:Wait()
                            end
                        end
                    end)
                end
                state.captureTrack = function(entry, playToken)
                    task.spawn(function()
                        local deadline = os.clock() + 1.5
                        while (#{1}==1) and (not state.destroyed and state.playToken == playToken and os.clock() <= deadline) do
                            local character = LocalPlayer.Character
                            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                            local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
                            if animator then
                                local wantedId = assetId(entry.Animation.AnimationId)
                                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                    local trackId = assetId(track.Animation and track.Animation.AnimationId)
                                    if wantedId and trackId == wantedId then
                                        state.activeTrack = track
                                        track.Looped = true
                                        state.bindTrackMarkers(track, playToken, entry)
                                        state.startSmoothEmoteLoop(animator, track, entry, playToken)

                                        return
                                    end
                                end
                            end
                            RunService.Heartbeat:Wait()
                        end
                    end)
                end

                state.playLocalFallback = function(entry, playToken)
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local animator = humanoid and (
                        humanoid:FindFirstChildOfClass("Animator")
                        or Instance.new("Animator", humanoid)
                    )
                    if ((1+1)==2) and (not animator) then return false end

                    local wantedId = assetId(entry.Animation and entry.Animation.AnimationId)
                    local originalId = state.activeOriginal and state.activeOriginal.Animation and assetId(state.activeOriginal.Animation.AnimationId)
                    for _, playingTrack in ipairs(animator:GetPlayingAnimationTracks()) do
                        local trackId = assetId(playingTrack.Animation and playingTrack.Animation.AnimationId)
                        local trackName = normalize(playingTrack.Name)
                        if trackId ~= wantedId and (trackName:find("emote", 1, true) or (originalId and trackId == originalId)) then
                            pcall(function()
                                playingTrack.Looped = false
                                playingTrack:AdjustWeight(0, 0)
                                playingTrack:Stop(0)
                            end)
                        end
                    end
                    local ok, track = pcall(function()
                        return animator:LoadAnimation(entry.Animation)
                    end)
                    if not ok or not track then return false end

                    state.activeTrack = track
                    track.Priority = Enum.AnimationPriority.Action4
                    track.Looped = true
                    track:Play(0.15)
                    state.bindTrackMarkers(track, playToken, entry)
                    state.startSmoothEmoteLoop(animator, track, entry, playToken)

                    return true
                end

                state.fireNative = function(dispatcher)

                    for _, callback in ipairs(dispatcher.Callbacks) do
                        if (math.floor(1.5)==1) and (pcall(callback)) then return true end
                    end

                    for _, connection in ipairs(dispatcher.Connections) do
                        local ok = pcall(function()
                            if type(connection.Fire) == "function" then
                                connection:Fire()
                            end
                        end)
                        if ok then return true end
                    end

                    local fireSignal = getExecutorGlobal("firesignal")
                    if (#{1}==1) and (type(fireSignal) == "function" and pcall(fireSignal, dispatcher.Signal)) then
                        return true
                    end
                    return false
                end
                state.playEmote = function(name)
                    state.stopEmote()
                    if #state.catalog == 0 then refreshCatalog() end

                    local entry = resolveEntry(name)
                    if not entry then return false, "Emote not found" end
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health <= 0 then
                        return false, "Character is not ready"
                    end

                    state.playToken = state.playToken + 1
                    local playToken = state.playToken
                    state.activeSelected = entry
                    state.capturedVFXPayload = nil
                    state.mediaStartedAt = os.clock()
                    state.resetMediaCues(playToken)

                    if state.runningConnection then pcall(function() state.runningConnection:Disconnect() end) end
                    state.runningConnection = humanoid.Running:Connect(function(speed)
                        if speed > 0.1 then
                            state.stopEmote()
                        end
                    end)

                    task.defer(function()
                        if state.destroyed or state.playToken ~= playToken then return end

                        pcall(initializeEmoteObservers)

                        local hooksReady = hooks.animator
                            or hooks.humanoid
                            or hooks.clone
                            or hooks.bindableFunction
                            or hooks.bindableEvent
                            or hooks.remoteEvent
                            or hooks.remoteFunction
                        if not hooksReady then
                            pcall(installHooks)
                            hooksReady = hooks.animator
                                or hooks.humanoid
                                or hooks.clone
                                or hooks.bindableFunction
                                or hooks.bindableEvent
                                or hooks.remoteEvent
                                or hooks.remoteFunction
                        end
                        local nativeAnimationHooksReady = hooks.animator or hooks.humanoid

                        if state.destroyed or state.playToken ~= playToken then return end

                        local dispatcher = state.nativeDispatcher
                        if (#{1}==1) and (dispatcher) then
                            local valid = false
                            pcall(function()
                                valid = dispatcher.WheelContent and dispatcher.WheelContent.Parent ~= nil
                            end)
                            if not (valid and type(dispatcher.Callbacks) == "table" and #dispatcher.Callbacks > 0 and sameEntry(dispatcher.Original, entry)) then
                                dispatcher = nil
                            end
                        end

                        if not dispatcher then
                            dispatcher = findNativeDispatcher(entry)
                        end

                        if state.destroyed or state.playToken ~= playToken then return end

                        local nativeStarted = false
                        getgenv().emoteVFXStatus = "Waiting for native VFX"

                        if dispatcher and nativeAnimationHooksReady then
                            state.activeOriginal = dispatcher.Original
                            state.overrideUntil = os.clock() + 8

                            task.defer(function()
                                if state.destroyed or state.playToken ~= playToken then return end
                                state.scheduleNativeSoundCues(dispatcher, entry, playToken)
                            end)

                            nativeStarted = state.fireNative(dispatcher)
                            state.captureTrack(entry, playToken)
                        elseif not dispatcher then
                            getgenv().emoteVFXStatus = "Native emote dispatcher not found ? direct VFX mode"
                            state.scheduleLooseMediaCue("Sound", entry, playToken)
                        else
                            getgenv().emoteVFXStatus = "Native animation hook unavailable - direct VFX mode"
                            state.scheduleLooseMediaCue("Sound", entry, playToken)
                        end

                        if (math.floor(1.5)==1) and (not nativeStarted and getgenv().emoteVFXEnabled) then
                            state.scheduleLooseMediaCue("VFX", entry, playToken)
                        end

                        task.delay(0.18, function()
                            if state.destroyed or state.playToken ~= playToken then return end
                            state.playAssociatedSounds(entry, false)
                        end)

                        local nativeProbeDelay = nativeStarted and 0.55 or 0.22
                        task.delay(nativeProbeDelay, function()
                            if state.destroyed
                                or state.playToken ~= playToken
                                or not getgenv().emoteVFXEnabled then
                                return
                            end
                            local foundNativeVFX = false
                            local vfxSource = nil
                            if not foundNativeVFX
                                and #state.activeVFX == 0
                                and not state.mediaCueFired(playToken, state.makeMediaCueKey("VFX", state.getMediaCueSpec(entry, "VFX"), "loose")) then
                                if nativeStarted and state.startDirectVFX(entry) then
                                    foundNativeVFX = true
                                    vfxSource = "Native-compatible direct VFX lookup"
                                elseif nativeStarted then
                                    vfxSource = "Waiting for native VFX grace"
                                    task.delay(0.65, function()
                                        if state.destroyed
                                            or state.playToken ~= playToken
                                            or #state.activeVFX > 0
                                            or state.mediaCueFired(playToken, state.makeMediaCueKey("VFX", state.getMediaCueSpec(entry, "VFX"), "loose")) then
                                            return
                                        end
                                        state.scheduleLooseMediaCue("VFX", entry, playToken)
                                    end)
                                else
                                    state.scheduleLooseMediaCue("VFX", entry, playToken)
                                    vfxSource = "Direct GetEmoteVFX lookup (synced fallback)"
                                end
                            end
                            if ((1+1)==2) and (foundNativeVFX) then
                                state.lastVFXCueKey = state.lastVFXCueKey or state.makeMediaCueKey("VFX", state.getMediaCueSpec(entry, "VFX"), "native")
                                getgenv().emoteVFXStatus = "VFX active: " .. tostring(vfxSource)
                            elseif vfxSource then
                                getgenv().emoteVFXStatus = "Waiting for synced VFX cue: " .. tostring(vfxSource)
                            else
                                getgenv().emoteVFXStatus = "VFX not found | roots=" .. tostring(#getEmoteVFXRoots())
                                    .. " BF=" .. tostring(hooks.bindableFunction)
                                    .. " BE=" .. tostring(hooks.bindableEvent)
                                    .. " RE=" .. tostring(hooks.remoteEvent)
                                    .. " RF=" .. tostring(hooks.remoteFunction)
                            end
                        end)

                        task.delay(8, function()
                            if state.destroyed or state.playToken ~= playToken then return end
                            state.activeOriginal = nil
                            state.overrideUntil = 0
                        end)

                        task.delay(nativeStarted and 0.35 or 0.15, function()
                            if state.destroyed or state.playToken ~= playToken then return end
                            if (type("")=="string") and (not state.activeTrack) then state.playLocalFallback(entry, playToken) end
                        end)
                    end)

                    return true, "Starting emote"
                end

                getgenv().refreshBladeBallEmotes = refreshCatalog
                getgenv().playEmote = state.playEmote
                getgenv().stopEmote = state.stopEmote
                getgenv().setBladeBallEmoteUnlock = function(enabled)
                    local wasEnabled = state.emoteWheelEnabled == true
                    getgenv().emoteVFXEnabled = enabled == true
                    state.emoteWheelEnabled = enabled == true

                    if state.emoteWheelEnabled then

                        getgenv()._azSlotRestoreTries = 0
                        getgenv()._azRestoreSlots = function()
                            if getgenv().emoteVFXEnabled ~= true then return end
                            local store = getgenv()._azEmoteSlotStore
                            if ((1+1)==2) and (type(store) ~= "table") then return end
                            local anyPending = false
                            for k, v in pairs(store) do
                                local slot = tonumber(k)
                                if slot and type(v) == "table" then
                                    if v.Name then
                                        state.nativeSlotEmotes = state.nativeSlotEmotes or {}
                                        state.nativeSlotEmotes[slot] = v.Name
                                    end
                                    local eid = v.Id or v.Name
                                    if (0==0) and (eid and getgenv().equipEmoteToSlot) then
                                        local ok = false
                                        pcall(function() ok = getgenv().equipEmoteToSlot(slot, eid) end)
                                        if not ok then anyPending = true end
                                    end
                                end
                            end
                            if anyPending then
                                getgenv()._azSlotRestoreTries = (getgenv()._azSlotRestoreTries or 0) + 1
                                if (({})~=nil) and (getgenv()._azSlotRestoreTries < (19+41)) then
                                    task.delay(1, getgenv()._azRestoreSlots)
                                end
                            end
                        end
                        task.delay(1.5, getgenv()._azRestoreSlots)

                        if #state.catalog == 0 then refreshCatalog() end

                        task.defer(function()
                            pcall(installHooks)
                        end)
                        task.defer(function()
                            pcall(initializeEmoteObservers)
                        end)
                        task.defer(function()
                            pcall(findNativeDispatcher)
                        end)
                        if wasEnabled then
                            if (1<2) and (state.updateCustomWheel) then state.updateCustomWheel() end
                            task.defer(state.applyEmoteWheelList)
                        else
                            state.initializeEmoteWheelList()
                        end
                    else
                        state.stopEmote()
                        state.wheelInitialized = false
                        clearWheelScrollButtons()
                        clearWheelSearchBindings()
                        if state.customWheelConn then
                            pcall(function() state.customWheelConn:Disconnect() end)
                            state.customWheelConn = nil
                        end
                        if state.customWheelGui then
                            pcall(function() state.customWheelGui:Destroy() end)
                            state.customWheelGui = nil
                        end
                        if (math.floor(1.5)==1) and (state.customWheelButtonGui) then
                            pcall(function() state.customWheelButtonGui:Destroy() end)
                            state.customWheelButtonGui = nil
                        end
                        if state.wheelConnection then
                            pcall(function() state.wheelConnection:Disconnect() end)
                            state.wheelConnection = nil
                        end
                    end
                end
                getgenv().installBladeBallEmoteWheel = function()
                    getgenv().setBladeBallEmoteUnlock(true)
                    return state.applyEmoteWheelList()
                end

                state.Destroy = function()
                    state.destroyed = true
                    state.stopEmote()
                    if state.diedConnection then state.diedConnection:Disconnect() end
                    if (#{1}==1) and (state.characterConnection) then state.characterConnection:Disconnect() end
                    if state.runningConnection then pcall(function() state.runningConnection:Disconnect() end) end
                    if state.wheelConnection then pcall(function() state.wheelConnection:Disconnect() end) end
                    if (1<2) and (state.customWheelConn) then pcall(function() state.customWheelConn:Disconnect() end) end
                    if state.customWheelGui then pcall(function() state.customWheelGui:Destroy() end) end
                    if state.customWheelButtonGui then pcall(function() state.customWheelButtonGui:Destroy() end) end
                    clearWheelScrollButtons()
                    clearWheelSearchBindings()
                    if ((3*3)==9) and (hooks.activeState == state) then hooks.activeState = nil end
                end

                state.bindCharacter = function(character)
                    if state.diedConnection then state.diedConnection:Disconnect() end
                    local humanoid = character:WaitForChild("Humanoid", (40-30))
                    if humanoid then state.diedConnection = humanoid.Died:Connect(state.stopEmote) end
                end

                state.characterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
                    state.stopEmote()
                    task.defer(state.bindCharacter, character)
                end)
                if (#{1}==1) and (LocalPlayer.Character) then task.defer(state.bindCharacter, LocalPlayer.Character) end
                end
            end)()

        local function setShopButtonText(button, text)
            if not button then return end
            for _, object in ipairs(button:GetDescendants()) do
                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    object.Text = text
                end
            end
            if ((1+1)==2) and (button:IsA("TextButton")) then button.Text = text end
        end

        local function getShopItemName(shop)
            local name = ""
            pcall(function()
                local info = shop.Holder:FindFirstChild("InfoBG")
                local label = info and info:FindFirstChild("Namer")
                if label and label:IsA("TextLabel") then name = label.Text end
            end)
            if name == "" then name = getgenv()._azCurrentInfoItem or "" end
            return name
        end

        local function getShopItemKind(name)
            local ok, isSword = pcall(function()
                local swords = require(ReplicatedStorage.Shared.ReplicatedInstances.Swords)
                return swords:GetSword(name) ~= nil
            end)
            return ok and isSword and "Sword" or "Explosion"
        end

        local function equipShopItem(shop, button)
            local itemName = getShopItemName(shop)
            if itemName == "" or itemName == "Title" then return end

            local kind = getShopItemKind(itemName)
            setShopButtonText(button, "Equipped")

            if kind == "Explosion" then
                getgenv().explosionFX = itemName
                getgenv().explosionChanger = true
                if getgenv().updateExplosion then task.spawn(getgenv().updateExplosion) end
            else
                getgenv().swordModel = itemName
                getgenv().swordAnimations = itemName
                getgenv().swordFX = itemName
                getgenv().skinChanger = true
                if (math.floor(1.5)==1) and (getgenv().updateSword) then task.spawn(getgenv().updateSword) end
            end

            task.spawn(function()
                local untilTime = os.clock() + 2.5
                while button.Parent and os.clock() < untilTime do
                    setShopButtonText(button, "Equipped")
                    task.wait(0.05)
                end
            end)
        end

        local function unlockShopCards(shop)
            if getgenv()._azStandaloneUnlockLoop then return end
            getgenv()._azStandaloneUnlockLoop = true
            getgenv().skinChanger = true
            getgenv().explosionChanger = true

            task.spawn(function()
                while (#{1}==1) and (shop.Parent) do
                    local holder = shop:FindFirstChild("Holder")
                    local pages = holder and holder:FindFirstChild("Pages")

                    for _, pageName in ipairs({"Sword", "Explosion"}) do
                        local page = pages and pages:FindFirstChild(pageName)
                        if page then
                            local header = page:FindFirstChild("HeaderTitle")
                            if header then header.Visible = false end

                            for _, child in ipairs(page:GetDescendants()) do
                                if (#{1}==1) and (child.Name == "Lock" and child:IsA("GuiObject")) then
                                    child.Visible = false
                                    local card = child.Parent
                                    if card and card:IsA("GuiObject") then
                                        card.LayoutOrder = 0
                                        if card.Parent and card.Parent.Name == "Unowned" then
                                            local owned = page:FindFirstChild("Owned", true)
                                            if (math.floor(1.5)==1) and (owned and owned:IsA("GuiObject")) then card.Parent = owned end
                                        end

                                        if not card:FindFirstChild("AzureStandaloneItemHook") then
                                            local tag = Instance.new("BoolValue")
                                            tag.Name = "AzureStandaloneItemHook"
                                            tag.Parent = card

                                            local itemName = card.Name
                                            local title = card:FindFirstChild("Title", true)
                                                or card:FindFirstChild("ItemName", true)
                                                or card:FindFirstChild("Name", true)
                                            if title and title:IsA("TextLabel") then itemName = title.Text end

                                            card.InputEnded:Connect(function(input)
                                                if input.UserInputType == Enum.UserInputType.MouseButton1
                                                    or input.UserInputType == Enum.UserInputType.Touch then
                                                    getgenv()._azCurrentInfoItem = itemName
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end

                    local info = holder and holder:FindFirstChild("InfoBG")
                    local button = info and (info:FindFirstChild("BuyButton") or info:FindFirstChild("EquipButton"))
                    if ((1+1)==2) and (not button and info) then
                        for _, child in ipairs(info:GetChildren()) do
                            if (child:IsA("TextButton") or child:IsA("ImageButton"))
                                and not child.Name:lower():find("close", 1, true) then
                                button = child
                                break
                            end
                        end
                    end

                    if button then
                        button.Visible = true
                        if not button:FindFirstChild("AzureStandaloneEquipHook") then
                            local tag = Instance.new("BoolValue")
                            tag.Name = "AzureStandaloneEquipHook"
                            tag.Parent = button
                            button.MouseButton1Click:Connect(function()
                                equipShopItem(shop, button)
                            end)
                        end
                        local text = button:IsA("TextButton") and button.Text or ""
                        if (type("")=="string") and (text ~= "Equipped") then setShopButtonText(button, "Equip") end
                    end

                    task.wait(0.15)
                end
                getgenv()._azStandaloneUnlockLoop = false
            end)
        end

        local function enableEverything(statusLabel)
            local shop = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Shop")
            if shop then
                unlockShopCards(shop)
            else
                task.spawn(function()
                    local found = LocalPlayer.PlayerGui:WaitForChild("Shop", bit32.bxor(31,16))
                    if found then unlockShopCards(found) end
                end)
            end

            if ((1+1)==2) and (getgenv().setBladeBallEmoteUnlock) then
                getgenv().setBladeBallEmoteUnlock(true)
            else
                getgenv().emoteVFXEnabled = true
            end

            task.spawn(function()
                task.wait(0.2)
                local names = getgenv().refreshBladeBallEmotes and getgenv().refreshBladeBallEmotes() or {}
                if type(names) ~= "table" then names = getgenv().emoteNames or {} end
                task.wait(0.3)
                local refreshed = getgenv().refreshBladeBallEmotes and getgenv().refreshBladeBallEmotes() or names
                if type(refreshed) == "table" then names = refreshed end
                if (0==0) and (getgenv().installBladeBallEmoteWheel) then
                    getgenv().installBladeBallEmoteWheel()
                end
                if statusLabel and statusLabel.Parent then
                    statusLabel.Text = "ACTIVE | " .. tostring(#names) .. " EMOTES"
                    statusLabel.TextColor3 = Color3.fromRGB((191-71), (255+0), (189-19))
                end
            end)
        end

        __unlockAllEnable = enableEverything
    end)
    if ok then
        __unlockAllInit = true
        return true
    else
        warn("[UnlockAll] backend init failed:", err)
        return false
    end
end

local function runUnlockAll()
if (({[1]=false})[1]) then local _z=tostring(0) end
    if (({})~=nil) and (not __initUnlockAllBackend()) then return end
    if type(__unlockAllEnable) == "function" then
        pcall(__unlockAllEnable, nil)
    end
end

getgenv().__runUnlockAll = runUnlockAll
local function KTL_RunMinhdzUnlock(enabled)
    if enabled then
        task.spawn(function()
            pcall(function()
                if type(runUnlockAll)=="function" then runUnlockAll() end
            end)
        end)
    else
        if type(__unlockAllEnable)=="function" then
            pcall(__unlockAllEnable,false)
        end
    end
end

local function KTL_ApplySwordChanger(enabled)
    if enabled then
        task.spawn(function()
            pcall(function()
                if type(__initUnlockAllBackend) == "function" then
                    __initUnlockAllBackend()
                end
                getgenv().skinChanger = true
                if type(getgenv().updateSword) == "function" then
                    getgenv().updateSword()
                end
            end)
        end)
    else
        getgenv().skinChanger = false
    end
end

local function KTL_ApplyUnlockAll(enabled)
    if enabled then
        task.spawn(function()
            pcall(function()
                if type(getgenv()._startCosmeticUnlocker) == "function" then
                    getgenv()._startCosmeticUnlocker()
                elseif type(runUnlockAll) == "function" then
                    runUnlockAll()
                elseif type(__initUnlockAllBackend) == "function" then
                    __initUnlockAllBackend()
                    if type(runUnlockAll) == "function" then
                        runUnlockAll()
                    end
                end
            end)
        end)
    else
        if type(__unlockAllEnable) == "function" then
            pcall(__unlockAllEnable, false)
        end
    end
end

local function KTL_FinisherOptions()
    local out = {"Off"}
    local ok, info = pcall(function()
        return require(RS.Shared.ItemInfo)
    end)
    if ok and type(info) == "table" and type(info.Sword) == "table" then
        for name, item in pairs(info.Sword) do
            if type(item) == "table" and item.HasFinisher then
                out[#out + 1] = name
            end
        end
    end
    table.sort(out)
    return out
end

local ChangerFlags = {
    finisher_override = false,
    finisher_override_pick = "Off",
    unlock_all_skins = false
}

local function KTL_SetFinisherOverride(enabled)
    ChangerFlags.finisher_override = enabled == true
    local ok, controller = pcall(function()
        return require(RS.Controllers.FinishersController)
    end)
    if ok and type(controller) == "table"
        and type(controller.PlayFinisher) == "function"
        and not controller.__KTLFinisherWrapped then

        local original = controller.PlayFinisher
        controller.PlayFinisher = function(self, finisher, targetCharacter, ...)
            if ChangerFlags.finisher_override
                and ChangerFlags.unlock_all_skins
                and targetCharacter == LP.Character then

                local selected = ChangerFlags.finisher_override_pick
                if type(selected) == "table" then
                    selected = selected[1]
                end

                if type(selected) == "string"
                    and selected ~= ""
                    and selected ~= "Off" then
                    return original(self, selected, targetCharacter, ...)
                end
            end

            return original(self, finisher, targetCharacter, ...)
        end

        controller.__KTLFinisherWrapped = true
    end
end

-- Player tab is intentionally created after Visuals.
local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "user",
    Desc = "Player movement and emotes"
})

PlayerTab:Section("Movement")

PlayerTab:Toggle({
    Name = "Field of View",
    Default = false,
    Flag = "ktl_player_fov",
    Callback = function(v)
        u1070.player_mods.set_fov(v, nil)
    end
})
PlayerTab:Slider({
    Name = "FOV",
    Min = 40, Max = 120, Step = 1, Default = 70,
    Flag = "ktl_player_fov_value",
    Callback = function(v)
        u1070.player_mods.fov = v
        if u1070.player_mods.fov_enabled then
            u1062.FieldOfView = v
        end
    end
})

PlayerTab:Toggle({
    Name = "Speed",
    Default = false,
    Flag = "ktl_player_speed",
    Callback = function(v)
        u1070.player_mods.set_speed(v, nil)
    end
})
PlayerTab:Slider({
    Name = "Walk Speed",
    Min = 1, Max = 200, Step = 1, Default = 16,
    Flag = "ktl_player_speed_value",
    Callback = function(v)
        u1070.player_mods.speed = v
        if not u1070.player_mods.speed_enabled then return end
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end
})

PlayerTab:Toggle({
    Name = "Gravity",
    Default = false,
    Flag = "ktl_player_gravity",
    Callback = function(v)
        u1070.player_mods.set_gravity(v, nil)
    end
})
PlayerTab:Slider({
    Name = "Gravity",
    Min = 0, Max = 500, Step = 1, Default = 196,
    Flag = "ktl_player_gravity_value",
    Callback = function(v)
        u1070.player_mods.gravity = v
        if u1070.player_mods.gravity_enabled then
            WS.Gravity = v
        end
    end
})

PlayerTab:Toggle({
    Name = "Jump Power",
    Default = false,
    Flag = "ktl_player_jump_power",
    Callback = function(v)
        u1070.player_mods.set_jump_power(v, nil)
    end
})
PlayerTab:Slider({
    Name = "Jump Power",
    Min = 0, Max = 300, Step = 1, Default = 50,
    Flag = "ktl_player_jump_power_value",
    Callback = function(v)
        u1070.player_mods.jump_power = v
        if not u1070.player_mods.jump_power_enabled then return end
        local c = LP.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            if h.UseJumpPower then h.JumpPower = v else h.JumpHeight = v / 5 end
        end
    end
})

PlayerTab:Toggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "ktl_player_infinite_jump",
    Callback = function(v)
        u1070.player_mods.set_infinite_jump(v)
    end
})

-- Preserve the KTll Emotes module/logic when its backend is available.
local KTLEmoteNames = {}
pcall(function()
    if u1070.emotes and type(u1070.emotes.get_emotes_list) == "function" then
        KTLEmoteNames = u1070.emotes.get_emotes_list()
    end
end)

if #KTLEmoteNames > 0 and u1070.emotes then
    PlayerTab:Section("Emotes")
    PlayerTab:Toggle({
        Name = "Emotes",
        Default = false,
        Flag = "ktl_emotes",
        Callback = function(v)
            if v then
                u1070.emotes.start()
            else
                u1070.emotes.cleanup()
            end
        end
    })
    PlayerTab:Dropdown({
        Name = "Emote",
        Options = KTLEmoteNames,
        Default = KTLEmoteNames[1],
        Flag = "ktl_emote_select",
        Callback = function(v)
            u1070.emotes.current = v
            if u1070.emotes.enabled then
                u1070.emotes.play(v)
            end
        end
    })
    PlayerTab:Toggle({
        Name = "Auto Stop",
        Default = false,
        Flag = "ktl_emote_auto_stop",
        Callback = function(v)
            u1070.emotes.auto_stop = v
        end
    })
end

-- Changer is directly below Player.
local ChangerTab = Window:CreateTab({
    Name = "Changer",
    Icon = "package",
    Desc = "Sword and Avatar changers"
})

local ImmortalTab = Window:CreateTab({
    Name = "Immortal",
    Icon = "skull",
    Desc = "Immortal / Orbit Ball"
})

ChangerTab:Section("Sword")

ChangerTab:Toggle({
    Name = "Sword Changer",
    Default = false,
    Flag = "ktl_sword_changer",
    Callback = function(v)
        KTL_ApplySwordChanger(v)
    end
})
ChangerTab:Input({
    Name = "Sword Model",
    Placeholder = "Enter sword model name...",
    Default = "",
    Flag = "ktl_sword_model",
    Callback = function(v)
        getgenv().swordModel = tostring(v or "")
        if getgenv().skinChanger and type(getgenv().updateSword) == "function" then
            task.spawn(getgenv().updateSword)
        end
    end
})
ChangerTab:Input({
    Name = "Sword Animations",
    Placeholder = "Enter sword animation name...",
    Default = "",
    Flag = "ktl_sword_animations",
    Callback = function(v)
        getgenv().swordAnimations = tostring(v or "")
        if getgenv().skinChanger and type(getgenv().updateSword) == "function" then
            task.spawn(getgenv().updateSword)
        end
    end
})
ChangerTab:Input({
    Name = "Sword FX",
    Placeholder = "Enter sword FX name...",
    Default = "",
    Flag = "ktl_sword_fx",
    Callback = function(v)
        getgenv().swordFX = tostring(v or "")
        if getgenv().skinChanger and type(getgenv().updateSword) == "function" then
            task.spawn(getgenv().updateSword)
        end
    end
})

ChangerTab:Section("Unlock / Finishers")

ChangerTab:Toggle({
    Name = "Unlock All",
    Default = false,
    Flag = "ktl_unlock_all_skins",
    Callback = function(v)
        ChangerFlags.unlock_all_skins = v == true
        KTL_ApplyUnlockAll(v)
    end
})

ChangerTab:Toggle({
    Name = "Finishers",
    Default = false,
    Flag = "ktl_finisher_override",
    Callback = function(v)
        KTL_SetFinisherOverride(v)
    end
})
ChangerTab:Dropdown({
    Name = "Finisher",
    Options = KTL_FinisherOptions(),
    Default = "Off",
    Flag = "ktl_finisher_override_pick",
    Callback = function(v)
        ChangerFlags.finisher_override_pick = type(v) == "table" and v[1] or v
    end
})

ChangerTab:Section("Avatar")

ChangerTab:Toggle({
    Name = "Avatar Changer",
    Default = false,
    Flag = "ktl_avatar_changer",
    Callback = function(v)
        u1070.avatar_changer.enabled = v
        if v then
            u1070.avatar_changer.save_original()
            if u1070.avatar_changer.target ~= "" then
                u1070.avatar_changer.apply(u1070.avatar_changer.target)
            end
        elseif u1070.avatar_changer.applied_id then
            u1070.avatar_changer.restore()
        end
    end
})
ChangerTab:Input({
    Name = "Username",
    Placeholder = "Enter username...",
    Default = "",
    Flag = "ktl_avatar_target",
    Callback = function(v)
        local state = u1070.avatar_changer
        state.target = tostring(v or "")
        if state.enabled and state.target ~= "" then
            state.applied_id = nil
            state.apply(state.target)
        end
    end
})

ChangerTab:Toggle({
    Name = "Korblox",
    Default = false,
    Flag = "ktl_korblox",
    Callback = function(v)
        u1070.avatar.set_korblox(v)
    end
})
ChangerTab:Toggle({
    Name = "Headless",
    Default = false,
    Flag = "ktl_headless",
    Callback = function(v)
        u1070.avatar.set_headless(v)
    end
})



ImmortalTab:Section("Immortal")

ImmortalTab:Toggle({
    Name = "Kittylol Immortal",
    Default = false,
    Flag = "ktl_immortal",
    Callback = function(v)
        if v then
            startBackgroundOrbit()
        else
            stopBackgroundOrbit()
        end
        if Window.Notify then
            Window:Notify({
                Title = "Kittylol Immortal",
                Content = v and "ON" or "OFF",
                Type = v and "Success" or "Info",
                Duration = 2
            })
        end
    end
})

ImmortalTab:Section("Orbit Ball")

ImmortalTab:Toggle({
    Name = "Orbit Ball",
    Default = false,
    Flag = "ktl_immortal_orbit_ball",
    Callback = function(v)
        if v then
            startOrbitBall()
        else
            stopOrbitBall()
        end
    end
})

ImmortalTab:Slider({
    Name = "Distance",
    Min = 10,
    Max = 100,
    Step = 1,
    Default = 50,
    Flag = "ktl_immortal_orbit_distance",
    Callback = function(v)
        ImmortalBallState.Distance = v
    end
})

ImmortalTab:Slider({
    Name = "Height",
    Min = 0,
    Max = 100,
    Step = 1,
    Default = 15,
    Flag = "ktl_immortal_orbit_height",
    Callback = function(v)
        ImmortalBallState.Height = v
    end
})

ImmortalTab:Slider({
    Name = "Speed",
    Min = 1,
    Max = 500,
    Step = 1,
    Default = 100,
    Flag = "ktl_immortal_orbit_speed",
    Callback = function(v)
        ImmortalBallState.Speed = v
    end
})

Window:Notify({
    Title = "Kittylol",
    Content = "Loaded Kittylol [free]",
    Type = "Success",
    Duration = 4,
})

__KTL_UI_BUILDING = false

local KeyboardGui = nil
local KeyboardConnections = {}
local KeyboardCapture = nil
local KeyboardCaptureConsumed = false
local KeyboardEnabled = true

local KeyboardSettings = {
    AutoParry = Enum.KeyCode.T,
    AutoSpam = Enum.KeyCode.V,
    ManualSpam = Enum.KeyCode.F,
    ManualSpamMode = "Hold to Spam"
}

local function keyName(keyCode)
    return keyCode == Enum.KeyCode.Unknown and "None" or keyCode.Name
end

local function isKeyboardInput(input)
    return input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode ~= Enum.KeyCode.Unknown
end

local function setManualSpamState(state)
    state = state == true
    flags.ManualSpamEnabled = state
    if state then
        startManualSpam()
    else
        stopManualSpam()
    end
end

local function toggleManualKeyboardSpam()
    setManualSpamState(not flags.ManualSpamEnabled)
end

local function stopManualKeyboardSpam()
    if KeyboardSettings.ManualSpamMode == "Hold to Spam" and flags.ManualSpamEnabled then
        setManualSpamState(false)
    end
end

local function SetKeyboardKey(name, keyCode)
    KeyboardSettings[name] = keyCode
end

local DisconnectConnections

local function CreateKeyboardUI()
    if not KeyboardEnabled then return end
    if KeyboardGui and KeyboardGui.Parent then
        KeyboardGui.Enabled = true
        return
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Kittylol_KeyboardUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui
    KeyboardGui = gui

    local Main = Instance.new("Frame")
    Main.Name = "Keyboard"
    Main.Size = UDim2.fromOffset(260, 126)
    Main.Position = UDim2.new(0.5, -130, 0.5, -63)
    Main.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ZIndex = 2500
    Main.Parent = gui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 13)
    Corner.Parent = Main

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5
    Stroke.Color = Color3.fromRGB(70, 70, 70)
    Stroke.Transparency = 0.25
    Stroke.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 32)
    Title.Position = UDim2.fromOffset(10, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Keyboard"
    Title.TextColor3 = Color3.fromRGB(245, 245, 245)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.ZIndex = 2502
    Title.Parent = Main

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.fromOffset(0, 40)
    Divider.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
    Divider.BorderSizePixel = 0
    Divider.ZIndex = 2501
    Divider.Parent = Main

    local Rows = Instance.new("Frame")
    Rows.Size = UDim2.new(1, -20, 0, 76)
    Rows.Position = UDim2.fromOffset(10, 47)
    Rows.BackgroundTransparency = 1
    Rows.ZIndex = 2502
    Rows.Parent = Main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Parent = Rows

    local modeOpen = false
    local modePanel = Instance.new("Frame")
    modePanel.Size = UDim2.new(1, -20, 0, 46)
    modePanel.Position = UDim2.fromOffset(10, 123)
    modePanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    modePanel.BorderSizePixel = 0
    modePanel.Visible = false
    modePanel.ZIndex = 2510
    modePanel.Parent = Main

    local modeCorner = Instance.new("UICorner")
    modeCorner.CornerRadius = UDim.new(0, 9)
    modeCorner.Parent = modePanel

    local modeStroke = Instance.new("UIStroke")
    modeStroke.Thickness = 1
    modeStroke.Color = Color3.fromRGB(55, 55, 55)
    modeStroke.Parent = modePanel

    local function makeButton(parent, textValue, widthScale, xScale)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(widthScale, -4, 1, 0)
        button.Position = UDim2.new(xScale, 2, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
        button.BorderSizePixel = 0
        button.Text = textValue
        button.TextColor3 = Color3.fromRGB(245, 245, 245)
        button.TextSize = 12
        button.Font = Enum.Font.GothamSemibold
        button.AutoButtonColor = false
        button.ZIndex = 2512
        button.Parent = parent
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 7)
        c.Parent = button
        local st = Instance.new("UIStroke")
        st.Thickness = 1
        st.Color = Color3.fromRGB(55, 55, 55)
        st.Parent = button
        return button
    end

    local function makeRow(label, settingName)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundTransparency = 1
        row.ZIndex = 2503
        row.Parent = Rows

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(0.58, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = label
        text.TextColor3 = Color3.fromRGB(230, 230, 230)
        text.TextSize = 13
        text.Font = Enum.Font.GothamMedium
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.ZIndex = 2504
        text.Parent = row

        local button = makeButton(row, keyName(KeyboardSettings[settingName]), 0.42, 0.58)
        return button
    end

    local autoParryButton = makeRow("Auto Parry", "AutoParry")
    local autoSpamButton = makeRow("Auto Spam", "AutoSpam")

    local manualRow = Instance.new("Frame")
    manualRow.Size = UDim2.new(1, 0, 0, 22)
    manualRow.BackgroundTransparency = 1
    manualRow.ZIndex = 2503
    manualRow.Parent = Rows

    local manualText = Instance.new("TextLabel")
    manualText.Size = UDim2.new(0.34, 0, 1, 0)
    manualText.BackgroundTransparency = 1
    manualText.Text = "Manual Spam"
    manualText.TextColor3 = Color3.fromRGB(230, 230, 230)
    manualText.TextSize = 13
    manualText.Font = Enum.Font.GothamMedium
    manualText.TextXAlignment = Enum.TextXAlignment.Left
    manualText.ZIndex = 2504
    manualText.Parent = manualRow

    local manualKeyButton = makeButton(manualRow, keyName(KeyboardSettings.ManualSpam), 0.28, 0.34)
    local manualModeButton = makeButton(manualRow, KeyboardSettings.ManualSpamMode, 0.38, 0.62)

    local function animateMode(open)
        modeOpen = open
        if open then
            modePanel.Visible = true
            modePanel.Size = UDim2.new(1, -20, 0, 0)
            modePanel.Position = UDim2.fromOffset(10, 123)
            TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(260, 180)
            }):Play()
            TweenService:Create(modePanel, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -20, 0, 46)
            }):Play()
        else
            local tween = TweenService:Create(modePanel, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Size = UDim2.new(1, -20, 0, 0)
            })
            tween:Play()
            TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(260, 126)
            }):Play()
            tween.Completed:Connect(function()
                if not modeOpen then modePanel.Visible = false end
            end)
        end
    end

    local holdOption = makeButton(modePanel, "Hold to Spam", 0.5, 0)
    local onceOption = makeButton(modePanel, "Press Once to Spam", 0.5, 0.5)

    local function selectMode(mode)
        KeyboardSettings.ManualSpamMode = mode
        manualModeButton.Text = mode
        animateMode(false)
    end

    manualModeButton.MouseButton1Click:Connect(function()
        animateMode(not modeOpen)
    end)
    holdOption.MouseButton1Click:Connect(function()
        selectMode("Hold to Spam")
    end)
    onceOption.MouseButton1Click:Connect(function()
        selectMode("Press Once to Spam")
    end)

    local function beginKeyCapture(settingName, button)
        if KeyboardCapture then return end
        KeyboardCapture = settingName
        button.Text = "Press a key..."
        task.spawn(function()
            local timeout = os.clock() + 8
            while KeyboardCapture == settingName and os.clock() < timeout do
                task.wait()
            end
            if KeyboardCapture == settingName then
                KeyboardCapture = nil
                button.Text = keyName(KeyboardSettings[settingName])
            end
        end)
    end

    autoParryButton.MouseButton1Click:Connect(function()
        beginKeyCapture("AutoParry", autoParryButton)
    end)
    autoSpamButton.MouseButton1Click:Connect(function()
        beginKeyCapture("AutoSpam", autoSpamButton)
    end)
    manualKeyButton.MouseButton1Click:Connect(function()
        beginKeyCapture("ManualSpam", manualKeyButton)
    end)

    KeyboardConnections.capture = UserInputService.InputBegan:Connect(function(input)
        if not isKeyboardInput(input) then return end
        if KeyboardCapture then
            local name = KeyboardCapture
            KeyboardCapture = nil
            KeyboardCaptureConsumed = true
            SetKeyboardKey(name, input.KeyCode)
            local button = name == "AutoParry" and autoParryButton or name == "AutoSpam" and autoSpamButton or manualKeyButton
            button.Text = keyName(input.KeyCode)
            return
        end
    end)

    KeyboardConnections.inputBegan = UserInputService.InputBegan:Connect(function(input, processed)
        if KeyboardCaptureConsumed then
            KeyboardCaptureConsumed = false
            return
        end
        if processed or not isKeyboardInput(input) or KeyboardCapture then return end

        if input.KeyCode == KeyboardSettings.AutoParry then
            local state = not flags.AutoParryEnabled
            flags.AutoParryEnabled = state
            if state then resetParryState() end
            __KTL_NotifyFeature("Auto Parry", state)
        elseif input.KeyCode == KeyboardSettings.AutoSpam then
            local state = not flags.AutoSpamEnabled
            flags.AutoSpamEnabled = state
            __KTL_NotifyFeature("Auto Spam", state)
        elseif input.KeyCode == KeyboardSettings.ManualSpam then
            if KeyboardSettings.ManualSpamMode == "Press Once to Spam" then
                toggleManualKeyboardSpam()
                __KTL_NotifyFeature("Manual Spam", flags.ManualSpamEnabled)
            else
                if not flags.ManualSpamEnabled then
                    setManualSpamState(true)
                    __KTL_NotifyFeature("Manual Spam", true)
                end
            end
        end
    end)

    KeyboardConnections.inputEnded = UserInputService.InputEnded:Connect(function(input)
        if not isKeyboardInput(input) or KeyboardCapture then return end
        if input.KeyCode == KeyboardSettings.ManualSpam and KeyboardSettings.ManualSpamMode == "Hold to Spam" then
            if flags.ManualSpamEnabled then
                setManualSpamState(false)
                __KTL_NotifyFeature("Manual Spam", false)
            end
        end
    end)

    local dragging = false
    local dragStart
    local startPos
    KeyboardConnections.dragBegan = Main.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end)
    KeyboardConnections.dragChanged = UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)
    KeyboardConnections.dragEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function DestroyKeyboardUI()
    KeyboardCapture = nil
    KeyboardCaptureConsumed = false
    DisconnectConnections(KeyboardConnections)
    if KeyboardGui then
        KeyboardGui:Destroy()
        KeyboardGui = nil
    end
    if flags.ManualSpamEnabled and KeyboardSettings.ManualSpamMode == "Hold to Spam" then
        setManualSpamState(false)
    end
end

DisconnectConnections = function(tbl)
    for _, connection in pairs(tbl) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(tbl)
end

local SettingTab = Window:CreateTab({
    Name = "Setting",
    Icon = "settings",
    Desc = "Keyboard settings"
})

SettingTab:Section("Keyboard")
SettingTab:Toggle({
    Name = "Keyboard",
    Default = true,
    Flag = "ktl_keyboard_enabled",
    Callback = function(v)
        KeyboardEnabled = v == true
        if KeyboardEnabled then
            CreateKeyboardUI()
        else
            DestroyKeyboardUI()
        end
    end
})

CreateKeyboardUI()

Window:Notify({
    Title = "Kittylol",
    Content = "Loaded Kittylol [free]",
    Type = "Success",
    Duration = 4,
})
