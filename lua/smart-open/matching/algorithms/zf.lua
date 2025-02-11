local function normalize_zf_score(zf_score, len)
  -- A negative score means no match
  if zf_score < 0 then
    return 0
  end

  -- Uninvert the score and normalize, similar to fzf pattern
  zf_score = 1 / zf_score - 0.001 * len
  return 1 / (1 + math.exp(-0.035 * zf_score + 5))
end

local ok, sorter = pcall(function()
  return require("smart-open.matching.algorithms.zf_implementation")({})
end)

if not ok then
  print(
    "Warning: Couldn't load zf. Do you need to add natecraddock/telescope-zf-native.nvim to your dependencies?"
  )
  print("Error loading zf:", sorter)
  return require("smart-open.matching.algorithms.fzy")
else
  sorter:init()
end

return {
  init = function() end,
  score = function(prompt, line)
    return normalize_zf_score(sorter:scoring_function(prompt, line), #line)
  end,
  destroy = sorter.destroy,
}
