# linux
Linux Development Configurations

### Git
```shell
sudo apt-get install git
```

### Gnome Tweaks
```shell
sudo apt-get install gnome-tweaks
```

### Misc
```shell
sudo apt-get install screenfetch
```

### Oh My Zsh!
```shell
sudo apt-get install zsh
sudo snap install curl
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)
```

### NVM & Node
```shell
git clone https://github.com/nvm-sh/nvm.git ~/.nvm
nano ~/.zshrc
```

Add the line:

```shell
source ~/.nvm/nvm.sh
```

Then run:

```shell
source ~/.zshrc
sudo snap remove curl
sudo apt install curl
nvm install node
```

### Npm & Yarn
```shell
sudo apt install npm
sudo npm install --global yarn
```

### Zsh Syntax Highlight
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
source ./zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

### Zsh Auto Suggestions
```shell
git clone https://github.com/zsh-users/zsh-autosuggestions \$ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### Zsh Fuzzy Finder
```shell
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
```

### Add installed plugins and alias
```shell
nano ~/.zshrc
```

replace `plugins=(git)` with

```shell
plugins=(
  git
  zsh-autosuggestions
  fzf
)

alias code='code-insiders'
alias term='terminator'
```

```shell
source ~/.zshrc
```


### Cedilha
```shell
sudo gedit /etc/environment
```

include this line in the file:
```shell
GTK_IM_MODULE=cedilla
```

### Fira Code Font
```shell
sudo apt install fonts-firacode
```

On vscode settings json:
```json
"editor.fontFamily": "'Fira Code'",
"editor.fontLigatures": true,
```

### [Terminator](https://gnometerminator.blogspot.com/p/introduction.html)

```shell
sudo apt install terminator
mkdir ~/.config/terminator
touch ~/.config/terminator/config;
echo '[global_config]
  enabled_plugins = CustomCommandsMenu, InactivityWatch, TestPlugin, ActivityWatch, TerminalShot, LaunchpadCodeURLHandler, APTURLHandler, Logger, MavenPluginURLHandler, LaunchpadBugURLHandler
  extra_styling = False
  geometry_hinting = True
  inactive_color_offset = 0.909420289855
  title_font = Fira Code 12
  title_transmit_fg_color = "#3465a4"
  title_use_system_font = False
  title_transmit_bg_color = "#000000"
[keybindings]
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
      profile = default
      type = Terminal
    [[[window0]]]
      parent = ""
      type = Window
[plugins]
[profiles]
  [[default]]
    audible_bell = True
    cursor_color = "#33ff33"
    font = Fira Code 14
    foreground_color = "#33ff33"
    palette = "#000000:#ff0000:#33ff33:#33ff33:#ffffff:#ffffff:#00cdcd:#e5e5e5:#7f7f7f:#ff0000:#33ff33:#ffff00:#ffffff:#ff00ff:#00ffff:#ffffff"
    scrollbar_position = hidden
    show_titlebar = False
    use_system_font = False
    visible_bell = True
    background_darkness = 0.8
    background_type = transparent' > ~/.config/terminator/config
```

### Apple Magic Keyboard

```
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all
sudo reboot # optional
```

### Google Calendar


https://atareao.es/aplicacion/calendar-indicator-o-google-calendar-en-ubuntu/
```
sudo add-apt-repository ppa:atareao/atareao
sudo apt-get update
sudo apt-get install calendar-indicator
```


### Java

```java
sudo snap install intellij-idea-community --classic
sudo snap install intellij-idea-ultimate --classic

sudo snap refresh intellij-idea-ultimate
sudo snap remove intellij-idea-community

sudo add-apt-repository ppa:ubuntuhandbook1/apps

sudo apt-get update

sudo apt-get install intellij-idea-community
sudo apt-get install intellij-idea-ultimate
```
