local Widget = require "widgets/widget"
local TextButton = require "widgets/textbutton"
local Button = require "widgets/button"
local Text = require "widgets/text"
local Image = require "widgets/image"

local KSFUN_PLAYER_PANEL = Class(Widget, function(self, owner)
	Widget._ctor(self, "KSFUN_PLAYER_PANEL")
	self.root = self:AddChild(Widget("ROOT"))
	
	local scale = 2
	local x = 0
	local y = 500
	local half_w = 512 * scale / 4
	local half_h = 512 * scale / 4
	
	self.bg = self.root:AddChild(Image("images/ksfun_player_panel_bg.xml", "ksfun_player_panel_bg.tex"))
	self.bg:SetScale(scale, scale, scale)
	self.bg:SetHAnchor(0)
	self.bg:SetVAnchor(0)
	self.bg:SetPosition(0, y, 0)

	
	self.pageIcon = self.root:AddChild(TextButton())
    self.pageIcon:SetText("关闭")
	self.pageIcon:SetScale(2, 2, 2)
	self.pageIcon:SetHAnchor(0) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
	self.pageIcon:SetVAnchor(0) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下
	self.pageIcon:SetPosition(x,  y - half_h - 25, 0)


	self.pageIcon:SetOnClick(function()
		self:Hide()
		owner.player_panel_showing = false
		if owner.replica.ksfun_hunger then
			self.pageIcon:SetText("level "..owner.replica.ksfun_hunger.level)
		end
	end)
end)

return KSFUN_PLAYER_PANEL