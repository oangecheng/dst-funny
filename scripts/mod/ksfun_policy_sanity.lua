local EXP_DEFS = {
    {TECH.SCIENCE_ONE, 30},
    {TECH.SCIENCE_TWO, 60},
    {TECH.SCIENCE_THREE, 90},
    {TECH.MAGIC_TWO, 120},
    {TECH.MAGIC_THREE, 150},
    {TECH.ANCIENT_TWO, 180},
    {TECH.ANCIENT_THREE, 210},
    {TECH.ANCIENT_FOUR, 240},
    {TECH.CELESTIAL_ONE, 270},
    {TECH.CELESTIAL_THREE, 300},
}


-- 更新角色的精神数据
local function update_sanity_state(inst)
    local lv = inst.components.ksfun_sanity.level
	inst.components.sanity.max = 100 + lv
    local sanity_percent = inst.components.sanity:GetPercent()
	inst.components.sanity:SetPercent(sanity_percent)
end


-- 精神等级提升的时候
local function on_sanity_up(inst, gain_exp)
    update_sanity_state(inst)
    GLOBAL.TheWorld.components.ksfun_data:CachePlayerStatus(inst)

    if gain_exp then
        inst.components.talker:Say("我越来越聪明了！")
    end
end


-- 查找对应列表中物品
local function get_target_exp(data)
	if data == nil or data.recipe == nil then
		return 10
	end
    local lv = data.recipe.lv
	for i = 1, #EXP_DEFS do
		if lv == EXP_DEFS[i][1] then
			return EXP_DEFS[i][2]
		end
	end
	return 10
end


-- 制作物品
local function on_item_build(inst, data)
    local exp = get_target_exp(data) * 1
    if inst.components.ksfun_sanity then
        inst.components.ksfun_sanity:GainExp(exp)
    end
end


-- 制作建筑的经验是物品的两倍
local function on_structure_build(inst, data)
    local exp = get_target_exp(data) * 2
    if inst.components.ksfun_sanity then
        inst.components.ksfun_sanity:GainExp(exp)
    end
end


-- 初始化角色
AddPlayerPostInit(function(player)
    player:AddComponent("ksfun_sanity")
    player.components.ksfun_sanity:SetSanityUpFunc(on_item_build)
    player:ListenForEvent("builditem", on_item_build)
    player:ListenForEvent("buildstructure", on_structure_build)

    local old_on_load = player.OnLoad
    player.OnLoad = function(inst)
        update_sanity_state(inst) 
        if old_on_load ~= nil then
            old_on_load(inst)
        end
    end
end)