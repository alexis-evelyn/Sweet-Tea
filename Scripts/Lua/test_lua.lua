function test_sandbox(...)
  local status, result

-- Multiline Comments
--[=====[
  status, result = run [[
    return debug.getinfo(1) -- Returns Function not Found (Because of Sandboxing)
  ]]
--]=====]

--[=====[
  status, result = run [[
    return 1337 -- Returns 1337
  ]]
--]=====]

  -- Is a custom function of the library
  status, result = run [[
    return cSum(1, 3) -- Returns 4
  ]]

  return status, result
end

-- http://lua-users.org/wiki/SandBoxes
function run(untrusted_code)
  local env = {
    cSum = cSum
  }

  local untrusted_function, message = load(untrusted_code, nil, 't', env) -- https://www.lua.org/manual/5.2/manual.html#pdf-load
  if not untrusted_function then return nil, message end

  return pcall(untrusted_function) -- https://www.lua.org/manual/5.2/manual.html#pdf-pcall
end

local function sum(...)
  local result = 0
  local arg = {...}
  for i,v in ipairs(arg) do
     result = result + v
  end
  return result
end
