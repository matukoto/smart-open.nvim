local zf = require("zf-native")

local M = {}

function M.has_match(needle, haystack)
  return zf.match(needle, haystack)
end

function M.score(needle, haystack)
  return zf.score(needle, haystack)
end

function M.get_score_min()
  return -math.huge
end

function M.get_score_floor()
  return -10
end

return M
