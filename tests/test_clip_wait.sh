#!/bin/sh
export PASSWORD_STORE_CLIP_TIME=1
"$PASS" genphrase -c Test/clip-wait
sleep 2
[ "$($PASTE_UTIL)" != "$($PASS Test/clip-wait)" ]
