# C.A.L.I.S. - Chocolate Arch Linux Install Script

[![asciicast](https://asciinema.org/a/UMe5VVeVzu8PhWJOYNrwG12c0.svg)](https://asciinema.org/a/UMe5VVeVzu8PhWJOYNrwG12c0)

## Yet another install script?

WIP: need a rewrite but 95% of whats here still holds true.

Short awnser yes, long one is that I could not find an installer that did just what I wanted, and they all did either waaay too much like alis or not enough like most others, even the official one. So here is yet another arch linux vanilla installer, but with cocoa inside!

Objective is to install arch linux without going throuh dozens of lines of configuration for a script. Defaults are sensible and using flags can easily customize it to your liking.

Chocolate will only ask for relevent passwords, everything else should be set by flags, or better yet using the config file option, see the examples below.

Chocolate will follow the [Arch Wiki installation guide](https://wiki.archlinux.org/title/installation_guide) step by step to be as vanilla as possilbe.

A full hearthy chocolaty arch linux is a 2 step process:

* Setup a vanilla system with `chocolate.sh` and a choice of extra milk by setting up a user and preparing the system.
* Using `chocodots.sh` at reboot to sprinkle some `cocoa.sh` from your [dotfiles](https://github.com/nekwebdev/chocodots-template).

**NOTE:** On an Arch Linux based system you can run `build.sh` to build an Arch Linux ISO with the scripts copied in /root and with a password of `root` set for the root user so you can ssh directly into the system and get things going in one command:

    ssh root@machine_ip "/root/chocolate.sh --drive ..."

## So how does it work?

Warning, EFI only for now.

I would advise to make a new github repository from this template to have a clean git history and add your own `.conf` files for your various setups. Here is mine built on this template: [nekwebdev/arch](https://github.com/nekwebdev/arch). Not 100% sure I like those github templates yet...

Boot into an [Arch Linux ISO](https://archlinux.org/download/), [Connect to the internet](https://wiki.archlinux.org/title/installation_guide#Connect_to_the_internet), then clone, download, scp copy, what ever works for you, **inside of /root/**, at least the `chocolate.sh` script. Make sure it is executable then run:

    ./chocolate.sh --drive sda

  Chocolate will create a 2GB swap partition and use the rest of the drive for an ext4 root partition. Note that it's `sda` and not /dev/sda.

  It then follows the arch wiki install with grub as the bootloader. And that's all it does. You can reboot into a working EFI vanilla Arch Linux.

    ./chocolate.sh --help | less

This will get you started with a list of all the available flags and their default values:

```
Options:
  -h --help    Show this screen.
  --config     Replace script default variables by those from a config file.

  ############ Paritions setup:

  --drive      Drive to install the system on. List drives with lsblk
  --nopart     Skips the partitioning part.
              Chocolate expects your partitions to be mounted in /mnt
  --onlypart   Only format, partition and mount the drive.
  --swap       Swap partition size in G/M, defaults to '2G'
  --swapfile   Create a swapfile instead of a partition.
  --root       Root partition size in G/M, defaults to all remaining space
  --data       Create ext4 partition with the remaining space in /mnt/data.
              --root must also be set to use data, defaults to false.
  --luks       Encrypt the root filesystem, defaults to false.
  --btrfs      Use the btrfs filesystem with @root, @home, @var_log and @snapshots subvolumes, defaults to false.
  --snapper    Install and setup snapper for managing btrfs automatic snapshots, defaults to false.
  --prober     Setup grub to use os-prober for multiboot, defaults to false.
  --efi        Mount an existing windows EFI partition before creating the grub config.

  ############ System setup:

  --zen        Install the linux-zen kernel, defaults to linux kernel.
  --lts        Install the linux-lts kernel, defaults to linux kernel.

  ############ Localization setup:

  --timezone   Region/City for timezone (timedatectl list-timezones | grep ...), defaults to 'Etc/UTC'.
  --keymap     Keyboard keymap code (ls /usr/share/kbd/keymaps/**/*.map.gz | grep ...), defaults to 'us'.
  --lang       Lang code for locale.conf(ls /usr/share/i18n/locales | grep ...), defaults to 'en_US.UTF-8'.
  --locale     List of other locales to generate along with '$CHOCO_LANG', defaults to 'UTF-8'.
  --vfont      Font in use in virtual consoles second number is size, defaults to 'lat1-14'.
  --fontmap    Map in the ISO characters set, defaults to '8859-1'.
  --hostname   System hostname, defaults to 'chocolate'.

  ############ Options to go slightly past vanilla:

  --aur        Install an aur helper, either 'paru' or 'yay', defaults to false.
  --vm         Install virtual machine drivers, defaults to false.
  --vga        Install vga drivers, defaults to false.
  --nvidia     Use proprietary NVIDIA drivers, defaults to false.
  --xorg       Install xorg-server and vga drivers, defaults to false.
  --extra      Create a user with proper xdg directories and extra configuration.
  --user       Username to use, defaults to prompting it.
  --dots       URL for bare git dotfiles directory.
  --pkgs       csv file for the extra script.
```
## Adding chocolate to vanilla

1. An install with all the current features:

        ./chocolate.sh --drive vda --swap 3G --root 15G --data --luks --btrfs --snapper --prober --zen --aur yay --vm --xorg --nvidia --extra

    For partitions, swap will be set to 3G, root to 15G and the rest of the drive will be formatted as ext4 and mounted to /data.
    
    Root and swap will be LUKS encrypted, formatted using btrfs with @root, @home, @var_log and @snapshots subvolumes.
    
    Grub will probe for other OS for multi-boot, linux-zen kernel will be used, snapper will be configured.

    yay will be installed as the aur helper, virtual machines will be detected and drivers installed.
    
    xorg-server will be installed with graphics drivers, which if nvidia is detected are specified to be the NVIDIA proprietary ones.

    Finally the `extra.sh` script will run as the admin in the chrooted system. This is where you can add all of your final setup.

    xdg-user-dirs will be configured with "better" defaults and a user with system privileges will be created. `extra.sh` will always install an aur helper.

2. You can also run almost the same command with `--nopart`:

        ./chocolate.sh --drive vda --nopart --luks --btrfs --snapper --prober --zen --xdg --user latte --aur yay --vm --xorg --nvidia --extra

    This time you did your own partitioning and mounting of the partitions in /mnt, but still want to automate the rest of the install using the same flags. Check `chocolate.sh` for the disk and partitions labels to be set.
    
    `--nopart` replaces the partition related flags.
    
    That would be the way to use a disk that has multiple operating systems on it as any partitioning chocolate does would use the whole drive.

3. Only do the partitioning:

        ./chocolate.sh --drive vda --onlypart --swap 3G --root 15G --data --luks --btrfs

    Chocolate would only do the partitioning and mounting according to your choices because of `--onlypart`.

4. I heard you liked config files:

        ./chocolate.sh --config /root/myconfig.conf

    Check the `example.conf` file for a complete list of all settings, they are the same as `chocolate.sh` default values.
    
    Config files should only be used when you plan on deploying various systems from the same repo. If not, might as well edit `chocolate.sh` directly.

## Extras

When using the `--extra` flag the `chocodots.sh` script will be copied over to the new system and a new privileged user will be created along with a few tweaks.

It focuses on what needs to happen after a vanilla install:

- Pull dotfiles.
- Run `cocoa.sh`, Configure the system accordingly including installing a list of packages from pacman, AUR, pip or git.

`cocoa.sh` is included in the companion repository template for bare git dotfiles at [chocodots-template](https://github.com/nekwebdev/chocodots-template). We keep nesting the scripts as dotfiles will run `cocoa.sh` if present, check the repository for more info.


Thanks to [LARBS](https://github.com/LukeSmithxyz/LARBS) for the inspiration in the `cocoa.sh` script and that smart use of a `csv` file to list all packages.

## Asciinema

You can run `./chococinema.sh` before running your `./chocolate.sh ...` command and run `exit` once chocolate is done.

You'll have an asciinema replay in `/root/chocolate.cast` of the live system.

`cp -f /root/chocolate.cast /mnt/var/log/chocolate.cast` to keep it with your other install logs after reboot.

Or copy it via ssh from another system before reboot: `scp root@machine_ip:/root/chocolate.cast chocolate.cast`

Enjoy!

```

                              ░░              ░░              ░░                                
                              ░░              ░░              ░░                                
                                ░░              ░░              ░░                              
                                ░░              ░░              ░░                              
                              ░░              ░░              ░░                                
                              ░░              ░░              ░░                                
                            ░░              ░░              ░░                                  
                            ░░              ░░              ░░                                  
                              ░░              ░░              ░░                                
                              ░░              ░░              ░░                                
                                ░░              ░░              ░░                              
                                ░░              ░░              ░░                              
                              ░░              ░░              ░░                                
                              ░░              ░░              ░░                                
                                                                                                
                                    ▓▓██████████████████████                                    
                            ████████                        ████████                            
                        ████        ████████████████████████        ████                        
                      ██░░    ██████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒██▓▓██  ░░░░██                      
                    ██    ████▒▒▓▓▓▓▓▓▓▓░░░░░░▓▓▓▓░░░░░░▓▓▓▓▒▒▓▓▓▓████    ██                    
                  ██    ██▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓░░░░▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▒▒▓▓██    ██                  
                  ██  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓  ██  ██▓▓▓▓▓▓██      
                  ██  ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒██  ████          ██    
                  ██    ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██    ██              ██  
                    ██  ░░████▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓████░░  ██░░    ████      ██  
                    ██        ██████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████        ██  ████    ██    ██  
                    ██              ████████████████████████              ████        ██    ██  
                    ██                ░░  ░░░░░░░░░░░░░░░░░░              ██          ██    ██  
                ██████                                                    ██████    ██      ██  
            ████    ██                                                    ██    ██  ██    ██    
        ░░██▒▒░░    ▒▒▓▓                                                ▓▓▒▒    ░░██▒▒    ██    
      ▓▓  ░░          ██                                                ██  ██████      ▓▓      
    ██                ██                                                ████        ████  ██    
  ██                  ░░██                                            ██░░░░    ████░░░░  ░░██  
  ██                ██████                                            ██████████░░░░        ██  
██                ██▒▒░░▒▒██                                        ██▒▒▒▒██                  ██
██              ██▒▒██▒▒▒▒██                                        ██▒▒▒▒▒▒██                ██
██              ██░░▓▓████▒▒▓▓                                    ▓▓▒▒██░░▒▒██                ██
  ██            ██▒▒██▓▓░░▒▒▒▒██                                ██▒▒░░▒▒████                ██  
  ██              ██░░██▒▒████▒▒████                        ████▒▒██▒▒██▒▒██                ██  
    ██            ██▒▒▒▒██▓▓░░▒▒░░▒▒██▓▓▓▓            ▓▓▓▓██▒▒██▒▒░░██▒▒░░██              ██    
      ██            ██████▒▒▒▒▒▒██████▒▒▒▒████████████▒▒██▒▒▒▒▓▓██▒▒▒▒████░░            ██      
        ██                ██████░░▒▒██░░▒▒██▒▒▒▒░░▒▒██▒▒▒▒██░░▒▒▒▒████                ██        
          ████                ██▒▒▒▒▓▓▒▒▒▒██░░▒▒████▒▒░░▒▒▒▒██████                ████          
          ░░  ████              ████  ████░░████░░░░████████    ░░            ████              
                  ████                                                    ████                  
                      ██▓▓▓▓██                                    ▓▓▓▓▓▓██                      
                              ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓             

```