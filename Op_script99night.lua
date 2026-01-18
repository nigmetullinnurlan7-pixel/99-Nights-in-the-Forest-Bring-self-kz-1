-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "Mind Pns [Buyer]",
    Desc = "99 Nights in the Forest 🔦",
    Icon = 109736955785576,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "Mind Pns"
    }
})

-- Sidebar Vertical Separator
local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0) -- adjust if needed
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui") -- Or Window.Gui if accessible

local Tab = Window:Tab({Title = "หาของ", Icon = "search"}) do
    -- Section
    Tab:Section({Title = "การสำรวจพื้นที่เพื่อหาไอเทมที่ซ่อนอยู่ หรือการค้นหาตำแหน่งของทรัพยากร"})

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local fileName = "MyConfig.json"

-- ตั้งค่าความเร็วการ Tween (ยิ่งตัวเลขเยอะยิ่งไว)
local TWEEN_SPEED = 300 

-- รายชื่อต้นไม้
local targetTreeNames = {
    ["Small Tree"] = true,
    ["Snowy Small Tree"] = true,
    ["Fairy Small Tree"] = true
}

_G.AutoFarmTree = false 

-- ฟังก์ชันหาต้นไม้ที่ใกล้ที่สุด
local function getClosestTree()
    local closestTree = nil
    local shortestDistance = math.huge
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local foliage = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Foliage")
    if foliage then
        for _, tree in pairs(foliage:GetChildren()) do
            if targetTreeNames[tree.Name] then
                -- หาตำแหน่งของต้นไม้
                local treePos = tree:IsA("Model") and tree:GetModelCFrame().Position or tree.Position
                local distance = (char.HumanoidRootPart.Position - treePos).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTree = tree
                end
            end
        end
    end
    return closestTree
end

-- ฟังก์ชัน Tween
local function tweenTo(targetCFrame)
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = distance / TWEEN_SPEED -- คำนวณเวลาตามระยะทางเพื่อให้ความเร็วคงที่
    
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = targetCFrame * CFrame.new(0, 5, 0)})
    
    tween:Play()
    return tween
end

-- ระบบ Save/Load
local function saveConfig(value)
    writefile(fileName, HttpService:JSONEncode({FeatureEnabled = value}))
end

local function loadConfig()
    if isfile(fileName) then
        local data = HttpService:JSONDecode(readfile(fileName))
        _G.AutoFarmTree = data.FeatureEnabled
        return data.FeatureEnabled
    end
    return false
end

-- ลูปการทำงานหลัก
local function startLoop()
    task.spawn(function()
        while _G.AutoFarmTree do
            local target = getClosestTree()
            
            if target then
                local targetCFrame = target:IsA("Model") and target:GetModelCFrame() or target.CFrame
                local tween = tweenTo(targetCFrame)
                
                if tween then
                    -- รอจนกว่าจะถึงเป้าหมาย หรือถ้ากดปิดก่อนให้หยุด Tween
                    local completed = false
                    local connection
                    connection = tween.Completed:Connect(function()
                        completed = true
                        connection:Disconnect()
                    end)
                    
                    while not completed and _G.AutoFarmTree do
                        task.wait(0.1)
                    end
                    
                    if not _G.AutoFarmTree then 
                        tween:Cancel() 
                        break 
                    end
                    
                    -- เมื่อถึงแล้ว พักแป๊บนึงก่อนไปต้นถัดไป
                    task.wait(0.5) 
                end
            else
                -- ถ้าไม่เจอต้นไม้เลย ให้รอสแกนใหม่
                task.wait(2)
            end
        end
    end)
end

-- เริ่มต้นใช้งาน
if loadConfig() then startLoop() end

Tab:Toggle({
    Title = "Auto Tween Trees (Closest)",
    Desc = "เคลื่อนที่ไปหาต้นไม้ที่ใกล้ที่สุดอัตโนมัติ",
    Value = _G.AutoFarmTree,
    Callback = function(v)
        _G.AutoFarmTree = v
        saveConfig(v)
        if v then startLoop() end
    end
})

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local inventory = player:WaitForChild("Inventory")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local fileName = "AutoChopConfig.json"

-- [1] ระบบจัดการไฟล์ Config
local function saveConfig(value)
    local data = {FeatureEnabled = value}
    if writefile then
        writefile(fileName, HttpService:JSONEncode(data))
    end
end

local function loadConfig()
    if isfile and isfile(fileName) then
        local status, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if status and data then
            return data.FeatureEnabled
        end
    end
    return false
end

-- [2] ตั้งค่าการทำงาน
local AutoChopEnabled = loadConfig()
local ATK_DISTANCE = 25          
local WAIT_TIME = 0.016          

-- รายชื่อต้นไม้ทั้งหมดที่ระบบจะตัด (เพิ่ม Snowy Small Tree แล้ว)
local TARGET_TREES = {
    ["Small Tree"] = true,
    ["Snowy Small Tree"] = true, -- เพิ่มใหม่
    ["FairyTreeBig2"] = true,
    ["FairyTreeBig1"] = true,
    ["Fairy Small Tree"] = true,
    ["TreeBig1"] = true,
    ["TreeBig2"] = true
}

local supportedTools = {
    "Old Axe", "Chainsaw", "Good Axe", "Ice Axe", "Strong Axe", 
    "Admin Axe", "Spear", "Morningstar", "Katana", "Laser Sword", 
    "Ice Sword", "Trident", "Poison Spear", "Infernal Sword", 
    "Cultist King Mace", "Obsidiron Hammer", "Scythe", "Vampire Scythe"
}

-- [3] สร้างเส้น Highlight สีแดง (SelectionBox)
local selectionBox = Instance.new("SelectionBox")
selectionBox.Name = "AutoChopHighlight"
selectionBox.Color3 = Color3.fromRGB(255, 0, 0)
selectionBox.LineThickness = 0.05
selectionBox.Parent = player:WaitForChild("PlayerGui")

-- [4] ฟังก์ชันการทำงานหลัก
local function getMyTool()
    local character = player.Character
    if not character then return nil end
    for _, toolName in pairs(supportedTools) do
        local tool = character:FindFirstChild(toolName) or inventory:FindFirstChild(toolName)
        if tool then return tool end
    end
    return nil
end

local function chopTree(targetTree, tool)
    local hitID = "3_3962714290"
    local hitCFrame = targetTree:IsA("BasePart") and targetTree.CFrame or targetTree:GetModelCFrame()
    pcall(function()
        remoteEvents:WaitForChild("ToolDamageObject"):InvokeServer(targetTree, tool, hitID, hitCFrame)
    end)
    remoteEvents:WaitForChild("PlayEnemyHitSound"):FireServer("FireAllClients", targetTree, tool)
end

-- [5] เชื่อมต่อกับ UI Toggle
Tab:Toggle({
    Title = "Enable Auto Chop",
    Desc = "ตัดไม้ทุกชนิด (รวมโซนหิมะและ Fairy) พร้อมเซฟค่า",
    Value = AutoChopEnabled,
    Callback = function(v)
        AutoChopEnabled = v
        saveConfig(v)
        if not v then selectionBox.Adornee = nil end
    end
})

-- [6] ลูปการทำงาน (Background Task)
task.spawn(function()
    while true do
        if AutoChopEnabled then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local currentTool = getMyTool()
            local foliageFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Foliage")

            local currentTarget = nil

            if rootPart and currentTool and foliageFolder then
                for _, object in pairs(foliageFolder:GetChildren()) do
                    -- ตรวจสอบว่าชื่อต้นไม้ตรงกับในรายการหรือไม่
                    if TARGET_TREES[object.Name] then
                        local targetPos = (object:IsA("BasePart") and object.Position) or (object:IsA("Model") and object.PrimaryPart and object.PrimaryPart.Position)
                        
                        if targetPos then
                            local distance = (targetPos - rootPart.Position).Magnitude
                            if distance <= ATK_DISTANCE then
                                currentTarget = object
                                chopTree(object, currentTool)
                            end
                        end
                    end
                end
            end
            -- อัปเดตเส้นสีแดงรอบต้นไม้ที่กำลังตัด
            selectionBox.Adornee = currentTarget
        else
            selectionBox.Adornee = nil
        end
        task.wait(WAIT_TIME)
    end
end)

local HttpService = game:GetService("HttpService")
local fileName = "BringFuelConfig.json"

-- --- ระบบ Save/Load ---
local function saveConfig(value)
    local data = {BringEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.BringEnabled
        end
    end
    return false
end

-- ตัวแปรควบคุม
local BringEnabled = loadConfig()
-- เปลี่ยนรายชื่อไอเทมที่นี่
local targetNames = {"Coal", "Fuel Canister", "Oil Barrel"}

-- --- ตั้งค่าตัวแปรหลัก ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")

-- --- ส่วนของ UI Toggle ---
Tab:Toggle({
    Title = "Auto Bring (Fuel & Coal)",
    Desc = "ดึงถ่านและเชื้อเพลิงมาไว้ข้างหน้าอัตโนมัติ",
    Value = BringEnabled,
    Callback = function(v)
        BringEnabled = v
        print("สถานะการดึงเชื้อเพลิง:", v)
        saveConfig(v)
    end
})

-- --- ฟังก์ชันหลักในการดึงของ (Bring Logic) ---
local function processBring()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(itemsFolder:GetChildren()) do
        if BringEnabled then
            local isTarget = false
            for _, name in pairs(targetNames) do
                if item.Name == name then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                -- [1] เริ่มลาก
                remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(item)

                -- [2] วาร์ปมาข้างหน้า (ระยะ 5 หน่วย)
                local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                if item:IsA("Model") then
                    item:PivotTo(targetCFrame)
                elseif item:IsA("BasePart") then
                    item.CFrame = targetCFrame
                end

                task.wait(0.05) -- รอซิงค์ตำแหน่ง

                -- [3] หยุดลาก (ปล่อยของ)
                remoteEvents:WaitForChild("StopDraggingItem"):FireServer(item)
                
                task.wait(0.05) -- หน่วงเวลาเล็กน้อยระหว่างชิ้น
            end
        else
            break
        end
    end
end

-- --- Loop การทำงานทำงานเบื้องหลัง ---
task.spawn(function()
    while true do
        if BringEnabled then
            processBring() 
        end
        task.wait(1) -- ตรวจสอบหาของใหม่ทุกๆ 1 วินาที
    end
end)
local HttpService = game:GetService("HttpService")
local fileName = "BringScrapConfig.json"

-- --- ระบบ Save/Load ---
local function saveConfig(value)
    local data = {BringEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.BringEnabled
        end
    end
    return false
end

-- ตัวแปรควบคุม
local BringEnabled = loadConfig()
-- รายชื่อไอเทมกลุ่มใหม่ (Scrap/Metal)
local targetNames = {
    "Broken Fan",
    "Bolt",
    "Broken Microwave",
    "Metal Chair",
    "Sheet Metal",
    "Washing Machine",
    "Old Car Engine",
    "Tyre",
    "Old Radio"
	
}

-- --- ตั้งค่าตัวแปรหลัก ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")

-- --- ส่วนของ UI Toggle ---
Tab:Toggle({
    Title = "Auto Bring (Scrap & Parts)",
    Desc = "ดึงขยะโลหะและอะไหล่รถมาไว้ข้างหน้าอัตโนมัติ",
    Value = BringEnabled,
    Callback = function(v)
        BringEnabled = v
        print("สถานะการดึงขยะโลหะ:", v)
        saveConfig(v)
    end
})

-- --- ฟังก์ชันหลักในการดึงของ (Bring Logic) ---
local function processBring()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(itemsFolder:GetChildren()) do
        if BringEnabled then
            local isTarget = false
            for _, name in pairs(targetNames) do
                if item.Name == name then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                -- [1] เริ่มลาก
                remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(item)

                -- [2] วาร์ปมาข้างหน้า (ระยะ 5 หน่วย)
                local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                if item:IsA("Model") then
                    item:PivotTo(targetCFrame)
                elseif item:IsA("BasePart") then
                    item.CFrame = targetCFrame
                end

                -- หน่วงเวลาเล็กน้อยให้ระบบฟิสิกส์รับรู้
                task.wait(0.05) 

                -- [3] หยุดลาก (ปล่อยของ)
                remoteEvents:WaitForChild("StopDraggingItem"):FireServer(item)
                
                -- เว้นระยะเล็กน้อยก่อนดึงชิ้นต่อไปเพื่อความปลอดภัย
                task.wait(0.05)
            end
        else
            break
        end
    end
end

-- --- Loop การทำงานทำงานเบื้องหลัง ---
task.spawn(function()
    while true do
        if BringEnabled then
            processBring() 
        end
        -- ตรวจสอบของใหม่ทุกๆ 1 วินาที
        task.wait(1) 
    end
end)
local HttpService = game:GetService("HttpService")
local fileName = "BringItemsConfig.json"

-- --- ระบบ Save/Load ---
local function saveConfig(value)
    local data = {BringEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.BringEnabled
        end
    end
    return false
end

-- ตัวแปรควบคุม
local BringEnabled = loadConfig()
local targetNames = {"Chair", "Log"}

-- --- ตั้งค่าตัวแปรหลัก ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")

-- --- ส่วนของ UI Toggle ---
Tab:Toggle({
    Title = "Auto Bring (Chair & Log)",
    Desc = "ดึงเก้าอี้และไม้มาไว้ข้างหน้าอัตโนมัติ (วนลูปเรื่อยๆ)",
    Value = BringEnabled,
    Callback = function(v)
        BringEnabled = v
        print("สถานะการดึงของ:", v)
        saveConfig(v)
    end
})

-- --- ฟังก์ชันหลักในการดึงของ (Bring Logic) ---
local function processBring()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(itemsFolder:GetChildren()) do
        -- เช็คว่า Toggle เปิดอยู่ และชื่อไอเทมตรงกับที่ระบุหรือไม่
        if BringEnabled then
            local isTarget = false
            for _, name in pairs(targetNames) do
                if item.Name == name then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                -- [1] เริ่มลาก
                remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(item)

                -- [2] วาร์ปมาข้างหน้า (ระยะ 5 หน่วย)
                local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                if item:IsA("Model") then
                    item:PivotTo(targetCFrame)
                elseif item:IsA("BasePart") then
                    item.CFrame = targetCFrame
                end

                task.wait(0.05) -- รอซิงค์ตำแหน่ง

                -- [3] หยุดลาก (ปล่อยของ)
                remoteEvents:WaitForChild("StopDraggingItem"):FireServer(item)
                
                -- หน่วงเวลาเล็กน้อยระหว่างชิ้น
                task.wait(0.05)
            end
        else
            -- ถ้า Toggle ถูกปิดระหว่างการวนลูป ให้หยุดทันที
            break
        end
    end
end

-- --- Loop การทำงานทำงานเบื้องหลัง ---
task.spawn(function()
    while true do
        if BringEnabled then
            processBring() -- ทำการดึงของที่มีอยู่ทั้งหมดในโฟลเดอร์ขณะนั้น
        end
        -- รอ 1 วินาทีก่อนตรวจสอบโฟลเดอร์ Items อีกรอบ (ป้องกันการสแปมหนักเกินไป)
        task.wait(1) 
    end
end)
local HttpService = game:GetService("HttpService")
local fileName = "SaplingConfig.json" -- เปลี่ยนชื่อไฟล์เก็บค่า Config ให้ตรงกับงาน

-- --- ระบบ Save/Load ---
local function saveConfig(value)
    local data = {BringEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.BringEnabled
        end
    end
    return false
end

-- ตัวแปรควบคุม
local BringEnabled = loadConfig()
local targetNames = {"Sapling"} -- เปลี่ยนเป้าหมายเป็น Sapling

-- --- ตั้งค่าตัวแปรหลัก ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")

-- --- ส่วนของ UI Toggle ---
-- หมายเหตุ: ตรวจสอบว่าตัวแปร 'Tab' ของคุณถูกประกาศไว้ก่อนหน้านี้แล้ว
Tab:Toggle({
    Title = "Auto Bring (Sapling)",
    Desc = "ดึงหน่อไม้ (Sapling) มาไว้ข้างหน้าอัตโนมัติ",
    Value = BringEnabled,
    Callback = function(v)
        BringEnabled = v
        print("สถานะการดึง Sapling:", v)
        saveConfig(v)
    end
})

-- --- ฟังก์ชันหลักในการดึงของ (Bring Logic) ---
local function processBring()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(itemsFolder:GetChildren()) do
        -- เช็คว่า Toggle เปิดอยู่ และชื่อไอเทมตรงกับ "Sapling" หรือไม่
        if BringEnabled then
            local isTarget = false
            for _, name in pairs(targetNames) do
                if item.Name == name then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                -- [1] เริ่มลาก
                remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(item)

                -- [2] วาร์ปมาข้างหน้า (ระยะ 5 หน่วย)
                local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                if item:IsA("Model") then
                    item:PivotTo(targetCFrame)
                elseif item:IsA("BasePart") then
                    item.CFrame = targetCFrame
                end

                task.wait(0.05) -- รอซิงค์ตำแหน่ง

                -- [3] หยุดลาก (ปล่อยของ)
                remoteEvents:WaitForChild("StopDraggingItem"):FireServer(item)
                
                -- หน่วงเวลาเล็กน้อยระหว่างชิ้น
                task.wait(0.05)
            end
        else
            -- ถ้า Toggle ถูกปิดระหว่างการวนลูป ให้หยุดทันที
            break
        end
    end
end

-- --- Loop การทำงานเบื้องหลัง ---
task.spawn(function()
    while true do
        if BringEnabled then
            processBring() 
        end
        -- รอ 1 วินาทีก่อนตรวจสอบรอบใหม่
        task.wait(1) 
    end
end)

local HttpService = game:GetService("HttpService")
local fileName = "BringWeaponsConfig.json"

-- --- ระบบ Save/Load ---
local function saveConfig(value)
    local data = {BringEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.BringEnabled
        end
    end
    return false
end

-- ตัวแปรควบคุม
local BringEnabled = loadConfig()
-- รายชื่ออาวุธและกระสุนกลุ่มใหม่
local targetNames = {
    "Revolver",
    "Revolver Ammo",
    "Rifle",
    "Rifle Ammo",
    "Kunai",
    "Tactical Shotgun",
    "Wildfire",
    "Spear",
    "Morningstar",
    "Katana",
    "Laser Sword",
    "Ice Sword",
    "Trident",
    "Poison Spear",
    "Infernal Sword",
    "Cultist King Mace",
    "Obsidiron Hammer",
    "Scythe",
    "Vampire Scythe"
}

-- --- ตั้งค่าตัวแปรหลัก ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")

-- --- ส่วนของ UI Toggle ---
Tab:Toggle({
    Title = "Auto Bring (Weapons & Ammo)",
    Desc = "ดึงอาวุธและกระสุนหายากมาไว้ข้างหน้าอัตโนมัติ",
    Value = BringEnabled,
    Callback = function(v)
        BringEnabled = v
        print("สถานะการดึงอาวุธ:", v)
        saveConfig(v)
    end
})

-- --- ฟังก์ชันหลักในการดึงของ (Bring Logic) ---
local function processBring()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(itemsFolder:GetChildren()) do
        if BringEnabled then
            local isTarget = false
            for _, name in pairs(targetNames) do
                if item.Name == name then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                -- [1] เริ่มลาก
                remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(item)

                -- [2] วาร์ปมาข้างหน้า (ระยะ 5 หน่วย)
                local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                if item:IsA("Model") then
                    item:PivotTo(targetCFrame)
                elseif item:IsA("BasePart") then
                    item.CFrame = targetCFrame
                end

                task.wait(0.05) 

                -- [3] หยุดลาก (ปล่อยของ)
                remoteEvents:WaitForChild("StopDraggingItem"):FireServer(item)
                
                task.wait(0.05)
            end
        else
            break
        end
    end
end

-- --- Loop การทำงานทำงานเบื้องหลัง ---
task.spawn(function()
    while true do
        if BringEnabled then
            processBring() 
        end
        task.wait(1) -- ตรวจสอบหาอาวุธใหม่ทุกๆ 1 วินาที
    end
end)
local HttpService = game:GetService("HttpService")
local fileName = "BringEquipmentConfig.json"

-- --- ระบบ Save/Load ---
local function saveConfig(value)
    local data = {BringEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.BringEnabled
        end
    end
    return false
end

-- ตัวแปรควบคุม
local BringEnabled = loadConfig()

-- รายชื่ออุปกรณ์และถุงไอเทมกลุ่มใหม่
local targetNames = {
    "Giant Sack",
    "Good Sack",
    "Infernal Sack",
    "Iron Body",
    "Good Axe",
    "Ice Axe",
    "Strong Axe",
    "Admin Axe",
    "Thorn Body",
    "Alien Armour",
    "Vampire Cloakr", -- ใส่ตามที่คุณพิมพ์มา (มี r ต่อท้าย)
    "Obsidiron Body"
}

-- --- ตั้งค่าตัวแปรหลัก ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")

-- --- ส่วนของ UI Toggle ---
Tab:Toggle({
    Title = "Auto Bring (Equipment & Sacks)",
    Desc = "ดึงชุดเกราะ, ขวาน และถุงไอเทมหายากมาไว้ข้างหน้า",
    Value = BringEnabled,
    Callback = function(v)
        BringEnabled = v
        print("สถานะการดึงอุปกรณ์:", v)
        saveConfig(v)
    end
})

-- --- ฟังก์ชันหลักในการดึงของ (Bring Logic) ---
local function processBring()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(itemsFolder:GetChildren()) do
        if BringEnabled then
            local isTarget = false
            for _, name in pairs(targetNames) do
                if item.Name == name then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                -- [1] เริ่มลาก
                remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(item)

                -- [2] วาร์ปมาข้างหน้า (ระยะ 5 หน่วย)
                local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                if item:IsA("Model") then
                    item:PivotTo(targetCFrame)
                elseif item:IsA("BasePart") then
                    item.CFrame = targetCFrame
                end

                task.wait(0.05) 

                -- [3] หยุดลาก (ปล่อยของ)
                remoteEvents:WaitForChild("StopDraggingItem"):FireServer(item)
                
                task.wait(0.05)
            end
        else
            break
        end
    end
end

-- --- Loop การทำงานทำงานเบื้องหลัง ---
task.spawn(function()
    while true do
        if BringEnabled then
            processBring() 
        end
        task.wait(1) -- ตรวจสอบหาของใหม่ทุกๆ 1 วินาที
    end
end)
local HttpService = game:GetService("HttpService")
local fileName = "BringMedicalConfig.json"

-- --- ระบบ Save/Load ---
local function saveConfig(value)
    local data = {BringEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.BringEnabled
        end
    end
    return false
end

-- ตัวแปรควบคุม
local BringEnabled = loadConfig()
-- รายชื่อไอเทมกลุ่มยารักษา
local targetNames = {
    "Bandage",
    "MedKit"
}

-- --- ตั้งค่าตัวแปรหลัก ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")

-- --- ส่วนของ UI Toggle ---
Tab:Toggle({
    Title = "Auto Bring (Medical)",
    Desc = "ดึงผ้าพันแผลและกล่องยามาไว้ข้างหน้าอัตโนมัติ",
    Value = BringEnabled,
    Callback = function(v)
        BringEnabled = v
        print("สถานะการดึงยารักษา:", v)
        saveConfig(v)
    end
})

-- --- ฟังก์ชันหลักในการดึงของ (Bring Logic) ---
local function processBring()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(itemsFolder:GetChildren()) do
        if BringEnabled then
            local isTarget = false
            for _, name in pairs(targetNames) do
                if item.Name == name then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                -- [1] เริ่มลาก
                remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(item)

                -- [2] วาร์ปมาข้างหน้า (ระยะ 5 หน่วย)
                local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                if item:IsA("Model") then
                    item:PivotTo(targetCFrame)
                elseif item:IsA("BasePart") then
                    item.CFrame = targetCFrame
                end

                task.wait(0.05) 

                -- [3] หยุดลาก (ปล่อยของ)
                remoteEvents:WaitForChild("StopDraggingItem"):FireServer(item)
                
                task.wait(0.05) -- หน่วงเวลาเล็กน้อยระหว่างชิ้น
            end
        else
            break
        end
    end
end

-- --- Loop การทำงานทำงานเบื้องหลัง ---
task.spawn(function()
    while true do
        if BringEnabled then
            processBring() 
        end
        task.wait(1) -- ตรวจสอบหาของใหม่ทุกๆ 1 วินาที
    end
end)


local HttpService = game:GetService("HttpService")
local fileName = "BringGemsConfig.json"

-- --- ระบบ Save/Load ---
local function saveConfig(value)
    local data = {BringEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.BringEnabled
        end
    end
    return false
end

-- ตัวแปรควบคุม
local BringEnabled = loadConfig()
-- รายชื่ออัญมณีหายาก
local targetNames = {
    "Cultist Gem",
    "Gem of the Forest Fragment"
}

-- --- ตั้งค่าตัวแปรหลัก ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")

-- --- ส่วนของ UI Toggle ---
Tab:Toggle({
    Title = "Auto Bring (Rare Gems)",
    Desc = "ดึงอัญมณี Cultist และเศษเสี้ยวอัญมณีป่ามาไว้ข้างหน้า",
    Value = BringEnabled,
    Callback = function(v)
        BringEnabled = v
        print("สถานะการดึงอัญมณี:", v)
        saveConfig(v)
    end
})

-- --- ฟังก์ชันหลักในการดึงของ (Bring Logic) ---
local function processBring()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(itemsFolder:GetChildren()) do
        if BringEnabled then
            local isTarget = false
            for _, name in pairs(targetNames) do
                if item.Name == name then
                    isTarget = true
                    break
                end
            end

            if isTarget then
                -- [1] เริ่มลาก
                remoteEvents:WaitForChild("RequestStartDraggingItem"):FireServer(item)

                -- [2] วาร์ปมาข้างหน้า (ระยะ 5 หน่วย)
                local targetCFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                if item:IsA("Model") then
                    item:PivotTo(targetCFrame)
                elseif item:IsA("BasePart") then
                    item.CFrame = targetCFrame
                end

                task.wait(0.05) 

                -- [3] หยุดลาก (ปล่อยของ)
                remoteEvents:WaitForChild("StopDraggingItem"):FireServer(item)
                
                task.wait(0.05) -- หน่วงเวลาเล็กน้อยระหว่างชิ้น
            end
        else
            break
        end
    end
end

-- --- Loop การทำงานเบื้องหลัง ---
task.spawn(function()
    while true do
        if BringEnabled then
            processBring() 
        end
        task.wait(1) -- ตรวจสอบหาของใหม่ทุกๆ 1 วินาที
    end
end)






















local Tab = Window:Tab({Title = "หาสิ่งมีชีวิต", Icon = "user"}) 
    -- Section
    Tab:Section({Title = "รายละเอียดเชิงลึก หรือประวัติการเล่นของตัวละครนั้น"})







local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local fileName = "MyScriptConfig.json"

local _G_Config = {
    FlyEnabled = false,
    SpeedValue = 25
}

-- [ฟังก์ชัน Save/Load]
local function SaveConfig()
    local success, json = pcall(function() return HttpService:JSONEncode(_G_Config) end)
    if success then writefile(fileName, json) end
end

local function LoadConfig()
    if isfile(fileName) then
        local success, content = pcall(function() return readfile(fileName) end)
        if success then
            local data = HttpService:JSONDecode(content)
            _G_Config.FlyEnabled = data.FlyEnabled or false
            _G_Config.SpeedValue = data.SpeedValue or 25
        end
    end
end

LoadConfig()

-- --- [ ระบบ Mobile UI ] --- --
local mobileUp = false
local mobileDown = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyControlGui"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local function createFlyButton(name, text, pos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.5
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 20
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = screenGui
    
    -- ลากมุมมน
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    -- เช็คการกด (รองรับทั้งนิ้วสัมผัสและเมาส์)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if name == "Up" then mobileUp = true else mobileDown = true end
            btn.BackgroundTransparency = 0.2
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if name == "Up" then mobileUp = false else mobileDown = false end
            btn.BackgroundTransparency = 0.5
        end
    end)
end

-- สร้างปุ่ม Up และ Down (ตำแหน่งจะอยู่แถวๆ ปุ่มกระโดดของมือถือ)
createFlyButton("Up", "▲", UDim2.new(0.85, -70, 0.7, -70))
createFlyButton("Down", "▼", UDim2.new(0.85, -70, 0.7, 10))

-- --- [ ระบบบิน ] --- --
local flyConnection
local flying = false

local function toggleFly(state)
    flying = state
    screenGui.Enabled = state -- เปิด/ปิด ปุ่มบนหน้าจอตามสถานะบิน
    
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if flying then
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "FlyGyro"
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = root.CFrame
        
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyVelocity"
        bv.velocity = Vector3.new(0, 0.1, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        
        if hum then hum.PlatformStand = true end
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying or not root or not hum then return end
            
            local moveDir = hum.MoveDirection 
            local verticalMove = 0
            
            -- บินขึ้น: กด Space (PC) หรือ ปุ่มกระโดดมือถือ หรือ ปุ่ม Up ที่สร้างใหม่
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump or mobileUp then
                verticalMove = 1
            -- บินลง: กด LeftControl (PC) หรือ ปุ่ม Down ที่สร้างใหม่
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or mobileDown then
                verticalMove = -1
            end
            
            root.FlyGyro.cframe = camera.CFrame
            
            if moveDir.Magnitude > 0 or verticalMove ~= 0 then
                local finalVec = (moveDir * _G_Config.SpeedValue) + Vector3.new(0, verticalMove * _G_Config.SpeedValue, 0)
                root.FlyVelocity.velocity = finalVec
            else
                root.FlyVelocity.velocity = Vector3.new(0, 0.1, 0)
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        if hum then hum.PlatformStand = false end
        mobileUp = false
        mobileDown = false
    end
end

-- --- [ UI Tab Setup ] --- --
Tab:Toggle({
    Title = "Enable Fly",
    Desc = "เปิดโหมดบิน (มีปุ่มสำหรับมือถือ)",
    Value = _G_Config.FlyEnabled,
    Callback = function(v)
        _G_Config.FlyEnabled = v
        SaveConfig()
        toggleFly(v)
    end
})

Tab:Slider({
    Title = "Fly Speed",
    Min = 10,
    Max = 300,
    Rounding = 0,
    Value = _G_Config.SpeedValue,
    Callback = function(val)
        _G_Config.SpeedValue = val
        SaveConfig()
    end
})

lp.CharacterAdded:Connect(function()
    task.wait(0.5)
    if _G_Config.FlyEnabled then toggleFly(true) end
end)

if _G_Config.FlyEnabled then
    task.spawn(function()
        task.wait(1)
        toggleFly(true)
    end)
end
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local fileName = "MySpeedConfig.json"

-- 1. สร้างตารางสำหรับเก็บค่า Config (สถานะเปิด/ปิด และ ความเร็ว)
local _G_Config = {
    SpeedEnabled = false,
    SpeedValue = 16 -- ค่าเริ่มต้นของ Roblox คือ 16
}

-- 2. ฟังก์ชันสำหรับบันทึกค่า (Save)
local function SaveConfig()
    local success, json = pcall(function()
        return HttpService:JSONEncode(_G_Config)
    end)
    if success then
        writefile(fileName, json)
    end
end

-- 3. ฟังก์ชันสำหรับโหลดค่า (Load)
local function LoadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            _G_Config.SpeedEnabled = data.SpeedEnabled or false
            _G_Config.SpeedValue = data.SpeedValue or 16
        end
    end
end

-- เรียกโหลดค่าก่อนเริ่ม
LoadConfig()

-- 4. ระบบ Loop เพื่อบังคับความเร็ว (ป้องกันเกมดึงค่ากลับ)
RunService.Stepped:Connect(function()
    if _G_Config.SpeedEnabled then
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = _G_Config.SpeedValue
        end
    end
end)

-- 5. ส่วนของ UI (Toggle และ Slider)
-- Toggle: เปิด/ปิด การใช้งานวิ่งเร็ว
Tab:Toggle({
    Title = "Enable Speed",
    Desc = "เปิดใช้งานวิ่งเร็ว",
    Value = _G_Config.SpeedEnabled,
    Callback = function(v)
        _G_Config.SpeedEnabled = v
        SaveConfig()
        
        -- ถ้าปิดการใช้งาน ให้คืนค่าความเร็วกลับเป็นปกติ (16)
        if not v then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

-- Slider: ปรับระดับความเร็ว
Tab:Slider({
    Title = "Run Speed",
    Min = 16,
    Max = 300, -- ปรับค่าสูงสุดได้ตามต้องการ
    Rounding = 0,
    Value = _G_Config.SpeedValue,
    Callback = function(val)
        _G_Config.SpeedValue = val
        SaveConfig()
    end
})

-- จัดการกรณีตัวละครเกิดใหม่ (Reset)
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if _G_Config.SpeedEnabled then
        humanoid.WalkSpeed = _G_Config.SpeedValue
    end
end)

local HttpService = game:GetService("HttpService")
local fileName = "RescueWarpConfig.json"

-- 1. รายชื่อเป้าหมายที่คุณต้องการ (เฉพาะกลุ่มนี้เท่านั้น)
local RescueList = {
    "Lost Child", "Lost Child2", "Lost Child3", "Lost Child4",
    "Alpha Wolf", "Bat", "Bear", "Bunny",
    "Crossbow Cultist", "Cultist", "Frog",
    "FrogBlue", "FrogPurple", "Scorpion", "Wolf",
    "Arctic Fox", "Kiwi", "Mammoth", "Meteor Crab",
    "Pelt Trader"
}

-- 2. โครงสร้าง Config
local Config = {
    SelectedTargets = {},
    AutoWarpEnabled = false
}

-- 3. ฟังก์ชัน Save/Load Config
local function SaveConfig()
    writefile(fileName, HttpService:JSONEncode(Config))
end

local function LoadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and type(data) == "table" then
            Config.SelectedTargets = data.SelectedTargets or {}
            Config.AutoWarpEnabled = data.AutoWarpEnabled or false
        end
    end
end

LoadConfig()

-- 4. ลูปวาร์ปตัวเราไปหาเป้าหมาย (Auto Warp)
task.spawn(function()
    while true do
        if Config.AutoWarpEnabled then
            local player = game.Players.LocalPlayer
            local character = player.Character
            local charFolder = workspace:FindFirstChild("Characters")

            if character and character:FindFirstChild("HumanoidRootPart") and charFolder then
                -- ค้นหาตัวละครเป้าหมายในโฟลเดอร์ Characters
                for _, target in pairs(charFolder:GetChildren()) do
                    -- ตรวจสอบว่าชื่อตรงกับที่เราเลือกในลิสต์หรือไม่
                    if table.find(Config.SelectedTargets, target.Name) then
                        -- วาร์ปตัวเราไปหาเป้าหมาย (ใช้ตำแหน่งปัจจุบันของเป้าหมาย)
                        if target:IsA("Model") then
                            character:PivotTo(target:GetPivot())
                            break -- วาร์ปไปหาทีละตัว (เพื่อความปลอดภัย)
                        elseif target:IsA("BasePart") then
                            character:PivotTo(target.CFrame)
                            break
                        end
                    end
                end
            end
        end
        task.wait(0.8) -- ปรับเวลาหน่วงการวาร์ป (วินาที) ยิ่งมากยิ่งปลอดภัย
    end
end)

-- 5. ส่วนของ UI

-- ปุ่มวาร์ปไปจุดเฉพาะ (CFrame ที่คุณกำหนด)
Tab:Button({
    Title = "วาร์ปไปจุดเซฟ (Warp to Custom Point)",
    Description = "วาร์ปไปยังพิกัดพิกัดเฉพาะทันที",
    Callback = function()
        local character = game.Players.LocalPlayer.Character
        if character then
            local targetCFrame = CFrame.new(-0.11, 4.00, -6.21) * CFrame.Angles(-3.14, -0.10, -3.14)
            character:PivotTo(targetCFrame)
            print("Warped to target point!")
        end
    end
})

-- Dropdown เลือกรายชื่อที่จะวาร์ปไปหา
Tab:Dropdown({
    Title = "เลือกเป้าหมายที่จะวาร์ปไปหา",
    List = RescueList,
    Multi = true,
    Default = Config.SelectedTargets,
    Callback = function(selected_table)
        Config.SelectedTargets = selected_table
        SaveConfig()
    end
})

-- Toggle เปิด/ปิด ระบบวาร์ปอัตโนมัติ
Tab:Toggle({
    Title = "เปิดระบบวาร์ปอัตโนมัติ",
    Desc = "วาร์ปตัวเราไปหาเป้าหมายที่เลือกใน Characters",
    Value = Config.AutoWarpEnabled,
    Callback = function(v)
        Config.AutoWarpEnabled = v
        SaveConfig()
        print("Auto Warp Status:", v)
    end
})
local Tab = Window:Tab({Title = "โจมตี", Icon = "axe"}) 
    -- Section
    Tab:Section({Title = "การโจมตีที่เน้นความรุนแรงและพลังทำลาย"})

local HttpService = game:GetService("HttpService")
local fileName = "KillAuraConfig.json"

-- [[ CONFIGURATION ]] --
local AttackRange = 100 -- ปรับระยะตามใจชอบ (1000 คือไกลมาก)
local KillAuraEnabled = false 

local TARGETS_LIST = {
    "Bunny", "Alpha Wolf", "Arctic Fox", "Bat", "Bear", 
    "Crossbow Cultist", "Cultist", "Polar Bear", "Wolf",
    "Alien", "Juggernaut Cultist", "Cultist King", 
    "Scorpion", "Hellephant", "Meteor Crab", "Shadow Cultist",
    "Brute Cultist", "Mammoth", "The Deer", "The Owl", 
    "The Ram", "The Bat", "Alien Elite", "Mossy Wolf", "Frog", "FrogBlue"
	, "FrogPurple"
}

local WEAPONS_LIST = {
    "Old Axe", "Chainsaw", "Good Axe", "Ice Axe", "Strong Axe", 
    "Admin Axe", "Spear", "Morningstar", "Katana", "Laser Sword", 
    "Ice Sword", "Trident", "Poison Spear", "Infernal Sword", 
    "Cultist King Mace", "Obsidiron Hammer", "Scythe", "Vampire Scythe"
}

-- [[ ฟังก์ชันจัดการ CONFIG ]] --
local function saveConfig(value)
    local data = {KillAuraEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.KillAuraEnabled
        end
    end
    return false
end

KillAuraEnabled = loadConfig()

-- [[ SERVICES & REMOTES ]] --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = game:GetService("Players").LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

-- [[ ฟังก์ชันช่วยเหลือ ]] --
local function getWeapon()
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    local inv = LP:FindFirstChild("Inventory")
    for _, name in pairs(WEAPONS_LIST) do
        if char and char:FindFirstChild(name) then return char[name] end
        if bp and bp:FindFirstChild(name) then return bp[name] end
        if inv and inv:FindFirstChild(name) then return inv[name] end
    end
    return nil
end

-- [[ ระบบ KILL AURA (MAX RANGE) ]] --
task.spawn(function()
    while true do
        if KillAuraEnabled then
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local weapon = getWeapon()
            local folder = workspace:FindFirstChild("Characters")

            if root and weapon and folder then
                for _, target in pairs(folder:GetChildren()) do
                    -- ตรวจสอบว่าเป็นศัตรูหรือไม่
                    local isEnemy = false
                    for _, n in pairs(TARGETS_LIST) do
                        if string.find(target.Name, n) then 
                            isEnemy = true 
                            break 
                        end
                    end

                    if isEnemy then
                        local t_humanoid = target:FindFirstChildOfClass("Humanoid")
                        local t_root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")

                        if t_humanoid and t_humanoid.Health > 0 and t_root then
                            -- ตรวจสอบระยะทาง (ใช้ตัวแปร AttackRange)
                            if (root.Position - t_root.Position).Magnitude <= AttackRange then
                                task.spawn(function()
                                    pcall(function()
                                        -- 1. ทำดาเมจ (ส่งตำแหน่ง CFrame ของเป้าหมายไปด้วยเพื่อให้เซิร์ฟเวอร์ยอมรับ)
                                        RemoteEvents.ToolDamageObject:InvokeServer(target, weapon, "1_3962714290", t_root.CFrame)
                                        -- 2. เอฟเฟกต์เสียง
                                        RemoteEvents.PlayEnemyHitSound:FireServer("FireAllClients", target, weapon)
                                        RemoteEvents.RequestReplicateSound:FireServer("FireAllClients", "WeaponHit", {Instance = t_root, Volume = 0.4})
                                    end)
                                end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.05) -- ปรับให้ไวขึ้นจาก 0.1 เป็น 0.05
    end
end)

-- [[ UI TOGGLE ]] --
-- หมายเหตุ: ส่วนของ Tab:Toggle ต้องใช้ร่วมกับ Library ที่คุณมีอยู่เดิม
Tab:Toggle({
    Title = "Enable Kill Aura (Max Range)",
    Desc = "โจมตีศัตรูรอบตัวในระยะไกลมากอัตโนมัติ",
    Value = KillAuraEnabled, 
    Callback = function(v)
        KillAuraEnabled = v
        saveConfig(v)
        warn("Kill Aura is now: " .. (v and "ON" or "OFF") .. " | Range: " .. AttackRange)
    end
})

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local players = game:GetService("Players")
local lp = players.LocalPlayer

local fileName = "CultistTeleportConfig.json"
local teleportConn -- ตัวแปรเก็บการเชื่อมต่อ loop

-- ตั้งค่าการวาร์ป
local TARGET_NAMES = {"Cultist", "Crossbow Cultist"}
local HEIGHT = 50 
local DODGE_SPEED = 12
local DODGE_DISTANCE = 15

-- ฟังก์ชันเซฟ
local function saveConfig(value)
    local data = {FeatureEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

-- ฟังก์ชันโหลด
local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.FeatureEnabled
        end
    end
    return false
end

-- ฟังก์ชันค้นหาเป้าหมาย
local function findTarget()
    local folder = workspace:FindFirstChild("Characters")
    if not folder then return nil end
    for _, child in pairs(folder:GetChildren()) do
        if table.find(TARGET_NAMES, child.Name) then
            local hum = child:FindFirstChildOfClass("Humanoid")
            local hrp = child:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                return hrp, hum
            end
        end
    end
    return nil
end

-- ฟังก์ชันจัดการการวาร์ป (Start/Stop)
local function toggleTeleport(enable)
    if enable then
        -- ถ้ามีการทำงานค้างอยู่ให้ปิดก่อนป้องกัน Loop ซ้อน
        if teleportConn then teleportConn:Disconnect() end
        
        teleportConn = RunService.Heartbeat:Connect(function()
            local hrp, hum = findTarget()
            local myChar = lp.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if hrp and hum and myRoot then
                -- คำนวณการหลบซ้ายขวา
                local sideMovement = math.sin(tick() * DODGE_SPEED) * DODGE_DISTANCE
                local targetCFrame = hrp.CFrame * CFrame.new(sideMovement, HEIGHT, 0)
                
                myChar:PivotTo(targetCFrame)
            end
        end)
    else
        -- ถ้ากดปิด ให้ยกเลิกการเชื่อมต่อ Loop
        if teleportConn then
            teleportConn:Disconnect()
            teleportConn = nil
        end
    end
end

-- ส่วนของ UI Toggle
Tab:Toggle({
    Title = "Auto TP & Dodge (Cultist)",
    Desc = "วาร์ปเหนือหัว 50 studs และขยับซ้ายขวาหลบการโจมตี",
    Value = loadConfig(), -- ดึงค่าเริ่มต้นจากไฟล์
    Callback = function(v)
        print("Feature Enabled:", v)
        saveConfig(v)      -- เซฟค่าลงไฟล์
        toggleTeleport(v)  -- เริ่มหรือหยุดการวาร์ป
    end
})

-- ตรวจสอบค่าเริ่มต้นตอนรันสคริปต์ครั้งแรก (Auto run if config is true)
if loadConfig() then
    toggleTeleport(true)
end
local Tab = Window:Tab({Title = "กิน", Icon = "utensils"}) 
    -- Section
    Tab:Section({Title = "เมนูหลักสำหรับการกินอาหารเพื่อฟื้นฟูค่าพลังงาน"})


local HttpService = game:GetService("HttpService")
local fileName = "AutoEatConfig.json"

-- --- ส่วนของระบบ Save/Load ---
local function saveConfig(value)
    local data = {AutoEatEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.AutoEatEnabled
        end
    end
    return false -- ค่าเริ่มต้นถ้าไม่มีไฟล์
end

-- ตัวแปรควบคุมการทำงาน
local AutoEatEnabled = loadConfig()

-- --- ตั้งค่าตัวแปรเบื้องต้น ---
local player = game:GetService("Players").LocalPlayer
local remoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
local foodNames = {
    "Apple", "Berry", "Cake", "Carrot", "Corn", "Pumpkin", 
     "Cooked Morsel", "Ribs", "Cooked Ribs", 
    "Chilli", "Stew", "Hearty Stew", "Meat? Sandwich", 
    "Seafood Chowder", "Steak Dinner", "Pumpkin Soup", 
    "BBQ Ribs", "Carrot Cake", "Jar o' Jelly", "Candy Apple", 
    "Candy Corn", "Pumpkin Pie", "Cotton Candy"
}

-- --- ฟังก์ชันช่วย (Helper Functions) ---
local function findFood()
    for _, item in pairs(workspace.Items:GetChildren()) do
        for _, name in pairs(foodNames) do
            if item.Name == name then return item end
        end
    end
    return nil
end

-- --- เพิ่ม Toggle ใน UI ของคุณ ---
Tab:Toggle({
    Title = "Auto Eat Food",
    Desc = "กินอาหารอัตโนมัติเมื่อหิว (เช็คที่ 0.93)",
    Value = AutoEatEnabled,
    Callback = function(v)
        AutoEatEnabled = v
        print("Auto Eat สถานะ:", v)
        saveConfig(v)
    end
})

-- --- Loop หลัก (ทำงานแยกส่วนเพื่อไม่ให้ UI ค้าง) ---
task.spawn(function()
    while true do
        if AutoEatEnabled then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local hungerBar = player.PlayerGui:FindFirstChild("Interface", true) 
                and player.PlayerGui.Interface.StatBars.HungerBar.Bar

            -- ตรวจสอบแถบความหิว
            if hungerBar and hungerBar.Size.X.Scale <= 0.93599999 then
                local target = findFood()
                
                if target and rootPart then
                    -- เริ่มกระบวนการกิน
                    remoteEvents.RequestStartDraggingItem:FireServer(target)
                    
                    -- Bring: ดึงมาข้างหน้า
                    if target:IsA("Model") then
                        target:PivotTo(rootPart.CFrame * CFrame.new(0, 0, -3))
                    else
                        target.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
                    end
                    
                    task.wait(0.1)
                    
                    -- เสียงกิน
                    remoteEvents.RequestReplicateSound:FireServer("FireAllClients", "Eat", {
                        Instance = character:FindFirstChild("Head"),
                        Volume = 0.15
                    })
                    
                    -- ส่งคำสั่งกิน
                    remoteEvents.RequestConsumeItem:InvokeServer(target)
                    
                    -- หยุดดึง
                    remoteEvents.StopDraggingItem:FireServer(target)
                    
                    task.wait(1) -- หน่วงเวลาระหว่างคำสั่ง
                end
            end
        end
        task.wait(1) -- ตรวจสอบความหิวทุกๆ 1 วินาที
    end
end)


local Tab = Window:Tab({Title = "ปลูก", Icon = "sprout"}) 
    -- Section
    Tab:Section({Title = "การนำเมล็ดลงดินเพื่อให้ต้นไม้ออกยอด"})


local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local fileName = "ProPlantingConfig_v2.json"

-- 1. ตารางเก็บค่า Config
local _G_Config = {
    VisualizerEnabled = false,
    PlantRadius = 20,
    Frequency = 10,
    SelectedShape = "Circle"
}

-- 2. ฟังก์ชัน Save/Load
local function SaveConfig()
    writefile(fileName, HttpService:JSONEncode(_G_Config))
end

local function LoadConfig()
    if isfile(fileName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
        if success then 
            _G_Config = data 
        end
    end
end
LoadConfig()

-- 3. ฟังก์ชันคำนวณตำแหน่งตามรูปทรง
local function GetPlantingPoints(centerCFrame, radius, amount, shape)
    local points = {}
    for i = 1, amount do
        local pos = Vector3.new(0, 0, 0)
        
        if shape == "Circle" then
            local angle = (i / amount) * (math.pi * 2)
            pos = Vector3.new(math.cos(angle) * radius, -2.5, math.sin(angle) * radius)
            
        elseif shape == "Square" then
            local sideCount = math.ceil(amount / 4)
            local side = math.floor((i-1) / sideCount)
            local progress = ((i-1) % sideCount) / sideCount
            local offset = (progress * 2 - 1) * radius
            if side == 0 then pos = Vector3.new(radius, -2.5, offset)
            elseif side == 1 then pos = Vector3.new(-offset, -2.5, radius)
            elseif side == 2 then pos = Vector3.new(-radius, -2.5, -offset)
            else pos = Vector3.new(offset, -2.5, -radius) end
            
        elseif shape == "Triangle" then
            local sideCount = math.ceil(amount / 3)
            local side = math.floor((i-1) / sideCount)
            local progress = ((i-1) % sideCount) / sideCount
            if side == 0 then
                pos = Vector3.new((progress * 2 - 1) * radius, -2.5, radius)
            elseif side == 1 then
                pos = Vector3.new(radius - (progress * radius), -2.5, radius - (progress * radius * 2))
            else
                pos = Vector3.new(0 - (progress * radius), -2.5, -radius + (progress * radius * 2))
            end

        elseif shape == "Line" then
            local spacing = (radius * 2) / amount
            pos = Vector3.new(0, -2.5, (i * spacing) - radius)
        end
        
        table.insert(points, (centerCFrame * CFrame.new(pos)).Position)
    end
    return points
end

-- 4. ระบบแสดงจุดมาร์ค (Visualizer) - เปลี่ยนเป็นสีดำ
local dotFolder = Instance.new("Folder", workspace)
dotFolder.Name = "PlantingDots"

RunService.RenderStepped:Connect(function()
    dotFolder:ClearAllChildren()
    local Character = game.Players.LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    
    if RootPart and _G_Config.VisualizerEnabled then
        local points = GetPlantingPoints(RootPart.CFrame, _G_Config.PlantRadius, _G_Config.Frequency, _G_Config.SelectedShape)
        for _, p in pairs(points) do
            local dot = Instance.new("Part")
            dot.Size = Vector3.new(0.8, 0.8, 0.8)
            dot.Shape = Enum.PartType.Ball
            -- [ เปลี่ยนเป็นสีดำที่นี่ ] --
            dot.Color = Color3.fromRGB(0, 0, 0) -- สีดำสนิท
            dot.Material = Enum.Material.SmoothPlastic 
            --------------------------
            dot.Anchored = true
            dot.CanCollide = false
            dot.CastShadow = false
            dot.Transparency = 0.2 -- ปรับให้ออกเข้มๆ ชัดๆ
            dot.Position = p
            dot.Parent = dotFolder
        end
    end
end)

--- [ ส่วนของ UI ] ---

Tab:Toggle({
    Title = "Show Markers (แสดงจุดปลูก)",
    Desc = "เปิดเพื่อดูจุดสีดำบอกพิกัดปลูก",
    Value = _G_Config.VisualizerEnabled,
    Callback = function(v)
        _G_Config.VisualizerEnabled = v
        SaveConfig()
    end
})

Tab:Dropdown({
    Title = "Select Shape (เลือกรูปทรง)",
    List = {"Circle", "Square", "Triangle", "Line"},
    Value = _G_Config.SelectedShape,
    Callback = function(choice)
        _G_Config.SelectedShape = choice
        SaveConfig()
    end
})

Tab:Slider({
    Title = "Amount/Frequency (จำนวนต้น)",
    Min = 1,
    Max = 100,
    Rounding = 0,
    Value = _G_Config.Frequency,
    Callback = function(val)
        _G_Config.Frequency = val
        SaveConfig()
    end
})

Tab:Slider({
    Title = "Radius/Size (ขนาด)",
    Min = 5,
    Max = 200,
    Rounding = 0,
    Value = _G_Config.PlantRadius,
    Callback = function(val)
        _G_Config.PlantRadius = val
        SaveConfig()
    end
})

Tab:Button({
    Title = "Run Multi-Shape Planting",
    Desc = "เริ่มปลูกตามรูปทรงที่เลือก",
    Callback = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Remotes = ReplicatedStorage:WaitForChild("RemoteEvents")
        local ItemsFolder = workspace:FindFirstChild("Items")
        local Player = game.Players.LocalPlayer
        local RootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

        if not ItemsFolder or not RootPart then return end

        local allSaplings = {}
        for _, v in pairs(ItemsFolder:GetChildren()) do
            if v.Name == "Sapling" then table.insert(allSaplings, v) end
        end

        if #allSaplings < _G_Config.Frequency then
            Window:Notify({
                Title = "Error", 
                Desc = "Sapling ไม่พอ! (มี " .. #allSaplings .. " ขาดอีก " .. (_G_Config.Frequency - #allSaplings) .. ")", 
                Time = 3
            })
            return
        end

        local points = GetPlantingPoints(RootPart.CFrame, _G_Config.PlantRadius, _G_Config.Frequency, _G_Config.SelectedShape)

        for i = 1, _G_Config.Frequency do
            local item = allSaplings[i]
            local plantPos = points[i]

            item:PivotTo(RootPart.CFrame * CFrame.new(0, 0, -3))
            task.wait(0.1)
            Remotes:WaitForChild("RequestStartDraggingItem"):FireServer(item)
            task.wait(0.1)
            Remotes:WaitForChild("RequestPlantItem"):InvokeServer(item, plantPos)
            task.wait(0.1)
            Remotes:WaitForChild("StopDraggingItem"):FireServer(item)
        end

        Window:Notify({Title = "Done", Desc = "ปลูกรูปทรง " .. _G_Config.SelectedShape .. " สำเร็จ", Time = 3})
    end
})
local Tab = Window:Tab({Title = "กล่อง", Icon = "box"}) 
    -- Section
    Tab:Section({Title = "กล่องเก็บของทั่วไปที่ใช้สำหรับเก็บไอเทมหรือวัตถุดิบ"})

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fileName = "ChestConfig.json"

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- รายชื่อกล่องที่อนุญาต
local targetNames = {
    ["Item Chest"] = true, ["Item Chest2"] = true, ["Item Chest3"] = true, 
    ["Item Chest4"] = true, ["Item Chest5"] = true, ["Item Chest6"] = true, 
    ["Volcanic Chest1"] = true, ["Volcanic Chest2"] = true, 
    ["Snow Chest1"] = true, ["Snow Chest2"] = true, ["Alien Chest"] = true
	, ["Stronghold Diamond Chest"] = true
}

-- ตารางสำหรับจำกล่องที่เปิดไปแล้ว (ป้องกันการดึงซ้ำ)
local openedChests = {}

-- ฟังก์ชันเซฟ/โหลด Config
local function saveConfig(value)
    local data = {FeatureEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then return data.FeatureEnabled end
    end
    return false
end

_G.AutoBringOpen = loadConfig()

-- ฟังก์ชันจัดการกล่อง (ดึงมาและเปิด)
local function processChest(chest, index)
    if not chest or openedChests[chest] then return end
    
    local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("RequestOpenItemChest")
    if not remoteEvent then return end

    -- ทำเครื่องหมายว่าเปิดแล้ว
    openedChests[chest] = true

    -- คำนวณตำแหน่งหน้ากระดาน (ใช้ index ช่วยเรียง)
    local spacing = 4
    local distanceFromPlayer = 7
    local xOffset = ((index - 1) % 5 - 2) * spacing -- เรียงแถวละ 5 ใบ
    local zOffset = -distanceFromPlayer - (math.floor((index - 1) / 5) * spacing)
    
    local targetCFrame = rootPart.CFrame * CFrame.new(xOffset, 0, zOffset)

    -- ดึงมาหา
    if chest:IsA("Model") then
        chest:PivotTo(targetCFrame)
    elseif chest:IsA("BasePart") then
        chest.CFrame = targetCFrame
    end

    task.wait(0.2) -- รอให้เซิร์ฟเวอร์รู้ว่ากล่องย้ายมาแล้ว
    remoteEvent:FireServer(chest)
end

-- ลูปหลักสำหรับตรวจสอบกล่องใหม่ๆ
task.spawn(function()
    while true do
        if _G.AutoBringOpen then
            local itemsFolder = workspace:FindFirstChild("Items")
            if itemsFolder then
                local currentBatch = {}
                -- สแกนหากล่องที่ยังไม่ได้เปิด
                for _, item in pairs(itemsFolder:GetChildren()) do
                    if targetNames[item.Name] and not openedChests[item] then
                        table.insert(currentBatch, item)
                    end
                end

                -- ถ้าเจอรายชื่อใหม่ ให้จัดการทีละใบ
                for i, chest in ipairs(currentBatch) do
                    if not _G.AutoBringOpen then break end
                    processChest(chest, i)
                    task.wait(0.1)
                end
            end
        end
        task.wait(1) -- ตรวจสอบกล่องใหม่ทุกๆ 1 วินาที
    end
end)

-- UI Toggle
Tab:Toggle({
    Title = "Auto Farm All Chests",
    Desc = "ดึงกล่องใหม่ที่เกิดมาเรียงหน้ากระดานและเปิดทันที",
    Value = _G.AutoBringOpen,
    Callback = function(v)
        _G.AutoBringOpen = v
        saveConfig(v)
        if v then
            -- ล้างประวัติกล่องเก่าเพื่อให้สแกนใหม่ทั้งหมดตอนกดเปิด
            openedChests = {}
            print("เริ่มระบบ Auto Farm")
        else
            print("ปิดระบบ Auto Farm")
        end
    end
})

local Tab = Window:Tab({Title = "ดึงสิ่งมีชีวิต", Icon = "hand"}) 
    -- Section
    Tab:Section({Title = "การยื่นมือออกไปคว้าสิ่งมีชีวิตแล้วดึงเข้ามา"})

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local fileName = "CultistConfig.json"

-- ค้นหา Remote
local remoteFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
local startRemote = remoteFolder:WaitForChild("RequestStartDraggingItem")
local stopRemote = remoteFolder:WaitForChild("StopDraggingItem")
local itemsFolder = workspace:WaitForChild("Items")

-- ตั้งค่าชื่อที่ต้องการดึง
local targetNames = {
    ["Cultist"] = true,
    ["Crossbow Cultist"] = true
}

-- ตัวแปรควบคุมสถานะ
local autoPullEnabled = false

-- ฟังก์ชันเซฟ Config
local function saveConfig(value)
    local data = {FeatureEnabled = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

-- ฟังก์ชันโหลด Config
local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data then
            return data.FeatureEnabled
        end
    end
    return false
end

-- เริ่มต้นค่าจากไฟล์
autoPullEnabled = loadConfig()

-- ลูปหลัก (ทำงานเบื้องหลัง)
task.spawn(function()
    while true do
        if autoPullEnabled then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if rootPart then
                local items = itemsFolder:GetChildren()
                
                for _, item in ipairs(items) do
                    -- ตรวจสอบว่าต้องเปิดใช้งานอยู่ และชื่อตรงตามที่กำหนด
                    if not autoPullEnabled then break end
                    
                    if targetNames[item.Name] then
                        -- 1. ดึงมาข้างหน้า
                        local targetPos = rootPart.CFrame * CFrame.new(0, 0, -5)
                        if item:IsA("Model") then
                            item:PivotTo(targetPos)
                        elseif item:IsA("BasePart") then
                            item.CFrame = targetPos
                        end

                        task.wait(0.1)

                        -- 2. จับ
                        startRemote:FireServer(item)
                        task.wait(0.2)

                        -- 3. ปล่อย
                        stopRemote:FireServer(item)
                        task.wait(0.05)
                    end
                end
            end
        end
        -- รอ 1 วินาทีก่อนเริ่มรอบใหม่ (ตามที่คุณต้องการ)
        task.wait(1)
    end
end)

-- ส่วนของ UI Toggle
Tab:Toggle({
    Title = "Auto Pull Cultists",
    Desc = "ดึงและจับ Cultist อัตโนมัติ (Save ข้ามเซิร์ฟ)",
    Value = autoPullEnabled,
    Callback = function(v)
        autoPullEnabled = v -- เปลี่ยนสถานะการทำงาน
        saveConfig(v)       -- เซฟลงไฟล์ JSON
        print("Auto Pull Status:", v)
    end
})

local Tab = Window:Tab({Title = "พัก", Icon = "moon"}) 
    -- Section
    Tab:Section({Title = "แปลตรงตัวจาก AFK สื่อว่าตอนนี้ไม่ได้เฝ้าจอแล้วนะ ถ้าทักมาหรือเรียกอะไรอาจจะไม่ตอบ"})
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local fileName = "MyConfig.json"

-- ตัวแปรควบคุมสถานะ Anti-AFK
local AntiAFK_Enabled = false

-- ฟังก์ชันเซฟ
local function saveConfig(value)
    local data = {AntiAFK = value}
    writefile(fileName, HttpService:JSONEncode(data))
end

-- ฟังก์ชันโหลด
local function loadConfig()
    if isfile(fileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if success and data.AntiAFK ~= nil then
            return data.AntiAFK
        end
    end
    return false
end

-- ตั้งค่าสถานะเริ่มต้นจากการโหลดไฟล์
AntiAFK_Enabled = loadConfig()

-- ### ส่วนของ Logic Anti-AFK ###
Players.LocalPlayer.Idled:Connect(function()
    if AntiAFK_Enabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("Anti-AFK: ประทำการป้องกันการหลุด (Anti-Kick performed)")
    end
end)

-- ### ส่วนของ UI Toggle ###
Tab:Toggle({
    Title = "เปิดใช้งานระบบกันหลุด",
    Desc = "ป้องกันการถูกเตะออกจากการเข้าเกมค้างไว้นานๆ",
    Value = AntiAFK_Enabled, -- ใช้ค่าที่โหลดมาจากไฟล์
    Callback = function(v)
        AntiAFK_Enabled = v -- อัปเดตสถานะตัวแปร
        saveConfig(v) -- เซฟค่าลงไฟล์ JSON
        print("Anti-AFK Status:", v)
    end
})
Window:Notify({
    Title = "Mind Pns",
    Desc = "ปลดล็อกขีดจำกัดระบบ... ผมพร้อมแล้ว แล้วคุณล่ะครับ?",
    Time = 10
})

end