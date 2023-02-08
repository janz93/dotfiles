DOTFILES_DIR 		?= ~/.dotfiles
DATE_DIR 			?= `date +%Y-%m-%d`
OLD_DOTFILES_DIR 	?= ~/.dotfiles_old
PERSONAL_DIR		= personal
WORK_DIR			= railslove
DOT_FILES 			= gitconfig zshrc vim vimrc asdfrc
OS_PLATFORM			:= $(shell uname)
RUBY_VERSION		= 3.2.0
NODEJS_VERSION		= 19.5.0
GOLANG_VERSION		= 1.20
TERRAFORM_VERSION	= 1.3.7
ifeq ($(OS_PLATFORM), Linux)
	VSCODE_DIR = ~/.config/Code/User
else
	VSCODE_DIR = ~/Library/Application\ Support/Code/User
endif

.PHONY: backup
backup: ## backup exsiting dotfiles
	@echo "Creating ${OLD_DOTFILES_DIR}/${DATE_DIR} for backup of any existing dotfiles in ~ ..."
	@mkdir -p ${OLD_DOTFILES_DIR}/${DATE_DIR}

	@for file in ${DOT_FILES}; do\
		echo "Move $$file from ~ to ${OLD_DOTFILES_DIR}/${DATE_DIR}";\
		mv ~/.$$file ${OLD_DOTFILES_DIR}/${DATE_DIR} 2>/dev/null ; true;\
		rm -f ~/.$$file;\
	done
	@mv ~/Documents/${PERSONAL_DIR}/.gitconfig ${OLD_DOTFILES_DIR}/${DATE_DIR} 2>/dev/null; true
	@rm -f ~/Documents/${PERSONAL_DIR}/.gitconfig
	@mv ~/Documents/${WORK_DIR}/.gitconfig ${OLD_DOTFILES_DIR}/${DATE_DIR} 2>/dev/null; true
	@rm -f ~/Documents/${WORK_DIR}/.gitconfig
	@mv ${VSCODE_DIR} ${OLD_DOTFILES_DIR}/${DATE_DIR}/vs_code/settings.json 2>/dev/null; true
	@mv ${VSCODE_DIR} ${OLD_DOTFILES_DIR}/${DATE_DIR}/vs_code/keybindings.json 2>/dev/null; true
	@rm -f ${VSCODE_DIR}/settings.json
	@rm -f ${VSCODE_DIR}/keybindings.json
	

.PHONY: install_brew 
install_brew: ## install brew if not already aviable
	@if [[ ${OS_PLATFORM} == 'Linux' ]]; then\
		if [ -f ~/.linuxbrew ]; then\
			echo "Linuxbrew already available. Good Bier!";\
		else\
			git clone https://github.com/Linuxbrew/brew.git $dir/system/linuxbrew;\
			echo 'PATH="$HOME/.linuxbrew/bin:$PATH"' >> ~/.zshrc;\
			echo 'export MANPATH="$(brew --prefix)/share/man:$MANPATH"' >> ~/.zshrc;\
			echo 'export INFOPATH="$(brew --prefix)/share/info:$INFOPATH"' >> ~/.zshrc;\
		fi;\
	elif [[ ${OS_PLATFORM} == 'Darwin' ]]; then\
		if [ -f /usr/local/Homebrew/bin/brew ]; then\
			echo "Homebrew already available. Good Bier!";\
		else\
			echo "download brew";\
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";\
			echo "update brew";\
			brew update;\
		fi;\
	fi

.PHONY: install_zsh
install_zsh: backup install_brew ## install zsh as bash alternative
	@if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then\
		echo "zsh already available. Good Job!";\
		if [[ ! $(echo $SHELL) == $(which zsh) ]]; then\
			echo "set default terminal to zsh";\
			chsh -s /bin/zsh;\
		fi;\
	else\
		if [[ ${OS_PLATFORM} == 'Linux' ]]; then\
			if [[ -f /etc/redhat-release ]]; then\
				sudo yum install zsh;\
			fi;\
			if [[ -f /etc/debian_version ]]; then\
				sudo apt-get install zsh;\
			fi;\
		elif [[ ${OS_PLATFORM} == 'Darwin' ]]; then\
			brew install zsh zsh-completions;\
		fi;\
	fi

.PHONY: install_oh_my_zsh
install_oh_my_zsh: install_zsh
	@if [[ -d ~/.oh-my-zsh/ ]]; then\
		echo "Oh my zsh already available. Good Job!";\
	else\
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";\
		echo "powerline fonts";\
		tmp_dir=$(shell mktemp -d);\
		echo $$tmp_dir;\
		cd $$tmp_dir;\
		git clone https://github.com/powerline/fonts.git ;\
		./fonts/install.sh;\
		rm -Rf $$tmp_dir;\
    fi
	@echo "copy personal zsh config"
	@ln -s ${DOTFILES_DIR}/config/.zshrc ~/.zshrc
	

.PHONY: install_tooling 
install_tooling: install_brew ## install addition tooling
	@if [[ ${OS_PLATFORM} == 'Darwin' ]]; then\
		echo "install terminal apps";\
		brew bundle --file=$$(pwd)/install/mac/brewfile;\
		echo "install gui apps";\
		brew bundle --file=$$(pwd)/install/mac/brewcask;\
	elif [[ ${OS_PLATFORM} == 'Linux' ]]; then\
		sh -c $(DOTFILES_DIR)/install/linux_tooling.sh;\
	fi

.PHONY: install_asdf 
install_asdf: backup install_brew install_zsh install_oh_my_zsh ## install asdf to manage programming languages
	@if [ -f $$(brew --prefix asdf)/asdf.sh ]; then\
		echo "asdf already available. Good job!";\
	else\
		echo "install prerequisites";\
		if [[ ${OS_PLATFORM} == 'Linux' ]]; then\
			if [[ -f /etc/redhat-release ]]; then\
				sudo apt install curl git;\
			fi;\
		elif [[ ${OS_PLATFORM} == 'Darwin' ]]; then\
			brew install coreutils curl git;\
		fi;\
		echo "install asdf";\
		brew install asdf;\
		echo "add asdf to you shell";\
	fi
	@echo "copy personal asdf config"
	@cp ${DOTFILES_DIR}/config/.asdfrc ~/.asdfrc


.PHONY: configure_vim
configure_vim: backup ## add personal vim configuration
	@echo "copy personal vim config"
	@ln -s ${DOTFILES_DIR}/config/vim/vimrc ~/.vimrc
	@ln -s ${DOTFILES_DIR}/config/vim ~/.vim

.PHONY: configure_git
configure_git: backup ## add git configuration
	@echo "copy global git config" 
	@ln -s ${DOTFILES_DIR}/config/git/global_gitconfig ~/.gitconfig
	@echo "copy personal git config"
	@mkdir -p ~/Documents/${PERSONAL_DIR}/
	@ln -s ${DOTFILES_DIR}/config/git/${PERSONAL_DIR}_gitconfig ~/Documents/${PERSONAL_DIR}/.gitconfig
	@echo "copy work config" 
	@mkdir -p ~/Documents/${WORK_DIR}/
	@ln -s ${DOTFILES_DIR}/config/git/${WORK_DIR}_gitconfig ~/Documents/${WORK_DIR}/.gitconfig

.PHONY: configure_vscode
configure_vscode: ## add personal vscode configuration and extentions
	@echo "install vscode extentions"
	@sh -c "${DOTFILES_DIR}/config/vscode/extentions.sh"
	@echo "copy vscode settings"
	@ln -s ${DOTFILES_DIR}/config/vscode/settings.json ${VSCODE_DIR}/settings.json
	@ln -s ${DOTFILES_DIR}/config/vscode/keybindings.json ${VSCODE_DIR}/keybindings.json

.PHONY: install_node
install_node: install_asdf ## install programming language nodejs
	@if [[ $$(asdf plugin list) == *"nodejs"* ]]; then\
		echo "nodejs via asdf already available. Good job!";\
	else\
		echo "add nodejs to asdf";\
		asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git;\
		echo "add nodejs PGP keys";\
		sh -c "$$HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring";\
		echo "install nodejs ${NODEJS_VERSION}";\
		asdf install nodejs ${NODEJS_VERSION};\
		asdf global nodejs ${NODEJS_VERSION};\
	fi

.PHONY: install_npm_packages
install_npm_packages: install_node ## install global npm tooling
	@echo "install npm packages"
	@sh -c "install/npm_packages.sh"

.PHONY: install_ruby
install_ruby: install_asdf ## install programming language ruby
	@if [[ $$(asdf plugin list) == *"ruby"* ]]; then\
		echo "ruby via asdf already available. Good job!";\
	else\
		echo "add ruby to asdf";\
		asdf plugin add ruby;\
		echo "install ruby ${RUBY_VERSION}";\
		asdf install ruby ${RUBY_VERSION};\
		asdf global ruby ${RUBY_VERSION};\
	fi

.PHONY: install_gems
install_gems: install_ruby ## install global ruby tooling
	@echo "install gems"
	@sh -c "install/gems.sh"

.PHONY: install_golang
install_golang: install_asdf ## install programming language go
	@if [[ $$(asdf plugin list) == *"go"* ]]; then\
		echo "golang via asdf already available. Good job!";\
	else\
		echo "add golang to asdf";\
		asdf plugin add golang;\
		echo "install golang ${GOLANG_VERSION}";\
		asdf install golang ${GOLANG_VERSION};\
		asdf global golang ${GOLANG_VERSION};\
	fi

.PHONY: install_terraform
install_terraform: install_asdf ## install programming language go
	@if [[ $$(asdf plugin list) == *"terraform"* ]]; then\
		echo "terraform via asdf already available. Good job!";\
	else\
		echo "add terraform to asdf";\
		asdf plugin add terraform;\
		echo "install terraform ${TERRAFORM_VERSION}";\
		asdf install terraform ${TERRAFORM_VERSION};\
		asdf global terraform ${TERRAFORM_VERSION};\
	fi

.PHONY: install_languages
setup:  install_node install_ruby install_golang ## will install all languages system
	@echo "install languages"

.PHONY: setup
setup: backup install_brew install_zsh install_oh_my_zsh install_asdf install_tooling install_languages install_npm_packages install_gems configure_git configure_vim ## will setup your system
	@echo "everything should be good to go"
	@exec $$SHELL

.PHONY: update_dynamic_configs
update_dynamic_configs: ## Here the current version of the dictionary and brew lock files will be commited
	@cp ~/.vim/spell/* config/vim/spell/
	@cp ${DOTFILES_DIR}/install/mac/brewfile.lock.json install/mac/brewfile.lock.json
	@if [[ ${OS_PLATFORM} == 'Darwin' ]]; then\
		cp ${DOTFILES_DIR}/install/mac/brewcask.lock.json install/mac/brewcask.lock.json;\
	fi

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
