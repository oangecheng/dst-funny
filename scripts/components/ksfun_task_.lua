

local KSFUN_TASK = Class(function(self, inst)
    self.inst = inst
    self.player = nil
    self.name = nil
    self.state = 0

    self.onAttachFunc = nil
    self.onDetachFunc = nil

    self.onStartFunc = nil
    self.onStopFunc = nil

    self.onWinFunc = nil
    self.onLoseFunc = nil
end)


-- player 任务需要绑定角色
function KSFUN_TASK:Attach(player)
    self.state = 1
    self.player = player
    if self.onAttachFunc then
        self.onAttachFunc(self.inst, self.player)
    end
end


-- player 任务解除绑定角色
function KSFUN_TASK:Deatch()
    local p = self.player
    self.player = nil
    self.state = 0
    if p and self.onDetachFunc then
        self.onDetachFunc(self.inst, p)
    end
end


--- 开始任务
function KSFUN_TASK:Start()
    self.state = 1
    if self.player and self.onStartFunc then
        self.onStartFunc(self.inst, self.player)
    end
end


--- 停止任务
function KSFUN_TASK:Stop()
    self.state = 2
    if self.player and self.onStopFunc then
        self.onStopFunc(self.inst, self.player)
    end
end


--- 任务胜利
function KSFUN_TASK:Win()
    self.state = 3
    if self.player and self.onWinFunc then
        self.onWinFunc(self.inst, self.player)
    end
end

--- 任务失败
function KSFUN_TASK:Lose()
    self.state = 4
    if self.player and self.onLoseFunc then
        self.onLoseFunc(self.inst, self.player)
    end
end


return KSFUN_TASK