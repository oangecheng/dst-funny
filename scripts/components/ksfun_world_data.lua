local WORLD_DATA = Class(function(self, inst)
    self.inst = inst
    self.powerdatas = {}
    self.ksfunitems = {}
end)


--- 属性计数器+1
function WORLD_DATA:AddWorldPowerCount(name)
    local data = self.powerdatas[name] or {}
    local count = data.count or 0
    data.count = count + 1
    self.powerdatas[name] = data
end


--- 属性计数器-1
function WORLD_DATA:RemoveWorldPowerCount(name)
    local data = self.powerdatas[name]
    if data then
        local count = data.count or 0
        data.count = math.max(0, count-1)
    end
end


--- 宝石是不可再生的，没了就是没了，不会恢复计数
function WORLD_DATA:AddWorldItemCount(prefab)
    local data = self.ksfunitems[prefab] or {}
    local count = data.count or 0
    data.count = count + 1
    self.ksfunitems[prefab] = data
end


function WORLD_DATA:GetWorldItemCount(prefab)
    local data = self.ksfunitems[prefab]
    if data then
        return data.count or 0
    else
        return 0
    end
end


--- 获取属性计数器 
function WORLD_DATA:GetWorldPowerCount(name)
    local data = self.powerdatas[name]
    if data then
        return data.count or 0
    else
        return 0
    end
end


function WORLD_DATA:OnSave()
    return {
        powerdatas = self.powerdatas,
        ksfunitems = self.ksfunitems,
    }
end


function WORLD_DATA:OnLoad(data)
    self.powerdatas = data and data.powerdatas or {}
    self.ksfunitems = data and data.ksfunitems or {}
end


return WORLD_DATA