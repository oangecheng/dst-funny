

local KSFUN_TASK = Class(function(self, inst)
    self.inst = inst
    self.player = nil
    self.target = nil

    self.state = 0
    self.desc = "击杀巨鹿1只"
    self.type = "ksfun_hunger"
    self.demand = nil
    self.reward = nil
    self.punish = nil

    self.on_success = nil
    self.on_fail = nil
    self.on_start = nil
end)

-- 任务开始
-- 任务需要绑定角色
function KSFUN_TASK:Start(player, target)
    self.player = player
    self.target = target
    if self.on_start then
        self.on_start(self.inst, self)
    end
end

-- 任务成功回调
function KSFUN_TASK:Success()
    self.state = 1
    if self.on_success then
        self.on_success(self.inst, self)
    end
end

-- 任务失败回调
function KSFUN_TASK:Fail()
    self.state = -1
    if self.on_fail then
        self.on_fail(self.inst, self)
    end
end