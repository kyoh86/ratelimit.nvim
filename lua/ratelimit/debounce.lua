local M = {}

--- Debounces a function on the leading edge. Automatically `schedule_wrap()`s.
---
--@param fn (function) Function to debounce
--@param timeout (number) Timeout in ms
--@returns (function, timer) Debounced function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function M.leading(fn, ms)
  require("ratelimit.args").validate(fn, ms)
  local timer = vim.loop.new_timer()
  local running = false

  local function wrapped_fn(...)
    timer:start(ms, 0, function()
      running = false
    end)

    if not running then
      running = true
      pcall(vim.schedule_wrap(fn), select(1, ...))
    end
  end

  return wrapped_fn, timer
end

--- Debounces a function on the trailing edge. Automatically
--- `schedule_wrap()`s.
---
--@param fn (function) Function to debounce
--@param timeout (number) Timeout in ms
--@param first (boolean, optional) Whether to use the arguments of the first
---call to `fn` within the timeframe. Default: Use arguments of the last call.
--@returns (function, timer) Debounced function and timer. Remember to call
---`timer:close()` at the end or you will leak memory!
function M.trailing(fn, ms, first)
  require("ratelimit.args").validate(fn, ms)
  local timer = vim.loop.new_timer()
  local wrapped_fn

  if not first then
    function wrapped_fn(...)
      local argv = { ... }
      local argc = select("#", ...)

      timer:start(ms, 0, function()
        pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
      end)
    end
  else
    local argv, argc
    function wrapped_fn(...)
      argv = argv or { ... }
      argc = argc or select("#", ...)

      timer:start(ms, 0, function()
        pcall(vim.schedule_wrap(fn), unpack(argv, 1, argc))
      end)
    end
  end
  return wrapped_fn, timer
end

--- Test deferment methods (`{leading,trailing}()`).
---
--@param bouncer (string) Bouncer function to test
--@param ms (number, optional) Timeout in ms, default 2000.
--@param firstlast (bool, optional) Whether to use the 'other' fn call
---strategy.
function M.test_defer(bouncer, ms, firstlast)
  local bouncers = {
    dl = M.leading,
    dt = M.trailing,
  }

  local timeout = ms or 2000

  local bounced = bouncers[bouncer](function(i)
    vim.cmd('echom "' .. bouncer .. ": " .. i .. '"')
  end, timeout, firstlast)

  for i, _ in ipairs({ 1, 2, 3, 4, 5 }) do
    bounced(i)
    vim.schedule(function()
      vim.cmd("echom " .. i)
    end)
    vim.fn.call(vim.fn.wait, { 1000, "v:false" })
  end
end

return M
