# linux-dev
Linux Development Configurations

# Oh My Zsh!
sudo apt-get install zsh
sudo snap install curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)

# Zsh Syntax Highlight
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
source ./zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Zsh Auto Suggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \$ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Zsh Fuzzy Finder
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install


# Add installed plugins
nano ~/.zshrc

replace 

plugins=(git)

with

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  fzf
)

# Alias (bash)
nano ~/.bash_profile
alias code='code-insiders' # add to bash_profile
source ~/.bash_profile

# Alias: (zsh)
nano ~/.zshrc
Find # Example alias and add uncommented
alias code="code-insiders ~/.zshrc"
source ~/.zshrc

# Fira Code Font
sudo apt install fonts-firacode

On vscode settings json:

"editor.fontFamily": "'Fira Code'",
"editor.fontLigatures": true,

# Java
sudo snap install intellij-idea-community --classic
sudo snap install intellij-idea-ultimate --classic

sudo snap refresh intellij-idea-ultimate
sudo snap remove intellij-idea-community

sudo add-apt-repository ppa:ubuntuhandbook1/apps

sudo apt-get update

sudo apt-get install intellij-idea-community
sudo apt-get install intellij-idea-ultimate
