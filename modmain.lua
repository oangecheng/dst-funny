GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

require("ksfun_tuning")
modimport("scripts/util/strings_c.lua")
modimport("scripts/util/ksfun_global_func.lua")
modimport("scripts/util/ksfun_util.lua")


---- mode配置
local diffculty = GetModConfigData("diffculty")
KSFUN_TUNING.DIFFCULTY = diffculty or 0
local mode = GetModConfigData("mode")
KSFUN_TUNING.MODE = mode or 0 



PrefabFiles = {
    "ksfun_tasks",
    "ksfun_player_powers",
    "ksfun_task_reel",
    "ksfun_power_gems"
}

Assets = {
    Asset("ANIM" , "anim/ksfun_task_reel.zip"),	
    Asset("ATLAS", "images/ksfun_task_reel.xml"),
    Asset("IMAGE", "images/ksfun_task_reel.tex"),
    Asset("ANIM" , "anim/ksfun_power_gem.zip"),	
    Asset("ANIM" , "anim/ui_chest_3x1.zip"),
}

local ITEM_POWER_NAMES = KSFUN_TUNING.ITEM_POWER_NAMES
for k,v in pairs(ITEM_POWER_NAMES) do
    table.insert(Assets, Asset("ATLAS", "images/inventoryitems/ksfun_power_gem_"..v..".xml"))
    table.insert(Assets, Asset("IMAGE", "images/inventoryitems/ksfun_power_gem_"..v..".tex"))
end



AddReplicableComponent("ksfun_power_system")
AddReplicableComponent("ksfun_task_system")
AddReplicableComponent("ksfun_task_demand")
AddReplicableComponent("ksfun_level")
AddReplicableComponent("ksfun_lucky")


local player_panel = require "mod/my_screen"
AddClassPostConstruct("widgets/controls", function(self, owner)
	owner.player_panel = self:AddChild(player_panel(self.owner))
    owner.player_panel:Hide()
    owner.player_panel_showing = false
end)


-- 加载各种玩法
modimport("scripts/mod/ksfun_hook.lua")
modimport("scripts/widgets/ksfun_containers.lua")
-- 物品制作
modimport("main/recipes.lua")
-- action
modimport("main/actions.lua")




AddPlayerPostInit(function(inst)
    TheInput:AddKeyDownHandler(108, function() 
        if inst.player_panel_showing then
            inst.player_panel:KsFunHide()
            inst.player_panel_showing = false
        else
            inst.player_panel:KsFunShow()
            inst.player_panel_showing = true
        end
    end)
end)



if GLOBAL.TheNet:GetIsServer() then

    -- 世界初始化
    AddPrefabPostInit("world", function(inst)
        inst:AddComponent("ksfun_world_monster")
        inst:AddComponent("ksfun_world_player")
        inst:AddComponent("ksfun_world_data")
    end)

    modimport("scripts/mod/ksfun_station.lua")
    modimport("scripts/mod/ksfun_player_init.lua")
    modimport("scripts/mod/ksfun_items_maker.lua")
    modimport("scripts/mod/ksfun_monsters_reinforce.lua")


end