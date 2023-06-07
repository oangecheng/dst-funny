



local ksfun_actions = {
    KSFUN_TASK_DEMAND = {
        id = "KSFUN_TASK_DEMAND",
        strfn = function(act)
            return "KSFUN_TASK_DEMAND"
        end,
        fn = function(act)
            local doer = act.doer
            if doer ~= nil and act.invobject ~= nil then
                act.doer.components.talker:Say("接受任务！")
                -- act.invobject.components.ndnr_bountytask:Do(act.doer)
                return true
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


AddComponentAction("INVENTORY", "ksfun_task_demand", function(inst, doer, actions)
    if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
        and inst:HasTag("ksfun_task") and doer:HasTag("player") and not doer:HasTag("playerghost") then
        table.insert(actions, ACTIONS.KSFUN_TASK_DEMAND)
    end
end)



local sgwilsons = {"wilson", "wilson_client"}
for i, v in ipairs(sgwilsons) do
    local _dolongactions = {
        ACTIONS.KSFUN_TASK_DEMAND,
    }
    for i1, v1 in ipairs(_dolongactions) do
        AddStategraphActionHandler(v, ActionHandler(v1, function(inst, action)
            return "dolongaction"
        end))
    end
end