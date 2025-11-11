-- plugins
require("config/lazy") -- lazy plugin manager config

require("plugins/autopairs")
require("plugins/colorschemes")
require("plugins/conform")
require("plugins/hover")
require("plugins/indent")
require("plugins/lint")
require("plugins/ls")
require("plugins/markdown")
require("plugins/nvim-cmp")
require("plugins/nvim-tree")
require("plugins/nvim-treesitter")
require("plugins/vimtex")

require("options") -- neovim options
require("keymaps") -- additional keymaps
require("send_code") -- send code to a terminal pane
