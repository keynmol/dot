local M = {}
M.setup = function()
  local cmp = require("cmp")
  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    sources = {
      { name = "nvim_lsp", priority = 10 },
      { name = "buffer" },
      { name = "vsnip" },
      { name = "path" },
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
    })
end

return M
