function test_sandbox(...)
  local status, result

-- Multiline Comments
--[=[
  status, result = run [[
    return debug.getinfo(1) -- Returns Function not Found (Because of Sandboxing)
  ]]
--]=]

--[=[
  status, result = run [[
    return 1337 -- Returns 1337
  ]]
--]=]

  -- Is a custom function of the library
  status, result = run [[
    return cSum(1, 3) -- Returns 4
  ]]

  --[=[
  -- Attempt at Loading Variables into Sandbox
  getmetatable("").__mod = interp
  status, result = run [[
    return sum(${array}) -- Returns All Numbers Added Together (e.g 1, 2, 3, 4 equals 10)
  ]] % { array = "{1, 2, 3, 4}" }
  --]=]

  return status, result
end

-- http://lua-users.org/wiki/SandBoxes
function run(untrusted_code)
  local env = {
    cSum = cSum,
    sum = sum
  }

  local untrusted_function, message = load(untrusted_code, nil, 't', env) -- https://www.lua.org/manual/5.2/manual.html#pdf-load
  if not untrusted_function then return nil, message end

  return pcall(untrusted_function) -- https://www.lua.org/manual/5.2/manual.html#pdf-pcall
end

function sum(...)
  local result = 0
  local arg = {...}
  for i,v in ipairs(arg) do
     result = result + v
  end
  return result
end

-- Found on http://lua-users.org/wiki/StringInterpolation, Made By RiciLake
function interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end
