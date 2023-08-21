#!/usr/bin/env bash
# https://github.com/nekwebdev/calis
# @nekwebdev
# LICENSE: GPLv3
#
# chocodots.sh
#
# script to create a local gitbare repository and pull from a bare github repository.
#
set -e

###### => variables ############################################################
CHOCO_DOTS="" # will skip if empty
CHOCO_COCOA=false # run cocoa.sh setup script

###### => echo helpers #########################################################
# _echo_step() outputs a step collored in cyan (6), without outputing a newline.
function _echo_step() { tput setaf 6;echo -n "$1";tput sgr 0 0; }
# _exit_with_message() outputs and logs a message in red (1) before exiting the script.
function _exit_with_message() { echo;tput setaf 1;echo "$1";tput sgr 0 0;echo;exit 1; }
# _echo_right() outputs a string at the rightmost side of the screen.
function _echo_right() { local T=$1;echo;tput cuu1;tput cuf "$(tput cols)";tput cub ${#T};echo "$T"; }
# _echo_success() outputs [ OK ] in green (2), at the rightmost side of the screen.
function _echo_success() { tput setaf 2;_echo_right "[ OK ]";tput sgr 0 0; }

###### => display help screen ##################################################
function displayHelp() {
    echo "  Description:"
    echo "    Create a local gitbare repository and pull from a bare github repository."
    echo
    echo "  Usage:"
    echo "    chocodots.sh"
    echo "    chocodots.sh --dots https://github.com/user/bare-git-repository --cocoa"
    echo
    echo "  Options:"
    echo "    -h --help   Show this screen."
    echo "    --dots      Url to a bare git repository to pull locally."
    echo "    --cocoa     Launch cocoa.sh script if present at the end."
    echo
}

###### => parse flags ##########################################################
while (( "$#" )); do
  case "$1" in
    -h|--help) displayHelp; exit 0 ;;
    --dots)
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        CHOCO_DOTS=$2; shift
      else
        _exit_with_message "when using --dots an url to a bare git repository must be specified. Example: '--dots https://github.com/myname/chocodots'"
      fi ;;
    --data) CHOCO_COCOA=true; shift ;;
    *)
      shift ;;
  esac
done

###### => main #################################################################
function main() {
  # main steps
  local work_tree="$HOME"
  local git_dir="$work_tree/.config/dotfiles"
  local dots="/usr/bin/git --git-dir=$git_dir --work-tree=$work_tree"

  _echo_step "Deploying dotfiles"; echo
  if [[ ! -d $git_dir ]]; then
    _echo_step "  (Initialize dotfiles bare git repository in $git_dir)"
    mkdir -p "$git_dir"
    git init --bare "$git_dir"
    $dots config status.showUntrackedFiles no
    _echo_success
  else
    _echo_step "  (Using local dotfiles in $git_dir)"
    _echo_success
  fi

  if [[ -n $CHOCO_DOTS ]]; then
    _echo_step "  (Pull main branch from $CHOCO_DOTS)"
    $dots remote add origin "$CHOCO_DOTS"
    $dots branch -m main
    $dots pull origin main
  fi

  if $CHOCO_COCOA; then
    local cocoa="$work_tree/.config/cocoa/cocoa.sh"
    if [[ -f $cocoa ]]; then
      ./"$cocoa"
    fi
  fi

  _exit_with_message "alias chocodots='$dots'"
}

main "$@"
