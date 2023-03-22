
KSFUN_UTILS = {}

KSFUN_UTILS.removeFromList = function(target, list)
    for i, v in ipairs(list) do
        if v == target then
            table.remove(list, i)
        end
    end
end