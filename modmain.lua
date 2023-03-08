

if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/fun_player.lua")

    AddPrefabPostInit("world",function(inst)
        inst:AddComponent("ksfun_data")
    end)

end