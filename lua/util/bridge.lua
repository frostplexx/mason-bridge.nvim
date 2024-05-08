local registry = require('mason-registry')


local function utils_Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

local function update_associations_table(associations, category, languages, name)
    local target = associations[category]
    for _, language in ipairs(languages) do
        local lang = language:lower()
        if not target[lang] then
            target[lang] = { name }
        else
            table.insert(target[lang], name)
        end
    end
end

local function load_associations()
    local packages = registry.get_installed_packages()
    local associations = { formatters = {}, linters = {} }

    for _, package in ipairs(packages) do
        local spec = package.spec
        local name = spec.name
        local categories = utils_Set(spec.categories)
        local languages = spec.languages


        if categories["Formatter"] then
            -- print(vim.inspect(package))
            update_associations_table(associations, 'formatters', languages, name)
        elseif categories["Linter"] then
            -- print(vim.inspect(package))
            update_associations_table(associations, 'linters', languages, name)
        end
    end
    return associations
end

return {
    load_associations = load_associations
}
