local WORLD_DATA = Class(function(self, inst)
    self.inst = inst
    self.powerdatas = {}
    self.ksfunitems = {}
end)


--- 宝石是不可再生的，没了就是没了，不会恢复计数
function WORLD_DATA:AddWorldItemCount(prefab)
    local data = self.ksfunitems[prefab] or {}
    local count = data.count or 0
    data.count = count + 1
    self.ksfunitems[prefab] = data
end


--- 宝石是不可再生的，没了就是没了，不会恢复计数
function WORLD_DATA:RemoveItemCount(prefab)
    local data = self.ksfunitems[prefab]
    if data and data.count then
        data.count = math.max(0, data.count - 1)
    end
end


function WORLD_DATA:GetWorldItemCount(prefab)
    local data = self.ksfunitems[prefab]
    if data then
        return data.count or 0
    else
        return 0
    end
end


function WORLD_DATA:OnSave()
    return {
        ksfunitems = self.ksfunitems,
    }
end


function WORLD_DATA:OnLoad(data)
    self.ksfunitems = data and data.ksfunitems or {}
end


return WORLD_DATA