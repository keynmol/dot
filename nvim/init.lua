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

require("settings.galaxyline").setup()

require("lspsaga").init_lsp_saga({
  server_filetype_map = { metals = { "sbt", "scala" } },
  code_action_prompt = { virtual_text = true },
})

-- vim.lsp.set_log_level('trace')

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
local local_overrides = {}

local function init_locals()
  local local_overrides = require('locals')
  if not(type(local_overrides) == table) then 
    local_overrides = {} 
  end
end 

pcall(init_locals)

local overriden = function(key, default)
  if not local_overrides[key] then
    return default
  else
    return local_overrides[key]
  end
end

local function add_tracing(name, raw_cmd)
  if not local_overrides.tracing then return raw_cmd
  else
    local tcf = local_overrides.tracing
    if not tcf.cmd or not tcf.enabled then
      print("Warning: Langoustine tracer `cmd` or `enabled` is not set in locals.lua")
      return raw_cmd
    else
      if tcf.enabled[name] and tcf.enabled[name] == true then
        return f.mergelists(tcf.cmd, raw_cmd)
      else
        return raw_cmd
      end
    end
  end
end

parser_config.scala = {
  install_info = {
    url = overriden("tree_sitter_scala_path", "https://github.com/keynmol/tree-sitter-scala"), -- local path or git repo
    files = { "src/parser.c", "src/scanner.c" },
    -- optional entries:
    branch = overriden("tree_sitter_scala_branch", "test-scala3"), -- default branch in case of git repo if different from master
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
  highlight = {
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
  },
}


require("indent_blankline").setup {
  show_current_context = true,
  show_current_context_start = true,
}

require 'lspconfig'.clangd.setup {}
require 'lspconfig'.zls.setup {}
require 'lspconfig'.smithy.setup {}
require 'lspconfig'.ocamllsp.setup {}
require 'lspconfig'.fsautocomplete.setup {}

if local_overrides.marksman_lsp then
  require 'lspconfig'.marksman.setup {
    cmd = add_tracing("marksman", {
      local_overrides.marksman_lsp, 'server' -- the command to launch target LSP
    })
  }
end

local lsp = vim.api.nvim_create_augroup("LSP", { clear = true })

if local_overrides.grammar_js_lsp then
  vim.api.nvim_create_autocmd("FileType", {
    group = lsp,
    pattern = "tree-sitter-grammar",
    callback = function()
      local path = vim.fs.find({ "grammar.js" })
      vim.lsp.start({
        name = "Grammar.js LSP",
        cmd = add_tracing("grammarJs", { local_overrides.grammar_js_lsp }),
        root_dir = vim.fs.dirname(path[1])
      })
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "grammar.js" },
    callback = function() vim.cmd("setfiletype tree-sitter-grammar") end
  })

  vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "grammar.js" },
    command = "set syntax=javascript"
  })
end

vim.cmd([[hi! link LspReferenceText CursorColumn]])
vim.cmd([[hi! link LspReferenceRead CursorColumn]])
vim.cmd([[hi! link LspReferenceWrite CursorColumn]])

if local_overrides.github_actions_lsp then
  vim.api.nvim_create_autocmd("FileType", {
    group = lsp,
    pattern = "yaml",
    callback = function()
      local path = vim.fs.find({ ".github/workflows" })
      vim.lsp.start({
        name = "Github Actions LSP",
        cmd = add_tracing("github_actions", { local_overrides.github_actions_lsp }),
        root_dir = vim.fs.dirname(path[1])
      })
    end,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  group = lsp,
  pattern = "smithy",
  callback = function()
    local path = vim.fs.find({ "smithy-build.json" })
    vim.lsp.start({
      name = "Smithy LSP",
      cmd = add_tracing("smithy", { 'cs', 'launch', 'com.disneystreaming.smithy:smithy-language-server:latest.release', '--', '0' }),
      root_dir = vim.fs.dirname(path[1])
    })
  end,
})

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

if local_overrides.quickmaffs_lsp then
  vim.api.nvim_create_autocmd("FileType", {
    group = lsp,
    pattern = "quickmaffs",
    callback = function()
      vim.lsp.start({
        name = "Quickmaffs",
        cmd = add_tracing("quickmaffs", { local_overrides.quickmaffs_lsp }),
      })
    end,
  })


  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.qmf" },
    callback = function() vim.cmd("setfiletype quickmaffs") end
  })
end

if local_overrides.langoustine_native_lsp then
  vim.api.nvim_create_autocmd("FileType", {
    group = lsp,
    pattern = "testnative",
    callback = function()
      vim.lsp.start({
        name = "Langoustine",
        cmd = add_tracing("langoustine_native", { local_overrides.langoustine_native_lsp }),
      })
    end,
  })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.lls" },
    callback = function() vim.cmd("setfiletype testnative") end
  })
end

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
opt("o", "relativenumber", true)
opt("o", "number", true)

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
map("n", "K", [[<cmd>lua vim.lsp.buf.hover()<CR>]])
map("v", "K", [[<Esc><cmd>lua require("metals").type_of_range()<CR>]])
map("n", "gi", [[<cmd>lua vim.lsp.buf.implementation()<CR>]])
map("n", "gr", [[<cmd>lua vim.lsp.buf.references()<CR>]])
map("n", "<leader>sh", [[<cmd>lua require"lspsaga.signaturehelp".signature_help()<CR>]])
map("n", "<leader>rn", [[<cmd>lua require"lspsaga.rename".rename()<CR>]])
map("n", "<leader>ca", [[<cmd>lua require"lspsaga.codeaction".code_action()<CR>]])
map("v", "<leader>ca", [[<cmd>lua require"lspsaga.codeaction".range_code_action()<CR>]])
map("n", "<leader>ws", [[<cmd>lua require"metals".worksheet_hover()<CR>]])
map("n", "<leader>rr", [[<cmd>lua vim.lsp.codelens.run()<CR>]])

map("n", "<leader>tt", [[<cmd>lua require("metals.tvp").toggle_tree_view()<CR>]])
map("n", "<leader>tr", [[<cmd>lua require("metals.tvp").reveal_in_tree()<CR>]])
map("n", "<leader>ws", [[<cmd>lua require("metals").hover_worksheet({ border = "single" })<CR>]])

-- diagnostics
map("n", "<leader>a", [[<cmd>lua vim.diagnostic.setqflist()<CR>]])
map("n", "<leader>d", [[<cmd>lua vim.diagnostic.setloclist()<CR>]]) -- buffer diagnostics only
map("n", "]c", [[<cmd>lua vim.diagnostic.goto_next()<CR>]])
map("n", "[c", [[<cmd>lua vim.diagnostic.goto_prev()<CR>]])
map("n", "<leader>ld", [[<cmd>lua vim.diagnostic.open_float(0, {scope = "line"})<CR>]])

-- telescope
map("n", "<leader>ff", [[<cmd>lua require"telescope.builtin".find_files({layout_strategy='vertical'})<CR>]])
map("n", "<leader>fg", [[<cmd>lua require"telescope.builtin".git_files({layout_strategy='vertical'})<CR>]])
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
cmd([[autocmd BufReadPost,BufNewFile *.md,*.txt,COMMIT_EDITMSG set wrap linebreak nolist spell spelllang=en_gb]])
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
