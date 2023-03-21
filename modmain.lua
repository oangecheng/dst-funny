GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})


AddReplicableComponent("ksfun_hunger")

local medalPage = require "mod/my_screen"
AddClassPostConstruct("widgets/controls", function(self, owner)
	self.medalPage = self:AddChild(medalPage(self.owner))--说明页图标
end)


-- 加载各种玩法
modimport("scripts/mod/ksfun_policy_hunger.lua")

if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/mod/ksfun_policy_health.lua")
    modimport("scripts/mod/ksfun_policy_sanity.lua")

    -- 世界初始化
    AddPrefabPostInit("world",function(inst)
        inst:AddComponent("ksfun_world_player")
    end)

end