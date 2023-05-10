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
	local x = 500
	local y = 500

	local offsetX = x
	local offsetY = 0

	-- offsetY = offsetY - 50
	-- self["buff_card_title"] = self.root:AddChild(self:BuffCard())
	-- self["buff_card_title"]:SetHAnchor(0)
	-- self["buff_card_title"]:SetVAnchor(0)
	-- self["buff_card_title"]:SetPosition(x, y + offsetY, 0)


	offsetY = offsetY - 50
	self["buff_card"] = self.root:AddChild(self:BuffCard())
	self["buff_card"]:SetHAnchor(0)
	self["buff_card"]:SetVAnchor(0)
	self["buff_card"]:SetPosition(x, y + offsetY, 0)

	self.pageClose = self.root:AddChild(TextButton())
    self.pageClose:SetText("关闭")
	self.pageClose:SetScale(2, 2, 2)
	self.pageClose:SetHAnchor(0) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
	self.pageClose:SetVAnchor(0) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下
	self.pageClose:SetPosition(x,  y, 0)
	self.pageClose:SetOnClick(function()
		self:Hide()
		owner.player_panel_showing = false
	end)



	-- 监听变化，这个应该放外边去，临时
	owner:ListenForEvent(KSFUN_TUNING.EVENTS.PLAYER_PANEL, function(inst, data)
		-- onPlayerStateChange(self, data, inst)
	end)


end)


--构造单个buff卡
function KSFUN_PLAYER_PANEL:BuffCard()
	local widget = Widget()--生成选项卡，编号不同

	local p = 10
	local w = 1000
	local half_w = (w - 2*p)/2


	widget.bg = widget:AddChild(Image("images/global.xml", "square.tex"))
	widget.bg:SetSize(w, 45)
	widget.bg:SetTint(0, 0, 0, 0.5)
	
	--buff时长
	widget.buff_time = widget:AddChild(Text(BODYTEXTFONT, 45))
	widget.buff_time:SetPosition(-half_w/2, 0)
	widget.buff_time:SetRegionSize(half_w, 45 )
	widget.buff_time:SetHAlign( ANCHOR_MIDDLE )--ANCHOR_RIGHT)
	widget.buff_time:SetVAlign( 0 )--ANCHOR_RIGHT)
	widget.buff_time:SetString("属性：血量")
	widget.buff_time:SetColour(1, 1, 1, 1)

	--buff名
	widget.buff_name = widget:AddChild(Text(BODYTEXTFONT, 45))
	widget.buff_name:SetPosition(half_w/2, 0)
	widget.buff_name:SetRegionSize(half_w, 45)
	widget.buff_name:SetHAlign( ANCHOR_MIDDLE)
	widget.buff_time:SetVAlign( 0 )--ANCHOR_RIGHT)

	widget.buff_name:SetString("描述：等级100")
	widget.buff_name:SetColour(1, 1, 1, 1)

	return widget
end



return KSFUN_PLAYER_PANEL