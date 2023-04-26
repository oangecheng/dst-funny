
 local function onHealthAttachFun(inst, player, name)

    local function onKill(inst, data)
    end
    -- 击杀怪物后，范围10以内的角色都可以获得血量升级的经验值
    -- 范围内只有一个人时，经验值为100%获取
    -- 人越多经验越低，最低50%
local function on_kill_other(inst, data)
    local victim = data.victim
    if victim == nil then return end
    if victim.components.health == nil then return end

    if victim.components.freezable or victim:HasTag("monster") then
        local exp = victim.components.health.maxhealth
        local x,y,z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x,y,z, 10, {"player"})
        
        if players == nil then return end
        local players_count = #players
        -- 单人模式经验100%，多人经验获取会减少，最低50%
        local exp_multi = math.max((6 - players_count) * 0.2, 0.5)
        for i, player in ipairs(players) do
            if player.components.ksfun_health then 
                player.components.ksfun_health:GainExp(exp * exp_multi)
            end
        end
    end
end
    player:ListenForEvent("killed", onKill)


end



local function powerHealth()

    local data = {}



   

end




local function MakePower(name, data)
    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:AddTransform()
        inst.entity:Hide()
        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("ksfun_power")
        inst.components.ksfun_power:SetOnAttachFunc(data.onAttachFunc)
        inst.components.ksfun_power:SetOnDetachFunc(data.onDetachFunc)
        inst.components.ksfun_power:SetOnExtendFunc(data.onExtendFunc)
        inst.components.ksfun_power:SetOnGetDescFun(data.onGetDescFunc)
        inst.components.ksfun_power.keepondespawn = true

        if data.duration and data.duration > 0 and data.onTimeDoneFunc then
            inst:AddComponent("timer")
            inst.components.timer:StartTimer("powerover", data.duration)
            inst:ListenForEvent("timerdone", data.onTimeDoneFunc)
        end

        inst.OnSave = data.OnSaveFunc
        inst.OnLoad = data.OnLoadFunc

        return inst
    end

    return Prefab("ksfun_power_"..name, fn, nil, prefabs)
end