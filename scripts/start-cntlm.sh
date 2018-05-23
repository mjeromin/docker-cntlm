#!/bin/sh

if [ -z "${CNTLM_CONF}" ]; then
    echo "ERROR: Missing config environment var CNTLM_CONF"
    exit 1
fi

if [ \! -r "${CNTLM_CONF}" ]; then
    cp -vp /usr/share/cntlm/cntlm.conf.example "${CNTLM_CONF}"
fi

exec /usr/sbin/cntlm -c "${CNTLM_CONF}" -f -g
