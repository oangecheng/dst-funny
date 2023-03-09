GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})



if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/fun_player.lua")

    AddPrefabPostInit("world",function(inst)
        inst:AddComponent("ksfun_data")
    end)

end