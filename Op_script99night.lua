-- BriAry Style Splash Screen

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SplashScreen"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- Background
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(10,10,10)
bg.Parent = gui

-- Logo
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0,300,0,100)
logo.Position = UDim2.new(0.5,-150,0.4,-50)
logo.BackgroundTransparency = 1
logo.Text = "BriAry"
logo.TextColor3 = Color3.fromRGB(255,255,255)
logo.TextScaled = true
logo.Font = Enum.Font.GothamBold
logo.Parent = bg

-- Loading text
local loading = Instance.new("TextLabel")
loading.Size = UDim2.new(0,200,0,50)
loading.Position = UDim2.new(0.5,-100,0.6,0)
loading.BackgroundTransparency = 1
loading.Text = "Loading..."
loading.TextColor3 = Color3.fromRGB(180,180,180)
loading.TextScaled = true
loading.Font = Enum.Font.Gotham
loading.Parent = bg

-- Loading bar background
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.4,0,0,6)
barBg.Position = UDim2.new(0.3,0,0.7,0)
barBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
barBg.BorderSizePixel = 0
barBg.Parent = bg

-- Loading bar fill
local bar = Instance.new("Frame")
bar.Size = UDim2.new(0,0,1,0)
bar.BackgroundColor3 = Color3.fromRGB(0,255,120)
bar.BorderSizePixel = 0
bar.Parent = barBg

-- Tween loading
local tween = TweenService:Create(bar, TweenInfo.new(3, Enum.EasingStyle.Quad), {
    Size = UDim2.new(1,0,1,0)
})

tween:Play()

-- Fade out after loading
tween.Completed:Wait()

wait(0.5)

local fade = TweenService:Create(bg, TweenInfo.new(1), {
    BackgroundTransparency = 1
})

fade:Play()

for _,v in pairs(bg:GetDescendants()) do
    if v:IsA("TextLabel") or v:IsA("Frame") then
        TweenService:Create(v, TweenInfo.new(1), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
    end
end

wait(1)
gui:Destroy()


--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("RemoteEvents")

--// FIND ALL ITEMS BY NAME (ALL COPIES)
local function findAllByName(parent, name, out)
    out = out or {}
    for _, obj in ipairs(parent:GetChildren()) do
        if obj.Name == name and (obj:IsA("BasePart") or obj:IsA("Model")) then
            table.insert(out, obj)
        end
        if #obj:GetChildren() > 0 then
            findAllByName(obj, name, out)
        end
    end
    return out
end

--// FULL CATEGORIES
local Categories = {
    Fuel = {"Log","Chair","Biofuel","Coal","Purple Fur Tuft","Fuel Canister","Oil Barrel"},
    Ammo = {"Revolver Ammo","Rifle Ammo","Shotgun Ammo"},
    Scrap = {"Bolt","Sheet Metal","UFO Junk","UFO Component","Broken Fan","Old Radio","Gears","Broken Microwave","Tyre","Metal Chair","Old Car Engine","Washing Machine","Cultist Experiment","Cultist Prototype","UFO Scrap"},
    Food = {"Carrot","Corn","Pumpkin","Berry","Apple","Morsel","Cooked Morsel","Steak","Cooked Steak","Ribs","Cooked Ribs","Cake","Chili","Stew","Hearty Stew","Meat Sandwich","Seafood Chowder","Steak Dinner","Pumpkin Soup","BBQ Ribs","Carrot Cake","Jar o' Jelly","Candy Apple","Candy Corn","Pumpkin Pie","Cotton Candy","Turkey Leg","Cooked Turkey Leg","Stuffing","Sweet Potato","Turkey Legs","Berry Juice","Casserole","Corn on the Cob","Stuffing Bowl","Roast Turkey","Stuffed Peppers","Sweet Potato Pie","Spicy Swordfish","Hearty Thanksgiving Meal"},
    Fish = {"Mackerel","Cooked Mackerel","Salmon","Cooked Salmon","Clownfish","Cooked Clownfish","Jellyfish","Char","Cooked Char","Eel","Cooked Eel","Swordfish","Cooked Swordfish","Shark","Cooked Shark","Lava Eel","Cooked Lava Eel","Lionfish","Cooked Lionfish"},
    Seeds = {"Chili Seeds","Flower Seeds","Berry Seeds","Firefly Seeds","Dripleaf Seeds","Moonflower Seeds","Stareweed Seeds","Cavevine Seeds","Mandrake Seeds"},
    WeaponsMelee = {"Spear","Morningstar","Katana","Laser Sword","Ice Sword","Trident","Poison Spear","Infernal Sword","Cultist King Mace","Obsidiron Hammer","Scythe","Vampire Scythe"},
    WeaponsRanged = {"Revolver","Rifle","Tactical Shotgun","Snowball","Frozen Shuriken","Kunai","Ray Gun","Laser Cannon","Flamethrower","Blowpipe","Admin Gun","Friendly Gun","Crossbow","Wildfire","Infernal Crossbow","Witch Potion","Bouncing Blade","Air Rifle"},
    Armor = {"Leather Body","Poison Armor","Iron Body","Thorn Body","Riot Shield","Alien Armor","Obsidiron Body","Vampire Cloak"},
    Warm = {"Earmuffs","Beanie","Arctic Fox Hat","Polar Bear Hat","Mammoth Helmet"},
    Boots = {"Frog Boots","Obsidiron Boots"},
    Pelts = {"Bunny Foot","Wolf Pelt","Alpha Wolf Pelt","Bear Pelt","Arctic Fox Pelt","Polar Bear Pelt","Mammoth Tusk","Scorpion Shell","Cultist King Antler"},
    Keys = {"Red Key","Blue Key","Yellow Key","Grey Key","Frog Key"},
    Materials = {"Wood","Scrap","Cultist Gem","Forest Gem","Forest Gem Fragment","Mossy Coin","Flower","Sapling","Sacrifice Totem","Meteor Shard","Gold Shard","Raw Obsidiron Ore","Raw Obsidiron Ore (Shard)","Scalding Obsidiron Ingot","Obsidiron Ingot","Obsidiron Crystals"},
    Healing = {"Bandage","Medkit","Cake","Hearty Stew","BBQ Ribs","Carrot Cake","Jar o' Jelly"},
    Anvils = {"Anvil Front","Anvil Back","Anvil Base","Meteor Anvil Front","Meteor Anvil Back","Meteor Anvil Base"},
    Potions = {"Dripleaf","Moonflower Bulb","Stareweed Petal","Cave Vine Flower","Mandrake"},
    Blueprints = {"Crafting Blueprint","Defense Blueprint","Furniture Blueprint","Obsidiron Chest Blueprint","Halloween Blueprint"},
    Tools = {"Hammer","Paint Brush"},
    Corpses = {"Cultist Corpse","Crossbow Cultist Corpse","Juggernaut Cultist Corpse","Cultist King Corpse","Alien Corpse","Elite Alien Corpse","Wolf Corpse","Alpha Wolf Corpse","Bear Corpse"},
}

--// BRING CORE (NO LIMIT)
local function bringList(list)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, name in ipairs(list) do
        local found = findAllByName(workspace.Items, name)
        for _, item in ipairs(found) do
            remotes.RequestStartDraggingItem:FireServer(item)
            if item:IsA("Model") then
                item:PivotTo(root.CFrame * CFrame.new(0,0,-5))
            else
                item.CFrame = root.CFrame * CFrame.new(0,0,-5)
            end
            remotes.StopDraggingItem:FireServer(item)
        end
    end
end

--// WINDUI
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "99 Nights | ULTRA BRING",
    Icon = "package",
    Author = "FULL UI"
})

--// UI TABS
for category, items in pairs(Categories) do
    local Tab = Window:Tab({ Title = category, Icon = "box" })
    Tab:Section({ Title = category.." Items", Opened = true })

    local selected = {}

    Tab:Dropdown({
        Title = "Select "..category,
        Desc = "Multi-select | brings ALL copies",
        Values = items,
        Multi = true,
        AllowNone = true,
        Callback = function(v) selected = v end
    })

    Tab:Button({
        Title = "🚀 Bring Selected",
        Callback = function() bringList(selected) end
    })

    Tab:Button({
        Title = "💥 Bring ALL "..category,
        Callback = function() bringList(items) end
    })
end

--// MASTER TAB
do
    local T = Window:Tab({ Title = "ALL", Icon = "zap" })
    T:Button({
        Title = "🔥 BRING EVERYTHING",
        Callback = function()
            for _, list in pairs(Categories) do
                bringList(list)
            end
        end
    })
end
