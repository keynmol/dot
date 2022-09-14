return require("packer").startup(function(use)
  use({ "glepnir/galaxyline.nvim" })
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

  use({'NLKNguyen/papercolor-theme'})
  use({ "kevinhwang91/nvim-bqf" })
  use({ "kyazdani42/nvim-web-devicons" })
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
  use({ "scalameta/nvim-metals"})
  use({ "sheerun/vim-polyglot" })
  use({ "tpope/vim-fugitive" })
  use({ "ziglang/zig.vim" })
  use({ "tpope/vim-commentary" })
  use({ "wbthomason/packer.nvim", opt = true })
  use({ "preservim/nerdtree" })
  use({ "rebelot/kanagawa.nvim" })
  use({ "cormacrelf/vim-colors-github" })
  use({'lukas-reineke/indent-blankline.nvim'})
  use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
  use {
        'nvim-treesitter/playground'
    }
end)
