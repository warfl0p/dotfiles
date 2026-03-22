This is my installation script for new Linux installs.

# Installation
Clone the repository into your home directory and run the installation script:
```
cd ~ && \
git clone -b ubuntu_core https://github.com/warfl0p/dotfiles && \
cd dotfiles && \
./install.sh
```

The installer is idempotent and intended for Ubuntu systems.
It does not require Homebrew.

It will not change your default shell unless requested. To set zsh as default during install:
```
SET_DEFAULT_SHELL=1 ./install.sh
```

After installation, start a new shell:
```
exec zsh
```

uv is installed using Astral's official installer:
https://docs.astral.sh/uv/getting-started/installation/
