local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local f = require("settings.functions")
local map = f.map
local opt = f.opt

----------------------------------
-- SETUP PLUGINS -----------------
----------------------------------
cmd([[packadd packer.nvim]])
require("plugins")
require("settings.functions")
require("settings.cmp").setup()
require("settings.telescope").setup()
require("settings.lsp").setup()
-- require("settings.zeta-note").setup()

require("settings.galaxyline").setup()
require("lspsaga").init_lsp_saga({
  server_filetype_map = { metals = { "sbt", "scala" } },
  code_action_prompt = { virtual_text = false },
})

require("indent_blankline").setup {
  char = "|",
  buftype_exclude = { "terminal" }
}
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.scala = {
  install_info = {
    url = "~/projects/tree-sitter-scala", -- local path or git repo
    files = { "src/parser.c", "src/scanner.c" },
    -- optional entries:
    branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = true, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = true, -- if folder contains pre-generated src/parser.c
  },
  filetype = "scala", -- if filetype does not agrees with parser name
  used_by = { "scala", "sbt" } -- additional filetypes that use this parser
}
parser_config.smithy = {
  install_info = {
    url = "https://github.com/indoorvivants/tree-sitter-smithy", -- local path or git repo
    files = { "src/parser.c" },
    -- optional entries:
    branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = true, -- if stand-alone parser without npm dependencies
    requires_generate_from_grammar = true, -- if folder contains pre-generated src/parser.c
  },
  filetype = "smithy" -- if filetype does not agrees with parser name
}

require 'nvim-treesitter.configs'.setup {
  -- ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
  ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    -- disable = { "scala" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

vim.filetype.add({
  extension = {
    smithy = "smithy",
  },
})

require 'lspconfig'.clangd.setup {}
require 'lspconfig'.zls.setup {}
require 'lspconfig'.smithy.setup {}
require 'lspconfig'.ocamllsp.setup{}
require 'lspconfig'.fsautocomplete.setup{}
require 'lspconfig'.marksman.setup {
  cmd = {'/Users/velvetbaldmime/projects/marksman/Marksman/bin/Debug/net6.0/marksman', 'server'}
}

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require 'lspconfig'.sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
----------------------------------
-- VARIABLES ---------------------
----------------------------------
-- g["mapleader"] = ","
g["netrw_gx"] = "<cWORD>"

-- plugin variables
-- polyglot's markdown settings
g["vim_markdown_conceal"] = 0
g["vim_markdown_conceal_code_blocks"] = 0

----------------------------------
-- OPTIONS -----------------------
----------------------------------
local indent = 2
vim.o.shortmess = string.gsub(vim.o.shortmess, "F", "") .. "c"
vim.o.path = vim.o.path .. "**"

-- global
opt("o", "termguicolors", true)
opt("o", "hidden", true)
opt("o", "showtabline", 1)
opt("o", "updatetime", 300)
opt("o", "showmatch", true)
opt("o", "laststatus", 2)
opt("o", "wildignore", ".git,*/node_modules/*,*/target/*,.metals,.bloop")
opt("o", "ignorecase", true)
opt("o", "smartcase", true)
opt("o", "clipboard", "unnamed")
opt("o", "completeopt", "menu,menuone,noselect")
opt("o", "splitbelow", true)
opt("o", "splitright", true)

-- window-scoped
opt("w", "wrap", false)
opt("w", "cursorline", true)
opt("w", "signcolumn", "yes")

-- buffer-scoped
opt("b", "tabstop", indent)
opt("b", "shiftwidth", indent)
opt("b", "softtabstop", indent)
opt("b", "expandtab", true)
opt("b", "fileformat", "unix")

-- MAPPINGS -----------------------
-- insert-mode mappings
map("n", "<leader>n", [[<cmd>lua require("settings.functions").toggle_nums()<CR>]])

-- normal-mode mappings
map("n", "<leader>hs", ":nohlsearch<cr>")
map("n", "<leader>xml", ":%!xmllint --format -<cr>")
map("n", "<leader>fo", ":copen<cr>")
map("n", "<leader>fc", ":cclose<cr>")
map("n", "<leader>fn", ":cnext<cr>")
map("n", "<leader>fp", ":cprevious<cr>")
map("n", "<leader>tv", ":vnew | :te<cr>")

-- LSP
map("n", "<leader>sf", [[<cmd>lua vim.lsp.buf.format { async = true }<CR>]])
map("n", "gd", [[<cmd>lua vim.lsp.buf.definition()<CR>]])
map("n", "K", [[<cmd>lua require"lspsaga.hover".render_hover_doc()<CR>]])
map("v", "K", [[<Esc><cmd>lua require("metals").type_of_range()<CR>]])
map("n", "gi", [[<cmd>lua vim.lsp.buf.implementation()<CR>]])
map("n", "gr", [[<cmd>lua vim.lsp.buf.references()<CR>]])
map("n", "<leader>rn", [[<cmd>lua require"lspsaga.rename".rename()<CR>]])
map("n", "<leader>ca", [[<cmd>lua require"lspsaga.codeaction".code_action()<CR>]])
map("v", "<leader>ca", [[<cmd>lua require"lspsaga.codeaction".range_code_action()<CR>]])
map("n", "<leader>ws", [[<cmd>lua require"metals".worksheet_hover()<CR>]])
map("n", "<leader>rr", [[<cmd>lua vim.lsp.codelens.run()<CR>]])
-- diagnostics
map("n", "<leader>a", [[<cmd>lua vim.diagnostic.setqflist()<CR>]])
map("n", "<leader>d", [[<cmd>lua vim.diagnostic.setloclist()<CR>]]) -- buffer diagnostics only
map("n", "]c", [[<cmd>lua vim.diagnostic.goto_next()<CR>]])
map("n", "[c", [[<cmd>lua vim.diagnostic.goto_prev()<CR>]])
map("n", "<leader>ld", [[<cmd>lua vim.diagnostic.open_float(0, {scope = "line"})<CR>]])

-- completion
-- map("i", "<S-Tab>", [[pumvisible() ? "<C-p>" : "<Tab>"]], { expr = true })
-- map("i", "<Tab>", [[pumvisible() ? "<C-n>" : "<Tab>"]], { expr = true })
-- map("i", "<CR>", [[compe#confirm("<CR>")]], { expr = true })

-- telescope
map("n", "<leader>ff", [[<cmd>lua require"telescope.builtin".find_files({layout_strategy='vertical'})<CR>]])
map("n", "<leader>lg", [[<cmd>lua require"telescope.builtin".live_grep({layout_strategy='vertical'})<CR>]])
map("n", "gds", [[<cmd>lua require"telescope.builtin".lsp_document_symbols({layout_stratey='vertical'})<CR>]])
map("n", "gws", [[<cmd>lua require"telescope.builtin".lsp_dynamic_workspace_symbols({layout_strategy='vertical'})<CR>]])
map("n", "<leader>mc", [[<cmd>lua require("telescope").extensions.metals.commands()<CR>]])
map("n", "<leader>fb", [[<cmd>lua require"telescope.builtin".file_browser({layout_strategy='vertical'})<CR>]])

-- nvim-dap
map("n", "<leader>dc", [[<cmd>lua require"dap".continue()<CR>]])
map("n", "<leader>dr", [[<cmd>lua require"dap".repl.toggle()<CR>]])
map("n", "<leader>dtb", [[<cmd>lua require"dap".toggle_breakpoint()<CR>]])
map("n", "<leader>dso", [[<cmd>lua require"dap".step_over()<CR>]])
map("n", "<leader>dsi", [[<cmd>lua require"dap".step_into()<CR>]])


-- nerdtree

vim.cmd([[nnoremap <C-a> :NERDTreeFind<CR>]])
vim.cmd([[nnoremap <C-t> :NERDTreeToggle<CR>]])

-- navigation
vim.cmd([[nnoremap <C-h> <C-w>h]])
vim.cmd([[nnoremap <C-l> <C-w>l]])
vim.cmd([[nnoremap <C-j> <C-w>j]])
vim.cmd([[nnoremap <C-k> <C-w>k]])



----------------------------------
-- COMMANDS ----------------------
----------------------------------
cmd([[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]])
cmd([[autocmd BufEnter *.js call matchadd('ColorColumn', '\%81v', 100)]])
cmd([[autocmd BufReadPost,BufNewFile *.md,*.txt,COMMIT_EDITMSG set wrap linebreak nolist spell spelllang=en_us complete+=kspell]])
cmd([[autocmd BufReadPost,BufNewFile .html,*.txt,*.md,*.adoc set spell spelllang=en_us]])
cmd([[autocmd TermOpen * startinsert]])

cmd("colorscheme kanagawa")

-- LSP
cmd([[augroup lsp]])
cmd([[autocmd!]])
cmd([[autocmd FileType scala,sbt setlocal omnifunc=v:lua.vim.lsp.omnifunc]])
cmd([[autocmd FileType scala,sbt,java lua require("metals").initialize_or_attach(Metals_config)]])
cmd([[augroup end]])

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.smithy" },
  callback = function() vim.cmd("setfiletype smithy") end
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.fs" },
  callback = function() vim.cmd("setfiletype fsharp") end
})
cmd([[autocmd FileType fsharp setlocal commentstring=//\ %s]])
----------------------------------
-- LSP Settings ------------------
----------------------------------
fn.sign_define("LspDiagnosticsSignError", { text = "▬" })
fn.sign_define("LspDiagnosticsSignWarning", { text = "▬" })
fn.sign_define("LspDiagnosticsSignInformation", { text = "▬" })
fn.sign_define("LspDiagnosticsSignHint", { text = "▬" })

vim.cmd([[hi! link LspReferenceText CursorColumn]])
vim.cmd([[hi! link LspReferenceRead CursorColumn]])
vim.cmd([[hi! link LspReferenceWrite CursorColumn]])

vim.cmd([[hi! link LspSagaFinderSelection CursorColumn]])
vim.cmd([[hi! link LspSagaDocTruncateLine LspSagaHoverBorder]])
