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
        target[lang] = target[lang] or {}
        table.insert(target[lang], name)
    end
end

local function load_associations_async(callback)
    vim.schedule(function()
        local registry = require 'mason-registry'
        local packages = registry.get_installed_packages()
        local associations = { formatters = {}, linters = {} }

        for _, package in ipairs(packages) do
            local spec = package.spec
            local categories = utils_Set(spec.categories)
            local languages = spec.languages

            if categories['Formatter'] then
                update_associations(associations, 'formatters', languages, spec.name)
            elseif categories['Linter'] then
                update_associations(associations, 'linters', languages, spec.name)
            end
        end

        callback(associations)
    end)
end

return {
    load_associations_async = load_associations_async,
}
