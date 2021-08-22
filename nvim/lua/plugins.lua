return require("packer").startup(function(use)
  use({ "glepnir/galaxyline.nvim" })
  use({ "glepnir/lspsaga.nvim" })
  use({ "joshdick/onedark.vim" })
  use({ "junegunn/goyo.vim" })
  use({ "hrsh7th/nvim-compe", requires = { { "hrsh7th/vim-vsnip" } } })
  use({
    "iamcco/markdown-preview.nvim",
    run = "cd app && yarn install",
    cmd = "MarkdownPreview",
  })
  use({ "kevinhwang91/nvim-bqf" })
  use({ "kyazdani42/nvim-web-devicons" })
  use({ "liuchengxu/vista.vim" })
  use({ "machakann/vim-sandwich" })
  use({ "mfussenegger/nvim-dap" })
  use({ "neovim/nvim-lspconfig" })
  use({ "norcalli/nvim-colorizer.lua" })
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
  use({ "tpope/vim-vinegar" })
  use({ "tpope/vim-commentary" })
  use({ "wbthomason/packer.nvim", opt = true })
  -- use({ "windwp/nvim-autopairs" })
  use({ "wlangstroth/vim-racket" })
  use({ "Yggdroot/indentLine" })
  use({ "preservim/nerdtree" })
end)
