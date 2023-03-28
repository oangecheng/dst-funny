

local KSFUN_TASK = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self.name = nil

    self.state = nil
    self.desc = "做任务哦！"
    self.demand = nil
    self.reward = nil
    self.punish = nil

    self.onSuccess = nil
    self.onFail = nil
    self.onStart = nil
    self.onAttach = nil
end)


-- player 任务需要绑定角色
function KSFUN_TASK:Bind(target)
    self.state = 0
    self.target = target
    if self.onAttach then
        self.onAttach(self)
    end
end


-- 任务开始
function KSFUN_TASK:Start()
    self.state = 1
    if self.onStart then
        self.onStart(self)
    end
end


-- 任务成功回调
function KSFUN_TASK:Success()
    self.state = 2
    if self.onSuccess then
        self.onSuccess(self)
    end
end  

-- 任务失败回调
function KSFUN_TASK:Fail()
    self.state = -1
    if self.onFail then
        self.onFail(self)
    end
end


return KSFUN_TASK