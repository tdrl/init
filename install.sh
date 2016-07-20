#!/bin/bash
#
# Install all shell / config files.

BACKUP_DIR="${HOME}/.dotfile_backups/$(date "+%Y%m%d_%H%M")"

cd ${HOME}
echo "Installing..."
for dotfile in ${HOME}/.init/dotfiles/*; do
  f="${HOME}/.$(basename ${dotfile})"
  echo -ne "\t${f}...  "
  if [ -h ${f} ]; then
    echo -n "Exists as a symlink.  Leaving alone... "
  elif [ -f ${f} ]; then
    echo -n "Exists as a regular file.  Backing up... "
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
