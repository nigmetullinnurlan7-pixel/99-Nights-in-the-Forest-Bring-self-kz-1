--// ҚЫЗМЕТТЕР
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("RemoteEvents")

--// Items папкасын табу
local function getItemsFolder()
    return workspace:FindFirstChild("Items")
end

--// ҚАЙТАЛАНБАЙТЫН item атаулары (Dropdown үшін)
local function getUniqueItemNames()
    local folder = getItemsFolder()
    if not folder then return {} end

    local list = {}
    local seen = {}

    for _, item in ipairs(folder:GetChildren()) do
        if (item:IsA("Model") or item:IsA("BasePart")) and not seen[item.Name] then
            seen[item.Name] = true
            table.insert(list, item.Name)
        end
    end

    table.sort(list)
    return list
end

--// БІР АТАУДАҒЫ БАРЛЫҚ ITEM-ДІ ТАРТУ
local function bringAllByName(itemName)
    local folder = getItemsFolder()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (folder and root) then return end

    for _, item in ipairs(folder:GetChildren()) do
        if item.Name == itemName then
            remotes.RequestStartDraggingItem:FireServer(item)

            local cf = root.CFrame * CFrame.new(0, 0, -5)
            if item:IsA("Model") then
                item:PivotTo(cf)
            else
                item.CFrame = cf
            end

            task.wait(0.05)
            remotes.StopDraggingItem:FireServer(item)
            task.wait(0.03)
        end
    end
end

--// WINDUI ЖҮКТЕУ
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "Bring Hub Арыслан",
    Icon = "box",
    Author = "KZ"
})

--// TAB
local BringTab = Window:Tab({
    Title = "Заттарды тарту",
    Icon = "package",
    Locked = false
})

--// SECTION
BringTab:Section({
    Title = "workspace.Items ішіндегі заттар",
    Opened = true
})

--// DROPDOWN (бір атау, бірақ бәрін тартады)
local selectedItem = nil

local ItemDropdown = BringTab:Dropdown({
    Title = "Затты таңда",
    Desc = "Предмет выбыри",
    Values = getUniqueItemNames(),
    Value = nil,
    Multi = false,
    AllowNone = true,
    Callback = function(value)
        selectedItem = value
    end
})

--// ITEM ТІЗІМІН ЖАҢАРТУ
BringTab:Button({
    Title = "Заттарды жаңарту",
    Desc = "Предмет Обновить",
    Icon = "refresh-cw",
    Callback = function()
        ItemDropdown:SetValues(getUniqueItemNames())
    end
})

--// BRING ALL ТҮЙМЕСІ
BringTab:Button({
    Title = "Беру",
    Desc = "Дать",
    Icon = "arrow-down",
    Callback = function()
        if selectedItem then
            bringAllByName(selectedItem)
        end
    end
})
