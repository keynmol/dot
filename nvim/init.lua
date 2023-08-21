vim.cmd([[packadd packer.nvim]])

local PLUGINS = {
  setup = function()
    return require("packer").startup(function(use)
      use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true } }
      use({
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" },
      })
      use({ "sourcegraph/sg.nvim", run = "cargo build --workspace", requires = { "nvim-lua/plenary.nvim" } })
      use({
        'nvimdev/lspsaga.nvim',
        after = 'nvim-lspconfig',
        config = function()
          require('lspsaga').setup({})
        end,
      })
      use({ "ThePrimeagen/harpoon" })
      use({ "shime/vim-livedown" })
      use({ "earthly/earthly.vim" })
      use({
        "hrsh7th/nvim-cmp",
        requires = {
          { "hrsh7th/cmp-buffer" },
          { "hrsh7th/cmp-nvim-lsp" },
          { "hrsh7th/cmp-path" },
          { "hrsh7th/cmp-vsnip" },
          { "hrsh7th/vim-vsnip" },
          { "hrsh7th/vim-vsnip-integ" },
        },
      })

      use({ "kevinhwang91/nvim-bqf" })
      use({ 'kyazdani42/nvim-web-devicons' })
      use({ 'kyazdani42/nvim-tree.lua' })

      use({ "mfussenegger/nvim-dap" })
      use({ "neovim/nvim-lspconfig" })
      use({
        "nvim-telescope/telescope.nvim",
        requires = {
          { "nvim-lua/popup.nvim" },
          { "nvim-lua/plenary.nvim" },
          { "nvim-telescope/telescope-fzy-native.nvim" },
        },
      })
      use({ "scalameta/nvim-metals" })
      use({ "sheerun/vim-polyglot" })
      use({ "tpope/vim-fugitive" })
      use({ "ziglang/zig.vim" })
      use({ "tpope/vim-commentary" })
      use({ "wbthomason/packer.nvim", opt = true })
      use({ "rebelot/kanagawa.nvim" })
      -- use({ "cormacrelf/vim-colors-github" })
      use({ 'lukas-reineke/indent-blankline.nvim' })
      use {
        'nvim-treesitter/nvim-treesitter',
      }
      use 'nvim-treesitter/nvim-treesitter-context'
      use {
        'nvim-treesitter/playground'
      }
      use({
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
          require("lsp_lines").setup()
        end,
      })

      use 'neandertech/nvim-langoustine'
    end)
  end
}

local LUALINE = {
  setup = function()
    local function metals_status()
      return vim.g["metals_status"] or ""
    end

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
          }, metals_status },
          lualine_x = { 'encoding', 'filetype' },
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
      mapping = {
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end,
        ["<S-Tab>"] = function(fallback)
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
          compare.offset,    -- we still want offset to be higher to order after 3rd letter
          compare.score,     -- same as above
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
    Metals_config.settings = {
      showImplicitArguments = true,
      showInferredType = true,
      excludedPackages = {
        "akka.actor.typed.javadsl",
        "com.github.swagger.akka.javadsl",
        "akka.stream.javadsl",
      },
      serverVersion = 'latest.snapshot',
      enableSemanticHighlighting = true
    }

    Metals_config.init_options.statusBarProvider = "on"
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

local NVIM_TREE = {
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Default mappings. Feel free to modify or remove as you wish.
    --
    -- BEGIN_DEFAULT_ON_ATTACH
    vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
    vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
    vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts('Info'))
    vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
    vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
    vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
    vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
    vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
    vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
    vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
    vim.keymap.set('n', '.', api.node.run.cmd, opts('Run Command'))
    vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
    vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
    vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
    vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts('Toggle No Buffer'))
    vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
    vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts('Toggle Git Clean'))
    vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
    vim.keymap.set('n', ']c', api.node.navigate.git.next, opts('Next Git'))
    vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
    vim.keymap.set('n', 'D', api.fs.trash, opts('Trash'))
    vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand All'))
    vim.keymap.set('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
    vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
    vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
    vim.keymap.set('n', 'F', api.live_filter.clear, opts('Clean Filter'))
    vim.keymap.set('n', 'f', api.live_filter.start, opts('Filter'))
    vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
    vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
    vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
    vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
    vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
    vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
    vim.keymap.set('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
    vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
    vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
    vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
    vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
    vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
    vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
    vim.keymap.set('n', 's', api.node.run.system, opts('Run System'))
    vim.keymap.set('n', 'S', api.tree.search_node, opts('Search'))
    vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts('Toggle Hidden'))
    vim.keymap.set('n', 'W', api.tree.collapse_all, opts('Collapse'))
    vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
    vim.keymap.set('n', 'y', api.fs.copy.filename, opts('Copy Name'))
    vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
    vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
    -- END_DEFAULT_ON_ATTACH


    -- Mappings migrated from view.mappings.list
    --
    -- You will need to insert "your code goes here" for any mappings with a custom action_cb
    vim.keymap.set('n', 'U', api.tree.change_root_to_parent, opts('Up'))
  end,

  setup = function()
    require("nvim-tree").setup({
      on_attach = on_attach,
      sort_by = "case_sensitive",
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = false,
      },
    })

    vim.cmd([[nnoremap <C-a> :NvimTreeFindFile<CR>]])
    vim.cmd([[nnoremap <C-t> :NvimTreeToggle<CR>]])
  end
}


-- require("settings.galaxyline").setup()


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
    local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

    parser_config.scala = {
      install_info = {
        generate_requires_npm = true, -- if stand-alone parser without npm dependencies
        url = "~/projects/tree-sitter-scala/",
        files = { "src/parser.c", "src/scanner.c" },
        requires_generate_from_grammar = false, -- requires_generate_from_grammar = true, -- if folder contains pre-generated src/parser.c
      },
      filetype = "scala",                       -- if filetype does not agrees with parser name
      used_by = { "scala", "sbt" }              -- additional filetypes that use this parser
    }

    require 'nvim-treesitter.configs'.setup {
      sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
      highlight = {
        enable = true,      -- false will disable the whole extension
        additional_vim_regex_highlighting = false,
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
    vim.keymap.set('n', '<leader>lg', function() B.live_grep({ layout_strategy = 'vertical' }) end)
    vim.keymap.set('n', 'gds', B.lsp_document_symbols)
    vim.keymap.set('n', 'gws',
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

    local Path = require("plenary.path")
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
              { rest,  "TelescopeResultsComment" },
            }
          else
            return p[1]
          end
        end
        -- file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        -- grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      },
      -- extensions = {
      --   langoustine = {
      --     command_prefix = { "langoustine-tracer-dev", "trace" }
      --   }
      -- }
    })

    require("telescope").load_extension("fzy_native")
  end
}


local VISUAL = {
  setup = function()
    vim.cmd("colorscheme kanagawa")

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
    vim.keymap.set("n", "<leader>ld", function() vim.diagnostic.open_float(0, { scope = "line" }) end)
    vim.keymap.set("n", "<leader>awf", vim.lsp.buf.add_workspace_folder)
  end
}

local KEY_BINDINGS = {
  setup = function()
    vim.keymap.set("n", "<leader>ht", function() vim.api.nvim_put({ '#' }, 'c', true, true) end)
  end
}


local LSP_SAGA = {
  setup = function()
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
    vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action)
    vim.keymap.set("n", "<leader>lt", '<cmd>Lspsaga term_toggle<cr>')
    vim.keymap.set("n", "<leader>lo", '<cmd>Lspsaga outline<cr>')
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
  end
}

local HARPOON = {
  setup = function()
    -- lua require("harpoon.mark").add_file()
    vim.keymap.set("n", "<leader>hm", function() require("harpoon.mark").add_file() end)
    vim.keymap.set("n", "<leader>hq", function() require("harpoon.ui").toggle_quick_menu() end)
  end
}

local SOURCEGRAPH = {
  setup = function()
    require("sg").setup()
  end
}

PLUGINS.setup()
OPTIONS.setup()
VISUAL.setup()
LSP_SERVERS.setup()
TREE_SITTER.setup()
NVIM_TREE.setup()
TELESCOPE.setup()
METALS.setup()
NVIM_DAP.setup()
LSP_KEY_BINDINGS.setup()
CMP.setup()
LUALINE.setup()
KEY_BINDINGS.setup()
HARPOON.setup()
LSP_SAGA.setup()
