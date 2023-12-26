---@diagnostic disable: undefined-field
local isch = KSFUN_TUNING.IS_CH
local materials = require("defs/ksfun_materials")


--移除预制物(预制物,数量)
local function removeItem(item, num)
	if item.components.stackable then
		item.components.stackable:Get(num):Remove()
	else
		item:Remove()
	end
end


local actions = {
    {
        id  = "KSFUN_TAKE",
        str = isch and "服用" and "take",
        state = "domediumaction",
        fn  = function (act)
            local doer = act.doer
            local item = act.invobject
            if doer and item and item.usefn then
                if item.usefn(doer, act.invobject) then
                    removeItem(item, 1)
                    return true
                end
            end
            return false
        end 
    },

    {
        id  = "KSFUN_REPAIR",
        str = isch and "修理" and "repair",
        state = "give",
        fn  = function (act)
            local repairable = act.target and act.target.components.ksfun_repairable
            if act.doer and repairable and act.invobject then
                if repairable:Repair(act.invobject, act.doer) then
                    removeItem(act.invobject, 1)
                    return true
                end
            end
            return false
        end,
        actiondata = {
            priority = 10,
        } 
    }
}




local component_actions = {
    {
        type = "INVENTORY",
        component = "inventoryitem",
        tests = {
            {
                action = "KSFUN_TAKE",
                testfn = function(inst, doer, actions, right)
                    return inst:HasTag("ksfun_potion")
                end
            }
        }
    },

    {
        type = "USEITEM",
        component = "inventoryitem",
        tests = {
            {
                action = "KSFUN_REPAIR",
                testfn = function (inst, doer, target, actions, right)
                    local items = materials.GetRepairItems()
                    return table.containskey(items, inst.prefab)
                end
            }
        }
    }

}



local old_actions = {

}





return {
	actions = actions,
	component_actions = component_actions,
	old_actions = old_actions,
}