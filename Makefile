DOTFILES_DIR 		?= ~/dotfiles  
DATE_DIR 			?= `date +%Y-%m-%d`
OLD_DOTFILES_DIR 	?= ~/dotfiles_old
DOT_FILES 			= gitconfig zshrc oh-my-zsh vim vimrc asdf
OS_PLATFORM			:= $(shell uname)


.PHONY: backup
backup: ## backup exsiting dotfiles
	@echo "Creating ${OLD_DOTFILES_DIR}/${DATE_DIR} for backup of any existing dotfiles in ~ ..."
	@mkdir -p ${OLD_DOTFILES_DIR}/${DATE_DIR}

	@for file in ${DOT_FILES}; do\
		echo "Move $$file from ~ to ${OLD_DOTFILES_DIR}/${DATE_DIR}";\
		mv ~/.$$file ${OLD_DOTFILES_DIR}/${DATE_DIR} 2>/dev/null ; true;\
	done

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
			xcode-select —-install;\
			/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";\
			brew update;\
			brew tap caskroom/cask;\
			brew tap caskroom/versions;\
		fi;\
	fi

.PHONY: install_zsh
install_zsh: install_brew ## install oh-my-zsh as bash alternative
	@if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then\
		echo "zsh already available. Good Job!";\
		if [[ ! $(echo $SHELL) == $(which zsh) ]]; then\
			echo "set default terminal to zsh";\
			chsh -s /bin/zsh;\
		fi;\
	else\
		if [[ $platform == 'Linux' ]]; then\
			if [[ -f /etc/redhat-release ]]; then\
				sudo yum install zsh;\
			fi;\
			if [[ -f /etc/debian_version ]]; then\
				sudo apt-get install zsh;\
			fi;\
		elif [[ $platform == 'Darwin' ]]; then\
			brew install zsh zsh-completions;\
		fi;\
	fi

.PHONY: install_oh_my_zsh
install_oh_my_zsh: install_zsh
	@if [[ -d $dir/system/oh-my-zsh/ ]]; then
		echo "Oh my zsh already available. Good Job!";\
	else\
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
	

.PHONY: install_tooling 
install_tooling: install_brew ## install addition tooling
	if [[ $platform == 'Darwin' ]]; then
		brew bundle --file=$(DOTFILES_DIR)/install/Brewfile
	elif [[ $platform == 'Linux' ]]; then
		chmox +x $(DOTFILES_DIR)/install/tooling.sh && $(DOTFILES_DIR)/install/linux_tooling.sh
	fi

.PHONY: install_asdf 
install_asdf: install_brew install_zsh install_oh_my_zsh ## install asdf to manage programming languages
	@if [ -f ~/.asdf/asdf.sh ]; then\
		echo "asdf already available. Good job!";\
	else\
		if [[ $platform == 'Linux' ]]; then\
			if [[ -f /etc/redhat-release ]]; then\
				sudo apt install curl git;\
			fi;\
		elif [[ $platform == 'Darwin' ]]; then\
			brew install coreutils curl git;\
		fi;\
		brew install asdf;\
		echo "add asdf to you shell";\
		echo '. $HOME/.asdf/asdf.sh' >> ~/.zshrc;\
		echo '. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc;\
	fi


.PHONY: create_symbolic_links
create_symbolic_links: ## create symlics for all config files
	ln -s ~/dotfiles/vim/vimrc ~/.vimrc
	ln -s ~/dotfiles/system/asdfrc ~/.asdfrc
	ln -s ~/dotfiles/system/zshrc ~/.zshrc
	ln -s ~/dotfiles/system/oh-my-zsh ~/.oh-my-zsh
	ln -s ~/dotfiles/tools/asdf ~/.asdf
	ln -s ~/dotfiles/git/gitconfig ~/.gitconfig

.PHONY: install_npm_packes
install_npm_packes: install_npm ## install global npm tooling
	. $(NVM_DIR)/nvm.sh; npm install -g $(shell cat install/npmfile)

.PHONY: install_gems
install_gems: install_ruby ## install global npm tooling
	export PATH="/usr/local/opt/ruby/bin:$PATH"; gem install $(shell cat install/Gemfile)

.PHONY: setup
setup: backup install_zsh install_brew install_asdf install_tooling create_symbolic_links ## will setup your system
	echo "everything should be good to go"

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
