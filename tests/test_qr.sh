#!/bin/sh
if [ -n "$TEST_QR_SUPPRESS_DISPLAY" ]; then
    CMD_ENV='env -u DISPLAY'
else
    CMD_ENV='env'
fi
$CMD_ENV $PASS genphrase -q Test/qr
