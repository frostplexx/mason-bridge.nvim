local M = {}

-- Table to hold cached associations
local cached_associations = {}

local DEFAULT_SETTINGS = {
    -- A table of filetypes with the respective tool (or tools) to be used
    overrides = {
        formatters = {},
        linters = {},
    },
}

M.setup = function(opts)
    local util = require 'util.bridge'
    local registry = require 'mason-registry'
    -- Function to update cached associations
    local update_cached_associations = function()
        util.load_associations_async(function(associations)
            -- Cache the loaded associations
            cached_associations = associations
            -- Apply overrides
            opts = vim.tbl_deep_extend('force', DEFAULT_SETTINGS, opts)
            cached_associations.formatters =
                vim.tbl_deep_extend('force', cached_associations.formatters or {},
                    opts.overrides.formatters == nil and {} or opts.overrides.formatters)
            cached_associations.linters =
                vim.tbl_deep_extend('force', cached_associations.linters or {},
                    opts.overrides == nil and {} or opts.overrides.linters)
        end)
    end

    -- Load associations asynchronously
    update_cached_associations()

    -- Hook into Mason's install and uninstall commands
    registry:on(
        'package:install:success',
        vim.schedule_wrap(function(_, _)
            update_cached_associations()
        end)
    )

    registry:on(
        'package:uninstall:success',
        vim.schedule_wrap(function(_)
            update_cached_associations()
        end)
    )
end

M.get_formatters = function()
    -- Return the cached formatters
    return cached_associations.formatters or {}
end

M.get_linters = function()
    -- Return the cached linters
    return cached_associations.linters or {}
end

M.get_mappings = function()
    -- Return the cached mappings
    return require 'util.mappings'
end

return M
