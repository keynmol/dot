local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=main", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local PLUGINS = {
  setup = function()
    return require("lazy").setup({
      "kevinhwang91/nvim-bqf",
      {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
          "MunifTanjim/nui.nvim",
          -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        }
      },
      {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
      },
      "mfussenegger/nvim-dap",
      "neovim/nvim-lspconfig",
      "scalameta/nvim-metals",
      "sheerun/vim-polyglot",
      "tpope/vim-fugitive",
      "tpope/vim-commentary",
      { "neandertech/nvim-langoustine",
        dit = "/Users/velvetbaldmime/projects/neandertech/nvim-langoustine",
        config = function()
          require('telescope').load_extension('langoustine')
        end, },
      "rebelot/kanagawa.nvim",
      {
        'nvim-lualine/lualine.nvim',
      },
      {
        "nvim-telescope/telescope.nvim",
        dependencies = {
          { "nvim-lua/popup.nvim" },
          { "nvim-lua/plenary.nvim" },
          { "nvim-telescope/telescope-fzy-native.nvim" },
        },
      },
      {
        "j-hui/fidget.nvim",
        opts = {
          -- options
        },
      },
      {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install",
        config = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" },
      },
      {
        'nvimdev/lspsaga.nvim',
        config = function()
          require('lspsaga').setup({})
        end,
      },
      'lukas-reineke/indent-blankline.nvim',
      'nvim-treesitter/nvim-treesitter',
      {
        'nvim-treesitter/nvim-treesitter-context',
        config = function()
          require 'treesitter-context'.setup {
            enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
            min_window_height = 50, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
            line_numbers = true,
            multiline_threshold = 1, -- Maximum number of lines to show for a single context
            trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
            -- Separator between context and content. Should be a single character string, like '-'.
            -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
            separator = nil,
            zindex = 20, -- The Z-index of the context window
            on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
          }
        end
      },
      'nvim-treesitter/playground',
      {
        "hrsh7th/nvim-cmp",
        dependencies = {
          { "hrsh7th/cmp-buffer" },
          { "hrsh7th/cmp-nvim-lsp" },
          { "hrsh7th/cmp-path" },
          { "hrsh7th/cmp-vsnip" },
          { "hrsh7th/vim-vsnip" },
          { "hrsh7th/vim-vsnip-integ" },
        },
      },
    })
  end
}

local LUALINE = {
  setup = function()
    require('lualine').setup(
      {
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff' },
        lualine_c = { 'filename', {
          'diagnostics',
          sources = { 'nvim_diagnostic' },
          symbols = { error = ' ', warn = ' ', info = ' ' },
          diagnostics_color = {
            color_error = { fg = '#ec5f67' },
            color_warn = { fg = '#ECBE7B' },
            color_info = { fg = '#008080' },
          }
        } },
        lualine_x = { 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      }
    }
    )
  end
}

local FUNCTIONS = {
  prequire = function(m, df)
    local ok, res = pcall(require, m)
    if not ok then return df, res end
    return res
  end,

  merge = function(a, b)
    local ab = {}

    table.foreach(a, function(_, v) table.insert(ab, v) end)
    table.foreach(b, function(_, v) table.insert(ab, v) end)

    return ab
  end

}

local CMP = {
  setup = function()
    local cmp = require("cmp")
    local compare = require 'cmp.config.compare'
    cmp.setup({
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        end,
      },
      sources = {
        { name = "nvim_lsp", priority = 100 },
        { name = "buffer" },
        { name = "path" },
        -- { name = "vsnip" },
      },
      window = {
        completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
      },
      mapping = {
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Down>"] = function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end,
        ["<Up>"] = function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end,
      },
      preselect = cmp.PreselectMode.None, -- disable preselection
      sorting = {
        priority_weight = 2,
        comparators = {
          compare.offset, -- we still want offset to be higher to order after 3rd letter
          compare.score, -- same as above
          compare.sort_text, -- add higher precedence for sort_text, it must be above `kind`
          compare.recently_used,
          compare.kind,
          compare.length,
          compare.order,
        },
      },
      -- if you want to add preselection you have to set completeopt to new values
      completion = {
        -- completeopt = 'menu,menuone,noselect', <---- this is default value,
        completeopt = 'menu,menuone', -- remove noselect
      },

    })
  end
}


local METALS = {
  setup = function()
    local shared_diagnostic_settings = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })
    local lsp_config = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    lsp_config.util.default_config = vim.tbl_extend("force", lsp_config.util.default_config, {
      handlers = {
        ["textDocument/publishDiagnostics"] = shared_diagnostic_settings,
      },
      capabilities = capabilities,
    })

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })

    Metals_config = require("metals").bare_config()

    if os.getenv("LANGOUSTINE_METALS") then
      Metals_config.cmd = { "langoustine-tracer", "trace", "--", os.getenv("LANGOUSTINE_METALS") }
    end
    Metals_config.settings = {
      showImplicitArguments = true,
      showInferredType = true,
      excludedPackages = {
        "akka.actor.typed.javadsl",
        "com.github.swagger.akka.javadsl",
        "akka.stream.javadsl",
      },
      serverVersion = 'latest.snapshot',
      enableSemanticHighlighting = false
    }
    Metals_config.find_root_dir_max_project_nesting = 0

    Metals_config.init_options.statusBarProvider = "off"
    Metals_config.handlers["textDocument/publishDiagnostics"] = shared_diagnostic_settings
    Metals_config.capabilities = capabilities

    local dap = require("dap")

    -- For that they usually provide a `console` option in their |dap-configuration|.
    -- The supported values are usually called `internalConsole`, `integratedTerminal`
    -- and `externalTerminal`.
    dap.configurations.scala = {
      {
        type = "scala",
        request = "launch",
        name = "Run or test with input",
        metals = {
          runType = "runOrTestFile",
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
          end,
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "Run or Test",
        metals = {
          runType = "runOrTestFile",
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "Test Target",
        metals = {
          runType = "testTarget",
        },
      },
    }
    Metals_config.on_attach = function(_, _)
      require("metals").setup_dap()
    end

    vim.keymap.set("n", "<leader>tt", require("metals.tvp").toggle_tree_view)
    vim.keymap.set("n", "<leader>tr", require("metals.tvp").reveal_in_tree)
    vim.keymap.set("v", "K", require("metals").type_of_range)
    vim.keymap.set("n", "<leader>ws", function() require("metals").hover_worksheet({ border = "single" }) end)
  end
}



local local_overrides = FUNCTIONS.prequire("locals")



local overriden = function(key, default)
  if not local_overrides[key] then
    return default
  else
    return local_overrides[key]
  end
end

local function add_tracing(name, raw_cmd)
  if not local_overrides.tracing then
    return raw_cmd
  else
    local tcf = local_overrides.tracing
    if not tcf.cmd or not tcf.enabled then
      print("Warning: Langoustine tracer `cmd` or `enabled` is not set in locals.lua")
      return raw_cmd
    else
      if tcf.enabled[name] and tcf.enabled[name] == true then
        return FUNCTIONS.merge(tcf.cmd, raw_cmd)
      else
        return raw_cmd
      end
    end
  end
end

local TREE_SITTER = {
  setup = function()
    require 'nvim-treesitter.configs'.setup {
      -- A list of parser names, or "all" (the five listed parsers should always be installed)
      -- ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "scala", "rust", "go", "cpp" },
      sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
      highlight = {
        enable = true, -- false will disable the whole extension
        additional_vim_regex_highlighting = false,
      },
      -- indent = {
      --   enable = true

      -- },
      keymaps = {
        init_selection = "gnn", -- set to `false` to disable one of the mappings
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    }
  end
}

local lsp = vim.api.nvim_create_augroup("LSP", { clear = true })


local LSP_SERVERS = {
  setup = function()
    require 'lspconfig'.clangd.setup {}
    require 'lspconfig'.zls.setup {}
    require 'lspconfig'.ocamllsp.setup {}
    require 'lspconfig'.fsautocomplete.setup {}
    require 'lspconfig'.html.setup {}
    require 'lspconfig'.crystalline.setup {}
    require 'lspconfig'.gopls.setup {}
    require 'lspconfig'.tsserver.setup {}
    require 'lspconfig'.rust_analyzer.setup {}
    require 'lspconfig'.jsonls.setup {}

    require 'lspconfig'.tailwindcss.setup = {
      -- exclude a filetype from the default_config
      filetypes_exclude = { "markdown" },
      -- add additional filetypes to the default_config
      filetypes_include = { "scala" },
      -- to fully override the default_config, change the below
      -- filetypes = {}
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              "[cls|className]\\s\\:\\=\\s\"([^\"]*)"
            }
          },
        }
      } }

    -- require 'lspconfig'.sourcekit.setup {}
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    require 'lspconfig'.cssls.setup {
      capabilities = capabilities,
    }

    if local_overrides.marksman_lsp then
      require 'lspconfig'.marksman.setup {
        cmd = add_tracing("marksman", {
          local_overrides.marksman_lsp, 'server' -- the command to launch target LSP
        })
      }
    else
      require 'lspconfig'.marksman.setup {}
    end


    -- if local_overrides.grammar_js_lsp then
    vim.api.nvim_create_autocmd("FileType", {
      group = lsp,
      pattern = "tree-sitter-grammar",
      callback = function()
        local path = vim.fs.find({ "grammar.js" })
        if (path[1]) then
          vim.lsp.start({
            name = "Grammar.js LSP",
            cmd = { 'tree-sitter-grammar-lsp' },
            root_dir = vim.fs.dirname(path[1])
          })
        end
      end,
    })

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { "grammar.js", "*/corpus/*.txt" },
      callback = function() vim.cmd("setfiletype tree-sitter-grammar") end
    })

    vim.api.nvim_create_autocmd({ "BufReadPost" }, {
      pattern = { "grammar.js" },
      command = "set syntax=javascript"
    })
    -- end


    if local_overrides.github_actions_lsp then
      vim.api.nvim_create_autocmd("FileType", {
        group = lsp,
        pattern = "yaml",
        callback = function()
          local path = vim.fs.find({ ".github/workflows" })
          if (path[1]) then
            vim.lsp.start({
              name = "Github Actions LSP",
              cmd = add_tracing("github_actions", { local_overrides.github_actions_lsp }),
              root_dir = vim.fs.dirname(path[1])
            })
          end
        end
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = lsp,
      pattern = "smithy",
      callback = function()
        local path = vim.fs.find({ "smithy-build.json" })
        vim.lsp.start({
          name = "Smithy LSP",
          cmd = add_tracing("smithy",
            { 'cs', 'launch', 'com.disneystreaming.smithy:smithy-language-server:latest.release', '--', '0' }),
          root_dir = vim.fs.dirname(path[1])
        })
      end,
    })

    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")

    require 'lspconfig'.lua_ls.setup {
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
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
      local cmd = add_tracing("quickmaffs", { local_overrides.quickmaffs_lsp })
      vim.api.nvim_create_autocmd("FileType", {
        group = lsp,
        pattern = "quickmaffs",
        callback = function()
          vim.lsp.start({
            name = "Quickmaffs",
            cmd = cmd,
          })
        end,
      })


      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.qmf" },
        callback = function() vim.cmd("setfiletype quickmaffs") end
      })
    end

    if local_overrides.llvm_lsp then
      vim.api.nvim_create_autocmd("FileType", {
        group = lsp,
        pattern = "lifelines",
        callback = function()
          vim.lsp.start({
            name = "LLVM LSP",
            cmd = add_tracing("llvm", { local_overrides.llvm_lsp }),
          })
        end
      })
    end

    vim.cmd([[augroup lsp]])
    vim.cmd([[autocmd!]])
    vim.cmd([[autocmd FileType scala,sbt setlocal omnifunc=v:lua.vim.lsp.omnifunc]])
    vim.cmd([[autocmd FileType scala,sbt,java lua require("metals").initialize_or_attach(Metals_config)]])
    vim.cmd([[augroup end]])

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { "*.smithy" },
      callback = function() vim.cmd("setfiletype smithy") end
    })

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { "*.fs" },
      callback = function() vim.cmd("setfiletype fsharp") end
    })


    vim.cmd([[autocmd FileType fsharp setlocal commentstring=//\ %s]])
  end
}

local TELESCOPE = {
  lsp_workspace_symbols = function()
    local input = vim.fn.input("Query: ")
    vim.api.nvim_command("normal :esc<CR>")
    if not input or #input == 0 then
      return
    end
    require("telescope.builtin").lsp_workspace_symbols({ query = input })
  end,
  setup = function()
    local B = require("telescope.builtin")
    local EXT = require("telescope").extensions

    vim.keymap.set('n', '<leader>hv', B.help_tags)
    vim.keymap.set('n', '<leader>ff', function() B.find_files({ layout_strategy = 'vertical' }) end)
    vim.keymap.set('n', '<leader>fg', function() B.git_files({ layout_strategy = 'vertical' }) end)
    vim.keymap.set('n', '<leader>gb', function() B.git_branches({ layout_strategy = 'vertical' }) end)
    vim.keymap.set('n', '<leader>b', function() B.buffers({ layout_strategy = 'vertical' }) end)
    vim.keymap.set('n', '<leader>lg', function() B.live_grep({ layout_strategy = 'vertical' }) end)
    vim.keymap.set('n', 'gs', B.lsp_document_symbols)
    vim.keymap.set('n', 'gS',
      function()
      B.lsp_dynamic_workspace_symbols({
        path_display = { shorten = { len = 1, exclude = { 1, -1 } } },
        layout_strategy = 'vertical'
      })
    end)
    vim.keymap.set('n', '<leader>mc', EXT.metals.commands)

    local previewers = require("telescope.previewers")

    local new_maker = function(filepath, bufnr, opts)
      opts = opts or {}

      filepath = vim.fn.expand(filepath)
      vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then return end
        if stat.size > 100000 then
          return
        else
          previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end
      end)
    end

    local Display = require("telescope.pickers.entry_display")

    local displayer = Display.create {
      separator = " in ",
      items = {
        { width = 25 },
        { remaining = true },
      },
    }

    require("telescope").setup({
      defaults = {
        buffer_previewer_maker = new_maker,
        file_ignore_patterns = { "target", "node_modules", "parser.c" },
        prompt_prefix = "❯",
        path_display = function(opts, path)
          local p = vim.split(path, '/')
          if #p > 1 then
            local rest = ''
            for i = 1, #p - 1 do
              rest = rest .. "/" .. p[i]
            end
            return displayer {
              { p[#p], "TelescopeResultsNumber" },
              { rest, "TelescopeResultsComment" },
            }
          else
            return p[1]
          end
        end
        -- file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        -- grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      },
      extensions = {
        langoustine = {
          command_prefix = { "langoustine-tracer-dev", "trace" }
        }
      }
    })

    require("telescope").load_extension("fzy_native")
  end
}


local VISUAL = {
  setup = function()
    vim.cmd("colorscheme tokyonight-night")
    -- vim.cmd("colorscheme catppuccin-latte")

    vim.fn.sign_define("LspDiagnosticsSignError", { text = "▬" })
    vim.fn.sign_define("LspDiagnosticsSignWarning", { text = "▬" })
    vim.fn.sign_define("LspDiagnosticsSignInformation", { text = "▬" })
    vim.fn.sign_define("LspDiagnosticsSignHint", { text = "▬" })

    vim.cmd([[hi! link LspReferenceText CursorColumn]])
    vim.cmd([[hi! link LspReferenceRead CursorColumn]])
    vim.cmd([[hi! link LspReferenceWrite CursorColumn]])

    vim.cmd([[hi! link LspSagaFinderSelection CursorColumn]])
    vim.cmd([[hi! link LspSagaDocTruncateLine LspSagaHoverBorder]])
    vim.cmd([[hi TreesitterContextBottom gui=underline guisp=Green]])
  end
}

local NVIM_DAP = {
  setup = function()
    vim.keymap.set("n", "<leader>dc", require "dap".continue)
    vim.keymap.set("n", "<leader>dl", require "dap".run_last)
    vim.keymap.set("n", "<leader>dr", require "dap".repl.toggle)
    vim.keymap.set("n", "<leader>dtb", require "dap".toggle_breakpoint)
    vim.keymap.set("n", "<leader>dso", require "dap".step_over)
    vim.keymap.set("n", "<leader>dsi", require "dap".step_into)
  end
}

local LSP_KEY_BINDINGS = {
  setup = function()
    vim.keymap.set("n", "<leader>sf", function() vim.lsp.buf.format { async = true } end)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition)
    vim.keymap.set("n", "gD", vim.lsp.buf.type_definition)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
    vim.keymap.set("n", "gr", vim.lsp.buf.references)
    vim.keymap.set("n", "<leader>rr", vim.lsp.codelens.run)
    vim.keymap.set("n", "<leader>aa", vim.diagnostic.setqflist)
    vim.keymap.set("n", "<leader>ae",
      function() vim.diagnostic.setqflist { severity = vim.diagnostic.severity.ERROR } end)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist)
    vim.keymap.set("n", "]c", vim.diagnostic.goto_next)
    vim.keymap.set("n", "[c", vim.diagnostic.goto_prev)
    vim.keymap.set("n", "]e", function() vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR } end)
    vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR } end)
    vim.keymap.set("n", "]w", function() vim.diagnostic.goto_next { severity = vim.diagnostic.severity.WARNING } end)
    vim.keymap.set("n", "[w", function() vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.WARNING } end)
    vim.keymap.set("n", "<leader>ih", function()
      vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled(0))
    end)
    vim.keymap.set("n", "<leader>ld", function() vim.diagnostic.open_float(0, { scope = "line" }) end)
    vim.keymap.set("n", "<leader>awf", vim.lsp.buf.add_workspace_folder)
  end
}

local KEY_BINDINGS = {
  setup = function()
    vim.keymap.set("n", "<leader>ht", function() vim.api.nvim_put({ '#' }, 'c', true, true) end)
    vim.keymap.set("n", "<leader>gc", ":G commit<CR>")
    vim.keymap.set("n", "<leader>gqw", ":G qwip<CR>")
    vim.keymap.set("n", "<leader>gqc", ":G qcm<CR>")
    vim.keymap.set("n", "<leader>gu", ":G up<CR>")
    vim.keymap.set("n", "<leader>cs", ":copen<CR>")
  end
}


local LSP_SAGA = {
  setup = function()
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action)
    vim.keymap.set("n", "<leader>lt", '<cmd>Lspsaga term_toggle<cr>')
    vim.keymap.set("n", "<leader>lo", '<cmd>Lspsaga outline<cr>')
    vim.keymap.set("n", "<leader>li", '<cmd>Lspsaga incoming_calls<cr>')
  end
}

local OPTIONS = {
  setup = function()
    vim.g.netrw_gx = "<cWORD>"
    vim.g.vim_markdown_conceal = 0
    vim.g.vim_markdown_conceal_code_blocks = 0

    local indent = 2
    vim.o.shortmess = string.gsub(vim.o.shortmess, "F", "") .. "c"
    vim.o.path = vim.o.path .. "**"

    vim.opt.clipboard = "unnamed"
    vim.opt.completeopt = "menu,menuone,noselect"
    vim.opt.cursorline = true
    vim.opt.expandtab = true
    vim.opt.fileformat = "unix"
    vim.opt.hidden = true
    vim.opt.ignorecase = true
    vim.opt.laststatus = 2
    vim.opt.modeline = false
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.shiftwidth = indent
    vim.opt.showmatch = true
    vim.opt.showtabline = 1
    vim.opt.signcolumn = "yes"
    vim.opt.smartcase = true
    vim.opt.softtabstop = indent
    vim.opt.splitbelow = true
    vim.opt.splitright = true
    vim.opt.tabstop = indent
    vim.opt.updatetime = 300
    vim.opt.wildignore = ".git,*/node_modules/*,*/target/*,.metals,.bloop"
    vim.opt.wrap = false

    vim.keymap.set("n", "<leader>tv", ":vnew | :te<cr>")
    vim.keymap.set("n", "<leader>vt", ":tabnew<CR>")
    vim.keymap.set("n", "<leader>cn", ":cnext<CR>")
    vim.keymap.set("n", "<leader>cp", ":cprev<CR>")
    vim.keymap.set("n", "<leader>cs", ":copen<CR>")
    vim.keymap.set("n", "<leader>cc", ":cclose<CR>")

    -- navigation
    vim.cmd([[nnoremap <C-h> <C-w>h]])
    vim.cmd([[nnoremap <C-l> <C-w>l]])
    vim.cmd([[nnoremap <C-j> <C-w>j]])
    vim.cmd([[nnoremap <C-k> <C-w>k]])

    ----------------------------------
    -- COMMANDS ----------------------
    ----------------------------------
    vim.cmd([[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]])
    vim.cmd([[autocmd BufReadPost,BufNewFile *.md,*.txt,COMMIT_EDITMSG set wrap linebreak nolist spell spelllang=en_gb]])
    vim.cmd([[autocmd TermOpen * startinsert]])
  end
}

local INDENT_BLANKLINE = {
  setup = function()
    require("ibl").setup()
  end
}


local NEO_TREE = {
  setup = function()
    require("neo-tree").setup({
      filesystem = {
        hijack_netrw_behavior = "open_current",
      }
    })

    vim.cmd([[nnoremap <C-a> :Neotree source=filesystem reveal=true position=left<CR>]])
    vim.cmd([[nnoremap <C-t> :Neotree toggle=true<CR>]])
    vim.keymap.set("n", "<leader>fn", ":Neotree current<CR>")
  end
}


PLUGINS.setup()
OPTIONS.setup()
VISUAL.setup()
LSP_SERVERS.setup()
TREE_SITTER.setup()
NEO_TREE.setup()
TELESCOPE.setup()
METALS.setup()
NVIM_DAP.setup()
LSP_KEY_BINDINGS.setup()
CMP.setup()
LUALINE.setup()
KEY_BINDINGS.setup()
LSP_SAGA.setup()
INDENT_BLANKLINE.setup()
