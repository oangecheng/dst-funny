GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})


AddReplicableComponent("ksfun_hunger")

local medalPage = require "mod/my_screen"
AddClassPostConstruct("widgets/controls", function(self, owner)
	self.medalPage = self:AddChild(medalPage(self.owner))--说明页图标
end)


if GLOBAL.TheNet:GetIsServer() then

    modimport("scripts/mod/fun_player.lua")

    AddPrefabPostInit("world",function(inst)
        inst:AddComponent("ksfun_data")
    end)

end