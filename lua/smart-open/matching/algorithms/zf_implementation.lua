local has_zf, zf = pcall(require, "zf")
if not has_zf then
  error("zf module is required for zf matching algorithm. Make sure telescope-zf-native.nvim is installed correctly.")
end

-- Load the C/Rust library
zf.load_zf()

local state = {
  prompt_cache = {},
}

local function get_struct(prompt)
  local struct = state.prompt_cache[prompt]
  if not struct then
    struct = zf.tokenize(prompt)
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
    local score = zf.rank(line, obj.tokens, obj.len, true, true)
    if score == 0 then
      return -1
    else
      return 1 / score
    end
  end

  function M.highlighter(_, prompt, display)
    local struct = get_struct(prompt)
    return zf.highlight(display, struct.tokens, struct.len, true, true)
  end

  function M.destroy()
    state.prompt_cache = {}
  end

  return M
end

return get_zf_sorter
