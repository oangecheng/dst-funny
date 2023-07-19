local taskhelper = require("tasks/ksfun_task_helper")



local function MakeTask(taskname)

    -- 生成任务
    local taskhandler = taskhelper.getTaskHandler(taskname)

    -- 任务结束发送通知
    local function finishTask(inst, player, iswin)
        local name = inst.components.ksfun_task:GetName()
        player:PushEvent(KSFUN_TUNING.EVENTS.TASK_FINISH, {name = name, iswin = iswin })
    end

    --- 重新启用timer
    local function onAttachFunc(inst, player, data)
        taskhandler.onAttachFunc(inst, player, data)
        inst.components.timer:ResumeTimer("ksfun_task_over")
    end

    --- 移除timer
    local function onDetachFunc(inst, player, data)
        taskhandler.onDetachFunc(inst, player, data)
        inst.components.timer:StopTimer("ksfun_task_over")
        inst:DoTaskInTime(0, inst:Remove())
    end

    --- 任务成功回调
    local function onWinFunc(inst, player, data)
        taskhandler.onWinFunc(inst, player, data)
        inst.components.timer:StopTimer("ksfun_task_over")
        finishTask(inst, player, true)
    end

    --- 任务失败回调
    local function onLoseFunc(inst, player, data)
        taskhandler.onLoseFunc(inst, player, data)
        inst.components.timer:StopTimer("ksfun_task_over")
        finishTask(inst, player, false)
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
        inst.components.ksfun_task.onWinFunc    = onWinFunc
        inst.components.ksfun_task.onLoseFunc   = onLoseFunc
        inst.components.ksfun_task.descFunc     = taskhandler.descFunc


        -- 倒计时结束任务失败
        local function onTimeDone(d)
            local ksfuntask = inst.components.ksfun_task
            if ksfuntask:IsTimeReverse() then
                ksfuntask:Win()
            else
                ksfuntask:Lose()
            end
        end

        -- 初始化时判定是否需要添加计时器
        inst.components.ksfun_task.onInitFunc = function(inst, taskdata)
            -- 如果有时间限制，就初始化timer
            -- 先暂停，等attach的时候才开始计算时间
            local duration = taskdata.demand.duration or 0
            if duration > 0 then
                inst.components.timer:StartTimer("ksfun_task_over", duration, true)
            end
        end

        inst:ListenForEvent("timerdone", onTimeDone)

        return inst
    end

    return Prefab("ksfun_task_"..taskname, fn, nil, prefabs)
end


local tasks = {}
for k,v in pairs(KSFUN_TUNING.TASK_NAMES) do
    table.insert(tasks, MakeTask(v))
end 

return unpack(tasks)