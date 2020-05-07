local raisin = require("raisin")
local _uid = 0
local newUID
newUID = function()
  _uid = _uid + 1
  return _uid
end
local State
State = function(name, priority)
  if priority == nil then
    priority = 0
  end
  expect(1, name, {
    "string"
  }, "State")
  expect(2, priority, {
    "number"
  }, "State")
  local this = typeset({
    instance = raisin.group(priority),
    threads = { },
    name = name
  }, "State")
  return this
end
local Thread
Thread = function(state)
  return function(fn, priority, uid)
    if priority == nil then
      priority = 0
    end
    if uid == nil then
      uid = newUID()
    end
    expect(1, state, {
      "State"
    }, "Thread")
    expect(2, fn, {
      "function"
    }, "Thread")
    expect(3, priority, {
      "number"
    }, "Thread")
    expect(4, uid, {
      "number"
    }, "Thread")
    if state.threads[uid] then
      error(tostring(state.name) .. "/" .. tostring(uid) .. " already exists.")
    end
    local this = typeset({
      instance = raisin.thread(fn, priority, state.instance),
      fn = fn,
      priority = priority,
      uid = uid
    }, "Thread")
    state.threads[uid] = this
    return this
  end
end
local runState
runState = function(state)
  expect(1, state, {
    "State"
  }, "runState")
  return raisin.manager.runGroup(state.instance)
end
local haltAll = raisin.manager.halt
local statusOf
statusOf = function(any)
  expect(1, any, {
    "Thread",
    "State"
  }, "statusOf")
  return any.instance:state()
end
local enable
enable = function(any)
  expect(1, any, {
    "Thread",
    "State"
  }, "enable")
  return any.instance:toggle(true)
end
local disable
disable = function(any)
  expect(1, any, {
    "Thread",
    "State"
  }, "disable")
  return any.instance:toggle(false)
end
local priorityOf
priorityOf = function(any)
  expect(1, any, {
    "Thread",
    "State"
  }, "priorityOf")
  return any.instance:getPriority()
end
local setPriority
setPriority = function(any)
  return function(priority)
    if priority == nil then
      priority = 0
    end
    expect(1, any, {
      "Thread",
      "State"
    }, "setPriority")
    expect(2, priority, {
      "number"
    }, "setPriority")
    return any.instance:setPriority(priority)
  end
end
local remove
remove = function(any)
  expect(1, any, {
    "Thread",
    "State"
  }, "remove")
  return any.instance:remove()
end
local find
find = function(state)
  return function(pat)
    expect(1, state, {
      "State"
    }, "find")
    expect(2, pat, {
      "string"
    }, "find")
    local results = { }
    local _list_0 = state.threads
    for _index_0 = 1, #_list_0 do
      local thread = _list_0[_index_0]
      if thread:match(pat) then
        table.insert(results, thread)
      end
    end
    return table.unpack(results)
  end
end
return {
  newUID = newUID,
  State = State,
  Thread = Thread,
  runState = runState,
  haltAll = haltAll,
  priorityOf = priorityOf,
  statusOf = statusOf,
  setPriority = setPriority,
  enable = enable,
  disable = disable,
  remove = remove,
  find = find
}
