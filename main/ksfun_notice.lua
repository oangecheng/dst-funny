local Widget = require("widgets/widget")
local Text   = require("widgets/text")

-- 创建一个自定义的提示信息窗口类
local KsFunNoticeWidget = Class(Widget, function(self)
    Widget._ctor(self, "KsFunNoticeWidget")

    -- 创建文本组件用于显示提示信息
    self.text = self:AddChild(Text(CHATFONT, 28))
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:SetVAlign(ANCHOR_MIDDLE)
    self.text:SetPosition(0, 0)
end)


-- 定义一个函数，用于显示提示信息
local function showMessage(message)
    -- 创建一个提示信息窗口
    local notice = KsFunNoticeWidget()
    -- 设置提示信息文本
    notice.text:SetString(message)
    -- 添加到HUD组件中显示
    ThePlayer.HUD:AddChild(notice)
    -- 设置显示时间
    notice:DoTaskInTime(5, function()
        notice:Kill()
    end)
end



local notice = {}

notice.showNotice = showNotice

return notice