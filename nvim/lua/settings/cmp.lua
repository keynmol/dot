local M = {}
M.setup = function()
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
      { name = "vsnip" },
      { name = "buffer" },
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
    sorting = {
      comparators = {
        compare.exact,
        compare.score,
        function(a, b)
          if a:get_kind() == 5 and b:get_kind() == 2 then
            return true
          elseif a:get_kind() == 2 and b:get_kind() == 5 then
            return false
          end
          return nil
        end,
        compare.kind,
        compare.recently_used,
        compare.locality,
        compare.offset,
        compare.sort_text,
        compare.length,
        compare.order
      }
    }

  })
end

return M
