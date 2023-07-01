local WORLD_DATA = Class(function(self, inst)
    self.inst = inst
    self.powerdatas = {}
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
        powerdatas = self.powerdatas
    }
end


function WORLD_DATA:OnLoad(data)
    self.powerdatas = data and data.powerdatas or {}
end


return WORLD_DATA