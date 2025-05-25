local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

local GUI = Mercury:Create{
    Name = "Grow-a-Garden script",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "Discord: varap228 /",
}

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local buySeedEvent = GameEvents:WaitForChild("BuySeedStock")
local plantSeedEvent = GameEvents:WaitForChild("Plant_RE")

local settings = {
    auto_buy_seeds = true,
    use_distance_check = true,
    collection_distance = 17,
    collect_nearest_fruit = true,
    debug_mode = false
}

local plant_position = nil
local selected_seed = "Carrot"
local is_auto_planting = false
local is_auto_collecting = false

local function get_player_farm()
    for _, farm in ipairs(workspace.Farm:GetChildren()) do
        local important_folder = farm:FindFirstChild("Important")
        if important_folder then
            local owner_value = important_folder:FindFirstChild("Data") and important_folder.Data:FindFirstChild("Owner")
            if owner_value and owner_value.Value == localPlayer.Name then
                return farm
            end
        end
    end
    return nil
end

local function buy_seed(seed_name)
    if playerGui.Seed_Shop.Frame.ScrollingFrame[seed_name].Main_Frame.Cost_Text.TextColor3 ~= Color3.fromRGB(255, 0, 0) then
        if _G.table_settings.debug_mode then
            print("Attempting to buy seed:", seed_name)
        end
        buySeedEvent:FireServer(seed_name)
    end
end

local function equip_seed(seed_name)
    local character = localPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    for _, item in ipairs(localPlayer.Backpack:GetChildren()) do
        if item:GetAttribute("ITEM_TYPE") == "Seed" and item:GetAttribute("Seed") == seed_name then
            humanoid:EquipTool(item)
            task.wait()
            local equipped_tool = character:FindFirstChildOfClass("Tool")
            if equipped_tool and equipped_tool:GetAttribute("ITEM_TYPE") == "Seed" and equipped_tool:GetAttribute("Seed") == seed_name then
                return equipped_tool
            end
        end
    end

    local equipped_tool = character:FindFirstChildOfClass("Tool")
    if equipped_tool and equipped_tool:GetAttribute("ITEM_TYPE") == "Seed" and equipped_tool:GetAttribute("Seed") == seed_name then
        return equipped_tool
    end
    
    return false
end

local function auto_collect_fruits()
    while is_auto_collecting do
        if not is_auto_collecting then return end

        local character = localPlayer.Character
        local player_root_part = character and character:FindFirstChild("HumanoidRootPart")
        local current_farm = get_player_farm()

        if not (player_root_part and current_farm and current_farm.Important and current_farm.Important.Plants_Physical) then
            if settings.debug_mode then
                print("Player, farm, or plants not found, skipping auto_collect iteration.")
            end
            task.wait(0.5)
            continue
        end

        local plants_physical = current_farm.Important.Plants_Physical

        if settings.collect_nearest_fruit then
            local nearest_prompt = nil
            local min_distance = math.huge

            for _, plant in ipairs(plants_physical:GetChildren()) do
                if not is_auto_collecting then return end
                for _, descendant in ipairs(plant:GetDescendants()) do
                    if not is_auto_collecting then return end
                    if descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.Parent then
                        local distance_to_fruit = (player_root_part.Position - descendant.Parent.Position).Magnitude
                        local can_collect = false

                        if settings.use_distance_check then
                            if distance_to_fruit <= settings.collection_distance then
                                can_collect = true
                            end
                        else
                            can_collect = true 
                        end

                        if can_collect and distance_to_fruit < min_distance then
                            min_distance = distance_to_fruit
                            nearest_prompt = descendant
                        end
                    end
                end
            end

            if nearest_prompt then
                if settings.debug_mode then
                    print("Nearest fruit prompt:", nearest_prompt.Parent and nearest_prompt.Parent.Name or "Unknown", "at distance", min_distance)
                end
                fireproximityprompt(nearest_prompt)
                task.wait(0.05)
            end
        else
            for _, plant in ipairs(plants_physical:GetChildren()) do
                if not is_auto_collecting then return end
                for _, fruit_prompt in ipairs(plant:GetDescendants()) do
                    if not is_auto_collecting then return end
                    if fruit_prompt:IsA("ProximityPrompt") and fruit_prompt.Enabled and fruit_prompt.Parent then
                        local collect_this = false
                        if settings.use_distance_check then
                            local distance = (player_root_part.Position - fruit_prompt.Parent.Position).Magnitude
                            if distance <= settings.collection_distance then
                                collect_this = true
                                if settings.debug_mode then
                                    print("Collecting (distance):", fruit_prompt.Parent.Name, "at", distance)
                                end
                            end
                        else
                            collect_this = true
                            if settings.debug_mode then
                                print("Collecting (no distance check):", fruit_prompt.Parent.Name)
                            end
                        end

                        if collect_this then
                            fireproximityprompt(fruit_prompt)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
        task.wait()
    end
end

local function auto_plant_seeds(seed_name)
    while is_auto_planting do
        if not is_auto_planting then return end
        
        local seed_in_hand = equip_seed(seed_name)

        if not seed_in_hand and settings.auto_buy_seeds then
            buy_seed(seed_name)
            task.wait(0.1)
            seed_in_hand = equip_seed(seed_name)
        end
        
        if seed_in_hand and plant_position then
            local quantity = seed_in_hand:GetAttribute("Quantity")
            if quantity and quantity > 0 then
                if settings.debug_mode then
                    print("Planting", seed_name, "at", plant_position, "Quantity:", quantity)
                end
                
                local args = {
                    plant_position,
                    seed_name 
                }
                plantSeedEvent:FireServer(unpack(args))
                task.wait(0.1) 
            else
                 if settings.debug_mode then
                    print("No quantity for seed or seed ran out:", seed_name)
                end
                -- is_auto_planting = false 
                -- break
            end
        else
            if settings.debug_mode then
                print("Could not equip seed or plant_position is nil. Seed:", seed_name, "Pos:", plant_position)
            end
            task.wait(1)
            -- is_auto_planting = false 
            -- break
        end
        task.wait(0.2)
    end
end


local farm = get_player_farm()
if farm and farm.Important and farm.Important.Plant_Locations then
    local default_plant_location = farm.Important.Plant_Locations:FindFirstChildOfClass("Part")
    if default_plant_location then
        plant_position = default_plant_location.Position
    else
        plant_position = Vector3.new(0,0,0) 
        warn("Default plant location part not found in farm.")
    end
else
    plant_position = Vector3.new(0,0,0)
    warn("Player farm or plant locations not found on script start.")
end

local TabMain = GUI:Tab{
    Name = "Main",
    Icon = "rbxassetid://124620632231839" 
}

local TabSettings = GUI:Tab{
    Name = "Settings",
    Icon = "rbxassetid://96957318452720"
}

TabMain:Button{
    Name = "Set Plant Position",
    Description = "Set the position to plant seeds (defaults to center of your farm)",
    Callback = function()
        local character = localPlayer.Character
        local root_part = character and character:FindFirstChild("HumanoidRootPart")
        if root_part then
            plant_position = root_part.Position
            GUI:Notification{
                Title = "Position Set",
                Text = "Planting position set to: " .. tostring(plant_position),
                Duration = 2
            }
        else
            GUI:Notification{ Title = "Error", Text = "Player character not found.", Duration = 2 }
        end
    end
}

TabMain:Dropdown{
    Name = "Seed Selection",
    StartingText = selected_seed,
    Description = "Select a seed to plant",
    Items = {'Carrot', 'Strawberry', "Blueberry", 'Orange Tulip', 'Tomato', 'Corn', 'Watermelon', 'Daffodil', "Pumpkin", 'Apple', 'Bamboo', 'Coconut', 'Cactus', 'Dragon Fruit', 'Mango', 'Grape', 'Mushroom', 'Pepper', 'Cacao', 'Beanstalk'},
    Callback = function(item)
        selected_seed = item
    end
}

TabMain:Toggle{
    Name = "Auto Plant",
    StartingState = is_auto_planting,
    Description = "Automatically plants selected seeds at the set position",
    Callback = function(state)
        is_auto_planting = state
        if state then
            task.spawn(auto_plant_seeds, selected_seed)
        end
    end
}

TabMain:Toggle{
    Name = "Auto Collect",
    StartingState = is_auto_collecting,
    Description = "Automatically collects fruits from plants",
    Callback = function(state)
        is_auto_collecting = state
        if state then
            task.spawn(auto_collect_fruits)
        end
    end
}

TabSettings:Toggle{
    Name = "Auto Buy Seeds",
    StartingState = settings.auto_buy_seeds,
    Description = "Automatically buy seeds when they run out",
    Callback = function(state)
        settings.auto_buy_seeds = state
    end
}

TabSettings:Toggle{
    Name = "Use Distance Check",
    StartingState = settings.use_distance_check,
    Description = "Enable to only collect fruits within a certain distance",
    Callback = function(state)
        settings.use_distance_check = state
    end
}

TabSettings:Toggle{
    Name = "Collect Nearest Fruit",
    StartingState = settings.collect_nearest_fruit,
    Description = "Collect only the nearest fruit if distance check is enabled",
    Callback = function(state)
        settings.collect_nearest_fruit = state
    end
}

TabSettings:Slider{
    Name = "Collection Distance",
    Description = "Distance to collect fruits (if distance check is enabled)",
    Default = settings.collection_distance,
    Min = 1,
    Max = 30,
    Rounding = 0.5,
    Callback = function(value)
        settings.collection_distance = value
    end
}

TabSettings:Toggle{
    Name = "Debug Mode",
    StartingState = settings.debug_mode,
    Description = "Enable debug mode for console logs",
    Callback = function(state)
        settings.debug_mode = state
    end
}

GUI:Notification{
    Title = "Grow-a-Garden script loaded!",
    Text = "Version 1.1",
    Duration = 5
}
