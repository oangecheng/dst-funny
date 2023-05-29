GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

require("ksfun_tuning")
modimport("scripts/strings_c.lua")
modimport("scripts/ksfun_global_func.lua")


PrefabFiles = {
    "ksfun_tasks",
    "ksfun_player_powers",
    "ksfun_melt_stone",
}

Assets = {
    Asset("ATLAS", "images/ksfun_player_panel_bg.xml"),
    Asset("IMAGE", "images/ksfun_player_panel_bg.tex"),
}



AddReplicableComponent("ksfun_power_system")
AddReplicableComponent("ksfun_task_system")


local player_panel = require "mod/my_screen"
AddClassPostConstruct("widgets/controls", function(self, owner)
	owner.player_panel = self:AddChild(player_panel(self.owner))--说明页图标
    owner.player_panel:Hide()
    owner.player_panel_showing = false
end)


-- 加载各种玩法
modimport("scripts/mod/ksfun_hook.lua")
modimport("scripts/widgets/ksfun_containers.lua")



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