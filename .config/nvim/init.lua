-- LOCALS
local cmd = vim.cmd
local exec = vim.api.nvim_exec
local g = vim.g
local b = vim.b
local opt = vim.opt
local api = vim.api

-- GENERAL SETTINGS
opt.number = true
opt.relativenumber = true
opt.autowrite = true
opt.ignorecase = true
opt.smartcase = true
opt.showmode = true
opt.history = 1000
opt.wildmenu = true
opt.autochdir = false
opt.spelllang = { 'en_us', 'ru_ru' }
opt.showmatch = false
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

-- INDENTATION
opt.autoindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.scrolloff = 5

-- COLORS
opt.termguicolors = false
cmd [[
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
syntax enable
]]
-- g.sonokai_enable_italic = 1
cmd'colorscheme gruvbox'
opt.background='dark'

-- FILETYPE-SPECIFIC THINGS
cmd'au Filetype lua setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab autoindent'

-- KEYMAPS/SHORTCUTS/HOTKEYS
local function map(mode, lhs, rhs, opts)
    local options = { noremap=true, silent=true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<C-T>', ':Files<CR>')
-- i hate reloading vim every single time
map('', '<C-M><C-M>', ':luafile $MYVIMRC<CR>')
-- i hate jumping lines
map('n', 'k', 'gk')
map('n', 'j', 'gj')
map('v', 'k', 'gk')
map('v', 'j', 'gj')
--tabs and stuff
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-s>', '<C-w>s')
map('n', '<C-v>', '<C-w>v')
map('n', '<C-q>', '<C-w>q')
-- nvim-dap maps monstrocity (even though I will be using mouse probably lmao)
map('n', '<F3>', ':set spell!<CR>')
map('n', '<F5>', ':DapContinue<CR>')
map('n', '<F6>', '<CMD>lua require(\'dap\').run_last()<CR>')
map('n', '<F7>', '<CMD>make clean debug<CR>')
map('n', '<F8>', '<CMD>luafile nvim-dap.lua<CR>') -- fuck nvim-dap-projects
map('n', '<C-b>', ':DapToggleBreakpoint<CR>')
map('n', '<C-d>', '<CMD>lua require(\'dapui\').toggle()<CR>')
map('n', '<F10>', ':DapStepOver<CR>')
map('n', '<F11>', ':DapStepInto<CR>')
map('n', '<F12>', ':DapStepOut<CR>')
map('v', '<C-k>', '<CMD>lua require("dapui").eval()<CR>')
-- escape terminal
map('t', '<C-space>', '<C-n><C-\\>')

-- LUALINE
require('lualine').setup {
    sections = {
        lualine_x = {'filetype'},
    },
    options = {
        theme = 'gruvbox',
    },
}

-- NVIM-DAP
require("neodev").setup()
require("dapui").setup()
require("nvim-dap-projects").search_project_config()

-- NULL-LS
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")
null_ls.setup({
    sources = { 
        null_ls.builtins.diagnostics.cppcheck, 
        null_ls.builtins.formatting.clang_format,
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
})

-- NEOVIDE-SPECIFIC
if vim.g.neovide then
  vim.o.guifont = "Fira Code:h10.5"
  vim.g.neovide_transparency = 0.95
end

-- PACKER
cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use 'sainnhe/sonokai'
  use 'morhetz/gruvbox'

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    use 'rstacruz/vim-closer'
    use 'tpope/vim-endwise'
    use 'tpope/vim-surround'
    use 'tpope/vim-commentary'
    use 'norcalli/nvim-colorizer.lua'
    use 'lukas-reineke/indent-blankline.nvim'
    use 'michaeljsmith/vim-indent-object'

    use {
        'jose-elias-alvarez/null-ls.nvim',
        requires = { 'nvim-lua/plenary.nvim' }
    }

    use 'neovim/nvim-lspconfig'
    use 'nvim-lua/completion-nvim'
    -- my monitor is not that big so this is not very useful
    -- use 'spolu/dwm.vim'
    use 'junegunn/fzf'
    use 'junegunn/fzf.vim'
    use 'ranjithshegde/ccls.nvim'

    use 'mfussenegger/nvim-dap'
    use 'rcarriga/nvim-dap-ui'
    use 'folke/neodev.nvim'
    use 'ldelossa/nvim-dap-projects'

    -- this is not even 200 lines omg
end)
