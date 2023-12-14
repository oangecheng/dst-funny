
local function onPowerWithLevelDirty(self, inst)
    local jsdata = self._itempowers:value()
    if jsdata and jsdata ~= "" then
        self.powers = json.decode(jsdata)
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
function KSFUN_POWERS:GetPowersData()
    return self.powers
end


function KSFUN_POWERS:GetPowerNames()
    local str = ""
    for k,v in pairs(self.powers) do
        local name = KsFunGetPowerNameStr(k)
        str = str.."["..name.."]"
    end
    return str
end


--- 获取指定属性
--- @param name string 属性
--- @return table { lv = number, exp = number}
function KSFUN_POWERS:GetPower(name)
    return self.powers[name]
end


return KSFUN_POWERS