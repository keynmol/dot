local M = {}

M.setup = function()
  local shared_diagnostic_settings = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true })
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
    testUserInterface = "Test Explorer"
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
      name = "Run",
      metalsRunType = "run",
    }
    -- },
    -- {
    --   type = "scala",
    --   request = "launch",
    --   name = "Test File",
    --   metalsRunType = "testFile",
    -- },
    -- {
    --   type = "scala",
    --   request = "launch",
    --   name = "Test Target",
    --   metalsRunType = "testTarget",
    -- },
  }

  Metals_config.on_attach = function(client, bufnr)
    require("metals").setup_dap()
  end
end

return M
