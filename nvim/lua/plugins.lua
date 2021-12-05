return require("packer").startup(function(use)
  use({ "glepnir/galaxyline.nvim" })
  use({ "tami5/lspsaga.nvim", branch='nvim51' })
  use({ "navarasu/onedark.nvim" })
  use({ "shime/vim-livedown" })
  -- auto complete
  use({ "hrsh7th/cmp-nvim-lsp" })
  use({ "hrsh7th/cmp-vsnip" })
  use({ "hrsh7th/nvim-cmp" })
  use({ "hrsh7th/vim-vsnip" })

  use({ "kevinhwang91/nvim-bqf" })
  use({ "kyazdani42/nvim-web-devicons" })
  use({ "liuchengxu/vista.vim" })
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
  use({ "tpope/vim-commentary" })
  use({ "wbthomason/packer.nvim", opt = true })
  use({ "preservim/nerdtree" })
  use({'lukas-reineke/indent-blankline.nvim'})
  use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
end)
