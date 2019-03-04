-- container-swap
-- swap models into folders, and folders into models

local Selection = game:GetService("Selection")
local HistoryService = game:GetService("ChangeHistoryService")

local source = script.Parent

local Config = require(source:WaitForChild("Config"))

local pluginToolbar = plugin:CreateToolbar(Config.TOOLBAR_NAME)
local pluginButton = pluginToolbar:CreateButton(
    Config.PLUGIN_NAME,
    Config.PLUGIN_DESC,
    Config.PLUGIN_ICON
)
local pluginAction = plugin:CreatePluginAction(
    Config.PLUGIN_ID.."-action",
    Config.PLUGIN_NAME,
    Config.PLUGIN_DESC,
    Config.PLUGIN_ICON
)

local function swapContainer(instance)
    local changeTo = (instance:IsA("Folder") and "Folder") or "Model"

    local newContainer = Instance.new(changeTo)

    newContainer.Name = instance.Name

    for _,child in pairs(instance:GetChildren()) do
        child.Parent = newContainer
    end

    newContainer.Parent = instance.Parent
    instance.Parent = nil
end

local function swapSelectionContainers()
    HistoryService:SetEnabled(true)

    local selection = Selection:Get()
    local toSwap = {}

    for _,instance in pairs(selection) do
        if instance:IsA("Model") or instance:IsA("Folder") then
            table.insert(toSwap,instance)
        end
    end

    HistoryService:SetWaypoint("Swapping container")

    for _,container in pairs(toSwap) do
        swapContainer(container)
    end

    HistoryService:SetWaypoint("Container swapped")
end


pluginAction.Triggered:Connect(swapSelectionContainers)
pluginButton.Click:Connect(swapSelectionContainers)