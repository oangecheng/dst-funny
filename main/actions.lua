


local function acceptTask(doer, invobject)
    -- 没有任务系统的不支持
    if doer.components.ksfun_task_system == nil then
        return
    end
    local taskdata = invobject.components.ksfun_task_demand:GetDemand()
    if taskdata then
        local data  = deepcopy(taskdata)
        KsFunBindTaskReel(invobject, doer, data)
    end
end





local ksfun_actions = {

    --- 接受任务
    KSFUN_TASK_DEMAND = {
        id = "KSFUN_TASK_DEMAND",
        strfn = function(act)
            return "KSFUN_TASK_DEMAND"
        end,
        fn = function(act)
            local doer = act.doer
            if doer ~= nil and act.invobject ~= nil then
                acceptTask(doer, act.invobject)
                return true
            end
        end
    },

    KSFUN_USE_ITEM = {
        id = "KSFUN_USE_ITEM",
        strfn = function(act)
            return "KSFUN_USE_ITEM"
        end,
        fn = function(act)
            local doer = act.doer
            if doer and act.invobject then
                act.invobject.components.ksfun_useable:Use(doer)
            end
        end
    }
}



for k, v in pairs(ksfun_actions) do
    local _action = Action()
    _action.id = v.id
    _action.priority = v.priority or 0
    _action.fn = v.fn
    if v.strfn then
        _action.strfn = v.strfn
    end
    if v.str then
        _action.str = v.str
    end
    if v.distance then
        _action.distance = v.distance
    end
    AddAction(_action)
end


STRINGS.ACTIONS.KSFUN_TASK_DEMAND = {
    GENERIC = ACTIONS_KSFUN_TASK_DEMAND_GENERIC_STR,
    KSFUN_TASK_DEMAND = ACTIONS_KSFUN_TASK_DEMAND_STR
}
STRINGS.ACTIONS.KSFUN_USE_ITEM = {
    GENERIC = ACTIONS_KSFUN_USE_ITEM_GENERIC_STR,
    KSFUN_USE_ITEM = ACTIONS_KSFUN_USE_ITEM_STR
}


AddComponentAction("INVENTORY", "ksfun_task_demand", function(inst, doer, actions)
    if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
        and inst:HasTag("ksfun_task") and doer:HasTag("player") and not doer:HasTag("playerghost") then
        table.insert(actions, ACTIONS.KSFUN_TASK_DEMAND)
    end
end)


AddComponentAction("INVENTORY", "ksfun_useable", function(inst, doer, actions)
    if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
        and inst:HasTag("ksfun_item") and doer:HasTag("player") and not doer:HasTag("playerghost") then
        table.insert(actions, ACTIONS.KSFUN_USE_ITEM)
    end
end)



local sgwilsons = {"wilson", "wilson_client"}
for i, v in ipairs(sgwilsons) do
    local _dolongactions = {
        ACTIONS.KSFUN_TASK_DEMAND,
        ACTIONS.KSFUN_USE_ITEM,
    }
    for i1, v1 in ipairs(_dolongactions) do
        AddStategraphActionHandler(v, ActionHandler(v1, function(inst, action)
            return "dolongaction"
        end))
    end
end