# Neovim configuration

[Official installation instructions](https://github.com/neovim/neovim/wiki/Installing-Neovim)

:warning: Lazy is updating each package automatically, but there might be breaking changes that make this config throw errors. This is typical, as the plugins are developed quite fast. Use `:checkhealth` to diagnose if the config isn't working properly. :warning:

Sadly, at the moment the `nvim` is not maintained very attentively in `apt` and hence a PPA should be used if one does not want to install manually. Unfortunately, the stable PPA is also practically buried, so the [unstable PPA](https://launchpad.net/~neovim-ppa/+archive/ubuntu/unstable) must be used.

First, check that you can use `add-apt-repository` by installing the required package:

```shell
sudo apt-get update
sudo apt-get install software-properties-common
```

Then, the PPA can be added and Neovim installed from it with the required Python modules. 

```shell
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim
sudo apt-get install python-dev python-pip python3-dev python3-pip
```

To set `nvim` as the default editor, run 

```shell
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor
```

Some of the packages require Node and `nvim-treesitter` requires an extra package for TeX formatting. Install these with 
```shell
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g tree-sitter-cli
```

Zathura is my go-to document viewer, see my [zathura-rc](https://github.com/vohonen/zathurarc). Zathura combined with VimTeX requires `xdotool` for forward search 
```shell
sudo apt-get install xdotool
```

For clipboard integration, install also `xclip`
```shell
sudo apt-get update
sudo apt-get install xclip
```

Finally, configure the software by cloning the repo to local configuration directory via 

```shell
cd ~/.config
git clone git@github.com:vohonen/nvim-config.git nvim
```

Lazy should install all packages automatically. The command `:checkhealth` is useful if some difficult errors arise.

Install prefered language servers, linting etc. with `:Mason`.

If `nvim-treesitter` breaks with some filetypes instead of others, try `:TSUpdate <filetype>`.

## External tools (linters, formatters, LSP servers)

The linting (`lua/plugins/lint.lua`) and formatting (`lua/plugins/conform.lua`)
configs shell out to external CLIs. These are **not** bundled with the plugins and
must be installed separately. The config is resilient: a linter whose executable is
missing is simply skipped (it will not throw errors on buffer enter / tab switch),
and `conform` silently skips missing formatters. So install only what you need.

Run `:checkhealth conform` and `:checkhealth lint` to see what is detected.

### Linters & formatters

| Filetype | Linter (nvim-lint) | Formatter (conform) | CLI(s) |
|----------|--------------------|---------------------|--------|
| markdown | `markdownlint`     | `prettier`          | `markdownlint`, `prettier` |
| python   | `ruff`             | `ruff_format`, `ruff_organize_imports` | `ruff` |
| lua      | `luacheck`         | `stylua`            | `luacheck`, `stylua` |
| tex      | `chktex`           | `latexindent`       | `chktex`, `latexindent` (see LaTeX below) |

Install on **macOS** (Homebrew + npm — npm's global prefix is Homebrew's, so binaries
land on `PATH` automatically):

```shell
# markdown
npm install -g markdownlint-cli prettier
# python / lua
brew install ruff stylua luacheck
```

On **Linux** the equivalents are `npm install -g markdownlint-cli prettier`,
`pipx install ruff` (or `cargo install ruff`), `cargo install stylua`, and
`luarocks install luacheck`.

### LSP servers (via Mason)

Servers are listed in `ensure_installed` in `lua/plugins/ls.lua` and are
auto-installed by `mason-lspconfig` on startup (or manually via `:Mason`):

- `lua_ls` — Lua (this Neovim config)
- `pyright` — Python
- `marksman` — Markdown
- `texlab` — LaTeX
- `html` — HTML

### LaTeX toolchain

`chktex`, `latexindent`, `latexmk`, `bibtex`, and `biber` ship with a TeX
distribution. On macOS, BasicTeX is the lightweight option (the installer needs an
admin password, so run it yourself):

```shell
brew install --cask basictex
# then, in a new shell, pull the pieces the config uses:
sudo tlmgr update --self
sudo tlmgr install latexindent latexmk chktex biber
```

On Linux: `sudo apt-get install texlive-extra-utils chktex latexmk biber`.

