

------ 吸血属性
local lifestealmax = 5

local lifesteal = {
    power = {
        onAttachFunc = function(inst, target, name)
            inst.components.ksfun_level:SetMax(lifestealmax)
        end,
    },
    level = {},
    -- 可升级
    forgable = {
        items = {["mosquitosack"] = 2}
    }
}



------- 溅射伤害
local aoemax = 10

local function onGetAoeDescFunc( inst, target, name )
    local multi,area = KsFunGetAoeProperty(inst)
    local desc = "造成范围"..area.."以内"..(multi*100).."%溅射伤害"
    return KsFunGeneratePowerDesc(inst, desc)
end

local aoe = {
    power = {
        onAttachFunc  = function(inst, target, name)
            inst.components.ksfun_level:SetMax(aoemax)
        end,
        onGetDescFunc = onGetAoeDescFunc
    },
    level = {},
    -- 可升级
    forgable = {
        items = {["minotaurhorn"] = 5}
    }
}




local weapon = {}


weapon.lifesteal = {
    data = lifesteal
}

weapon.aoe = {
    data = aoe
}


return weapon