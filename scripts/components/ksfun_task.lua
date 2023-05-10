
local function notify(self, func)
    if func and self.player then
        func(self.inst, self.player, self.name)
    end
end



local KSFUN_TASK = Class(function(self, inst)
    self.inst = inst
    self.player = nil
    self.name = nil
    --- state只做一些校验，不做存储，仅仅防重入
    self.state = 0
    self.task_data = {}

    self.onAttachFunc = nil
    self.onDetachFunc = nil

    self.onStartFunc = nil
    self.onStopFunc = nil

    self.onWinFunc = nil
    self.onLoseFunc = nil
end)


function KSFUN_TASK:GetTaskData()
    return self.task_data
end


function KSFUN_TASK:SetTaskData(data)
    self.task_data = data
end


-- player 任务需要绑定角色
function KSFUN_TASK:Attach(name, player)
    if self.state == 0 then
        self.state = 1
        self.name = name
        self.player = player
        notify(self, self.onAttachFunc)
    end
end


-- player 任务解除绑定角色
function KSFUN_TASK:Deatch()
    if self.player and self.state > 0 then
        self.state = 0
        notify(self, self.onDetachFunc)
        self.player = nil
    end
end


--- 开始任务
function KSFUN_TASK:Start()
    if self.player and self.state ~= 2 then
        self.state = 2
        notify(self, self.onStartFunc)
    end
end


--- 停止任务
function KSFUN_TASK:Stop()
    if self.player and self.state ~= 3 then
        self.state = 3
        notify(self, self.onStopFunc)
    end
end


--- 任务胜利
function KSFUN_TASK:Win()
    if self.player and self.state ~= 4 then
        self.state = 4
        notify(self, self.onWinFunc)
    end
end

--- 任务失败
function KSFUN_TASK:Lose()
    if self.player and self.state ~= 5 then
        self.state = 5
        notify(self, self.onLoseFunc)
    end
end


function KSFUN_TASK:OnSave()
    return {task_data = self.task_data}
end


function KSFUN_TASK:OnLoad(data)
    self.task_data = data and data.task_data or {}
end


return KSFUN_TASK