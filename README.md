# Neovim configuration

[Official installation instructions](https://github.com/neovim/neovim/wiki/Installing-Neovim)

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


Finally, configure the software by cloning the repo to local configuration directory via 

```shell
cd ~/.config
git clone git@github.com:vohonen/nvim-config.git nvim
```
For clipboard integration, install also `xclip`
```shell
sudo apt-get update
sudo apt-get install xclip
```

To ensure that the plugins work properly, first comment out all plugins from `init.lua` file except plugins/plugins (which includes Packer configuration) and then run `:PackerInstall` to get everything installed. Then, one should be able to require all plugins, and they should run smoothly.

The command `:checkhealth` is useful if some difficult errors arise.

If `nvim-treesitter` breaks with some filetypes instead of others, try `:TSUpdate <filetype>`.
