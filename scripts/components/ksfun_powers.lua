local function addPower(self, ent, name)
    if ent.components.ksfun_power then
        self.powers[name] = {
            inst = ent,
        }
        if self.onPowerAddFunc then
            self.onPowerAddFunc(self.inst, name, ent)
        end
        ent.persists = false
        ent.components.ksfun_power:Attach(name, self.inst)
    else
        ent:Remove()
    end
end



local KSFUN_POWERS = Class(function(self, inst)
    self.inst = inst
    self.enable = true
    self.powers = {}

    self.onPowerAddFunc = nil
    self.onPowerRemoveFunc = nil
end)


function KSFUN_POWERS:GetPower(name)
    local power = self.powers[name]
    if power then
        return power.inst
    else
        return nil
    end
end

--- 设置新增属性监听
--- 一般用来刷新数据
function KSFUN_POWERS:SetOnPowerAddFunc(func)
    self.onPowerAddFunc = func
end


--- 设置属性移除监听
--- 一般用来刷新显示
function KSFUN_POWERS:SetOnPowerRemoveFunc(func)
    self.onPowerRemoveFunc = func
end


function KSFUN_POWERS:SetEnable(enable)
    self.enable = enable
end


function KSFUN_POWERS:IsEnable()
    return self.enable
end


--- 新增一个属性
--- @param name type=string prefab type=string
function KSFUN_POWERS:AddPower(name, prefab)
    local power = self.powers[name]
    if power == nil then
        local ent = SpawnPrefab(prefab)
        addPower(self, name, ent)
        return ent
    else
        power.inst.components.ksfun_power:Extend()
        return power.inst
    end
end


--- 彻底移除一个属性
--- 这个属性会被永久移除，一般用于
function KSFUN_POWERS:RemovePower(name)
    local power = self.powers[name]
    if power ~= nil then
        self.powers[name] = nil
        if self.onPowerRemoveFunc then
            self.onPowerRemoveFunc(self.inst, name, power.inst)
        end
        if power.inst.components.ksfun_power then
            power.inst.components.ksfun_power:Deatch()
        else
            power.inst:Remove()
        end
    end
end


--- 暂停属性作用 
function KSFUN_POWERS:PausePower(name)
    local power = self.powers[name]
    if power then
        if power.inst.components.ksfun_power then
            power.inst.components.ksfun_power:Deatch()
        end
    end
end


--- 恢复属性
function KSFUN_POWERS:ResumePower(name)
    local power = self.powers[name]
    if power then
        if power.inst.components.ksfun_power then
            power.inst.components.ksfun_power:Attach(name, self.inst)
        end
    end
end


function KSFUN_POWERS:OnSave()
    if next(self.powers) == nil then return end
    local data = {}
    for k, v in pairs(self.powers) do
        local saved--[[, refs]] = v.inst:GetSaveRecord()
        data[k] = saved
    end
    return { powers = data, enable = enable }
end


function KSFUN_POWERS:OnLoad(data)
    if data then
        self.enable = data.enable or true
    end
    if data ~= nil and data.powers ~= nil then
        for k, v in pairs(data.powers) do
            if self.powers[k] == nil then
                local ent = SpawnSaveRecord(v)
                if ent ~= nil then
                    AddPower(self, k, ent)
                end
            end
        end
    end

end


return KSFUN_POWERS