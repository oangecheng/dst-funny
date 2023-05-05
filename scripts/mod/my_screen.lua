local Widget = require "widgets/widget"
local TextButton = require "widgets/textbutton"
local Button = require "widgets/button"
local Text = require "widgets/text"
local Image = require "widgets/image"

local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES


local function onPlayerStateChange(self, powers, owner)
	print(KSFUN_TUNING.LOG_TAG.."ksfun_player_panel onPlayerStateChange")
	local hunger = powers[NAMES.HUNGER]
	if hunger then
		self.hunger:Show()
		self.hunger:SetString("饱食度: 等级=" .. tostring(hunger.lv) .. "  经验=" .. tostring(hunger.exp))
	end
	local sanity = powers[NAMES.SANITY]
	if sanity then
		self.sanity:Show()
		self.sanity:SetString("精神值: 等级=" .. tostring(sanity.lv) .. "  经验=" .. tostring(sanity.exp))
	end
	local health = powers[NAMES.HEALTH]
	if health then
		self.health:Show()
		self.health:SetString("生命值: 等级=" .. tostring(health.lv) .. "  经验=" .. tostring(health.exp))
	end
end


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


	local offsetX = x
	local offsetY = half_h + 25

	self.title = self.root:AddChild(Text(NEWFONT, 25))
	self.title:SetString("属性面板")
	self.title:SetScale(2, 2, 2)
	self.title:SetHAnchor(0)
	self.title:SetVAnchor(0)
	self.title:SetPosition(x,  y + offsetY , 0)

	offsetY = offsetY - 75

	self.hunger = self.root:AddChild(Text(NEWFONT, 25))
	self.hunger:SetScale(2, 2, 2)
	self.hunger:SetHAnchor(0)
	self.hunger:SetVAnchor(0)
	self.hunger:SetPosition(x,  y + offsetY, 0)

	offsetY = offsetY - 50

	self.sanity = self.root:AddChild(Text(NEWFONT, 25))
	self.sanity:SetScale(2, 2, 2)
	self.sanity:SetHAnchor(0)
	self.sanity:SetVAnchor(0)
	self.sanity:SetPosition(x,  y + offsetY, 0)

	offsetY = offsetY - 50

	self.health = self.root:AddChild(Text(NEWFONT, 25))
	self.health:SetScale(2, 2, 2)
	self.health:SetHAnchor(0)
	self.health:SetVAnchor(0)
	self.health:SetPosition(x,  y + offsetY, 0)
	

	self.pageClose = self.root:AddChild(TextButton())
    self.pageClose:SetText("关闭")
	self.pageClose:SetScale(2, 2, 2)
	self.pageClose:SetHAnchor(0) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
	self.pageClose:SetVAnchor(0) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下
	self.pageClose:SetPosition(x,  y - half_h - 25, 0)
	self.pageClose:SetOnClick(function()
		self:Hide()
		owner.player_panel_showing = false
	end)

	-- 监听变化，这个应该放外边去，临时
	owner:ListenForEvent(KSFUN_TUNING.EVENTS.PLAYER_PANEL, function(inst, data)
		onPlayerStateChange(self, data, inst)
	end)

end)



return KSFUN_PLAYER_PANEL