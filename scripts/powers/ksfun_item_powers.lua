

------ 吸血属性 ----------------------------------------------------------------------------------------
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



------- 溅射伤害 ----------------------------------------------------------------------------------------
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



----- 挖矿 ----------------------------------------------------------------------------------------
local minemax = 10
local function updateMineStatus(inst, l, n)
    local lv = inst.components.ksfun_level:GetLevel()
    local m = math.max(minemax - lv, 1)
    inst.target.components.finiteuses:SetConsumption(ACTIONS.MINE, math.max(1, lv))
    inst.target.components.tool:SetAction(ACTIONS.MINE, minemax/m)
end

local mine = {
    power = {
        onAttachFunc = function(inst, target, name)
            if target.components.tool == nil then 
                target:AddComponent("tool") 
            end
            inst.components.ksfun_level:SetMax(minemax)
            updateMineStatus(inst) 
        end,  
    },
    level = {
        onLvChangeFunc = updateMineStatus
    },
    -- 使用大理石或者硝石进行升级
    forgable = {
        items = {
            ["marble"] = 1,
            ["nitre"]  = 1,
        }
    }
}



----- 伐木 ----------------------------------------------------------------------------------------
local chopmax = 15
local function updateChopStatus(inst, l, n)
    local lv = inst.components.ksfun_level:GetLevel()
    local m = math.max(chopmax - lv, 1)
    inst.target.components.finiteuses:SetConsumption(ACTIONS.CHOP, math.max(1, lv))
    inst.target.components.tool:SetAction(ACTIONS.CHOP, chopmax/m)
end

local chop = {
    power = {
        onAttachFunc = function(inst, target, name)
            if target.components.tool == nil then 
                target:AddComponent("tool") 
            end
            inst.components.ksfun_level:SetMax(chopmax)
            updateChopStatus(inst) 
        end,  
    },
    level = {
        onLvChangeFunc = updateChopStatus
    },
    -- 使用活木升级
    forgable = {
        items = {
            ["livinglog"] = 1,
        }
    }
}




----- 最大使用次数 ----------------------------------------------------------------------------------------
local function updateMaxusesStatus(inst, l, n)
    local data = inst.components.ksfun_power:GetData()
    local finiteuses = inst.target and inst.target.components.finiteuses or nil
    if finiteuses and data then
        local lv = inst.components.ksfun_level:GetLevel()
        local percent = finiteuses:GetPercent()
        finiteuses:SetMaxUses(data.maxuses * (lv + 1))
        finiteuses:SetPercent(percent)
    end
end

local maxuses = {
    power = {
        onAttachFunc = function(inst, target, name)
            if target.components.finiteuses then
                inst.components.ksfun_power:SetData({maxuses = target.components.finiteuses.total})
            end
            updateMaxusesStatus(inst)
        end,


    },
    level = {
        onLvChangeFunc = updateMaxusesStatus
    },
    -- 使用活木升级
    forgable = {
        items = {
            ["dragon_scales"] = 10,
        }
    }
}




----- 武器基础伤害 ----------------------------------------------------------------------------------------
local function updateDamageStatus(inst, l, n)
    local power = inst.components.ksfun_power
    local data  = power:GetData()
    if data then
        local damage = data.damage or 0
        if inst.target and inst.target.components.weapon then
            local level = inst.components.ksfun_level:GetLevel()
            inst.target.components.weapon:SetDamage(damage + level)
        end
    end
end

local damage = {
    power = {
        onAttachFunc = function(inst, target, name)
            if target.components.weapon then
                local d = target.components.weapon.damage
                inst.components.ksfun_power:SetData({ damage = d})
            end
            updateDamageStatus(inst)
        end,


    },
    level = {
        onLvChangeFunc = updateDamageStatus
    },
    -- 铥矿棒/狗牙/蜂刺升级
    forgable = {
        items = {
            ["ruins_bat"]   = 100,
            ["tentaclespike"] = 10,
            ["houndstooth"] = 1,
            ["stinger"]     = 1,
        }
    }
}




------ 移速 ----------------------------------------------------------------------------------------
local speedmax = 50
local function updateSpeedStatus(inst, l, n)
    local d = inst.components.ksfun_power:GetData()
    local speed = d and d.speed or 1
    local lv = inst.components.ksfun_level:GetLevel()
    if inst.target.components.equippable ~= nil then
        inst.target.components.equippable.walkspeedmult = speed + lv / 100
    end
end

local speed = {
    onAttachFunc = function(inst, target, name)
        if target.components.equippable then
            inst.components.ksfun_power:SetData({speed = target.components.equippable:GetWalkSpeedMult()})
            inst.components.ksfun_level:SetMax(speedmax)
            updateSpeedStatus(inst)
        end
    end,
    level = {
        onLvChangeFunc = updateSpeedStatus
    },
    -- 海象牙/步行手杖
    forgable = {
        items = {
            ["walrus_tusk"] = 100,
            ["cane"] = 150,
        }
    }
}




local item = {
    
}


item.lifesteal = { data = lifesteal }
item.aoe       = { data = aoe }
item.mine      = { data = mine }
item.chop      = { data = chop }
item.maxuses   = { data = maxuses }
item.damage    = { data = damage }
item.speed     = { data = speed }


return item