
local actions = {
    KSFUN_USE_ITEM = {
        id = "KSFUN_USE_ITEM",
        strfn = function(act)
            return "DRINK_POTION"
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

    KSFUN_REPAIR = {
        id = "KSFUN_REPAIR",
        strfn = function(act)
            return "REPAIR"
        end,
        fn = function(act)
            local doer = act.doer
            if doer and act.target and act.target.components.ksfun_repairable then
                if act.target and act.target.components.ksfun_repairable:Repair(act.invobject, act.doer) then
                    return true
                end
            end
            return false
        end
    },
}



for k, v in pairs(actions) do
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



AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
        and inst:HasTag("ksfun_potion") and doer:HasTag("player") and not doer:HasTag("playerghost") then
        table.insert(actions, ACTIONS.KSFUN_USE_ITEM)
    end
end)


AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right)
    if inst.prefab == "goldnugget"  then
        table.insert(actions, ACTIONS.KSFUN_REPAIR)
    end
end)


local sgwilsons = {"wilson", "wilson_client"}
for i, v in ipairs(sgwilsons) do
    local _dolongactions = {
        ACTIONS.KSFUN_USE_ITEM,
        ACTIONS.KSFUN_REPAIR
    }
    for i1, v1 in ipairs(_dolongactions) do
        AddStategraphActionHandler(v, ActionHandler(v1, function(inst, action)
            return "dolongaction"
        end))
    end
end