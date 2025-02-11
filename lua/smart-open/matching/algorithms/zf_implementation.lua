local zf = require("telescope._extensions.zf-native")

local state = {
  prompt_cache = {},
}

local function get_struct(prompt)
  local struct = state.prompt_cache[prompt]
  if not struct then
    struct = zf.parse_pattern(prompt)
    state.prompt_cache[prompt] = struct
  end
  return struct
end

local function get_zf_sorter(opts)
  local M = {}

  function M.init()
    state.prompt_cache = {}
  end

  function M.scoring_function(_, prompt, line)
    local obj = get_struct(prompt)
    local score = zf.get_score(line, obj)
    if score == 0 then
      return -1
    else
      return 1 / score
    end
  end

  function M.highlighter(_, prompt, display)
    return zf.get_pos(display, get_struct(prompt))
  end

  function M.destroy()
    state.prompt_cache = {}
  end

  return M
end

return get_zf_sorter
