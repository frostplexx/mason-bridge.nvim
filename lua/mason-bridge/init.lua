local M = {}

-- Table to hold cached associations
local cached_associations = {}
local associations_loaded = false

local DEFAULT_SETTINGS = {
    -- A table of filetypes with the respective tool (or tools) to be used
    overrides = {
        formatters = {},
        linters = {},
    },
}

M.setup = function(opts)
    local util = require 'util.bridge'
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
        -- Set the flag to indicate associations are loaded
        associations_loaded = true
    end)
end

-- Helper function to block until associations are loaded
local function wait_until_loaded()
    while not associations_loaded do
        vim.wait(0.1)
        -- this is not ideal but fixes cases where .get_formatters is called before .setup
        M.setup()
    end
end

-- Returns a table of formatters
M.get_formatters = function()
    wait_until_loaded()
    -- Return the cached formatters
    return cached_associations.formatters
end

-- Returns a table of linters
M.get_linters = function()
    wait_until_loaded()
    -- Return the cached linters
    return cached_associations.linters
end
--
-- Returns the language to filetype mappings
M.get_mappings = function()
    -- Return the cached mappings
    return require 'util.mappings'
end

return M
