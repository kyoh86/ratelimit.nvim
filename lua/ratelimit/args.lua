local M = {}

---Validates args for `throttle()` and  `debounce()`.
function M.validate(fn, ms)
  vim.validate({
    fn = { fn, "f" },
    ms = {
      ms,
      function(v)
        return type(v) == "number" and v > 0
      end,
      "number > 0",
    },
  })
end

return M
