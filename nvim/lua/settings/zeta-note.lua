-- https://github.com/nvim-telescope/telescope.nvim
local M = {}

M.setup = function()
  require'lspconfig'.zeta_note.setup({
      cmd = {getenv("HOME") .. "/.tools/zeta-note"}
  })
end

return M
