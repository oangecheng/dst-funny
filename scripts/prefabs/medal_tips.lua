local function SetMedalTips(inst)
	local msg = inst.medal_d_value:value()
	local label=inst.Label
	if msg then
		label:SetFontSize(25)
		label:SetText(msg)
		label:SetColour(255/255, 0, 0)
		label:Enable(true)
		label:SetWorldOffset(0, 5, 0)
	end
end

local function UpdatePing(inst, t0, duration)
    local t = GetTime() - t0
    local k = 1 - math.max(0, t - 0.1) / duration
    k = 1 - k * k
    local s = Lerp(15, 30, k)--字体从15到30
	local y = Lerp(4, 5, k)--高度从4到5
    local label=inst.Label
	if label then
		label:SetFontSize(s)
		label:SetWorldOffset(0, y, 0)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddNetwork()
	inst.entity:SetCanSleep(false)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	
	local label = inst.entity:AddLabel()
	label:SetFont(NUMBERFONT)
	label:SetFontSize(15)
	label:SetWorldOffset(0, 4, 0)
	label:SetColour(255/255, 204/255, 51/255)
	label:SetText("+0")
	label:Enable(false)

	inst.medal_d_value = net_string(inst.GUID, "medal_d_value", "medal_d_valuedirty")
	inst:ListenForEvent("medal_d_valuedirty", SetMedalTips)

	inst.entity:SetPristine()

	-- if not TheWorld.ismastersim then
	-- 	return inst
	-- end
	-- inst.medal_d_value:set(1)
	inst.persists = false
	local duration = 2--持续时间
	-- inst:DoPeriodicTask(0, UpdatePing, nil, GetTime(), duration)
	inst:DoTaskInTime(duration, inst.Remove)

	return inst
end

return Prefab("medal_tips", fn)
