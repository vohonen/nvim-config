# Neovim configuration
Clone to local configuration directory via 

```shell
cd ~/.config
git clone git@github.com:vohonen/nvim-config.git nvim
```

To ensure that the plugins work properly, first comment out all plugins except plugins/plugins (which includes Packer configuration) and then run `:PackerInstall` to get everything installed. Then, one should be able to require all plugins and they should run smoothly.
