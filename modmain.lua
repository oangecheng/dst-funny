GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

modimport("scripts/util/strings_c.lua")

require("ksfun_tuning")
require("util/ksfun_functions")
require("tasks/ksfun_task_func")



---- mode配置
local diffculty = GetModConfigData("diffculty")
KSFUN_TUNING.DIFFCULTY = diffculty or 0
local mode = GetModConfigData("mode")
KSFUN_TUNING.MODE = mode or 0 



PrefabFiles = {
    "ksfun_tasks",
    "ksfun_powers",
    -- "ksfun_task_reel",
    "ksfun_power_gems",
    "ksfun_potions",
}

Assets = {
    Asset("ANIM" , "anim/ksfun_task_reel.zip"),	
    Asset("ATLAS", "images/inventoryitems/ksfun_task_reel.xml"),
    Asset("IMAGE", "images/inventoryitems/ksfun_task_reel.tex"),

    Asset("ANIM" , "anim/ksfun_potion.zip"),
    Asset("IMAGE", "images/inventoryitems/ksfun_potion.tex"),
    Asset("ATLAS", "images/inventoryitems/ksfun_potion.xml"),	
    
    Asset("ANIM" , "anim/ksfun_power_gem.zip"),	
    Asset("ANIM" , "anim/ui_chest_3x1.zip"),
}

local ITEM_POWER_NAMES = KSFUN_TUNING.ITEM_POWER_NAMES
for k,v in pairs(ITEM_POWER_NAMES) do
    table.insert(Assets, Asset("ATLAS", "images/inventoryitems/ksfun_power_gem_"..v..".xml"))
    table.insert(Assets, Asset("IMAGE", "images/inventoryitems/ksfun_power_gem_"..v..".tex"))
end



AddReplicableComponent("ksfun_power_system")
AddReplicableComponent("ksfun_level")



if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/mod/ksfun_init.lua")
end



modimport("main/recipes.lua")
modimport("main/actions.lua")
modimport("scripts/mod/ksfun_hook.lua")
modimport("scripts/widgets/ksfun_containers.lua")
modimport("scripts/widgets/ksfun_ui.lua")--UI、容器等
modimport("scripts/mod/ksfun_rpc.lua")--UI、容器等




TheInput:AddKeyDownHandler(108, function()
    if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
        if ThePlayer.HUD.ksfunscreen ~= nil then
            ThePlayer.HUD:CloseKsFunScreen()
        else
            ThePlayer.HUD:ShowKsFunScreen()
        end
    end
end)



