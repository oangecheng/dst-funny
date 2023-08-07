local function addPower(self, name, ent)
    if ent.components.ksfun_power then
        self.powers[name] = {
            inst = ent,
        }
        ent.persists = false

        --- 属性系统才可以绑定
        ent.components.ksfun_power:Attach(name, self.inst)
        self.inst:PushEvent(KSFUN_TUNING.EVENTS.POWER_ATTACH, { name = name, power = ent })
    else
        ent:Remove()
    end
end



local KSFUN_POWERS = Class(function(self, inst)
    self.inst = inst
    self.enable = true
    self.powers = {}
    self.ongain = nil
    self.onlost = nil
end)


function KSFUN_POWERS:GetPower(name)
    local power = self.powers[name]
    if power then
        return power.inst
    else
        return nil
    end
end


--- 新增一个属性
--- 对于一个inst，同一种属性只能添加一次，多次添加无效，会回调 OnExtend
--- 对于临时power可以延长时间
--- @param name 属性名称
--- @param p 属性实体，这个一般只有在发生属性迁移的时候才会传参
function KSFUN_POWERS:AddPower(name, p)
    local existed = self.powers[name]
    local ret = nil
    if existed == nil then
        local ent = p and p or SpawnPrefab("ksfun_power_"..name)
        if ent then
            addPower(self, name, ent)
            if self.ongain then
                self.ongain(self.inst, { name = name, power = ent } )
            end
        end
        ret = ent
    else
        existed.inst.components.ksfun_power:Extend()
        ret = existed.inst
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
        power.inst.components.ksfun_power:Detach()
        if self.onlost then
            self.onlost(self.inst, { name = name, power = power.inst } )
        end
        self:SyncData()
        self.inst:DoTaskInTime(0.1, power.inst:Remove()) 
    end
end



function KSFUN_POWERS:SetOnGainPowerFunc(func)
    self.ongain = func
end


function KSFUN_POWERS:SetOnLostPowerFunc(func)
    self.onlost = func
end


--- 获取当前属性的数量
function KSFUN_POWERS:GetPowerNum()
    local powers = self:GetAllPowers()
    return GetTableSize(powers)
end


function KSFUN_POWERS:GetPowerNames()
    local list = {}
    local powers = self:GetAllPowers()
    for k,v in pairs(powers) do
        table.insert(list, k)
    end
    return list
end


--- 获取当前的属性列表, 非临时属性
function KSFUN_POWERS:GetAllPowers()
    local list = {}
    for k,v in pairs(self.powers) do
        if not v.inst.components.ksfun_power:IsTemp() then
            list[k] = v.inst
        end
    end
    return list
end



local function getTitle(inst)
    local prefab = inst.prefab
    local name = KsFunGetPrefabName(inst.prefab)
    if inst.components.ksfun_activatable and inst.components.ksfun_activatable:IsActivated() then
        local cnt = inst.components.ksfun_breakable:GetCount()
        -- 1阶战斗长矛
        name = cnt..STRINGS.KSFUN_BREAK_COUNT..name
    end
    local level = inst.components.ksfun_level
    local lv = level and level:GetLevel() or -1
    return prefab,name,lv 
end


--- 同步用户数据
--- power的等级经验
function KSFUN_POWERS:SyncData()

    local prefab,name,lv = getTitle(self.inst)
    local data = prefab.."|"..name.."|"..lv

    local powers = self:GetAllPowers()
    for k, power in pairs(powers) do
        local lv   = power.components.ksfun_level:GetLevel()
        local exp  = power.components.ksfun_level:GetExp()
        local desc = power.components.ksfun_power:GetDesc()
        local bcnt = power.components.ksfun_breakable and power.components.ksfun_breakable:GetCount() or -1
        -- 名称|等级|经验值|描述|等阶
        local d = k .. "|" .. tostring(lv) .. "|" .. tostring(exp) .. "|" ..desc .."|" .. tostring(bcnt)
        data = data .."#".. d
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