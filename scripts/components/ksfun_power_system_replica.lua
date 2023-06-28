
local function onPowerWithLevelDirty(self, inst)
    local data = self._itempowers:value()
    if data then
        local d1 = string.split(data, ";")

        for i1,v1 in pairs(d1) do
            local d2 = string.split(v1, ",")

            --- 标题数据
            if i1 == 1 then
                if #d2 == 3 then
                    local prefab = d2[1]
                    self.title = {
                        prefab = prefab,
                        name   = d2[2],
                        lv     = tonumber(d2[3]),
                    }
                end
            else
                --- 属性数据
                if GetTableSize(d2) == 4 then
                    local name = d2[1]
                    local lv   = tonumber(d2[2])
                    local exp  = tonumber(d2[3])
                    local desc = d2[4]
                    self.powers[name] = {
                        name = name,
                        lv   = lv,
                        exp  = exp,
                        desc = desc,
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
    self.title = {}
    self.onPowersChangeFunc = nil

    self._itempowers = net_string(inst.GUID, "ksfun_power_system._itempowers", "ksfun_itemdirty")
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

function KSFUN_POWERS:GetTitle()
    return self.title
end


--- 获取指定属性
--- @param name 属性 string
--- @return {lv = number, exp = number}
function KSFUN_POWERS:GetPower(name)
    return self.powers[name]
end


return KSFUN_POWERS