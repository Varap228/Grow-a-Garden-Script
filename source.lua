local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:SetNotificationLower(true)
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jxereas/UI-Libraries/main/notification_gui_library.lua", true))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local buySeedEvent = GameEvents:WaitForChild("BuySeedStock")
local plantSeedEvent = GameEvents:WaitForChild("Plant_RE")
local sellInventoryEvent = GameEvents:WaitForChild("Sell_Inventory")

local settings = {
    auto_buy_seeds = true,
    use_distance_check = true,
    collection_distance = 17,
    collect_nearest_fruit = true,
    auto_sell = false,
    option_auto_sell = "Check notification", 
    debug_mode = false
}

local plant_position = nil
local selected_seed = "Carrot"
local is_auto_planting = false
local is_auto_collecting = false
local maxHoldableItems = 200 

local Window = WindUI:CreateWindow({
    Title = "Grow-a-Garden script",
    Icon = "banana",
    Author = "Discord: varap228",
    Folder = "Aboba_goida228",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            local themes = {'Rose', 'Indigo', 'Plant', 'Red', 'Light', 'Dark'}
            local currentThemeName = WindUI:GetCurrentTheme()
            local currentThemeIndex = table.find(themes, currentThemeName) or 0
            local nextThemeIndex = (currentThemeIndex % #themes) + 1
            WindUI:SetTheme(themes[nextThemeIndex])
        end,
    }
})

local function getPlayerCharacterAndRoot()
    local character = localPlayer.Character
    if not character then return nil, nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    return character, rootPart
end

local function getPlayerFarm()
    local farmContainer = workspace:FindFirstChild("Farm")
    if not farmContainer then return nil end

    for _, farmInstance in ipairs(farmContainer:GetChildren()) do
        local importantFolder = farmInstance:FindFirstChild("Important")
        local dataFolder = importantFolder and importantFolder:FindFirstChild("Data")
        local ownerValue = dataFolder and dataFolder:FindFirstChild("Owner")

        if ownerValue and ownerValue.Value == localPlayer.Name then
            return farmInstance
        end
    end
    return nil
end

local function teleportAndSell()
    local character, rootPart = getPlayerCharacterAndRoot()
    if not rootPart then return end

    local sellPoint = workspace:FindFirstChild("Tutorial_Points", true) and workspace.Tutorial_Points:FindFirstChild("Tutorial_Point_1")
    if not sellPoint then 
        if settings.debug_mode then print("Sell point not found.") end
        return
    end

    rootPart.CFrame = sellPoint.CFrame
    task.wait(0.2) 
    sellInventoryEvent:FireServer()
    task.wait(0.1)
end

local function checkBackpackAndSell()
    local holdableItemCount = 0
    local character = localPlayer.Character
    local toolInHand = character and character:FindFirstChildOfClass("Tool")

    if toolInHand and toolInHand:GetAttribute("ITEM_TYPE") == "Holdable" then
        holdableItemCount = 1 
    end

    for _, item in ipairs(localPlayer.Backpack:GetChildren()) do
        if item:GetAttribute("ITEM_TYPE") == "Holdable" then
            holdableItemCount += 1
            if holdableItemCount >= maxHoldableItems then
                if settings.debug_mode then print("Max items reached, selling.") end
                teleportAndSell()
                return true 
            end
        end
    end
    return false
end

local function checkNotificationAndSell()
    local topNotificationFrame = playerGui:FindFirstChild("Top_Notification", true) and playerGui.Top_Notification:FindFirstChild("Frame")
    if not topNotificationFrame then return false end

    for _, notificationElement in ipairs(topNotificationFrame:GetChildren()) do
        if notificationElement:GetAttribute("OG") == "Max backpack space! Go sell!" then
            if settings.debug_mode then print("Max backpack notification found, selling.") end
            teleportAndSell()
            return true
        end
    end
    return false
end

local function autoSellLoop()
    while settings.auto_sell do
        if not settings.auto_sell then return end

        local sold = false
        if settings.option_auto_sell == "Check notification" then
            sold = checkNotificationAndSell()
        elseif settings.option_auto_sell == "Check backpack (200 items)" then
            sold = checkBackpackAndSell()
        end
        
        task.wait(sold and 1 or 0.3) 
    end
end

local function buySeed(seedName)
    local seedShopUI = playerGui:FindFirstChild("Seed_Shop", true)
    if not seedShopUI then return end
    local seedEntry = seedShopUI.Frame.ScrollingFrame:FindFirstChild(seedName)
    if not seedEntry then return end

    local costText = seedEntry.Main_Frame:FindFirstChild("Cost_Text")
    if costText and costText.TextColor3 ~= Color3.fromRGB(255, 0, 0) then
        if settings.debug_mode then print("Buying seed:", seedName) end
        buySeedEvent:FireServer(seedName)
    end
end

local function equipSeed(seedName)
    local character, rootPart = getPlayerCharacterAndRoot()
    if not rootPart then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local function findAndEquip(container)
        for _, item in ipairs(container:GetChildren()) do
            if item:GetAttribute("ITEM_TYPE") == "Seed" and item:GetAttribute("Seed") == seedName then
                humanoid:EquipTool(item)
                task.wait() 
                local equipped = character:FindFirstChildOfClass("Tool")
                if equipped and equipped:GetAttribute("ITEM_TYPE") == "Seed" and equipped:GetAttribute("Seed") == seedName then
                    return equipped
                end
            end
        end
        return nil
    end
    
    local equippedTool = findAndEquip(localPlayer.Backpack)
    if equippedTool then return equippedTool end

    equippedTool = character:FindFirstChildOfClass("Tool")
    if equippedTool and equippedTool:GetAttribute("ITEM_TYPE") == "Seed" and equippedTool:GetAttribute("Seed") == seedName then
        return equippedTool
    end

    return false
end

local function autoCollectFruitsLoop()
    while is_auto_collecting do
        if not is_auto_collecting then return end

        local character, playerRootPart = getPlayerCharacterAndRoot()
        local currentFarm = getPlayerFarm()

        if not (playerRootPart and currentFarm and currentFarm.Important and currentFarm.Important.Plants_Physical) then
            if settings.debug_mode then print("Auto-collect: Missing player, farm, or plants_physical.") end
            task.wait(0.5)
            continue
        end

        local plantsPhysical = currentFarm.Important.Plants_Physical
        local promptToFire = nil

        if settings.collect_nearest_fruit then
            local minDistance = math.huge
            for _, plant in ipairs(plantsPhysical:GetChildren()) do
                if not is_auto_collecting then break end
                for _, descendant in ipairs(plant:GetDescendants()) do
                    if not is_auto_collecting then break end
                    if descendant:IsA("ProximityPrompt") and descendant.Enabled and descendant.Parent then
                        local distance = (playerRootPart.Position - descendant.Parent.Position).Magnitude
                        if (not settings.use_distance_check or distance <= settings.collection_distance) and distance < minDistance then
                            minDistance = distance
                            promptToFire = descendant
                        end
                    end
                end
                if not is_auto_collecting then break end
            end

            if promptToFire then
                if settings.debug_mode then print("Nearest fruit:", promptToFire.Parent.Name, "Dist:", minDistance) end
                fireproximityprompt(promptToFire)
                task.wait(0.05)
            end
        else
            for _, plant in ipairs(plantsPhysical:GetChildren()) do
                if not is_auto_collecting then break end
                for _, fruitPrompt in ipairs(plant:GetDescendants()) do
                    if not is_auto_collecting then break end
                    if fruitPrompt:IsA("ProximityPrompt") and fruitPrompt.Enabled and fruitPrompt.Parent then
                        if not settings.use_distance_check or (playerRootPart.Position - fruitPrompt.Parent.Position).Magnitude <= settings.collection_distance then
                            if settings.debug_mode then print("Collecting:", fruitPrompt.Parent.Name) end
                            fireproximityprompt(fruitPrompt)
                            task.wait(0.05)
                        end
                    end
                end
                if not is_auto_collecting then break end
            end
        end
        task.wait(0.01) 
    end
end

local function autoPlantSeedsLoop(seedNameToPlant)
    while is_auto_planting do
        if not is_auto_planting then return end
        
        local seedInHand = equipSeed(seedNameToPlant)

        if not seedInHand and settings.auto_buy_seeds then
            buySeed(seedNameToPlant)
            task.wait(0.15) 
            seedInHand = equipSeed(seedNameToPlant)
        end
        
        if seedInHand and plant_position then
            local quantity = seedInHand:GetAttribute("Quantity")
            if quantity and quantity > 0 then
                if settings.debug_mode then print("Planting", seedNameToPlant, "at", plant_position, "Qty:", quantity) end
                plantSeedEvent:FireServer(plant_position, seedNameToPlant)
                task.wait(0.15) 
            else
                if settings.debug_mode then print("Seed ran out or no quantity:", seedNameToPlant) end
                 is_auto_planting = false 
                 Window:GetSection("Main"):Get("Auto Plant"):Set(false)
                 break
            end
        else
            if settings.debug_mode then print("Cannot plant. Seed in hand:", seedInHand, "Pos:", plant_position) end
            task.wait(0.5)
        end
        task.wait(0.1) 
    end
end

do
    local playerFarm = getPlayerFarm()
    if playerFarm and playerFarm.Important and playerFarm.Important.Plant_Locations then
        local defaultPlantLocPart = playerFarm.Important.Plant_Locations:FindFirstChildOfClass("Part")
        if defaultPlantLocPart then
            plant_position = defaultPlantLocPart.Position
        else
            warn("Default plant location part not found in farm. Plant position needs to be set manually.")
        end
    else
        warn("Player farm or plant locations not found on script start. Plant position needs to be set manually.")
    end
end

local TabMain = Window:Tab({ Title = "Main", Icon = "rbxassetid://124620632231839" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "rbxassetid://96957318452720" })
Window:SelectTab(1)

TabMain:Button({
    Title = "Set Plant Position",
    Desc = "Set the position to plant seeds (current character position)",
    Callback = function()
        local _, rootPart = getPlayerCharacterAndRoot()
        if rootPart then
            plant_position = rootPart.Position
            Notification.new("info", "Position Set", string.format("Planting position: %.0f, %.0f, %.0f", plant_position.X, plant_position.Y, plant_position.Z)):deleteTimeout(2)
        else
            Notification.new("error", "Error", "Player character not found."):deleteTimeout(2)
        end
    end
})  

TabMain:Dropdown({
    Title = "Seed Selection",
    Values = {'Carrot', 'Strawberry', "Blueberry", 'Orange Tulip', 'Tomato', 'Corn', 'Watermelon', 'Daffodil', "Pumpkin", 'Apple', 'Bamboo', 'Coconut', 'Cactus', 'Dragon Fruit', 'Mango', 'Grape', 'Mushroom', 'Pepper', 'Cacao', 'Beanstalk'},
    Value = selected_seed,
    Callback = function(option) 
        selected_seed = option
    end
})

TabMain:Toggle({
    Title = "Auto Plant",
    Desc = "Automatically plants selected seeds",
    Default = is_auto_planting,
    Callback = function(state) 
        is_auto_planting = state
        if state and selected_seed and plant_position then
            task.spawn(autoPlantSeedsLoop, selected_seed)
        elseif state and not plant_position then
            is_auto_planting = false
            Window:GetSection("Main"):Get("Auto Plant"):Set(false)
            Notification.new("warning", "Plant Position Needed", "Please set a plant position first."):deleteTimeout(3)
        end
    end
})

TabMain:Toggle({
    Title = "Auto Collect",
    Desc = "Automatically collects fruits",
    Default = is_auto_collecting,
    Callback = function(state) 
        is_auto_collecting = state
        if state then
            task.spawn(autoCollectFruitsLoop)
        end
    end
})

TabMain:Toggle({
    Title = "Auto Sell",
    Desc = "Automatically sells items",
    Default = settings.auto_sell,
    Callback = function(state) 
        settings.auto_sell = state
        if state then
            task.spawn(autoSellLoop)
        end
    end
})

TabMain:Dropdown({
    Title = "Auto-Sell Method",
    Values = {"Check notification", "Check backpack (200 items)"},
    Value = settings.option_auto_sell,
    Callback = function(option) 
        settings.option_auto_sell = option
    end
})

local autoBuyToggle = TabSettings:Toggle({
    Title = "Auto Buy Seeds",
    Desc = "Automatically buy seeds when they run out",
    Default = settings.auto_buy_seeds,
    Callback = function(state) 
        settings.auto_buy_seeds = state
    end
})
autoBuyToggle:Set(settings.auto_buy_seeds)

local distCheckToggle = TabSettings:Toggle({
    Title = "Use Distance Check (Collect)",
    Desc = "Only collect fruits within a certain distance",
    Default = settings.use_distance_check,
    Callback = function(state) 
        settings.use_distance_check = state
    end
})
distCheckToggle:Set(settings.use_distance_check)

local collectNearestToggle = TabSettings:Toggle({
    Title = "Collect Nearest Fruit First",
    Desc = "Collects only the closest fruit per scan (if distance check is on)",
    Default = settings.collect_nearest_fruit,
    Callback = function(state) 
        settings.collect_nearest_fruit = state
    end
})
collectNearestToggle:Set(settings.collect_nearest_fruit)

TabSettings:Slider({
    Title = "Collection Distance",
    Desc = "Max distance to collect fruits",
    Step = 0.5,
    Value = { Min = 1, Max = 50, Default = settings.collection_distance },
    Callback = function(value)
        settings.collection_distance = value
    end
})

local debugToggle = TabSettings:Toggle({
    Title = "Debug Mode",
    Desc = "Enable console logs for debugging",
    Icon = "bug",
    Default = settings.debug_mode,
    Callback = function(state) 
        settings.debug_mode = state
    end
})
debugToggle:Set(settings.debug_mode)

Notification.new("success", "Grow-a-Garden script loaded! Version 1.2 | By varap228", "Add: Auto Sell"):deleteTimeout(5)
