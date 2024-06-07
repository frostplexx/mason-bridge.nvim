# mason-bridge.nvim

<p align="center">
  <code>mason-bridge</code> automatically registers linters and formatters installed using
<a href="https://github.com/williamboman/mason.nvim"><code>mason.nvim</code></a> in <a href="https://github.com/stevearc/conform.nvim"><code>conform.nvim</code></a> and <a href="https://github.com/mfussenegger/nvim-lint"><code>nvim-lint</code></a>.  
</p>

# Introduction

- Automatically generates the `formatters_by_ft` and `linters_by_ft` tables to be used in their respective plugins
- Provides and override in case the tool name and linter name mismatch e.g. [snyk](https://github.com/snyk/cli) and `snyk_iac`

# Requirements

- neovim `>= 0.7.0`
- `mason.nvim`
- `conform.nvim`
- `nvim-lint`

# Installation

## [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "williamboman/mason.nvim",
    "frostplexx/mason-bridge.nvim",
    "stevearc/conform.nvim",
    "mfussenegger/nvim-lint"
}
```

## [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "williamboman/mason.nvim",
    "frostplexx/mason-bridge.nvim",
    "stevearc/conform.nvim",
    "mfussenegger/nvim-lint"
}
```

# Setup

It's important that you set up the plugins in the following order:

1. `mason.nvim`
2. `mason-bridge`
3. `conform.nvim` and/or `nvim-lint` (this order doesnt matter)

Pay extra attention to this if you lazy-load plugins, or somehow "chain" the loading of plugins via your plugin manager.

```lua
require("mason").setup()
require("mason-bridge").setup()

-- After setting up mason-bridge you may set up conform.nvim and nvim-lint
require("conform").setup({
    formatters_by_ft = require("mason-bridge").get_formatters(),
})

require("lint").linters_by_ft = require("mason-bridge").get_linters()
-- ...
```

## Have Tools Register for Every Filetype

Some tools like for example `codespell` do not have a language specified because they are to be used on every filetype / language.
`mason-bridge` returns these tools with a `*` as the placeholder for the language.
To correctly register correctly in nvim-lint you need to modify your `nvim-lint` config like this: 
```lua
local names = lint._resolve_linter_by_ft(vim.bo.filetype)
names = vim.list_extend({}, names)
vim.list_extend(names, lint.linters_by_ft["*"] or {})

-- try_lint() can be called in an autocommand as described in the nvim-lint README
lint.try_lint(names)
```

## Dynamically Load Linters and Formatters

### Linters

You can have `nvim-lint` dynamically load linters so you dont have to restart nvim after installing or uninstalling a tool. To achive this you need to update the [autcommand from the nvim-lint README](https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#usage) like this:
```lua
local bridge = require("mason-bridge")
vim.api.nvim_create_autocmd({ "BufWritePost" },{
  callback = function()
    -- get the linters from mason
    local linters = bridge.get_linters()
    -- filter for linters for the current filetype
    local names = linters[vim.bo.filetype] or {}
    -- Create a copy of the names table to avoid modifying the original.
    names = vim.list_extend({}, names)
    -- insert the linters that have ["*"] as filetype into the names table
    vim.list_extend(names, linters["*"])
    -- apply those linters to the current buffer
    lint.try_lint(names)
  end,
})
```

### Formatters

We ask for the currently installed formatters in a similar way to how we ask for linters. To achieve this we need to turn `format_on_save` into a function that re-sets the `formatters_by_ft` for `conform.nvim` like shown in the example below.

```lua
local bridge = require("mason-bridge")
require("conform").setup({
	formatters_by_ft = bridge.get_formatters(),
	format_on_save = function(bufnr)
		require("conform").formatters_by_ft = bridge.get_formatters()
		return { timeout_ms = 200, lsp_fallback = true }, on_format
	end,
})
```

Refer to the [Configuration](#configuration) section for information about which settings are available.

# Configuration

You may optionally configure certain behavior of `mason-bridge.nvim` when calling the `.setup()` function. Refer to
the [default configuration](#default-configuration) for a list of all available settings.

Example:

```lua
require("mason-bridge").setup({
    overrides = {
        linters = {
            javascript = { "snyk_iac" },
            docker = { "snyk_iac" }
        },
        formatters = {
            my_language = {"formatter_1", "formatter_2"}
        }
    }
})

```

## Default configuration

```lua
local DEFAULT_SETTINGS = {
    -- A table of filetypes with the respective tool (or tools) to be used
    overrides = {
        formatters = {},
        linters = {}
    }
}
```

# Roadmap

- [ ] Add a handler system similar to `mason-lspconfig.nvim` and `mason-nvim-dap.nvim`
- [ ] Find i better way of handling language to filetype mappings
- [x] Add vim help file

# Similar Projects

- <a href="https://github.com/jay-babu/mason-nvim-dap.nvim"><code>mason-nvim-dap.nvim</code></a>
- <a href="https://github.com/rshkarin/mason-nvim-lint"><code>mason-nvim-lint</code></a>
- <a href="https://github.com/LittleEndianRoot/mason-conform"><code>mason-conform</code></a>

[help-mason-bridge]: ./doc/mason-bridge.txt#L1
