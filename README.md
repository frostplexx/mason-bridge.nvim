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
- [ ] Testing if the all filetypes are detected correctly is required
- [x] Add vim help file

# Similar Projects

- <a href="https://github.com/jay-babu/mason-nvim-dap.nvim"><code>mason-nvim-dap.nvim</code></a>
- <a href="https://github.com/rshkarin/mason-nvim-lint"><code>mason-nvim-lint</code></a>
- <a href="https://github.com/LittleEndianRoot/mason-conform"><code>mason-conform</code></a>

[help-mason-bridge]: ./doc/mason-bridge.txt#L1
