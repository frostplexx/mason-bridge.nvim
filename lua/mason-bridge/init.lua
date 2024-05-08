local M = {}
local util = require 'util.bridge'

-- Table to hold cached associations
local cached_associations = {}

local DEFAULT_SETTINGS = {
    -- A table of filetypes with the respective tool (or tools) to be used
    overrides = {
        formatters = {},
        linters = {},
    },
}

M.setup = function(opts, callback)
    -- Load associations asynchronously
    util.load_associations_async(function(associations)
        -- Cache the loaded associations
        cached_associations = associations
        -- Merge the default settings with the user provided settings
        opts = opts or {}
        opts = vim.tbl_deep_extend('force', DEFAULT_SETTINGS, opts)
        -- Apply overrides
        cached_associations.formatters =
            vim.tbl_deep_extend('force', cached_associations.formatters, opts.overrides.formatters)
        cached_associations.linters = vim.tbl_deep_extend('force', cached_associations.linters, opts.overrides.linters)
        if callback then
            callback()
        end
    end)
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
