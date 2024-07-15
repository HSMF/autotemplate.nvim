# autotemplate

## Installation


Using lazy.nvim

```lua
{
  "HSMF/autotemplate.nvim",
  opts = {},
  dependencies = { "nvim-treesitter/nvim-treesitter" }
},
```

Add the following to `after/ftplugin/javascript.lua`


```lua
vim.api.nvim_set_keymap("i", "$", "", {
    nowait = true,
    noremap = true,
    callback = function()
        require("autotemplate").autotemplate(vim.bo.filetype)
    end,
})
```
