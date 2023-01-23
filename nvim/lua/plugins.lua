return require("packer").startup(function(use)
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  -- use({ "glepnir/galaxyline.nvim" })
  use({ "kkharji/lspsaga.nvim" })
  use({ "shime/vim-livedown" })
  -- auto complete
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
