local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local Spinner = require "widgets/spinner"
local PopupDialogScreen = require "screens/redux/popupdialog"


local function AddPowerCards(inst)

	local powers = {}

	if TheWorld.ismastersim then
		local system = inst.components.ksfun_power_system
		if system ~= nil then
			local list = system:GetAllPowers()
			for k,v in pairs(list) do
				local l = v.components.ksfun_level
				local d = v.components.ksfun_power:GetDesc()
				local bcnt = v.components.ksfun_breakable and v.components.ksfun_breakable:GetCount() or -1
				powers[k] = {name = k, lv = l:GetLevel(), exp = l:GetExp(), desc = d, bcnt = bcnt}
			end
		end
	
	else
		local system = inst.replica.ksfun_power_system
		if system then
			powers = system:GetPowers()
		end
	end

	return powers
end



local GridPage = Class(Widget, function(self, parent_widget, owner)
    Widget._ctor(self, "GridPage")

    self.parent_widget = parent_widget
	self.root = self:AddChild(Widget("root"))

	--皮肤面板
	self.skin_grid = self.root:AddChild(self:BuildSkinScrollGrid())
	self.skin_grid:SetPosition(-15, -12)

	--当前货币数量
	self.skin_money = self.root:AddChild(Text(CODEFONT, 24))
	self.skin_money:SetPosition(-345, 242)
	self.skin_money:SetRegionSize( 70, 24 )
	self.skin_money:SetHAlign( ANCHOR_LEFT)
	self.skin_money:SetString("888")
	self.skin_money:SetColour(UICOLOURS.GOLD)

	--已解锁皮肤数量(文字)
	self.skin_num = self.root:AddChild(Text(CODEFONT, 24))
	self.skin_num:SetPosition(-250, 243)
	self.skin_num:SetRegionSize( 150, 24 )
	self.skin_num:SetHAlign( ANCHOR_LEFT)
	self.skin_num:SetString("已拥有:2/5")
	self.skin_num:SetColour(UICOLOURS.GOLD)

	local name = STRINGS.NAMES[string.upper(owner.prefab)]

	--提示文字
	self.skin_help = self.root:AddChild(Text(CODEFONT, 24))
	self.skin_help:SetPosition(0, 243)
	self.skin_help:SetRegionSize( 250, 24 )
	self.skin_help:SetHAlign( ANCHOR_LEFT)
	self.skin_help:SetString(name)
	self.skin_help:SetColour(UICOLOURS.GOLD)


	local datas = {}--皮肤数据
	local p = AddPowerCards(owner)
	for _, v in pairs(p) do--遍历皮肤数据表
		table.insert(datas, v)
	end
	self.skin_grid:SetItemsData(datas)
	self.parent_default_focus = self.skin_grid
end)

local textures = {
	arrow_left_normal = "arrow2_left.tex",
	arrow_left_over = "arrow2_left_over.tex",
	arrow_left_disabled = "arrow_left_disabled.tex",
	arrow_left_down = "arrow2_left_down.tex",
	arrow_right_normal = "arrow2_right.tex",
	arrow_right_over = "arrow2_right_over.tex",
	arrow_right_disabled = "arrow_right_disabled.tex",
	arrow_right_down = "arrow2_right_down.tex",
	bg_middle = "blank.tex",
	bg_middle_focus = "blank.tex",
	bg_middle_changing = "blank.tex",
	bg_end = "blank.tex",
	bg_end_focus = "blank.tex",
	bg_end_changing = "blank.tex",
	bg_modified = "option_highlight.tex",
}


--构造皮肤列表
function GridPage:BuildSkinScrollGrid()
    local row_w = 160
    local row_h = 230
	local row_spacing = 2

	local width_spinner = 135
	local width_label = 135
	local height = 25

	local font = HEADERFONT
	local font_size = 20

	local function ScrollWidgetsCtor(context, index)
		local w = Widget("skin-cell-".. index)
		w.cell_root = w:AddChild(ImageButton("images/plantregistry.xml", "plant_entry.tex", "plant_entry_focus.tex"))

		w.focus_forward = w.cell_root

		w.cell_root.ongainfocusfn = function()
			self.skin_grid:OnWidgetFocus(w)
		end
		--外框
		w.skin_seperator = w.cell_root:AddChild(Image("images/plantregistry.xml", "plant_entry_seperator.tex"))
		w.skin_seperator:SetPosition(0, 88)


		-- 属性标题，在每个cell最上方
		w.powername = w.cell_root:AddChild(Text(font, font_size))
		w.powername:SetPosition(0, 100)
		w.powername:SetRegionSize( width_label, height )
		w.powername:SetHAlign( ANCHOR_MIDDLE )

		--- 等级
		w.powerlv = w.cell_root:AddChild(Text(font, font_size))
		w.powerlv:SetPosition(0, 50)
		w.powerlv:SetRegionSize( width_label, height )
		w.powerlv:SetHAlign( ANCHOR_MIDDLE )

		--- 描述
		w.powerdesc = w.cell_root:AddChild(Text(font, font_size))
		w.powerdesc:SetPosition(0, 0)
		w.powerdesc:SetRegionSize( width_label, height )
		w.powerdesc:SetHAlign( ANCHOR_MIDDLE )

		--已购买文字显示
		w.bought_label = w.cell_root:AddChild(Text(font, font_size))
		w.bought_label:SetPosition(0, -95)
		w.bought_label:SetRegionSize( width_label, height )
		w.bought_label:SetHAlign( ANCHOR_MIDDLE )
		w.bought_label:SetString("已拥有")
		w.bought_label:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
		

		local lean = true
		--皮肤切换箭头
		w.skin_spinner = w.cell_root:AddChild(Spinner({}, width_spinner, height, {font = font, size = font_size}, nil, "images/plantregistry.xml", textures, lean))

		w.skin_spinner:SetPosition(0, -85)
		w.skin_spinner:SetTextColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
		w.skin_spinner.text:SetPosition(8, 12)

		--按钮
		w.buy_button = w.cell_root:AddChild(
			TEMPLATES.StandardButton(
				nil,
				"确定",--按钮文字
				{60, 30}--按钮尺寸
			)
		)
		w.buy_button:SetTextSize(18)
		w.buy_button:SetPosition(0, -95, 0)
		
		--皮肤选项卡展示
		function w:SetSkinPage()
			local data = w.data
			if not data then return end

			local info = data.info
			if info then
				w.powerlv:SetString("等级:"..tostring(info.lv).." 经验:"..tostring(info.exp))
				w.powerdesc:SetString("属性描述:"..tostring(info.desc))
			end

			w.buy_button:SetOnClick(function()
				local popup
				popup = PopupDialogScreen("title", "desc",
					{
						{text = "按钮1", cb = function()
							TheFrontEnd:PopScreen(popup)
						end},
						{text = "按钮2", cb = function()
							TheFrontEnd:PopScreen(popup)
						end},
					}
				)
				TheFrontEnd:PushScreen(popup)
			end)
			w.buy_button:Enable()
		end

		local _OnControl = w.cell_root.OnControl
		w.cell_root.OnControl = function(_, control, down)
			if w.skin_spinner.focus or (control == CONTROL_PREVVALUE or control == CONTROL_NEXTVALUE) then if w.skin_spinner:IsVisible() then w.skin_spinner:OnControl(control, down) end return true end
			if w.buy_button.focus or (control == CONTROL_PREVVALUE or control == CONTROL_NEXTVALUE) then if w.buy_button:IsVisible() then w.buy_button:OnControl(control, down) end return true end
			return _OnControl(_, control, down)
		end

		local _OnGainFocus = w.cell_root.OnGainFocus
		function w.cell_root.OnGainFocus()
			---@diagnostic disable-next-line: redundant-parameter
			_OnGainFocus(w.cell_root)
			w.skin_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator_focus.tex")
			w.powername:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
			w.skin_spinner:SetTextColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
		end

		local _OnLoseFocus = w.cell_root.OnLoseFocus
		function w.cell_root.OnLoseFocus()
			---@diagnostic disable-next-line: redundant-parameter
			_OnLoseFocus(w.cell_root)
			if not w.data then return end
			if ThePlantRegistry:IsAnyPlantStageKnown(w.data.plant) then
				w.skin_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator_active.tex")
			else
				w.skin_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator.tex")
			end
			w.powername:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
			w.skin_spinner:SetTextColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
		end

		function w.cell_root:GetHelpText()
			if not w.skin_spinner.focus and w.skin_spinner:IsVisible() then
				return w.skin_spinner:GetHelpText()
			end
		end

		return w
	end


	--设定皮肤数据
	local function ScrollWidgetSetData(context, widget, data, index)
		if data == nil then
			widget.cell_root:Hide()
			return
		else
			widget.cell_root:Show()
		end

		widget.data = data
		widget:SetSkinPage()

		widget.powername:SetString(KsFunGetPowerNameStr(data.name))

		local spinner_options = {} --皮肤选项卡数据
		-- for i, v in ipairs(data.info) do --遍历数据表，加入到选项卡里
		-- 	table.insert( spinner_options, { text= 100, data = i } )
		-- end

		widget.cell_root:SetTextures("images/plantregistry.xml", "plant_entry_active.tex", "plant_entry_focus.tex")
		widget.skin_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator_active.tex")
		widget.skin_spinner:SetOptions(spinner_options)
		widget.skin_spinner:SetOnChangedFn(function(spinner_data)
			-- do nothing
		end)
		widget.skin_spinner:SetSelected(data.currentid)
    end

    local grid = TEMPLATES.ScrollingGrid(
        {},
        {
            context = {},
            widget_width  = row_w + row_spacing,
            widget_height = row_h + row_spacing,
			force_peek    = true,
            num_visible_rows = 2,
            num_columns      = 5,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetSetData,
            scrollbar_offset = 15,
			scrollbar_height_offset = -60,
			peek_percent = 30/(row_h + row_spacing),
			end_offset = math.abs(1 - 5/(row_h + row_spacing)),
		})

	--滚动条设定
	grid.up_button:SetTextures("images/plantregistry.xml", "plantregistry_recipe_scroll_arrow.tex")
	grid.up_button:SetScale(0.5)

	grid.down_button:SetTextures("images/plantregistry.xml", "plantregistry_recipe_scroll_arrow.tex")
	grid.down_button:SetScale(-0.5)

	grid.scroll_bar_line:SetTexture("images/plantregistry.xml", "plantregistry_recipe_scroll_bar.tex")
	grid.scroll_bar_line:SetScale(.8)

	grid.position_marker:SetTextures("images/plantregistry.xml", "plantregistry_recipe_scroll_handle.tex")
	grid.position_marker.image:SetTexture("images/plantregistry.xml", "plantregistry_recipe_scroll_handle.tex")
	grid.position_marker:SetScale(.6)

    return grid
end


function GridPage:OnControl(control, down)
	if self.plantregistrywidget then
		self.plantregistrywidget:OnControl(control, down)
		return true
	end
	return GridPage._base.OnControl(self, control, down)
end

return GridPage
