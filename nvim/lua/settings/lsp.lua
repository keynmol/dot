local M = {}

M.setup = function()
  local shared_diagnostic_settings = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = true })
  local lsp_config = require("lspconfig")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  lsp_config.util.default_config = vim.tbl_extend("force", lsp_config.util.default_config, {
    handlers = {
      ["textDocument/publishDiagnostics"] = shared_diagnostic_settings,
    },
    capabilities = capabilities,
  })

  Metals_config = require("metals").bare_config()
  Metals_config.settings = {
    showImplicitArguments = true,
    showInferredType = true,
    excludedPackages = {
      "akka.actor.typed.javadsl",
      "com.github.swagger.akka.javadsl",
      "akka.stream.javadsl",
    },
    serverVersion = '0.10.9+236-b93b0a91-SNAPSHOT'
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
    },
    {
      type = "scala",
      request = "launch",
      name = "Test File",
      metalsRunType = "testFile",
    },
    {
      type = "scala",
      request = "launch",
      name = "Test Target",
      metalsRunType = "testTarget",
    },
  }

  Metals_config.on_attach = function(client, bufnr)
    require("metals").setup_dap()
  end


  -- lsp_config.html.setup({})
  -- lsp_config.jsonls.setup({
  --   commands = {
  --     Format = {
  --       function()
  --         vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
  --       end,
  --     },
  --   },
  -- })

  -- lsp_config.yamlls.setup({})


  -- Uncomment for trace logs from neovim
  --vim.lsp.set_log_level('trace')
end

return M
