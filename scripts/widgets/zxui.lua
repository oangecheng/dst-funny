local ZxSkinPopupScreen = require "screens/zxskinscreen"--皮肤界面


AddClassPostConstruct("screens/playerhud", function(self, anim, owner)
    KsFunLog("AddClassPostConstruct", self.owner)
	self.ShowKsFunScreen = function(_, holder)
		self.zxskinscreen = ZxSkinPopupScreen(self.owner)
        self:OpenScreenUnderPause(self.zxskinscreen)
        return self.zxskinscreen
	end

    self.CloseKsFunScreen = function(_)
		if self.zxskinscreen ~= nil then
            if self.zxskinscreen.inst:IsValid() then
                TheFrontEnd:PopScreen(self.zxskinscreen)
            end
            self.zxskinscreen = nil
        end
	end
end)


AddPopup("KSFUNSCREEN")
POPUPS.KSFUNSCREEN.fn = function(inst, show, holder)
    if inst.HUD then
        if not show then
            inst.HUD:CloseKsFunScreen()
        elseif not inst.HUD:ShowKsFunScreen(holder) then
            POPUPS.KSFUNSCREEN:Close(inst)
        end
    end
end


