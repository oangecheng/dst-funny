
local KSFUN_POWER = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self.name = nil

    self.onAttachFunc = nil
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


function KSFUN_POWER:SetOnGetDescFun(func)
    self.onGetDescFunc = func
end


--- 绑定到目标
--- 目标可以是人物，也可以是物品
--- @param target type inst 
function KSFUN_POWER:Attach(name, target)
    self.target = target
    self.name = name
    if self.onAttachFun then
        self.onAttachFun(self.inst, target, name)
    end
end


--- 解绑目标
--- 属性系统可以换绑
function KSFUN_POWER:Deatch()
    local temp = self.target
    self.target = nil
    if self.onDetachFunc then
        self.onDetachFunc(self.inst, temp, self.name)
    end
end


--- 属性覆盖
function KSFUN_POWER:Extend()
    if self.onExtendFunc then
        self.onExtendFunc(self.inst, self.target, self.name)
    end
end


--- 获取属性描述
--- @return string
function KSFUN_POWER:GetDesc()
    if self.onGetDescFunc and self.target then
        return self.onGetDescFunc(self.onGetDescFunc)
    else
        return nil
    end
end


return KSFUN_POWER