# nvim-oxlint-fix-on-save

A lightweight Neovim plugin that automatically runs `oxlint --fix` on save when the [oxlint LSP](https://oxc.rs/docs/guide/usage/linter) is attached.

## Features

- Runs `oxlint --fix` on the current file after every save (`BufWritePost`)
- Automatically detects your project root via oxlint config files or `package.json`
- Resolves the correct package manager command (`pnpm`, `npm`, `yarn`, `bun`)

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'SimeonGrancharov/nvim-oxlint-fix-on-save',
  config = function()
    require('oxlint-fix-on-save').setup()
  end,
}
```

## How it works

1. Listens for `LspAttach` events from the `oxlint` language server
2. On `BufWritePost`, finds the project root by walking up the directory tree looking for oxlint config files (`oxlint.config.ts`, `.oxlintrc.json`, etc.) or `package.json`
3. Detects the package manager from the lockfile and runs `oxlint --fix` on the saved file
4. Reloads the buffer after the fix is applied

## Supported package managers

| Lockfile | Command |
|---|---|
| `pnpm-lock.yaml` | `pnpm exec oxlint` |
| `package-lock.json` | `npx --no-install oxlint` |
| `yarn.lock` | `yarn run oxlint` |
| `bun.lockb` / `bun.lock` | `bunx oxlint` |

## Requirements

- Neovim >= 0.10
- [oxlint](https://oxc.rs/) installed in your project
- An LSP config that starts the `oxlint` language server (e.g. via [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig))
