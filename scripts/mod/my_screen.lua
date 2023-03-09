local Widget = require "widgets/widget"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"

local medalPage = Class(Widget, function(self, owner)
	Widget._ctor(self, "medalPage")
	self.root = self:AddChild(Widget("ROOT"))		
	self.pageIcon = self.root:AddChild(TextButton())
    self.pageIcon:SetText("OK")
	self.pageIcon:SetScale(2, 2, 2)
	self.pageIcon:SetHAnchor(0) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
	self.pageIcon:SetVAnchor(0) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下
	self.pageIcon:SetPosition(26,26,0)
	self.pageIcon:SetTooltip("123")--tips
	self.pageIcon:SetOnClick(function()
		-- VisitURL("https://www.guanziheng.com/", false)
		if owner.replica.ksfun_hunger then
			self.pageIcon:SetText("level "..owner.replica.ksfun_hunger.level)
		end
	end)
end)

return medalPage