local HELPER = require("tasks/ksfun_task_helper")



local function MakeTask(task_name)

    -- 生成任务
    local task = HELPER.createTask(task_name)

    local function finishTask(inst, player, name)
        player:PushEvent(KSFUN_TUNING.EVENTS.TASK_FINISH, {name = name})
    end


    local function onAttachFunc(inst, player, name, data)
        task.onAttachFunc(inst, player, name, data)
        --- 重新启用timer
        inst.components.timer:ResumeTimer("ksfun_task_over")
    end


    local function onDetachFunc(inst, player, name, data)
        task.onDetachFunc(inst, player, name, data)
        inst.components.timer:StopTimer("ksfun_task_over")
        inst:DoTaskInTime(0, inst:Remove())
    end


    local function onWinFunc(inst, player, name, data)
        task.onWinFunc(inst, player, name, data)
        inst.components.timer:StopTimer("ksfun_task_over")
        finishTask(inst, player, name)
    end


    local function onLoseFunc(inst, player, name, data)
        task.onLoseFunc(inst, player, name, data)
        inst.components.timer:StopTimer("ksfun_task_over")
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

        inst.entity:AddTransform()
        inst.entity:Hide()
        inst.persists = false

        inst:AddComponent("timer")
        inst:AddComponent("ksfun_task")


        inst.components.ksfun_task.onAttachFunc = onAttachFunc
        inst.components.ksfun_task.onDetachFunc = onDetachFunc
        inst.components.ksfun_task.onWinFunc = onWinFunc
        inst.components.ksfun_task.onLoseFunc = onLoseFunc


        -- 倒计时结束任务失败
        local function onTimeDone(d)
            inst.components.ksfun_task:Lose()
        end

        -- 初始化
        inst.components.ksfun_task.onInitFunc = function(inst, task_data)
            -- 如果有时间限制，就初始化timer
            if task_data and task_data.demand.data.duration > 0 then
                -- 先暂停，等attach的时候才开始计算时间
                inst.components.timer:StartTimer("ksfun_task_over", task_data.demand.data.duration, true)
                inst:ListenForEvent("timerdone", onTimeDone)
            end
        end

        return inst
    end

    return Prefab("ksfun_task_"..task_name, fn, nil, prefabs)
end


local NAMES = KSFUN_TUNING.TASK_NAMES

return MakeTask(NAMES.KILL)