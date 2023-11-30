

local ksfun_actions = {
    KSFUN_USE_ITEM = {
        id = "KSFUN_USE_ITEM",
        strfn = function(act)
            return act.invobject.prefab == "ksfun_task_reel" and "ACCEPT" or "KSFUN_USE_ITEM"
        end,
        fn = function(act)
            local doer = act.doer
            if doer and act.invobject and act.invobject.usefn then
                if act.invobject.usefn(act.doer, act.invobject) then
                    return true
                end
            end
            return false
        end
    },

    KSFUN_ITEM_ACTIVATE = {
        id = "KSFUN_ITEM_ACTIVATE",
        strfn = function(act)
            return "KSFUN_ITEM_ACTIVATE"
        end,
        fn = function(act)
            local doer = act.doer
            if doer and act.invobject and act.target then
                return act.invobject.components.ksfun_useable:Use(doer, act.target)
            end
            return false
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


STRINGS.ACTIONS.KSFUN_USE_ITEM = {
    GENERIC = ACTIONS_KSFUN_USE_ITEM_GENERIC_STR,
    KSFUN_USE_ITEM = ACTIONS_KSFUN_USE_ITEM_STR,
    ACCEPT = ACTIONS_KSFUN_TASK_DEMAND_STR,
}
STRINGS.ACTIONS.KSFUN_ITEM_ACTIVATE = {
    GENERIC = ACTIONS_KSFUN_USE_ITEM_GENERIC_STR,
    KSFUN_ITEM_ACTIVATE = ACTIONS_KSFUN_USE_ITEM_STR
}



AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
        and inst:HasTag("ksfun_potion") and doer:HasTag("player") and not doer:HasTag("playerghost") then
        table.insert(actions, ACTIONS.KSFUN_USE_ITEM)
    end
end)


AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
    if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
        and inst:HasTag("ksfun_item") and doer:HasTag("player") and not doer:HasTag("playerghost") then
        table.insert(actions, ACTIONS.KSFUN_ITEM_ACTIVATE)
    end
end)


local sgwilsons = {"wilson", "wilson_client"}
for i, v in ipairs(sgwilsons) do
    local _dolongactions = {
        ACTIONS.KSFUN_USE_ITEM,
        ACTIONS.KSFUN_ITEM_ACTIVATE,
    }
    for i1, v1 in ipairs(_dolongactions) do
        AddStategraphActionHandler(v, ActionHandler(v1, function(inst, action)
            return "dolongaction"
        end))
    end
end