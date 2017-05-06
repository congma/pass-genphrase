#!/bin/sh
if [ -n "$TEST_QR_SUPPRESS_DISPLAY" ]; then
    unset DISPLAY
fi
$PASS genphrase -q Test/qr
