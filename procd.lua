local tempFilename, writeTo
do
  local _obj_0 = require("libc.io")
  tempFilename, writeTo = _obj_0.tempFilename, _obj_0.writeTo
end
local libproc = require("libproc")
local echo = kdprint("procd")
local Manager, State, Thread
Manager, State, Thread = libproc.Manager, libproc.State, libproc.Thread
echo("creating global (world) manager")
PROC_MGR = Manager("world")
echo("creating PROC_MAIN state")
PROC_MAIN = State(PROC_MGR, "PROC_MAIN", 1)
local newThread = Thread(PROC_MAIN)
local selectl
selectl = function(n, ...)
  local argl, toRet = {
    ...
  }, { }
  for i = 1, n do
    toRet[i] = table.remove(argl, 1)
  end
  table.insert(toRet, argl)
  return table.unpack(toRet)
end
local newLog
newLog = function(name, uid, txt, filename)
  if filename == nil then
    filename = (tempFilename("/tmp/" .. tostring(fs.getName(name)) .. "-" .. tostring(uid) .. "-"))
  end
  return writeTo(filename, txt)
end
local GC_ON = { }
local collectGarbage
collectGarbage = function(state)
  return function()
    expect(1, state, {
      "State"
    }, "collectGarbage")
    for _index_0 = 1, #GC_ON do
      local uid = GC_ON[_index_0]
      state.threads[uid] = nil
      coroutine.yield()
    end
  end
end
newThread((collectGarbage(PROC_MAIN)), 3, -1)
local newUID, disable
newUID, disable = libproc.newUID, libproc.disable
call = function(name, fn, priority, uid)
  if priority == nil then
    priority = 0
  end
  if uid == nil then
    uid = newUID()
  end
  expect(1, name, {
    "string"
  }, "call")
  expect(2, fn, {
    "function"
  }, "call")
  expect(3, priority, {
    "number"
  }, "call")
  expect(4, uid, {
    "number"
  }, "call")
  local fc
  fc = function(...)
    echo("switching to thread " .. tostring(name) .. "#" .. tostring(uid))
    local args = {
      ...
    }
    local ok, errt = selectl(1, pcall(function()
      return fn(table.unpack(args))
    end))
    if ok then
      return table.unpack(errt)
    else
      local err = tostring(name) .. "#" .. tostring(uid) .. ": " .. tostring(errt[1])
      local log = tempFilename("/tmp/" .. tostring(fs.getName(name)) .. "-" .. tostring(uid) .. "-")
      kprint("!! " .. tostring(name) .. "#" .. tostring(uid) .. " crashed and had to stop")
      echo("dumping log at " .. tostring(log))
      newLog(name, uid, err, log)
      echo("stopping thread")
      return disable(PROC_MAIN.threads[uid])
    end
  end
  return newThread(fc, priority, uid)
end
callFile = function(name, priority, uid)
  if priority == nil then
    priority = 0
  end
  if uid == nil then
    uid = newUID()
  end
  return call(name, (loadfile(name)), priority, uid)
end
PROC_THREADS = PROC_MAIN.threads
local runState
runState = libproc.runState
local runProcd
runProcd = function()
  return runState(PROC_MAIN)
end
return {
  runProcd = runProcd
}
