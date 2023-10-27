local ZxSkinPopupScreen = require "screens/ksfun_screen"--皮肤界面


AddClassPostConstruct("screens/playerhud", function(self, anim, owner)
	self.ShowKsFunScreen = function(_, holder)
		self.ksfunscreen = ZxSkinPopupScreen(self.owner)
        self:OpenScreenUnderPause(self.ksfunscreen)
        return self.ksfunscreen
	end

    self.CloseKsFunScreen = function(_)
		if self.ksfunscreen ~= nil then
            if self.ksfunscreen.inst:IsValid() then
                TheFrontEnd:PopScreen(self.ksfunscreen)
            end
            self.ksfunscreen = nil
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


