#!/bin/bash

TARGETS=(
    ${HOME}/Pictures/pix
    ${HOME}/Pictures
    ${HOME}/tmp
#    /tmp/${USER}
#    ${HOME}/work
)

LOGFILE=/tmp/nuke.log

if [ -x /usr/bin/srm ]; then
    zorch() {
        nohup /usr/bin/srm "$*" >> "${LOGFILE}" 2>&1 ;
    }
elif [ -x /bin/rm ]; then
    zorch() {
        nohup /bin/rm -rfP -- "$*" >> "${LOGFILE}" 2>&1 ;
    }
fi

for t in ${TARGETS[@]}; do
    zorch "${t}" &
done
