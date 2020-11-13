#!/bin/bash
#
# Install all shell / config files.

BACKUP_DIR="${HOME}/.dotfile_backups/$(date "+%Y%m%d_%H%M")"
DIR_TREE=(
  .ssh
  private/bin
  private/src
  tmp
  work
)

cd ${HOME}
echo "Installing..."
for dotfile in ${HOME}/.init/dotfiles/*; do
  f="${HOME}/.$(basename ${dotfile})"
  echo -ne "\t${f}...  "
  if [ -h ${f} ]; then
    echo -n "Exists as a symlink.  Leaving alone... "
  elif [ -f ${f} -o -d ${f} ]; then
    echo -n "Exists as a regular file or directory.  Backing up... "
    if [ ! -d ${BACKUP_DIR} ]; then
      mkdir -p ${BACKUP_DIR}
    fi
    mv "${f}" "${BACKUP_DIR}"
    ln -s "${dotfile}" "${f}"
  elif [ -a ${f} ]; then
    echo -n "Exists, but not as a symlink or reg file.  Leaving alone. " \
         "DOUBLE CHECK! "
  else
    echo -n "Doesn't exist.  Creating..."
    ln -s "${dotfile}" "${f}"
  fi
  echo "Done."
done

echo "Setting up directory tree..."
for target_dir in ${DIR_TREE[*]}; do
  echo "mkdir ${HOME}/${target_dir}"
  mkdir -p ${HOME}/${target_dir}
done

if [ ! -d ${HOME}/private/src/tools ]; then
  echo "Installing local tools..."
  cd ${HOME}/private/src
  git clone git@github.com:tdrl/tools.git
fi
