





local function MakeTask(name, data)
    local function fn()
        local inst = CreateEntity()
        inst:AddTag("CLASSIFIED")
        inst:AddTag("ksfun_task")

        if not TheWorld.ismastersim then
            inst:DoTaskInTime(0, inst:Remove())
            return inst
        end

        inst.entity:Hide()

        inst:AddComponent("timer")
        inst:AddComponent("ksfun_task")

        inst.components.ksfun_task.onStart = onTaskStart
        inst.components.ksfun_task.onSuccess = onTaskSuccess
        inst.components.ksfun_task.onFail = onTaskFail

        inst.monitorFunc = nil

        -- 任务生成时，
        inst.components.ksfun_task.onAttach = function(task)
            local test = createTestTask()
            task.name = test.type
            task.demand = test.demand
            task.reward = test.reward
            task.punish = test.punish
        end

        return inst
    end

    return Prefab(name, fn, nil, prefabs)
end


local data = {}


return MakeTask(data.name, data)