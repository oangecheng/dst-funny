local Widget = require "widgets/widget"
local TextButton = require "widgets/textbutton"
local Button = require "widgets/button"
local Text = require "widgets/text"
local Image = require "widgets/image"

local NAMES = KSFUN_TUNING.PLAYER_POWER_NAMES

local card_width = 800
local card_padding = 20
local card_height = 50
local card_space = 5


local KSFUN_PLAYER_PANEL = Class(Widget, function(self, owner)
	Widget._ctor(self, "KSFUN_PLAYER_PANEL")
	self.owner = owner
	self.root = self:AddChild(Widget("ROOT"))
	
	self.y = 500
	self.x = 500

	self.offsetY = 0

	self.powers = {}
	self.tasks = {}

	self.pageClose = self.root:AddChild(TextButton())
    self.pageClose:SetText("关闭")
	self.pageClose:SetScale(2, 2, 2)
	self.pageClose:SetHAnchor(0) -- 设置原点x坐标位置，0、1、2分别对应屏幕中、左、右
	self.pageClose:SetVAnchor(0) -- 设置原点y坐标位置，0、1、2分别对应屏幕中、上、下
	self.pageClose:SetPosition(self.x,  self.y, 0)
	self.pageClose:SetOnClick(function()
		self:KsFunHide()
		owner.player_panel_showing = false
	end)

	-- 面板距离关闭按钮50
	self.offsetY = self.offsetY - 50

	-- 监听变化，这个应该放外边去，临时
	owner:ListenForEvent(KSFUN_TUNING.EVENTS.PLAYER_PANEL, function(inst, data)
		-- local y = self:AddPowerCards()
		-- self:AddTaskCards(y)
	end)
end)



local function getEquipments(self)
	if TheWorld.ismastersim then
		if self.owner.components.inventory ~= nil then
			for k, v in pairs(self.owner.components.inventory.equipslots) do
				self:AddPowerCards(v)
			end
		end
	else
		local inventory = self.owner.replica.inventory
		if inventory ~= nil then
			for k, v in pairs(inventory:GetEquips()) do
				self:AddPowerCards(v)
			end
		end
	end
end


-- 新增一条向下偏移位置
local function updateCardOffsetY(self)
	self.offsetY = self.offsetY - (card_height + card_space)
end


function KSFUN_PLAYER_PANEL:KsFunShow()
	self:Show()
	self.offsetY = - 50
	self:AddPowerCards(self.owner)
	self:AddTaskCards()
	getEquipments(self)
end


function KSFUN_PLAYER_PANEL:KsFunHide()
	self:Hide()
	for k,v in pairs(self.powers) do
		v:Kill()
		self.powers[k] = nil
	end
	self.powers = {}
	for k,v in pairs(self.tasks) do
		v:Kill()
		self.tasks[k] = nil		
	end
	self.tasks = {}
end



function KSFUN_PLAYER_PANEL:AddPowerCards(inst)

	local powers = {}
	if TheWorld.ismastersim then
		local system = inst.components.ksfun_power_system
		if system ~= nil then
			local list = system:GetAllPowers()
			for k,v in pairs(list) do
				local l = v.components.ksfun_level
				list[k] = {name = k, lv = l.lv, exp = l.exp}
			end
		end
		
	else
		local system = inst.replica.ksfun_power_system
		if system then
			powers = system:GetPowers()
		end
	end

	for k,v in pairs(powers) do
		local name = string.upper("ksfun_power_"..k)
		name = STRINGS.NAMES[name]
		if self.powers[k] == nil then
			self.powers[k] = self.root:AddChild(self:KsFunCard())
		end

		self.powers[k].title:SetString(name)
		self.powers[k].desc:SetString("等级: "..v.lv.."  经验: "..v.exp)

		self.powers[k]:SetHAnchor(0)
		self.powers[k]:SetVAnchor(0)
		self.powers[k]:SetPosition(self.x, self.y + self.offsetY, 0)

		updateCardOffsetY(self)
	end
end



function KSFUN_PLAYER_PANEL:AddTaskCards()
	local system = self.owner.replica.ksfun_task_system

	local tasks = system:GetTasks()
	if tasks then
		for k,v in pairs(tasks) do
			local name = string.upper("ksfun_task_"..k)
			name = STRINGS.NAMES[name]
			if self.tasks[k] == nil then
				self.tasks[k] = self.root:AddChild(self:KsFunCard())
			end
			
			self.tasks[k].title:SetString(name)
			self.tasks[k].desc:SetString(v.desc)

			self.tasks[k]:SetHAnchor(0)
			self.tasks[k]:SetVAnchor(0)
			self.tasks[k]:SetPosition(self.x, self.y + self.offsetY, 0)
			
			updateCardOffsetY(self)
		end
	end
end


--构造单个buff卡
function KSFUN_PLAYER_PANEL:KsFunCard()
	local widget = Widget()--生成选项卡，编号不同

	local p = card_padding
	local w = card_width
	local half_w = (w - 2*p)/2


	widget.bg = widget:AddChild(Image("images/global.xml", "square.tex"))
	widget.bg:SetSize(w, card_height)
	widget.bg:SetTint(0, 0, 0, 0.5)
	
	-- 属性名称
	widget.title = widget:AddChild(Text(BODYTEXTFONT, 45))
	widget.title:SetPosition(-half_w/2, 0)
	widget.title:SetRegionSize(half_w, card_height)
	widget.title:SetHAlign( ANCHOR_LEFT )--ANCHOR_RIGHT)
	widget.title:SetVAlign( 0 )--ANCHOR_RIGHT)
	widget.title:SetString("")
	widget.title:SetColour(1, 1, 1, 1)

	-- 属性值
	widget.desc = widget:AddChild(Text(BODYTEXTFONT, 45))
	widget.desc:SetPosition(half_w / 4, 0)
	widget.desc:SetRegionSize(half_w * 1.5, card_height)
	widget.desc:SetHAlign( ANCHOR_LEFT)
	widget.desc:SetVAlign( 0 )--ANCHOR_RIGHT)

	widget.desc:SetString("")
	widget.desc:SetColour(1, 1, 1, 1)

	return widget
end


function KSFUN_PLAYER_PANEL:AddItemsCard()

end


return KSFUN_PLAYER_PANEL