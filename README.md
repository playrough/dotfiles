# Dotfiles

My personal Arch Linux dotfiles and system configuration.

## Installation

Run the following command:

```bash
curl -fsSL https://raw.githubusercontent.com/playrough/dotfiles/master/.setup/install.sh | bash
```

The installer will automatically:

- Clone the bare dotfiles repository.
- Check out configuration files into `$HOME`.
- Install required packages.
- Configure system services.
- Set up Zsh, ZRAM, Fcitx5 and Caps2Esc.
- Configure user services.

## Notes

- Review `install.sh` and `setup.sh` before running.
- Existing files may cause checkout conflicts.
- Back up important files before installation.
- Designed for Arch Linux (x86_64).

## License

Personal use.
