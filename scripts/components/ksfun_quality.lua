local QUALITY = KSFUN_TUNING.ITEM_QUALITY


local KSFUN_QUALITY = Class(function(self, inst)
    self.inst = inst
    self.quality = QUALITY.WHITE
    self.onQualityChangeFunc = nil 
end)


--- 设置品质
--- @param quality 品质 定义见 KSFUN_TUNING.ITEM_QUALITY
function KSFUN_QUALITY:SetQuality(quality)
    if quality >= QUALITY.WHITE and quality <= QUALITY.MAX then
        self.quality = quality
        if self.onQualityChangeFunc then
            self.onQualityChangeFunc(self.inst, quality)
        end
    end
end


--- 品质升级，每次只能提升一个品质
function KSFUN_QUALITY:QualityUpgrade()
    if self.quality < QUALITY.MAX then
        self:SetQuality(self.quality + 1)
    end
end


function KSFUN_QUALITY:OnSave()
    return {
        quality = self.quality,
    }
end


function KSFUN_QUALITY:OnLoad(data)
    self.quality = data.quality or QUALITY.WHITE
    self:SetQuality(self.quality)
end


return KSFUN_QUALITY