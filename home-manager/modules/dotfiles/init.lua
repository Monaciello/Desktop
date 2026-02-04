-- Title:       init.lua
-- Description: NeoVim Configuration (plugins managed by home-manager)
-- Adapted from PrettyBoyCosmo's for monaciello's nix-cfg dotfiles

--------------------------------------------------------------------------------
-- 0. Basic Setup & Keybindings
--------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Create a shortcut for keymaps
local keymap = vim.keymap.set
local opts = { silent = true }

-- Keybindings
keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)

-- LSP keybindings (set up by lsp-zero)
keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)

-- Navigation (tmux-aware)
keymap("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", opts)
keymap("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", opts)
keymap("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", opts)
keymap("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", opts)

-- Window management
keymap("n", "<leader>wh", "<cmd>wincmd h<CR>", opts)
keymap("n", "<leader>wj", "<cmd>wincmd j<CR>", opts)
keymap("n", "<leader>wk", "<cmd>wincmd k<CR>", opts)
keymap("n", "<leader>wl", "<cmd>wincmd l<CR>", opts)

-- Buffer management
keymap("n", "<leader>bn", "<cmd>bnext<CR>", opts)
keymap("n", "<leader>bp", "<cmd>bprevious<CR>", opts)
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", opts)

-- File operations
keymap("n", "<leader>w", "<cmd>write<CR>", opts)
keymap("n", "<leader>q", "<cmd>quit<CR>", opts)

--------------------------------------------------------------------------------
-- 1. LSP Configuration (lsp-zero)
--------------------------------------------------------------------------------
local lsp_zero = require("lsp-zero")
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- Setup completion
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- Configure LSPs (Nix-provided binaries)
local lspconfig = require("lspconfig")

lspconfig.nixd.setup({
  on_attach = function(client, bufnr)
    lsp_zero.on_attach(client, bufnr)
  end,
})

lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    lsp_zero.on_attach(client, bufnr)
  end,
})

lsp_zero.setup()

--------------------------------------------------------------------------------
-- 2. Treesitter Configuration
--------------------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = { enable = true },
})

--------------------------------------------------------------------------------
-- 3. Telescope Configuration
--------------------------------------------------------------------------------
local telescope = require("telescope")
local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    file_ignore_patterns = {
      "^.git/",
      "^__pycache__/",
      "^.venv/",
      "^node_modules/",
    },
    mappings = {
      i = {
        ["<C-c>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
    },
  },
})

telescope.load_extension("fzf")

--------------------------------------------------------------------------------
-- 4. UI Configuration
--------------------------------------------------------------------------------
-- Airline
vim.g.airline_theme = "nord"
vim.g.airline_powerline_fonts = 1

-- Nord theme
vim.opt.termguicolors = true
vim.cmd.colorscheme("nord")

-- Alpha (dashboard)
local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
  "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
  "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
  "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
  "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
  "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
  "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
}

dashboard.section.buttons.val = {
  dashboard.button("f", "🔍 Find file", ":Telescope find_files <CR>"),
  dashboard.button("r", "📝 Recent", ":Telescope oldfiles <CR>"),
  dashboard.button("g", "🔎 Grep", ":Telescope live_grep <CR>"),
  dashboard.button("e", "⚙️  Edit config", ":e ~/.config/nvim/init.lua<CR>"),
  dashboard.button("q", "❌ Quit", ":qa<CR>")
}

alpha.setup(dashboard.config)

-- Notifications
require("notify").setup({
  timeout = 3000,
  stages = "fade_in_slide_out",
})
vim.notify = require("notify")

-- Gitsigns
require("gitsigns").setup()

-- Obsidian
require("obsidian").setup({
  workspaces = {
    {
      name = "Files",
      path = vim.fn.expand("~/Files/Obsidian"),
    },
  },
  completion = {
    nvim_cmp = true,
    min_chars = 1,
  },
  new_notes_location = "Files/unsorted",
  picker = {
    name = "telescope.nvim",
  },
})

--------------------------------------------------------------------------------
-- 5. Editor Options
--------------------------------------------------------------------------------
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs and indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Display
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.cursorline = false
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"

-- Performance
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")

-- Completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Clipboard - system integration
vim.opt.clipboard = "unnamedplus"

-- Status line
vim.opt.laststatus = 3
vim.opt.showcmd = true
vim.opt.showmode = false

-- Encoding
vim.opt.fileencoding = "utf-8"

-- Spelling
vim.opt.spell = true
vim.opt.spelllang = "en_us"

-- Folding
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"

-- True colors
vim.opt.termguicolors = true
