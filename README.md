# increment.nvim

An enhanced `<C-a>` and `<C-x>` plugin for Neovim that allows toggling between predefined keyword groups in addition to the default numeric increment/decrement behavior.

## Features

- Works like `<C-a>` and `<C-x>`, but supports custom keyword groups.
- Supports language-specific groups (e.g., `==` ↔ `~=` in Lua, `let` ↔ `var` in Swift).
- Customizable via `setup()`.

## Installation

Use your favorite plugin manager:

### Using `lazy.nvim`
```lua
{
    "Ipomoea/increment.nvim",
    config = function()
        require("increment").setup()
    end
}
```

### Using `packer.nvim`
```lua
use {
    "Ipomoea/increment.nvim",
    config = function()
        require("increment").setup()
    end
}
```

### Using `vim-plug`
```vim
Plug 'Ipomoea/increment.nvim'
```
Then, in your Lua config:
```lua
require("increment").setup()
```

## Configuration

Call `require("increment").setup()` with an optional configuration table:

```lua
require("increment").setup({
    groups = {
        { "+", "-" },
        { "==", "!=" },
        { "true", "false" },
        { "YES", "NO" },
        { "&&", "||" },
    },
    lang_groups = {
        lua = {
            { "==", "~=" },
        },
        swift = {
            { "let", "var" },
        },
    }
})
```

## Usage

- Place the cursor over a word from a defined group and press `<C-a>` to cycle forward or `<C-x>` to cycle backward.
- Works with language-specific groups if defined.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Credits

Inspired by the default behavior of `<C-a>` and `<C-x>` in Neovim and extended for additional keyword toggling.


