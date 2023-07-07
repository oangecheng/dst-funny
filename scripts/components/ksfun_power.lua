
local KSFUN_POWER = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self.name = nil
    self.enable = true
    -- 这个字段是用来缓存物品原本的属性
    self.data = nil
    self.istemp = false

    self.onAttachFunc = nil
    self.onEnableChanged = nil
    self.onDetachFunc = nil
    self.onExtendFunc = nil
    self.onGetDescFunc = nil
end)

--- 设置监听
--- @param func arg1=self.inst arg2=self.target 
function KSFUN_POWER:SetOnAttachFunc(func)
    self.onAttachFunc = func
end

--- 设置监听
--- @param func arg1=self.inst arg2=self.target 
function KSFUN_POWER:SetOnDetachFunc(func)
    self.onDetachFunc = func
end

--- 设置监听
--- @param func arg1=self.inst arg2=self.target 
function KSFUN_POWER:SetOnExtendFunc(func)
    self.onExtendFunc = func
end


function KSFUN_POWER:SetOnGetDescFunc(func)
    self.onGetDescFunc = func
end

function KSFUN_POWER:SetOnEnableChangedFunc(func)
    self.onEnableChanged = func
end


function KSFUN_POWER:SetEnable(enable)
    self.enable = enable
    if self.onEnableChanged then
        self.onEnableChanged(self.enable)
    end
end


function KSFUN_POWER:SetTemp()
    self.istemp = true
end


function KSFUN_POWER:IsTemp()
    return self.istemp
end


function KSFUN_POWER:IsEnable()
    return self.enable
end


function KSFUN_POWER:GetData()
    return self.data
end


function KSFUN_POWER:SetData(data)
    if self.data == nil then
        self.data = data
    end
end


function KSFUN_POWER:GetName()
    return self.name
end


--- 绑定到目标
--- 目标可以是人物，也可以是物品
--- @param target type inst 
function KSFUN_POWER:Attach(name, target)
    -- nil说明没解绑，不允许重新绑定
    if self.target ~= nil then return end
    self.target = target
    self.name = name
    if self.onAttachFunc then
        self.onAttachFunc(self.inst, target, name)
    end
end


--- 解绑目标
--- 属性系统可以换绑
--- 如果target为nil，则认为无效，因为还没有绑定过
function KSFUN_POWER:Detach()
    -- nil说明没绑定，不允许解绑
    if self.target == nil then return end
    local temp = self.target
    self.target = nil
    if temp and self.onDetachFunc then
        self.onDetachFunc(self.inst, temp, self.name)
    end
    -- 缓存的数据要清理掉
    self.data = nil
end


--- 属性覆盖
--- 一般用在临时属性上
function KSFUN_POWER:Extend()
    if self.onExtendFunc and self.target then
        self.onExtendFunc(self.inst, self.target, self.name)
    end
end


--- 获取属性描述
--- @return string
function KSFUN_POWER:GetDesc()
    if self.onGetDescFunc and self.target then
        return self.onGetDescFunc(self.inst, self.target, self.name)
    else
        return "default"
    end
end


function KSFUN_POWER:OnSave()
    return {
        data = self.data,
        istemp = self.istemp,
    }
end


function KSFUN_POWER:OnLoad(d)
    self.data = d.data or nil
    self.istemp = d.istemp
end


return KSFUN_POWER