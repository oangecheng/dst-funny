

local KSFUN_QUALITY = Class(function(self, inst)
    self.inst = inst
    self.quality = nil
    self.onQualityChangeFun = nil
end)


--- 设置品质
--- @param quality int 见 KSFUN_TUNING.QUALITY
function KSFUN_QUALITY:SetQuality(quality)
    self.quality = quality
    if self.onQualityChangeFun then
        self.onQualityChangeFun(self.inst)
    end
end

function KSFUN_QUALITY:GetQulity()
    return self.quality or 0
end

function KSFUN_QUALITY: GetQulityDesc()
    if self.quality == 1 then
        return "白色"
    end
end


return KSFUN_QUALITY