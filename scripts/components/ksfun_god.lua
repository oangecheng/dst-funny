
local function ongodchange(self, god)
    if self.ongodfn then
        self.ongodfn(self.inst, god)
    end
end


local God = Class(
    function (self, inst)
        self.inst = inst
        self.god = 1
        self.max = 4
        self.enable = false
    end,
    nil,
    {
        god = ongodchange
    }
)


---comment 启用功能
function God:Enable()
    self.enable = true
end


---comment 设置最大等阶
---@param max integer
function God:SetMax(max)
    self.max = math.max(max, 4)
end


---comment 设置等阶提升回调
---@param fn function
function God:SetOnGodFn(fn)
    self.ongodfn = fn
end


---comment 判断是否是真神
---@return boolean
function God:IsGod()
    return self.god >= self.max
end


function God:GetGod()
    return self.god
end


---comment 提升等阶
function God:Upgrade()
    KsFunLog("Upgrade", self.enable, self.max, self.god)
    if self.enable then
        local god = math.min(self.max, self.god + 1)
        if self.god ~= god then
            self.god = god
            return true
        end
    end
    return false
end


function God:OnLoad(data)
    self.enable = data.enable
    self.god = data.god
end


function God:OnSave()
    return {
        enable = self.enable,
        god = self.god,
    }
end


return God