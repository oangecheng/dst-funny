local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local MultiTabWidget = require "widgets/redux/ksfun_task_widget"

local ZxSkinPopupScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "ZxSkinPopupScreen")

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0,0,0,.5)
    black:SetOnClick(function() TheFrontEnd:PopScreen() end)
    black:SetHelpTextMessage("")

	local root = self:AddChild(Widget("root"))
	root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
	root:SetPosition(0, -25)

	self.zxskin = root:AddChild(MultiTabWidget(owner))

	self.default_focus = self.zxskin

    SetAutopaused(true)
end)

function ZxSkinPopupScreen:OnDestroy()
    SetAutopaused(false)
    POPUPS.KSFUNSCREEN:Close(self.owner)
	ZxSkinPopupScreen._base.OnDestroy(self)
end

function ZxSkinPopupScreen:OnBecomeInactive()
    ZxSkinPopupScreen._base.OnBecomeInactive(self)
end

function ZxSkinPopupScreen:OnBecomeActive()
    ZxSkinPopupScreen._base.OnBecomeActive(self)
end

function ZxSkinPopupScreen:OnControl(control, down)
    if ZxSkinPopupScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end

	return false
end

function ZxSkinPopupScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return ZxSkinPopupScreen
