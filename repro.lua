vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").repro({
  spec = {
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = { "typescript", "javascript", "tsx" },
        auto_install = true,
        sync_install = true,
      },

      build = function()
        vim.cmd(":TSInstallSync javascript")
        vim.cmd(":TSInstallSync typescript")
        vim.cmd(":TSInstallSync tsx")
        vim.cmd(":TSUpdate")
      end,
    },
    { "HSMF/autotemplate.nvim", opts = {}, dependencies = { "nvim-treesitter/nvim-treesitter" } },
  },
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.js", "*.ts", "*.tsx" },
  callback = function()
    vim.api.nvim_set_keymap("i", "$", "", {
      nowait = true,
      noremap = true,
      callback = function()
        require("autotemplate").autotemplate(vim.bo.filetype)
      end,
    })
  end,
})

-- do anything else you need to do to reproduce the issue
