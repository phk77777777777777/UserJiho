local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- LinoriaLib 전역 객체 바인딩
local Toggles = getgenv().Toggles or Library.Toggles
local Options = getgenv().Options or Library.Options

-- 로블록스 필수 서비스 선언
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local Window = Library:CreateWindow({
    Title = 'your.jiho - Rivals (Super Enhanced)',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    Setting = Window:AddTab('Setting'),
    TikTok = Window:AddTab('TikTok'),
    Spoofers = Window:AddTab('Spoofers') -- TikTok 옆에 스푸퍼 탭 추가
}

-- 클립보드 복사 헬퍼 함수
local function copyToClipboard(url)
    local clipboardFunc = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if clipboardFunc then
        clipboardFunc(url)
        Library:Notify("틱톡 링크가 클립보드에 복사되었습니다!")
    else
        Library:Notify("실행기가 클립보드 복사를 지원하지 않습니다.")
    end
end

-- ==========================================
-- 다국어 (Language System) 데이터 정의
-- ==========================================
local Translations = {
    ["한국어"] = {
        MainTab = "메인",
        VisualsTab = "비주얼",
        MiscTab = "기타",
        SettingTab = "설정",
        TikTokTab = "틱톡",
        SpoofersTab = "Spoofers",
        CombatGroup = "전투 (Combat)",
        RagebotText = "레이지봇 (Ragebot)",
        RageTargetPartText = "레이지 타겟 부위",
        DesyncText = "할무 소프트 디싱크",
        VoidSpamText = "보이드 스팸",
        VoidHideText = "보이드 숨김 지연시간",
        SkinGroup = "스킨 해금 (Skin Unlocker)",
        UnlockSkinsText = "올스킨 해금 (Unlock All Skins)",
        ForceSkinText = "스킨 재적용 시도",
        HitboxGroup = "히트박스 확장 (Hitbox Extender)",
        HitboxToggle = "히트박스 확장 활성화",
        HitboxSize = "히트박스 크기",
        HitboxTrans = "투명도",
        AimbotGroup = "에임봇 & 트리거봇",
        AimbotToggle = "에임봇 활성화",
        ShowFOV = "FOV 범위 표시",
        FOVSize = "FOV 크기",
        Triggerbot = "트리거봇 (자동 발사)",
        TriggerDelay = "트리거 지연시간 (초)",
        KillSoundGroup = "킬 사운드",
        EnableKillSound = "킬 사운드 활성화",
        SoundPreset = "사운드 프리셋",
        CustomSound = "커스텀 사운드 ID",
        Volume = "볼륨",
        CopyJihoTikTok = "지호 틱톡 (링크 복사)",
        CopyUserTikTok = "유저 틱톡 (링크 복사)"
    },
    ["English"] = {
        MainTab = "Main",
        VisualsTab = "Visuals",
        MiscTab = "Misc",
        SettingTab = "Setting",
        TikTokTab = "TikTok",
        SpoofersTab = "Spoofers",
        CombatGroup = "Combat",
        RagebotText = "Ragebot",
        RageTargetPartText = "Rage Target Part",
        DesyncText = "Halmu Soft Desync",
        VoidSpamText = "Void Spam",
        VoidHideText = "Void Hide Delay",
        SkinGroup = "Skin Unlocker",
        UnlockSkinsText = "Unlock All Skins",
        ForceSkinText = "Force Unlock Skins",
        HitboxGroup = "Hitbox Extender",
        HitboxToggle = "Enable Hitbox Extender",
        HitboxSize = "Hitbox Size",
        HitboxTrans = "Transparency",
        AimbotGroup = "Aimbot & Triggerbot",
        AimbotToggle = "Aimbot Enabled",
        ShowFOV = "Show FOV",
        FOVSize = "FOV Size",
        Triggerbot = "Triggerbot (Auto Fire)",
        TriggerDelay = "Trigger Delay (s)",
        KillSoundGroup = "Kill Sound",
        EnableKillSound = "Enable Kill Sound",
        SoundPreset = "Sound Preset",
        CustomSound = "Custom Sound ID",
        Volume = "Volume",
        CopyJihoTikTok = "Jiho TikTok (Copy Link)",
        CopyUserTikTok = "User TikTok (Copy Link)"
    }
}

-- ==========================================
-- All Skins Unlocker Engine
-- ==========================================
local function applySkinUnlocker()
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                local name = obj.Name:lower()
                if name:find("skin") or name:find("item") or name:find("inventory") or name:find("wrap") or name:find("cosmetic") then
                    local ok, mod = pcall(require, obj)
                    if ok and type(mod) == "table" then
                        for k, v in pairs(mod) do
                            if type(v) == "function" then
                                local fname = tostring(k):lower()
                                if fname:find("own") or fname:find("unlock") or fname:find("has") or fname:find("get") then
                                    mod[k] = function(...) return true end
                                end
                            end
                        end
                    end
                end
            end
        end

        local controllers = LocalPlayer:FindFirstChild("PlayerScripts")
        if controllers then
            for _, v in ipairs(controllers:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    local ok, mod = pcall(require, v)
                    if ok and type(mod) == "table" then
                        if mod.OwnsItem then mod.OwnsItem = function() return true end end
                        if mod.IsUnlocked then mod.IsUnlocked = function() return true end end
                        if mod.HasSkin then mod.HasSkin = function() return true end end
                        if mod.GetOwnedSkins then mod.GetOwnedSkins = function() return true end end
                    end
                end
            end
        end
    end)
end

-- ==========================================
-- Spoofer Engine (이름 설정 & 아크네메시스 티어 유지)
-- ==========================================
getgenv().SpoofedName = ""
getgenv().ArchNemesisSpoof = false

local originalName = LocalPlayer.Name
local originalDisplayName = LocalPlayer.DisplayName

local function applySpoofers()
    pcall(function()
        -- 1. 이름 변경 적용
        if getgenv().SpoofedName and getgenv().SpoofedName ~= "" then
            LocalPlayer.DisplayName = getgenv().SpoofedName
        end

        -- 2. 아크네메시스 및 티어 스푸핑 (데이터 유실 방지 포함)
        if getgenv().ArchNemesisSpoof then
            for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    local n = v.Name:lower()
                    if n:find("rank") or n:find("tier") or n:find("level") or n:find("stats") or n:find("nemesis") then
                        local ok, mod = pcall(require, v)
                        if ok and type(mod) == "table" then
                            for k, fn in pairs(mod) do
                                if type(fn) == "function" then
                                    local fname = tostring(k):lower()
                                    if fname:find("getrank") or fname:find("gettier") or fname:find("getnemesis") then
                                        mod[k] = function(...) return "Arch-Nemesis" end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if getgenv().SpoofedName and getgenv().SpoofedName ~= "" then
        LocalPlayer.DisplayName = getgenv().SpoofedName
    end
end)

-- ==========================================
-- Ragebot UI (Crosshair & Rainbow Text)
-- ==========================================
local RageUIGui = Instance.new("ScreenGui", PlayerGui)
RageUIGui.Name = "HoNyangRageUI"
RageUIGui.ResetOnSpawn = false

local CrosshairContainer = Instance.new("Frame", RageUIGui)
CrosshairContainer.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairContainer.Position = UDim2.new(0.5, 0, 0.5, -35)
CrosshairContainer.Size = UDim2.new(0, 40, 0, 40)
CrosshairContainer.BackgroundTransparency = 1
CrosshairContainer.Visible = false

local lines = {
    {Size = UDim2.new(0, 8, 0, 2), DefaultPos = UDim2.new(0, 0, 0.5, -1)},
    {Size = UDim2.new(0, 8, 0, 2), DefaultPos = UDim2.new(1, -8, 0.5, -1)},
    {Size = UDim2.new(0, 2, 0, 8), DefaultPos = UDim2.new(0.5, -1, 0, 0)},
    {Size = UDim2.new(0, 2, 0, 8), DefaultPos = UDim2.new(0.5, -1, 1, -8)}
}

local crosshairLines = {}
for _, info in ipairs(lines) do
    local line = Instance.new("Frame", CrosshairContainer)
    line.Size = info.Size
    line.Position = info.DefaultPos
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    table.insert(crosshairLines, {Line = line, DefaultPos = info.DefaultPos})
end

local RageTextLabel = Instance.new("TextLabel", RageUIGui)
RageTextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
RageTextLabel.Position = UDim2.new(0.5, 0, 0.5, 25)
RageTextLabel.Size = UDim2.new(0, 200, 0, 25)
RageTextLabel.BackgroundTransparency = 1
RageTextLabel.Text = "ragebot active"
RageTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RageTextLabel.TextStrokeTransparency = 0
RageTextLabel.Font = Enum.Font.GothamBold
RageTextLabel.TextSize = 13
RageTextLabel.TextXAlignment = Enum.TextXAlignment.Center
RageTextLabel.Visible = false

local rageHue = 0
local rotAngle = 0
RunService.RenderStepped:Connect(function()
    RageTextLabel.Visible = CrosshairContainer.Visible
    if CrosshairContainer.Visible then
        rageHue = (rageHue + 2) % 360
        local rainbowColor = Color3.fromHSV(rageHue / 360, 1, 1)
        for _, item in ipairs(crosshairLines) do
            item.Line.BackgroundColor3 = rainbowColor
        end
        RageTextLabel.TextColor3 = rainbowColor

        rotAngle = (rotAngle + 4) % 360
        CrosshairContainer.Rotation = rotAngle

        local timeVal = tick() * 5
        local pulse = (math.sin(timeVal) + 1) * 0.5 
        
        crosshairLines[1].Line.Position = UDim2.new(0, math.floor(3 + pulse * 6), 0.5, -1)
        crosshairLines[2].Line.Position = UDim2.new(1, math.floor(-11 - pulse * 6), 0.5, -1)
        crosshairLines[3].Line.Position = UDim2.new(0.5, -1, 0, math.floor(3 + pulse * 6))
        crosshairLines[4].Line.Position = UDim2.new(0.5, -1, 1, math.floor(-11 - pulse * 6))
    end
end)

-- Halmu-style Ragebot Engine
local _halmu = {
    rageEnabled = false, desyncEnabled = false, desyncDist = 3,
    currentTarget = nil, rageConn = nil, findConn = nil,
    RealCFrame = nil, ready = false, targetPartSetting = "Head"
}

local FighterCtrl, EnumLib, useItemRemote, ssEnum
task.spawn(function()
    local okF, fc = pcall(function() return require(LocalPlayer.PlayerScripts.Controllers.FighterController) end)
    if okF then FighterCtrl = fc end

    local okE, el = pcall(function() return require(ReplicatedStorage.Modules.EnumLibrary) end)
    if okE then EnumLib = el end

    pcall(function() useItemRemote = ReplicatedStorage.Remotes.Replication.Fighter.UseItem end)
    pcall(function() if EnumLib then ssEnum = EnumLib:ToEnum("StartShooting") end end)
    _halmu.ready = true
end)

local function isSameTeam(plr)
    if not (Toggles.TeamCheck and Toggles.TeamCheck.Value) then return false end
    local a = LocalPlayer:GetAttribute("TeamID")
    local b = plr:GetAttribute("TeamID")
    if a == nil or b == nil then return false end
    return a == b
end

local function getRageHead(char)
    if not char then return nil end
    if _halmu.targetPartSetting == "Torso" then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
    end
    return char:FindFirstChild("HitboxHead") or char:FindFirstChild("HitboxHeadSmall") or char:FindFirstChild("Head")
end

local function getObjId()
    if not (FighterCtrl and FighterCtrl.LocalFighter) then return nil end
    local item = FighterCtrl.LocalFighter.EquippedItem
    if not item then return nil end
    local ok, id = pcall(function() return item:Get("ObjectID") end)
    if ok and id then return id end
    ok, id = pcall(function() return item.Data and item.Data.ObjectID end)
    return ok and id or nil
end

local function buildShot(originPos, targetPart)
    local targetPos = targetPart.Position
    local lookCF = CFrame.lookAt(originPos, targetPos)
    local lX, lY, lZ = lookCF:ToOrientation()
    local originStruct = {
        [utf8.char(0)] = originPos.X, [utf8.char(1)] = originPos.Y, [utf8.char(2)] = originPos.Z,
        [utf8.char(3)] = lX, [utf8.char(4)] = lY, [utf8.char(5)] = lZ,
    }
    local relCF = targetPart.CFrame:ToObjectSpace(CFrame.new(targetPos))
    local rX, rY, rZ = relCF:ToOrientation()
    return {
        [utf8.char(1)] = {
            [utf8.char(0)] = originStruct, [utf8.char(1)] = originStruct,
            [utf8.char(2)] = targetPart,
            [utf8.char(3)] = {
                [utf8.char(0)] = relCF.X, [utf8.char(1)] = relCF.Y, [utf8.char(2)] = relCF.Z,
                [utf8.char(3)] = rX, [utf8.char(4)] = rY, [utf8.char(5)] = rZ,
            },
        },
    }
end

local function startTargetFinder()
    if _halmu.findConn then return end
    _halmu.findConn = RunService.Heartbeat:Connect(function()
        if not _halmu.rageEnabled then _halmu.currentTarget = nil; return end
        local ref = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local refPos = ref and ref.Position or Vector3.zero
        local closest, best = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and not isSameTeam(plr) then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local d = (Vector3.new(refPos.X, 0, refPos.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
                    if d < best then best = d; closest = plr end
                end
            end
        end
        _halmu.currentTarget = closest and getRageHead(closest.Character) or nil
    end)
end

local function startRageFire()
    if _halmu.rageConn then _halmu.rageConn:Disconnect(); _halmu.rageConn = nil end
    if not _halmu.rageEnabled then return end

    local cachedId = nil
    _halmu.rageConn = RunService.Heartbeat:Connect(function()
        if not _halmu.rageEnabled then return end
        if not useItemRemote or not ssEnum then return end
        local target = _halmu.currentTarget
        if not target or not target.Parent then return end

        local objId = getObjId()
        if objId then cachedId = objId else objId = cachedId end
        if not objId then return end

        local origin = target.Position + Vector3.new(0, 0.1, 0)
        pcall(function()
            useItemRemote:FireServer(objId, ssEnum, buildShot(origin, target), nil)
        end)
    end)
end

-- Soft Desync
local restoreName = "cg_halmu_restore"
RunService.Heartbeat:Connect(function()
    if not (_halmu.rageEnabled and _halmu.desyncEnabled and _halmu.currentTarget) then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    _halmu.RealCFrame = hrp.CFrame
    local tp = _halmu.currentTarget.Position
    hrp.CFrame = CFrame.new(tp + Vector3.new(0, _halmu.desyncDist, 0), tp)
    hrp.AssemblyLinearVelocity = Vector3.zero
end)

RunService:BindToRenderStep(restoreName, 150, function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and _halmu.RealCFrame then
        hrp.CFrame = _halmu.RealCFrame
        hrp.AssemblyLinearVelocity = Vector3.zero
        _halmu.RealCFrame = nil
    end
end)

local function setRage(on)
    _halmu.rageEnabled = on and true or false
    CrosshairContainer.Visible = _halmu.rageEnabled
    if on then startTargetFinder(); startRageFire()
    else
        if _halmu.rageConn then _halmu.rageConn:Disconnect(); _halmu.rageConn = nil end
        _halmu.currentTarget = nil
    end
end

-- ==========================================
-- 1. Main 탭
-- ==========================================
local MainGroup = Tabs.Main:AddLeftGroupbox('Combat')

local RageToggle = MainGroup:AddToggle('Ragebot', { Text = 'Ragebot', Default = false, Callback = function(Value) setRage(Value) end })
local RageTargetPartDrop = MainGroup:AddDropdown('RageTargetPart', { Values = { 'Head', 'Torso' }, Default = 1, Text = 'Rage Target Part', Callback = function(Value) _halmu.targetPartSetting = Value end })
local DesyncToggleObj = MainGroup:AddToggle('DesyncToggle', { Text = 'Halmu Soft Desync', Default = false, Callback = function(Value) _halmu.desyncEnabled = Value end })
local VoidSpamToggleObj = MainGroup:AddToggle('VoidSpamToggle', { Text = 'Void Spam', Default = false, Callback = function(Value) getgenv().VoidSpamEnabled = Value end })
local VoidHideSliderObj = MainGroup:AddSlider('VoidHideSlider', { Text = 'Void Hide Delay', Default = 0.1, Min = 0.01, Max = 1.0, Rounding = 2, Callback = function(Value) getgenv().VoidHideValue = Value end })

-- Skin Unlocker
local SkinGroup = Tabs.Main:AddLeftGroupbox('Skin Unlocker')

local UnlockAllSkinsToggleObj = SkinGroup:AddToggle('UnlockAllSkins', {
    Text = 'Unlock All Skins (올스킨 해금)',
    Default = false,
    Callback = function(Value)
        if Value then
            applySkinUnlocker()
            Library:Notify("스킨 해금 시도 완료! (인벤토리/로커 확인)")
        end
    end
})

local ForceUnlockBtn = SkinGroup:AddButton('Force Unlock Skins', function()
    applySkinUnlocker()
    Library:Notify("스킨 재적용을 시도했습니다.")
end)

-- Hitbox Extender
local HitboxGroup = Tabs.Main:AddLeftGroupbox('Hitbox Extender')
local HitboxToggleObj = HitboxGroup:AddToggle('HitboxEnabled', { Text = 'Enable Hitbox Extender', Default = false })
local HitboxSizeSliderObj = HitboxGroup:AddSlider('HitboxSize', { Text = 'Hitbox Size', Default = 5, Min = 2, Max = 30, Rounding = 0 })
local HitboxTransSliderObj = HitboxGroup:AddSlider('HitboxTrans', { Text = 'Transparency', Default = 0.7, Min = 0, Max = 1, Rounding = 1 })

RunService.RenderStepped:Connect(function()
    if Toggles.HitboxEnabled and Toggles.HitboxEnabled.Value then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and not isSameTeam(plr) then
                local head = getRageHead(plr.Character)
                if head then
                    head.Size = Vector3.new(Options.HitboxSize.Value, Options.HitboxSize.Value, Options.HitboxSize.Value)
                    head.Transparency = Options.HitboxTrans.Value
                    head.CanCollide = false
                end
            end
        end
    end
end)

getgenv().VoidSpamEnabled = false
getgenv().VoidHideValue = 0.1

task.spawn(function()
    local lastAttackTime = 0
    RunService.Heartbeat:Connect(function()
        if not getgenv().VoidSpamEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local originalCFrame = root.CFrame
        local voidCFrame = originalCFrame + Vector3.new(0, 10000, 0)
        local targetPart = _halmu.currentTarget
        local currentTime = tick()
        local hideInterval = getgenv().VoidHideValue or 0.1

        if targetPart and targetPart.Parent and (currentTime - lastAttackTime >= hideInterval) then
            lastAttackTime = currentTime
            root.CFrame = targetPart.CFrame
            RunService:BindToRenderStep("__void_restore", 1, function()
                root.CFrame = voidCFrame
                RunService:UnbindFromRenderStep("__void_restore")
            end)
            return
        end

        root.CFrame = voidCFrame
        RunService:BindToRenderStep("__void_hold", 1, function()
            root.CFrame = originalCFrame
            RunService:UnbindFromRenderStep("__void_hold")
        end)
    end)
end)

-- Aimbot 및 Triggerbot
local AimbotGroup = Tabs.Main:AddRightGroupbox('Aimbot & Triggerbot')

local FOVGui = Instance.new("ScreenGui", PlayerGui)
FOVGui.Name = "HoNyangFOV"
FOVGui.ResetOnSpawn = false

local FOVFrame = Instance.new("Frame", FOVGui)
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false

local UICorner = Instance.new("UICorner", FOVFrame)
UICorner.CornerRadius = UDim.new(1, 0)

local FOVStroke = Instance.new("UIStroke", FOVFrame)
FOVStroke.Thickness = 2

local hue = 0
RunService.RenderStepped:Connect(function()
    hue = (hue + 2) % 360
    FOVStroke.Color = Color3.fromHSV(hue / 360, 1, 1)
end)

local AimbotToggleObj = AimbotGroup:AddToggle('AimbotToggle', { Text = 'Aimbot Enabled', Default = false })
local ShowFOVToggleObj = AimbotGroup:AddToggle('ShowFOVToggle', { Text = 'Show FOV', Default = false, Callback = function(Value) FOVFrame.Visible = Value end })
local FOVSliderObj = AimbotGroup:AddSlider('FOVSlider', { Text = 'FOV Size', Default = 150, Min = 50, Max = 500, Rounding = 0, Callback = function(Value) FOVFrame.Size = UDim2.new(0, Value * 2, 0, Value * 2) end })
local TriggerbotToggleObj = AimbotGroup:AddToggle('TriggerbotToggle', { Text = 'Triggerbot (Auto Fire)', Default = false })
local TriggerDelaySliderObj = AimbotGroup:AddSlider('TriggerDelay', { Text = 'Trigger Delay (s)', Default = 0.05, Min = 0, Max = 0.5, Rounding = 2 })

local lastTriggerShot = 0
RunService.RenderStepped:Connect(function()
    if Toggles.AimbotToggle and Toggles.AimbotToggle.Value then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local currentFOV = Options.FOVSlider.Value
            local nearestTarget = nil
            local shortestDistance = math.huge

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and not isSameTeam(player) then
                    local enemyChar = player.Character
                    local humanoid = enemyChar:FindFirstChildOfClass("Humanoid")
                    local linkHead = enemyChar:FindFirstChild("Head")
                    if humanoid and humanoid.Health > 0 and linkHead then
                        local pos, onScreen = Camera:WorldToViewportPoint(linkHead.Position)
                        local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if onScreen and distance <= currentFOV and distance < shortestDistance then
                            shortestDistance = distance
                            nearestTarget = linkHead
                        end
                    end
                end
            end
            if nearestTarget then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, nearestTarget.Position)
            end
        end
    end

    if Toggles.TriggerbotToggle and Toggles.TriggerbotToggle.Value then
        local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local raycastResult = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
        if raycastResult and raycastResult.Instance then
            local hitModel = raycastResult.Instance:FindFirstAncestorOfClass("Model")
            if hitModel then
                local plr = Players:GetPlayerFromCharacter(hitModel)
                if plr and plr ~= LocalPlayer and not isSameTeam(plr) then
                    if tick() - lastTriggerShot >= Options.TriggerDelay.Value then
                        lastTriggerShot = tick()
                        mouse1click()
                    end
                end
            end
        end
    end
end)

-- Kill Sound
local KillSoundGroup = Tabs.Main:AddRightGroupbox('Kill Sound')
local killSoundEnabled = false
local killSoundVolume = 1
local selectedSoundId = "rbxassetid://6820230230"

local soundPresets = {
    ["Mambo"] = "rbxassetid://119974879573475",
    ["Neverlose"] = "rbxassetid://2865227271",
    ["Skeet"] = "rbxassetid://5633691856",
    ["Rust Headshot"] = "rbxassetid://5043539486",
    ["Minecraft Hit"] = "rbxassetid://4018616850",
    ["Call of Duty"] = "rbxassetid://160432334",
    ["TF2 Bell"] = "rbxassetid://2865227271",
    ["Quake Kill"] = "rbxassetid://130768850"
}

local killSoundObj = Instance.new("Sound", SoundService or Workspace)
killSoundObj.Name = "RivalsKillSound"

local function playKillSound()
    if not killSoundEnabled or selectedSoundId == "" then return end
    killSoundObj.SoundId = selectedSoundId
    killSoundObj.Volume = killSoundVolume
    killSoundObj:Play()
end

local KillSoundToggleObj = KillSoundGroup:AddToggle('KillSoundToggle', { Text = 'Enable Kill Sound', Default = false, Callback = function(Value) killSoundEnabled = Value end })
local KillSoundDropObj = KillSoundGroup:AddDropdown('KillSoundDropdown', {
    Values = { '사단다기', 'Neverlose', 'Skeet', 'Rust Headshot', 'Minecraft Hit', 'Call of Duty', 'TF2 Bell', 'Quake Kill', 'Custom' },
    Default = 1, Text = 'Sound Preset',
    Callback = function(Value)
        if Value == 'Custom' then
            if Options.CustomSoundInput and Options.CustomSoundInput.Value ~= "" then
                selectedSoundId = "rbxassetid://" .. tostring(Options.CustomSoundInput.Value)
            else selectedSoundId = "" end
        elseif soundPresets[Value] then selectedSoundId = soundPresets[Value] end
    end
})

local CustomSoundInputObj = KillSoundGroup:AddInput('CustomSoundInput', {
    Default = '', Numeric = true, Finished = true, Text = 'Custom Sound ID', Placeholder = 'Sound ID Input...',
    Callback = function(Value)
        if Options.KillSoundDropdown and Options.KillSoundDropdown.Value == 'Custom' then
            selectedSoundId = "rbxassetid://" .. tostring(Value)
        end
    end
})

local KillSoundVolSliderObj = KillSoundGroup:AddSlider('KillSoundVolume', { Text = 'Volume', Default = 1, Min = 0.1, Max = 5, Rounding = 1, Callback = function(Value) killSoundVolume = Value end })

local trackedHumanoids = {}
local function listenForKill(plr)
    if plr == LocalPlayer then return end
    local function onCharacterAdded(char)
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 5)
        if hum and not trackedHumanoids[hum] then
            trackedHumanoids[hum] = true
            hum.Died:Connect(function()
                if not isSameTeam(plr) then playKillSound() end
            end)
        end
    end
    if plr.Character then onCharacterAdded(plr.Character) end
    plr.CharacterAdded:Connect(onCharacterAdded)
end

for _, plr in ipairs(Players:GetPlayers()) do listenForKill(plr) end
Players.PlayerAdded:Connect(listenForKill)

-- ==========================================
-- 2. Visuals 탭
-- ==========================================
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP Options')
ESPGroup:AddToggle('TeamCheck', { Text = 'Team Check', Default = true })
ESPGroup:AddToggle('ESPBox', { Text = 'Box ESP', Default = false })
ESPGroup:AddToggle('ESPName', { Text = 'Name ESP', Default = false })
ESPGroup:AddToggle('ESPHealth', { Text = 'Health ESP', Default = false })
ESPGroup:AddToggle('ESPDistance', { Text = 'Distance ESP', Default = false })
ESPGroup:AddToggle('ESPTracer', { Text = 'Tracer ESP', Default = false })
ESPGroup:AddToggle('ESPHeadDot', { Text = 'Head Dot ESP', Default = false })
ESPGroup:AddToggle('ESPChams', { Text = 'Chams ESP', Default = false })

local SkyboxGroup = Tabs.Visuals:AddRightGroupbox('Skybox & Camera')
SkyboxGroup:AddToggle('FullbrightToggle', {
    Text = 'Fullbright (시야 확보)', Default = false,
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
            Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        else Lighting.Ambient = Color3.fromRGB(127, 127, 127) end
    end
})

SkyboxGroup:AddSlider('CamFOV', { Text = 'Camera Field of View', Default = 70, Min = 50, Max = 120, Rounding = 0, Callback = function(v) Camera.FieldOfView = v end })
SkyboxGroup:AddToggle('ThirdPerson', {
    Text = 'Third Person View', Default = false,
    Callback = function(v)
        if v then LocalPlayer.CameraMaxZoomDistance = 15; LocalPlayer.CameraMinZoomDistance = 15
        else LocalPlayer.CameraMaxZoomDistance = 0.5; LocalPlayer.CameraMinZoomDistance = 0.5 end
    end
})

local Presets = {
    ["Purple Nebula"] = "rbxassetid://159454299",
    ["Night Sky"] = "rbxassetid://12064107",
    ["Pink Sunset"] = "rbxassetid://271042310",
    ["Vaporwave"] = "rbxassetid://1417494402"
}

SkyboxGroup:AddDropdown('SkyboxPresetDropdown', {
    Values = { 'Disable', 'Purple Nebula', 'Night Sky', 'Pink Sunset', 'Vaporwave' }, Default = 1, Text = 'Presets',
    Callback = function(Value)
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        if Value == 'Disable' then if sky then sky:Destroy() end
        elseif Presets[Value] then
            local id = Presets[Value]
            sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = id, id, id, id, id, id
        end
    end
})

-- ==========================================
-- 3. Misc 탭
-- ==========================================
local MovementGroup = Tabs.Misc:AddLeftGroupbox('Movement Hacks')
local flySpeed = 50
local walkSpeedValue = 16
local flyBodyVelocity, flyBodyGyro

MovementGroup:AddToggle('SpeedToggle', { Text = 'Speed Hack', Default = false })
MovementGroup:AddSlider('SpeedSlider', { Text = 'Walk Speed', Default = 16, Min = 16, Max = 200, Rounding = 0, Callback = function(v) walkSpeedValue = v end })
MovementGroup:AddToggle('InfJumpToggle', { Text = 'Infinite Jump (무한 점프)', Default = false })

UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJumpToggle and Toggles.InfJumpToggle.Value then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

MovementGroup:AddToggle('FlyToggle', {
    Text = 'Fly', Default = false,
    Callback = function(Value)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if Value and hrp then
            flyBodyVelocity = Instance.new("BodyVelocity", hrp)
            flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBodyGyro = Instance.new("BodyGyro", hrp)
            flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        else
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            if flyBodyGyro then flyBodyGyro:Destroy() end
        end
    end
})
MovementGroup:AddSlider('FlySpeedSlider', { Text = 'Fly Speed', Default = 50, Min = 10, Max = 300, Rounding = 0, Callback = function(v) flySpeed = v end })
MovementGroup:AddToggle('NoclipToggle', { Text = 'Noclip', Default = false })

-- Spinbot / Anti-Aim
local AntiAimGroup = Tabs.Misc:AddLeftGroupbox('Anti-Aim / Spinbot')
AntiAimGroup:AddToggle('SpinbotToggle', { Text = 'Enable Spinbot', Default = false })
AntiAimGroup:AddSlider('SpinSpeed', { Text = 'Spin Speed', Default = 20, Min = 1, Max = 100, Rounding = 0 })

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if Toggles.SpeedToggle and Toggles.SpeedToggle.Value and hum then hum.WalkSpeed = walkSpeedValue end
    if Toggles.NoclipToggle and Toggles.NoclipToggle.Value then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if Toggles.FlyToggle and Toggles.FlyToggle.Value and hrp and flyBodyVelocity and flyBodyGyro then
        local moveDir = hum and hum.MoveDirection or Vector3.zero
        local camCF = Camera.CFrame
        local flyDir = moveDir.Magnitude > 0 and (camCF:VectorToWorldSpace(camCF:WorldToSpace(moveDir))).Unit or Vector3.zero
        flyBodyVelocity.Velocity = flyDir * flySpeed
        flyBodyGyro.CFrame = camCF
    end
    if Toggles.SpinbotToggle and Toggles.SpinbotToggle.Value and hrp then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Options.SpinSpeed.Value), 0)
    end
end)

local DeviceGroup = Tabs.Misc:AddRightGroupbox('Device Spoofing')
local SetControlsRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Replication"):WaitForChild("Fighter"):WaitForChild("SetControls")

DeviceGroup:AddDropdown('DeviceDropdown', {
    Values = { 'PC (Mouse & Keyboard)', 'Mobile (Touch)', 'Controller (Gamepad)', 'VR' },
    Default = 1, Text = 'Device Spoof',
    Callback = function(Value)
        local TargetDevice = "MouseKeyboard"
        if Value:find("Mobile") then TargetDevice = "Touch"
        elseif Value:find("Controller") then TargetDevice = "Gamepad"
        elseif Value:find("VR") then TargetDevice = "VR" end
        SetControlsRemote:FireServer("MouseKeyboard")
        task.wait(0.1)
        SetControlsRemote:FireServer(TargetDevice)
    end
})

-- ==========================================
-- 4. ESP Render Engine
-- ==========================================
local espData = {}
local function addESP(p)
    if p == LocalPlayer then return end
    task.spawn(function()
        local box, hpBg, hpBar, hpText, nameText, distText, tracer, headDot
        pcall(function()
            if Drawing then
                box = Drawing.new("Square"); box.Visible = false; box.Color = Color3.new(1, 1, 1); box.Thickness = 1; box.Filled = false
                hpBg = Drawing.new("Square"); hpBg.Visible = false; hpBg.Color = Color3.new(0, 0, 0); hpBg.Thickness = 1; hpBg.Filled = true
                hpBar = Drawing.new("Square"); hpBar.Visible = false; hpBar.Color = Color3.new(0, 1, 0); hpBar.Thickness = 1; hpBar.Filled = true
                hpText = Drawing.new("Text"); hpText.Visible = false; hpText.Center = true; hpText.Outline = true; hpText.Color = Color3.new(1, 1, 1); hpText.Size = 13
                nameText = Drawing.new("Text"); nameText.Visible = false; nameText.Center = true; nameText.Outline = true; nameText.Color = Color3.new(1, 1, 1); nameText.Size = 13
                distText = Drawing.new("Text"); distText.Visible = false; distText.Center = true; distText.Outline = true; distText.Color = Color3.new(1, 1, 1); distText.Size = 13
                tracer = Drawing.new("Line"); tracer.Visible = false; tracer.Color = Color3.new(1, 1, 1); tracer.Thickness = 1
                headDot = Drawing.new("Circle"); headDot.Visible = false; headDot.Color = Color3.new(1, 0, 0); headDot.Radius = 4; headDot.Filled = true
            end
        end)
        
        if box then
            espData[p] = { Box = box, HpBg = hpBg, HealthBar = hpBar, HealthText = hpText, NameText = nameText, DistText = distText, Tracer = tracer, HeadDot = headDot, Skeleton = {} }
            local bones = {{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}}
            for _, b in pairs(bones) do 
                pcall(function() if Drawing then table.insert(espData[p].Skeleton, {b[1], b[2], Drawing.new("Line")}) end end) 
            end
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
Players.PlayerAdded:Connect(addESP)

local function IsToggleActive(toggleName)
    return Toggles and Toggles[toggleName] and Toggles[toggleName].Value == true
end

RunService.RenderStepped:Connect(function()
    for p, d in pairs(espData) do
        local isAlive = false
        local c = p.Character
        local root, head, rootPos, boxSize, boxPos, top, bottom, height, width
        
        if c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 and not isSameTeam(p) then
            root = c:FindFirstChild("HumanoidRootPart")
            head = c:FindFirstChild("Head")
            if root and head then
                local rPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    isAlive = true
                    rootPos = rPos
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    height = math.abs(headPos.Y - legPos.Y)
                    width = height * 0.6 
                    boxSize = Vector2.new(width, height)
                    boxPos = Vector2.new(rootPos.X - width / 2, headPos.Y)
                    top, bottom = {Y = headPos.Y}, {Y = legPos.Y}
                end
            end
        end
        
        if isAlive then
            if IsToggleActive("ESPBox") then d.Box.Size = boxSize; d.Box.Position = boxPos; d.Box.Visible = true else d.Box.Visible = false end
            if IsToggleActive("ESPName") then d.NameText.Text = p.Name; d.NameText.Position = Vector2.new(boxPos.X + width/2, top.Y - 15); d.NameText.Visible = true else d.NameText.Visible = false end
            if IsToggleActive("ESPDistance") then local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude); d.DistText.Text = dist .. "m"; d.DistText.Position = Vector2.new(boxPos.X + width/2, bottom.Y + 2); d.DistText.Visible = true else d.DistText.Visible = false end
            if IsToggleActive("ESPTracer") then d.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); d.Tracer.To = Vector2.new(rootPos.X, bottom.Y); d.Tracer.Visible = true else d.Tracer.Visible = false end
            
            if IsToggleActive("ESPHeadDot") and head then
                local hPos, hOnScreen = Camera:WorldToViewportPoint(head.Position)
                if hOnScreen then d.HeadDot.Position = Vector2.new(hPos.X, hPos.Y); d.HeadDot.Visible = true else d.HeadDot.Visible = false end
            else d.HeadDot.Visible = false end

            local highlight = c:FindFirstChild("AntiHubChams")
            if IsToggleActive("ESPChams") then
                if not highlight then
                    highlight = Instance.new("Highlight", c)
                    highlight.Name = "AntiHubChams"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                end
            elseif highlight then highlight:Destroy() end
        else
            d.Box.Visible = false; d.HpBg.Visible = false; d.HealthBar.Visible = false
            d.NameText.Visible = false; d.DistText.Visible = false; d.Tracer.Visible = false; d.HeadDot.Visible = false
        end
    end
end)

-- ==========================================
-- 5. TikTok 탭
-- ==========================================
local TikTokGroup = Tabs.TikTok:AddLeftGroupbox('TikTok Links')

local TikTokJihoBtn = TikTokGroup:AddButton('지호 틱톡 (링크 복사)', function()
    copyToClipboard("https://www.tiktok.com/@hacker_jiho15688?_r=1&_t=ZS-99j8xi7ogYG")
end)

local TikTokUserBtn = TikTokGroup:AddButton('유저 틱톡 (링크 복사)', function()
    copyToClipboard("https://www.tiktok.com/@user1223gg?_r=1&_t=ZS-99j8xyLK0bl")
end)

-- ==========================================
-- 6. Spoofers 탭 (TikTok 바로 옆)
-- ==========================================
local NameSpoofGroup = Tabs.Spoofers:AddLeftGroupbox('Name & Rank Spoofer')

NameSpoofGroup:AddInput('CustomNameInput', {
    Default = '', Finished = true, Text = '자유 닉네임 설정 (Name Spoof)', Placeholder = '원하는 이름 입력...',
    Callback = function(Value)
        getgenv().SpoofedName = Value
        if Value == '' then LocalPlayer.DisplayName = originalDisplayName end
    end
})

NameSpoofGroup:AddToggle('ArchNemesisToggle', {
    Text = '아크네메시스 티어 고정 (Arch-Nemesis Tier)',
    Default = false,
    Callback = function(Value)
        getgenv().ArchNemesisSpoof = Value
        if Value then
            applySpoofers()
            Library:Notify("아크네메시스 티어가 적용되었습니다! (데이터 안전 보장)")
        end
    end
})

NameSpoofGroup:AddButton('스푸퍼 즉시 재적용', function()
    applySpoofers()
    Library:Notify("스푸퍼 설정이 갱신되었습니다.")
end)

-- ==========================================
-- 7. Settings Configuration & Language Selector
-- ==========================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder('yourjiho')
SaveManager:SetFolder('yourjiho/Rivals')

local LanguageGroup = Tabs.Setting:AddLeftGroupbox('Language / 언어 설정')

local function changeLanguage(langName)
    local t = Translations[langName]
    if not t then return end
    
    Tabs.Main.TabButton.Text = t.MainTab
    Tabs.Visuals.TabButton.Text = t.VisualsTab
    Tabs.Misc.TabButton.Text = t.MiscTab
    Tabs.Setting.TabButton.Text = t.SettingTab
    Tabs.TikTok.TabButton.Text = t.TikTokTab
    Tabs.Spoofers.TabButton.Text = t.SpoofersTab or "Spoofers"

    MainGroup.Text = t.CombatGroup
    RageToggle:SetText(t.RagebotText)
    RageTargetPartDrop:SetText(t.RageTargetPartText)
    DesyncToggleObj:SetText(t.DesyncText)
    VoidSpamToggleObj:SetText(t.VoidSpamText)
    VoidHideSliderObj:SetText(t.VoidHideText)

    SkinGroup.Text = t.SkinGroup
    UnlockAllSkinsToggleObj:SetText(t.UnlockSkinsText)
    ForceUnlockBtn.Text = t.ForceSkinText

    HitboxGroup.Text = t.HitboxGroup
    HitboxToggleObj:SetText(t.HitboxToggle)
    HitboxSizeSliderObj:SetText(t.HitboxSize)
    HitboxTransSliderObj:SetText(t.HitboxTrans)

    AimbotGroup.Text = t.AimbotGroup
    AimbotToggleObj:SetText(t.AimbotToggle)
    ShowFOVToggleObj:SetText(t.ShowFOV)
    FOVSliderObj:SetText(t.FOVSize)
    TriggerbotToggleObj:SetText(t.Triggerbot)
    TriggerDelaySliderObj:SetText(t.TriggerDelay)

    KillSoundGroup.Text = t.KillSoundGroup
    KillSoundToggleObj:SetText(t.EnableKillSound)
    KillSoundDropObj:SetText(t.SoundPreset)
    CustomSoundInputObj:SetText(t.CustomSound)
    KillSoundVolSliderObj:SetText(t.Volume)

    TikTokJihoBtn.Text = t.CopyJihoTikTok
    TikTokUserBtn.Text = t.CopyUserTikTok
end

LanguageGroup:AddDropdown('LanguageDropdown', {
    Values = { '한국어', 'English' },
    Default = 1, Text = 'Select Language',
    Callback = function(Value) changeLanguage(Value) end
})

SaveManager:BuildConfigSection(Tabs.Setting)
ThemeManager:ApplyToTab(Tabs.Setting)
SaveManager:LoadAutoloadConfig()

-- ==========================================
-- 8. UI 투명화 실행 코드
-- ==========================================
task.spawn(function()
    task.wait(0.5)
    if Library and Library.Holder then
        for _, gui in ipairs(Library.Holder:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScrollingFrame") then
                if gui.BackgroundTransparency < 1 then gui.BackgroundTransparency = 0.8 end
            elseif gui:IsA("TextLabel") or gui:IsA("TextButton") then
                if gui.BackgroundTransparency < 1 then gui.BackgroundTransparency = 0.85 end
            end
        end
    end
end)
