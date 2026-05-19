#!/usr/bin/env bash
section "Neovim"
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install -y neovim

[[ -d ~/.config/nvim ]] && mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/init.lua <<'EOF'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.editor.telescope" },
    { import = "plugins" },
  },
  install = { colorscheme = { "catppuccin", "tokyonight" } },
  checker = { enabled = true, notify = false },
})
EOF

cat >~/.config/nvim/lua/plugins/plugins.lua <<'EOF'
return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000,
    opts = { flavour = "macchiato" } },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
  { "christoomey/vim-tmux-navigator",
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
  },
  { "kdheepak/lazygit.nvim",
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } } },
  { "max397574/better-escape.nvim", event = "InsertEnter",
    opts = { timeout = 300, mappings = { i = { j = { k = "<Esc>" } } } } },
  { "folke/which-key.nvim", event = "VeryLazy",
    init = function()
      vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
      vim.keymap.set("v", "<", "<gv")
      vim.keymap.set("v", ">", ">gv")
      vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
      vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
      vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
      vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")
    end },
}
EOF
ok "Neovim + LazyVim configured"
