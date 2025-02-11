local zf

local function normalize_zf_score(zf_score)
  -- A negative score means no match
  if zf_score < 0 then
    return 0
  end
  return 1 - 1 / (1 + math.exp(-10 * (zf_score * 10 - 0.65)))
end

local function score(prompt, line)
  -- Check for actual matches before running the scoring algorithm.
  if not zf.has_match(prompt, line) then
    return -1
  end

  local zf_score = zf.score(prompt, line)

  -- Handle minimum score case
  if zf_score == zf.get_score_min() then
    return 1
  end

  -- Convert to positive range and invert for telescope convention
  return 1 / (zf_score - zf.get_score_floor())
end

return {
  init = function(options)
    if options.native_zf_path then
      zf = loadfile(options.native_zf_path)()
    else
      zf = require("smart-open.matching.algorithms.zf_implementation")
    end
  end,
  score = function(prompt, line)
    local result = normalize_zf_score(score(prompt, line))
    return result
  end,
  destroy = function() end,
}
