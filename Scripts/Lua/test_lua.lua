function sum(...)
    result = 0
    local arg = {...}
    for i,v in ipairs(arg) do
       result = result + v
    end
    return result
end
