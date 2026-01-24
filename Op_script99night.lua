--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("RemoteEvents")

--// Рекурсивный поиск предмета по имени
local function findItemByName(parent, name)
    for _, obj in ipairs(parent:GetChildren()) do
        if obj.Name == name then
            return obj
        elseif #obj:GetChildren() > 0 then
            local found = findItemByName(obj, name)
            if found then return found end
        end
    end
end

--// FULL ITEMS CATEGORIES
local Categories = {
    ["Fuel"] = {"Log","Chair","Biofuel","Coal","Purple Fur Tuft","Fuel Canister","Oil Barrel"},
    ["Ammo"] = {"Revolver Ammo","Rifle Ammo","Shotgun Ammo"},
    ["Scrap"] = {"Bolt","Sheet Metal","UFO Junk","UFO Component","Broken Fan","Old Radio","Gears","Broken Microwave","Tyre","Metal Chair","Old Car Engine","Washing Machine","Cultist Experiment","Cultist Prototype","UFO Scrap"},
    ["Food"] = {"Carrot","Corn","Pumpkin","Berry","Apple","Morsel","Cooked Morsel","Steak","Cooked Steak","Ribs","Cooked Ribs","Cake","Chili","Stew","Hearty Stew","Meat Sandwich","Seafood Chowder","Steak Dinner","Pumpkin Soup","BBQ Ribs","Carrot Cake","Jar o' Jelly","Candy Apple","Candy Corn","Pumpkin Pie","Cotton Candy","Turkey Leg","Cooked Turkey Leg","Stuffing","Sweet Potato","Turkey Legs","Berry Juice","Casserole","Corn on the Cob","Stuffing Bowl","Roast Turkey","Stuffed Peppers","Sweet Potato Pie","Spicy Swordfish","Hearty Thanksgiving Meal"},
    ["Fish"] = {"Mackerel","Cooked Mackerel","Salmon","Cooked Salmon","Clownfish","Cooked Clownfish","Jellyfish","Char","Cooked Char","Eel","Cooked Eel","Swordfish","Cooked Swordfish","Shark","Cooked Shark","Lava Eel","Cooked Lava Eel","Lionfish","Cooked Lionfish"},
    ["Seeds"] = {"Chili Seeds","Flower Seeds","Berry Seeds","Firefly Seeds","Dripleaf Seeds","Moonflower Seeds","Stareweed Seeds","Cavevine Seeds","Mandrake Seeds"},
    ["Weapons Melee"] = {"Spear","Morningstar","Katana","Laser Sword","Ice Sword","Trident","Poison Spear","Infernal Sword","Cultist King Mace","Obsidiron Hammer","Scythe","Vampire Scythe"},
    ["Weapons Ranged"] = {"Revolver","Rifle","Tactical Shotgun","Snowball","Frozen Shuriken","Kunai","Ray Gun","Laser Cannon","Flamethrower","Blowpipe","Admin Gun","Friendly Gun","Crossbow","Wildfire","Infernal Crossbow","Witch Potion","Bouncing Blade","Air Rifle"},
    ["Armor"] = {"Leather Body","Poison Armor","Iron Body","Thorn Body","Riot Shield","Alien Armor","Obsidiron Body","Vampire Cloak"},
    ["Warm Clothing"] = {"Earmuffs","Beanie","Arctic Fox Hat","Polar Bear Hat","Mammoth Helmet"},
    ["Boots"] = {"Frog Boots","Obsidiron Boots"},
    ["Pelts"] = {"Bunny Foot","Wolf Pelt","Alpha Wolf Pelt","Bear Pelt","Arctic Fox Pelt","Polar Bear Pelt","Mammoth Tusk","Scorpion Shell","Cultist King Antler"},
    ["Keys"] = {"Red Key","Blue Key","Yellow Key","Grey Key","Frog Key"},
    ["Materials"] = {"Wood","Scrap","Cultist Gem","Forest Gem","Forest Gem Fragment","Mossy Coin","Flower","Sapling","Sacrifice Totem","Meteor Shard","Gold Shard","Raw Obsidiron Ore","Raw Obsidiron Ore (Shard)","Scalding Obsidiron Ingot","Obsidiron Ingot","Obsidiron Crystals"},
    ["Healing"] = {"Bandage","Medkit","Cake","Hearty Stew","BBQ Ribs","Carrot Cake","Jar o' Jelly"},
    ["Anvils"] = {"Anvil Front","Anvil Back","Anvil Base","Meteor Anvil Front","Meteor Anvil Back","Meteor Anvil Base"},
    ["Potions"] = {"Dripleaf","Moonflower Bulb","Stareweed Petal","Cave Vine Flower","Mandrake"},
    ["Blueprints"] = {"Crafting Blueprint","Defense Blueprint","Furniture Blueprint","Obsidiron Chest Blueprint","Halloween Blueprint"},
    ["Tools"] = {"Hammer","Paint Brush"},
    ["Corpses"] = {"Cultist Corpse","Crossbow Cultist Corpse","Juggernaut Cultist Corpse","Cultist King Corpse","Alien Corpse","Elite Alien Corpse","Wolf Corpse","Alpha Wolf Corpse","Bear Corpse"},
}

--// WINDUI LOAD
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "99 Nights | Ultra Fast Bring",
    Icon = "package",
    Author = "Ultra Edition"
})

--// CREATE TABS FOR EACH CATEGORY
for category, items in pairs(Categories) do
    local Tab = Window:Tab({Title = category, Icon = "box"})
    Tab:Section({Title = category.." Items", Opened = true})
    local selectedItems = {}

    Tab:Dropdown({
        Title = "Select "..category.." Items",
        Desc = "Multi select | Ultra fast",
        Values = items,
        Multi = true,
        AllowNone = true,
        Callback = function(selected)
            selectedItems = selected
        end
    })

    local function bring(list)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for _, name in ipairs(list) do
            local item = findItemByName(workspace.Items, name)
            if item then
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

    Tab:Button({
        Title = "🚀 Bring Selected "..category,
        Callback = function()
            bring(selectedItems)
        end
    })

    Tab:Button({
        Title = "💥 Bring ALL "..category,
        Callback = function()
            bring(items)
        end
    })
end
