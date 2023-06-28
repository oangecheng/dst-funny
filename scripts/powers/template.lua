
local function updateXXStatus(inst)
end

local def = { power = {}, level = {} }

def.power.onAttachFunc = function(inst, target, name)
    updateXXStatus(inst)
end




local p = {
    onattach  = function(inst, target, name)
    end,

    onupgrade = function(inst)
    end,

    ondesc    = function(inst, target, name)
    end,
}