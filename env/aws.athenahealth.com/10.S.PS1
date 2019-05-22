# -*- shell-script -*-
# Prompt setup

__GIT_PROMPT_LOCATIONS=(
    /usr/local/git/current/share/git-core/git-prompt.sh
    /etc/bash_completion.d/git-prompt
    ${HOME}/private/bin/git-prompt.sh
    /usr/local/git/contrib/completion/git-prompt.sh
)

__git_script_found=0
for loc in ${__GIT_PROMPT_LOCATIONS[@]}; do
    if [ -f "${loc}" ]; then
        . "${loc}"
        __git_script_found=1
        break
    fi
done
if (( ! __git_script_found )); then
  function __git_ps1() {
    true
  }
fi

unset __GIT_PROMPT_LOCATIONS
unset __git_script_found

# Truncate a pathname that is longer than $PROMPT_DIRTRIM elements long;
# otherwise, return the original unchanged.
function truncate_path() {
  local path_components=($(echo $1 | tr ' /' '^ '))
  local end_path=""
  if [[ ("${PROMPT_DIRTRIM}" != "") && (${#path_components[@]} -gt $PROMPT_DIRTRIM) ]]; then
    end_path="..."
    for (( i=-${PROMPT_DIRTRIM}; $i <= -1; ++i )); do
      end_path+="/$(echo ${path_components[${#path_components[@]} + $i]} | tr '^' ' ')"
    done
  else
    end_path=$1;
  fi
  echo $end_path
}

# Intelligently rewrite the current working directory for display.  This:
#   - Replaces the home directory with ~
#   - Replaces git repo dirs with :repo(branch)://
#   - Replaces CitC (Perforce) clients with :clientname://
#   - Leaves other paths unchanged
# and truncates any paths longer than $PROMPT_DIRTRIM elements long.
function get_condensed_path() {
  if [[ $PWD =~ ${HOME}/?(.*)? ]]; then
    local truncated=$(truncate_path "${BASH_REMATCH[1]}")
    local git_branch=$(__git_ps1 "(%s)")
    if [[ -z "$truncated" ]]; then
      DISPLAY_PATH="~"
    elif [[ ! -z "$git_branch" ]]; then
      # We don't want to show the full path -- only the bit relative to the
      # current git repo root.
      truncated="$(truncate_path $(git rev-parse --show-prefix))"
      local repo=$(basename $(git rev-parse --show-toplevel))
      DISPLAY_PATH=":${repo}${git_branch}://${truncated}"
    else
      DISPLAY_PATH="~/${truncated}"
    fi
  elif [[ $PWD =~ ^/google/src/cloud/${USER}/([-a-zA-Z0-9_.]+)/google3/?(.*) ]];
  then
    local citc_client=${BASH_REMATCH[1]}
    DISPLAY_PATH=":${citc_client}://$(truncate_path ${BASH_REMATCH[2]})"
  else
    local truncated=$(truncate_path $PWD)
    if [[ $truncated =~ ^\.\.\. ]]; then
      DISPLAY_PATH="/${truncated}"
    else
      DISPLAY_PATH=$PWD
    fi
  fi
}

# The magic color values come from terminfo codes.  See man
# terminfo(5)#Color Handling for details.
prompt_color_black=$(tput setaf 0)
prompt_color_red=$(tput setaf 1)
prompt_color_green=$(tput setaf 2)
prompt_color_yellow=$(tput setaf 3)
prompt_color_blue=$(tput setaf 4)
prompt_color_magenta=$(tput setaf 5)
prompt_color_cyan=$(tput setaf 6)
prompt_color_white=$(tput setaf 7)
prompt_color_reset=$(tput op)
prompt_mode_bold=$(tput bold)
prompt_mode_reset=$(tput sgr0)

PROMPT_COMMAND=get_condensed_path
PROMPT_DIRTRIM=2
if [[ "${TERM}" =~ "screen" ]]; then
  PROMPT_SC="(SC)"
else
  PROMPT_SC=""
fi
PROMPT_HOSTNAME=${SHORT_HOSTNAME:-unknown}
if [ ! -z "${PLACE_SUBNET}" ]; then
    PROMPT_HOSTNAME+=".${PLACE_SUBNET}"
fi
PS1="<\[${prompt_mode_bold}${prompt_color_red}\]\u@\${PROMPT_HOSTNAME}\${PROMPT_SC}\[${prompt_color_reset}${prompt_mode_reset}\]>[\[${prompt_mode_bold}${prompt_color_blue}\]\${DISPLAY_PATH}\[${prompt_color_reset}${prompt_mode_reset}\]]\\$ "
