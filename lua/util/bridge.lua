local registry = require 'mason-registry'

local function utils_Set(list)
    local set = {}
    for _, item in ipairs(list) do
        set[item] = true
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
    -- Assume vim.schedule is available to handle the async behavior
    vim.schedule(function()
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
