AddClassPostConstruct("widgets/hoverer", function(self)
    local old_SetString = self.text.SetString
    self.text.SetString = function(text, str)
        local target = TheInput:GetHUDEntityUnderMouse()
        if target ~= nil then
            target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item
        else
            target = TheInput:GetWorldEntityUnderMouse()
        end
        if target and target.entity ~= nil then
            if target.prefab ~= nil then
                if target.prefab == "ksfun_task_reel" and target.replica.ksfun_task_demand then
                    local content = target.replica.ksfun_task_demand:GetContent()
                    KsFunLog("hhhhhhhhhhhhhhhhhhhhhh5", content , str)
                    if content then
                        str = str .. "\n" .. content
                    end
                end
            end
        end
        return old_SetString(text, str)
    end
end)
