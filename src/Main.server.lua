-- container-swap
-- swap models into folders, and folders into models

-- dependant services
local Selection = game:GetService("Selection")
local HistoryService = game:GetService("ChangeHistoryService")

local source = script.Parent

-- plugin configuration constants
local Config = require(source:WaitForChild("Config"))

local pluginToolbar = plugin:CreateToolbar(Config.TOOLBAR_NAME)
-- the plugin button :D
local pluginButton = pluginToolbar:CreateButton(
    Config.PLUGIN_NAME,
    Config.PLUGIN_DESC,
    Config.PLUGIN_ICON
)
-- action that allows you to bind this plugin to a hotkey
local pluginAction = plugin:CreatePluginAction(
    Config.PLUGIN_ID.."-action",
    Config.PLUGIN_NAME,
    Config.PLUGIN_DESC,
    Config.PLUGIN_ICON
)

-- Swaps instance to a folder/model, retaining common properties and reparenting children
local function swapContainer(instance)
    -- fancy bit of boolean magic that resolves to folder if instance is a model, and model if it's a folder.
    local changeTo = (instance:IsA("Model") and "Folder") or "Model"

    local newContainer = Instance.new(changeTo)

    -- These are the common properties of model and folder, as such they transfer
    -- TODO: Store PrimaryPart in an objectvalue?
    newContainer.Name = instance.Name
    newContainer.Archivable = instance.Archivable

    -- Put all children of instance in the new container
    for _,child in pairs(instance:GetChildren()) do
        child.Parent = newContainer
    end

    -- replace the old container with the new one in the datamodel
    newContainer.Parent = instance.Parent
    instance.Parent = nil -- We dont destroy because HistoryService requires instances to still exist

    return newContainer
end

local function swapSelectionContainers()
    HistoryService:SetEnabled(true) -- ensure HistoryService is enabled

    local selection = Selection:Get()
    local toSwap = {} -- swappable instances from selection
    local unswappable = {} -- instances that cant be swapped but should stay selected
    local newContainers = {} -- containers after being swapped
    local newSelection = {} -- final selection

    -- loop thru selection, add swappables to toSwap, others to unswappable
    for _,instance in pairs(selection) do
        if instance:IsA("Model") or instance:IsA("Folder") then
            table.insert(toSwap,instance)
        else
            table.insert(unswappable,instance)
        end
    end

    -- set our entry waypoint
    HistoryService:SetWaypoint("Swapping container")

    -- swap all toSwap
    for _,container in pairs(toSwap) do
        table.insert(newContainers,swapContainer(container))
    end

    -- combine newContainers and unswappable into one selection table
    for _,instance in pairs(newContainers) do
        table.insert(newSelection,instance)
    end

    for _,instance in pairs(unswappable) do
        table.insert(newSelection,instance)
    end

    Selection:Set(newSelection)

    -- set our exit waypoint
    HistoryService:SetWaypoint("Container swapped")
end

-- bind the main function to events
pluginAction.Triggered:Connect(swapSelectionContainers)
pluginButton.Click:Connect(swapSelectionContainers)