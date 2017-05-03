#!/bin/sh
"$PASS" genphrase -c Test/clip
[ "$($PASTE_UTIL)" = "$($PASS Test/clip)" ]
