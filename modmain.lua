GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

require("ksfun_tuning")
modimport("scripts/strings_c.lua")
modimport("scripts/ksfun_global_func.lua")


GLOBAL.AddPlayerPostInit = AddPrefabPostInit


PrefabFiles = {
    "ksfun_tasks",
    "ksfun_player_powers",
    "ksfun_melt_stone",
    "ksfun_task_reel",
    "medal_tips",
    "ksfun_power_gems"
}

Assets = {
    Asset("ANIM" , "anim/ksfun_task_reel.zip"),	
    Asset("ATLAS", "images/ksfun_task_reel.xml"),
    Asset("IMAGE", "images/ksfun_task_reel.tex"),
    
    Asset("ANIM" , "anim/ksfun_melt_stone.zip"),	
    Asset("ATLAS", "images/ksfun_melt_stone.xml"),
    Asset("IMAGE", "images/ksfun_melt_stone.tex"),

    Asset("ANIM" , "anim/ksfun_power_gem.zip"),	
    Asset("ATLAS", "images/inventoryitems/ksfun_power_gem_item_maxuses.xml"),
    Asset("IMAGE", "images/inventoryitems/ksfun_power_gem_item_maxuses.tex"),
}



AddReplicableComponent("ksfun_power_system")
AddReplicableComponent("ksfun_task_system")
AddReplicableComponent("ksfun_task_demand")


local player_panel = require "mod/my_screen"
AddClassPostConstruct("widgets/controls", function(self, owner)
	owner.player_panel = self:AddChild(player_panel(self.owner))--说明页图标
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
    modimport("scripts/mod/ksfun_station.lua")
    modimport("scripts/mod/ksfun_player.lua")
    modimport("scripts/mod/ksfun_items_maker.lua")

    -- 世界初始化
    AddPrefabPostInit("world", function(inst)
        inst:AddComponent("ksfun_world_monster")
    end)
end