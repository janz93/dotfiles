# Dotfiles
My dotfiles are in this repo.
There's some simple statements for different operating systems: OS X and Linux. Since PATHS and tools can differ between these to operating systems, having separate sections was necessary. Right now, these dotfiles can be installed and run for either system essentially seamlessly.

## Package overview

- [Homebrew](https://brew.sh) (packages: [Brewfile](./install/mac/brewfile))
- [homebrew-cask](https://github.com/Homebrew/homebrew-cask) (packages: [Caskfile](./install/mac/brewcask))
- [zsh](https://www.zsh.org/) and [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh)
- [asdf](https://asdf-vm.com/)
- npm packages: [npmfile](./install/npm_packages.sh)
- gems: [gemfile](./install/gems.sh)

## Install
```bash
bash -c "`curl -fsSL https://github.com/janz93/dotfiles/master/remote-install.sh`"
```
This will clone (using `git`), or download (using `curl` or `wget`), this repo to `~/.dotfiles`. Alternatively, clone manually into the desired location:


```bash
git clone https://github.com/janz93/dotfiles.git ~/dotfiles
```

Use the [Makefile](./Makefile) to install everything [listed above](#package-overview), and symlink [runcom](./runcom) and [config](./config) (using [stow](https://www.gnu.org/software/stow/)):

```bash
cd ~/.dotfiles
make setup
```

## The `dotfiles` command

```bash
$ dotfiles help
Usage: dotfiles <command>

Commands:
    backup                         backup exsiting dotfiles
    install_brew                   install brew if not already aviable
    install_zsh                    install zsh as bash alternative
    install_tooling                install addition tooling
    install_asdf                   install asdf to manage programming languages
    configure_vim                  add personal vim configuration
    configure_git                  add personal git configuration
    configure_vscode               add personal vscode configuration and extentions
    install_node                   install programming language nodejs
    install_npm_packages           install global npm tooling
    install_ruby                   install programming language ruby
    install_gems                   install global npm tooling
    setup                          will setup your system
    update_dynamic_configs         Here the current version of the dictionary and brew lock files will be commited
```

## Credits
* Many thanks to [`@HongxuChen`](https://github.com/HongxuChen/dotfiles) and [`@edsonma`](https://github.com/edsonma/dotfiles) for the inspirations