local function addPower(self, name, ent)
    if ent.components.ksfun_power then
        self.powers[name] = {
            inst = ent,
        }
        ent.persists = false

        --- 属性系统才可以绑定
        ent.components.ksfun_power:Attach(name, self.inst)

        if self.onPowerAddFunc then
            self.onPowerAddFunc(self.inst, name, ent)
        end
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
    for k,v in pairs(self.powers) do
        v.inst.components.ksfun_power:SetEnable(self.enable)
    end
end


function KSFUN_POWERS:IsEnable()
    return self.enable
end


--- 新增一个属性
--- 对于一个inst，同一种属性只能添加一次，多次添加无效，会回调 OnExtend
--- 对于临时power可以延长时间
--- @param name 属性名称
function KSFUN_POWERS:AddPower(name)
    local power = self.powers[name]
    local ret = nil
    if power == nil then
        local ent = SpawnPrefab("ksfun_power_"..name)
        if ent then
            addPower(self, name, ent)
        end
        ret = ent
    else
        power.inst.components.ksfun_power:Extend()
        ret =  power.inst
    end
    self:SyncData()
    return ret
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
        self:SyncData()
    end
end


function KSFUN_POWERS:GetPowerNum()
    return GetTableSize(self.powers)
end


function KSFUN_POWERS:GetAllPowers()
    local list = {}
    for k,v in pairs(self.powers) do
        list[k] = v.inst
    end
    return list
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



local function getTitle(inst)
    local prefab = inst.prefab
    local name = STRINGS.NAMES[string.upper(prefab)]
    if inst.components.ksfun_enhantable and inst.components.ksfun_enhantable:IsEnable() then
        name = name.."[可升级]"
    end
    local level = inst.components.ksfun_level
    local lv = level and level:GetLevel() or -1
    return prefab,name,lv 
end


--- 同步用户数据
--- power的等级经验
function KSFUN_POWERS:SyncData()

    local prefab,name,lv = getTitle(self.inst)
    local data = prefab..","..name..","..lv

    for k,v in pairs(self.powers) do
        local power = v.inst
        local lv   = power.components.ksfun_level:GetLevel()
        local exp  = power.components.ksfun_level:GetExp()
        local desc = power.components.ksfun_power:GetDesc()
        -- 名称;等级;经验值;描述
        local d = k .. "," .. tostring(lv) .. "," .. tostring(exp) .. "," ..desc
        data = data ..";".. d
    end

    if data ~= "" and self.inst.replica.ksfun_power_system then
        self.inst.replica.ksfun_power_system:SyncData(data)
    end
end





function KSFUN_POWERS:OnSave()
    if next(self.powers) == nil then return end
    local data = {}
    for k, v in pairs(self.powers) do
        local saved--[[, refs]] = v.inst:GetSaveRecord()
        data[k] = saved
    end
    return { powers = data, enable = self.enable }
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
                    addPower(self, k, ent)
                end
            end
        end
    end
    self:SyncData()
end


return KSFUN_POWERS