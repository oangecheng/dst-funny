GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

modimport("scripts/strings_c.lua")
require("ksfun_tuning")


PrefabFiles = {
    "ksfun_tasks",
    "ksfun_player_powers",
}

Assets = {
    Asset("ATLAS", "images/ksfun_player_panel_bg.xml"),
    Asset("IMAGE", "images/ksfun_player_panel_bg.tex"),
}



AddReplicableComponent("ksfun_hunger")
AddReplicableComponent("ksfun_powers")


local player_panel = require "mod/my_screen"
AddClassPostConstruct("widgets/controls", function(self, owner)
	owner.player_panel = self:AddChild(player_panel(self.owner))--说明页图标
    owner.player_panel:Hide()
    owner.player_panel_showing = false
end)


-- 加载各种玩法
modimport("scripts/mod/ksfun_hook.lua")
modimport("scripts/mod/ksfun_clotheses.lua")


AddPlayerPostInit(function(inst)
    TheInput:AddKeyDownHandler(108, function() 
        if inst.player_panel_showing then
            inst.player_panel:Hide()
            inst.player_panel_showing = false
        else
            inst.player_panel:Show()
            inst.player_panel_showing = true
        end
    end)
end)

if GLOBAL.TheNet:GetIsServer() then
    -- modimport("scripts/mod/ksfun_policy_health.lua")
    -- modimport("scripts/mod/ksfun_policy_sanity.lua")
    modimport("scripts/mod/ksfun_player.lua")

    -- 世界初始化
    AddPrefabPostInit("world", function(inst)
        inst:AddComponent("ksfun_world_player")
    end)

end