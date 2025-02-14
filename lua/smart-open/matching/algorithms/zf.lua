local function normalize_zf_score(zf_score, len)
  -- A negative score means no match
  if zf_score < 0 then
    return 0
  end

  -- Uninvert the score and normalize, similar to fzf pattern
  zf_score = 1 / zf_score - 0.001 * len
  return 1 / (1 + math.exp(-0.035 * zf_score + 5))
end

local has_zf = pcall(require, "zf")
if not has_zf then
  print("Warning: Couldn't load zf. Do you need to add natecraddock/telescope-zf-native.nvim to your dependencies?")
  return require("smart-open.matching.algorithms.fzy")
end

local ok, zf_impl = pcall(require, "smart-open.matching.algorithms.zf_implementation")
if not ok then
  print("Error loading zf implementation:", zf_impl)
  return require("smart-open.matching.algorithms.fzy")
end

local sorter = zf_impl({})
sorter:init()

return {
  init = function() end,
  score = function(prompt, line)
    return normalize_zf_score(sorter:scoring_function(prompt, line), #line)
  end,
  destroy = sorter.destroy,
}
