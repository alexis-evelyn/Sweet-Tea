function test_sandbox(...)
  local result

  --result = run [[print(debug.getinfo(1))]]
  result = run [[x=1]]

  return result
end

-- http://lua-users.org/wiki/SandBoxes
function run(untrusted_code)
  local env = {}

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
