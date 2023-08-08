local containers = require "containers"
local params = containers.params
local itemsdef = require("defs/ksfun_items_def")


params.dragonflyfurnace = {
    widget = {
        slotpos = {
            Vector3(-(64 + 12), 0, 0),
            Vector3(0, 0, 0),
            Vector3(64 + 12, 0, 0),
        },
        animbank = "ui_chest_3x1",
        animbuild = "ui_chest_3x1",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo = {
            text = "炼制",
            position = Vector3(0, -65, 0),
        }
    },
    type = "chest",
}

params.dragonflyfurnace.itemtestfn = function(_, item, slot)
    if slot == 1 then
        ---@diagnostic disable-next-line: undefined-field
        return table.containskey(itemsdef.ksfunitems, item.prefab) or item:HasTag("ksfun_item")
    end
    return true
end

params.dragonflyfurnace.widget.buttoninfo.fn = function(inst, doer)
    if inst.components.container ~= nil then
		if inst.startWork then
			inst.startWork(inst, doer)
		end
	elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
		SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
	end
end