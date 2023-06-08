local Widget = require("widgets/widget")
local Text   = require("widgets/text")
local TextButton = require "widgets/textbutton"


-- 创建一个自定义的提示信息窗口类
local KsFunNoticeWidget = Class(Widget, function(self)
    Widget._ctor(self, "KsFunNoticeWidget")
    self.root = self:AddChild(Widget("ROOT"))		

    self.text = self.root:AddChild(TextButton())
    self.text:SetText("关闭")

    -- 创建文本组件用于显示提示信息
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:SetVAlign(ANCHOR_MIDDLE)
    self.text:SetPosition(0, 0)
end)


-- 定义一个函数，用于显示提示信息
function KsFunNoticeWidget:ShowNotice(message)

    KsFunLog("showMessage 111", ThePlayer == nil)
    if ThePlayer == nil then return end
    -- 设置提示信息文本
    self.text:SetText(message)
    -- 添加到HUD组件中显示
    ThePlayer.HUD:AddChild(self)
    -- 设置显示时间
    self:DoTaskInTime(5, function()
        self:Kill()
    end)
end



return KsFunNoticeWidget