


local function MakeTask(data)

    local function finishTask(inst, player, name)
        player:PushEvent(KSFUN_TUNING.EVENTS.TASK_FINISH, {name = name})
    end


    local function onAttachFunc(inst, player, name)
        data.onAttachFunc(inst, player, name)
        --- 重新启用timer
        inst.components.timer:ResumeTimer(inst)
    end


    local function onDetachFunc(inst, player, name)
        data.onDetachFunc(inst, player, name)
        inst.components.timer:StopTimer(inst)
        inst:Remove()
    end


    local function onWinFunc(inst, player, name)
        data.onWinFunc(inst, player, name)
        inst.components.timer:StopTimer(inst)
        finishTask(inst, player, name)
    end


    local function onLoseFunc(inst, player, name)
        data.onLoseFunc(inst, player, name)
        inst.components.timer:StopTimer(inst)
        finishTask(inst, player, name)
    end


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

        -- 给任务赋值
        local d = data.generateTaskData()
        inst.components.ksfun_task:SetTaskData(d)
        inst.components.ksfun_task.onAttachFunc = onAttachFunc
        inst.components.ksfun_task.onDetachFunc = onDetachFunc
        inst.components.ksfun_task.onWinFunc = onWinFunc
        inst.components.ksfun_task.onLoseFunc = onLoseFunc


        -- 倒计时结束任务失败
        local function onTimeDone(d)
            inst.components.ksfun_task:Lose()
        end

        -- 如果有时间限制，就初始化timer
        local task_data = inst.components.ksfun_task:GetTaskData()
        if task_data and task_data.duration then
            -- 先暂停，等attach的时候才开始计算时间
            inst.components.timer:StartTimer(inst, task_data.duration, true)
            inst:ListenForEvent("timerdone", onTimeDone)
        end

        return inst
    end

    return Prefab("ksfun_task_"..data.name, fn, nil, prefabs)
end



local data = require("tasks/ksfun_kill")


return MakeTask(data)