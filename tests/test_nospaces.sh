#!/bin/sh
$PASS genphrase -n Test/nospaces
if ! { $PASS Test/nospaces | grep ' ' ; } ; then
    exit 0
else
    exit 1
fi
