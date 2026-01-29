local vim = vim
vim.cmd [[colorscheme vibrantink]]

-- Force filetype detection for helm templates.
vim.filetype.add({
  extension = {
    gotmpl = 'gotmpl',
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})

local Plug = vim.fn['plug#']
vim.call('plug#begin')

Plug('google/vim-jsonnet')
Plug('pgr0ss/vim-github-url')
Plug('scrooloose/nerdtree')
Plug('tpope/vim-surround')
Plug('junegunn/fzf', {
  ['do'] = function()
    vim.fn['fzf#install']()
  end
})
Plug('ibhagwan/fzf-lua', { ['branch'] = 'main' })
Plug('mfussenegger/nvim-dap') -- dependency for fzf-lua
Plug('neovim/nvim-lspconfig')
Plug('mason-org/mason.nvim')
Plug('mason-org/mason-lspconfig.nvim')
Plug('lukas-reineke/lsp-format.nvim')
Plug('nvim-treesitter/nvim-treesitter', {
  ['do'] = function()
    vim.cmd('TSUpdate')
  end
})

-- copilot
Plug('nvim-lua/plenary.nvim')
Plug('CopilotC-Nvim/CopilotChat.nvim')

vim.call('plug#end')

-- if no plugins are installed, install them.
if vim.fn.isdirectory(vim.fn.stdpath("data") .. "/plugged") == 0 then
  vim.cmd('PlugInstall|q')
end

vim.opt.number = true
vim.opt.showmatch = true
vim.opt.backspace = "indent,eol,start"
vim.opt.smartindent = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.ruler = true
vim.opt.wrap = true
vim.opt.dir = "/tmp//"
vim.opt.scrolloff = 5
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wildignore = { '*.pyc', '*.o', '*.class', '*.lo', '.git', 'vendor/*', 'node_modules/**', '*/build_gradle/*',
  '*/build_intellij/*', '*/build/*' }
vim.opt.mouse = ""
vim.opt.backupcopy = "yes"
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile = true

-- LSP Server configurations
-- https://github.com/williamboman/mason-lspconfig.nvim/blob/25c11854aa25558ee6c03432edfa0df0217324be/README.md#available-lsp-servers
local servers = { "lua_ls", "gopls", "elixirls", "bashls", "terraformls", "kotlin_language_server", "jsonnet_ls",
  "yamlls", "helm_ls", "starpls" }

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = servers
}
vim.lsp.config('elixirls', {
  cmd = { "~/.local/share/nvim/mason/packages/elixir-ls/language_server.sh" },
})

if vim.fn.isdirectory("/home/owner/src/kotlin-bazel.nvim") ~= 0 then
  vim.opt.rtp:append("/home/owner/src/kotlin-bazel.nvim")
  require('kotlin_bazel').setup()
end

-- vim.lsp.set_log_level("debug")

local on_attach = function(client, buf)
  vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { buffer = buf, desc = "Go to Declaration" })
  vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to Definition" })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf, desc = "LSP Hover" })
  vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { buffer = buf, desc = "Go to Implementation" })
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = buf, desc = "Signature Help" })
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = buf, desc = "Rename Symbol" })
  vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { buffer = buf, desc = "Symbol References" })
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = buf, desc = "Code Action" })
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = buf, desc = "Go to Next Diagnostic" })
  vim.keymap.set("n", "<leader>gl", vim.diagnostic.open_float, { buffer = buf, desc = "Open Diagnostic Float" })
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = buf, desc = "Go to Previous Diagnostic" })
  vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { buffer = buf, desc = "Diagnostic to local list" })

  require("lsp-format").on_attach(client, buf) -- format on save
end

vim.lsp.config('*', {
  on_attach = on_attach,
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  },
})

-- Treesitter setup
local treesitter_parsers = { "bash", "diff", "dockerfile", "elixir", "go", "kotlin", "lua", "rego", "terraform" }
require 'nvim-treesitter'.install(treesitter_parsers)
vim.api.nvim_create_autocmd('FileType', {
  pattern = treesitter_parsers,
  callback = function() vim.treesitter.start() end,
})

-- Copilot Chat
require("CopilotChat").setup {
  model = 'claude-3.5-sonnet',
}

-- Shortcuts

-- NERDTree
vim.keymap.set('n', '<LocalLeader>nt', ':NERDTreeToggle<CR>', { silent = true })
vim.keymap.set('n', '<LocalLeader>nr', ':NERDTree<CR>', { silent = true })
vim.keymap.set('n', '<LocalLeader>nf', ':NERDTreeFind<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<LocalLeader>cw', ':%s/\\s\\+$//e<CR>', { desc = "Remove trailing whitespace" })

-- FZF
vim.keymap.set("n", "<LocalLeader>ff", ':FzfLua git_files<CR>', { desc = "Fzf Git Files" })
vim.keymap.set("n", "<LocalLeader>gw", ':FzfLua grep_cWORD<CR>', { desc = "Grep current word in normal mode" })
vim.keymap.set("v", "<LocalLeader>gw", ':FzfLua grep_visual<CR>', { desc = "Grep current word in visual mode" })
vim.keymap.set("n", "<LocalLeader>be", ':FzfLua buffers<CR>', { desc = "Show active buffers" })
require('fzf-lua').setup {
  keymap = {
    fzf = {
      ["ctrl-q"] = "select-all+accept", -- send all to quickfix
    }
  },
}
