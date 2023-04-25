

local KSFUN_ITEM_QUALITY = Class(function(self, inst)
    self.inst = inst
    self.quality = nil
    self.onQualityChangeFun = nil
end)


--- 设置品质
--- @param quality int 见 KSFUN_TUNING.ITEM_QUALITY
function KSFUN_ITEM_QUALITY:SetQuality(quality)
    self.quality = quality
    if self.onQualityChangeFun then
        self.onQualityChangeFun(self.inst)
    end
end


--- 获取物品品质
function KSFUN_ITEM_QUALITY:GetQulity()
    return self.quality or 0
end


--- 获取描述性的文字
function KSFUN_ITEM_QUALITY: GetQulityDesc()
    if self.quality == 1 then
        return "白色"
    end
end


return KSFUN_ITEM_QUALITY