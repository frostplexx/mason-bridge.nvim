local M = {}
local util = require 'util.bridge'

-- Declare a local table to hold cached associations
local cached_associations = {}

local DEFAULT_SETTINGS = {
    overrides = {
        formatters = {},
        linters = {},
    },
}

M.setup = function(opts)
    -- Load associations once during setup and cache them
    cached_associations = util.load_associations()
    -- Merge the default settings with the user provided settings
    opts = vim.tbl_deep_extend('force', DEFAULT_SETTINGS.overrides, opts or {})
    -- Set the overrides
    cached_associations = vim.tbl_deep_extend('force', cached_associations, opts.overrides) or {}
end

M.get_formatters = function()
    -- Return the cached formatters
    return cached_associations.formatters or {}
end

M.get_linters = function()
    -- Return the cached linters
    return cached_associations.linters or {}
end
return M
