local utils_Set = function(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

local function update_associations(associations, category, languages, name)
    local target = associations[category]
    for _, language in ipairs(languages) do
        local lang = language:lower()
        -- if there are multiple filetypes with the same language, we need to add them all
        -- e.g. typescriptreact and typescript becomes { typescriptreact = { name }, typescript = { name }}
        local mappings = require 'util.mappings'
        local filetype = mappings[lang] or { lang }
        for _, filetype in ipairs(filetype) do
            target[filetype] = target[filetype] or {}
            table.insert(target[filetype], name)
        end
    end
end

local function load_associations_async(callback)
    vim.schedule(function()
        local registry = require 'mason-registry'
        local packages = registry.get_installed_packages()
        local associations = { formatters = {}, linters = {} }

        for _, package in ipairs(packages) do
            local spec = package.spec
            local languages = spec.languages

            local categories = utils_Set(spec.categories)
            if categories['Formatter'] then
                update_associations(associations, 'formatters', languages, spec.name)
            end
            if categories['Linter'] then
                update_associations(associations, 'linters', languages, spec.name)
            end
        end

        callback(associations)
    end)
end

return {
    load_associations_async = load_associations_async,
}
