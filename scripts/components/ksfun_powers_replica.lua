
local function onPowerWithLevelDirty(self, inst)
    local data = self._itempowers:value()
    if data then
        local powers = data.split(";")
        for i1,v1 in ipairs(powers) do
            local d = v1.split(",")
            for i2,v2 in ipairs(d) do
                if #v2 == 3 then
                    self.powers[v2[1]] = {
                        lv =  tonumber(v2[2]),
                        exp = tonumber(v2[3]),
                    }
                end
            end
        end
        if self.inst then
            self.inst:PushEvent(KSFUN_TUNING.EVENTS.PLAYER_PANEL, self.powers)
        end
    end
end


local KSFUN_POWERS = Class(function(self, inst)
    self.inst = inst
    self.powers= {}
    self.onPowersChangeFunc = nil

    self._itempowers = net_string(inst.GUID, "ksfun_powers._itempowers", "ksfun_itemdirty")
    self.inst:ListenForEvent("ksfun_itemdirty", function(inst) onPowerWithLevelDirty(self, inst) end)

end)


function KSFUN_POWERS:SyncData(data)
    self._itempowers:set_local(data)
    self._itempowers:set(data)
end


function KSFUN_POWERS:SetOnPowersChangedFunc(func)
    self.onPowersChangeFunc = func
end


--- 获取所有的属性
--- 包含名称 等级 经验值
function KSFUN_POWERS:GetPowers()
    return self.powers
end


--- 获取指定属性
--- @param name 属性 string
--- @return {lv = number, exp = number}
function KSFUN_POWERS:GetPower(name)
    return self.power[name]
end


return KSFUN_POWERS