---@diagnostic disable: undefined-field

local function addMark(self, mark)
    if mark and not table.contains(self.marks, mark) then
        table.insert(self.marks, mark)
        local fn = self.fns[mark]
        if fn then
            fn(self.inst, mark)
        end
    end
end


local Mark = Class(function (self, inst)
    self.inst = inst
    self.marks = {}
    self.fns = nil
end)


---comments 设置监听
---@param mark string 
---@param fn function
function Mark:SetMarkFn(mark, fn)
    if self.fns == nil then
       self.fns = {}
    end
    self.fns[mark] = fn
end


---comments 添加标记
---@param mark string
function Mark:Add(mark)
    addMark(self, mark)
end


---comments 移除标记
---@param mark string
function Mark:Remove(mark)
    table.removearrayvalue(self.marks, mark)
end


---comments 是否有标记
---@param mark string 
---@return boolean 
function Mark:HasMark(mark)
    return table.contains(self.marks, mark)
end


function Mark:OnSave()
    return {
        marks = self.marks
    }
end


function Mark:OnLoad(data)
    if data and data.marks then
        for _, v in ipairs(data.marks) do
            addMark(self, v)
        end
    end
end


return Mark