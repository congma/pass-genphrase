#!/bin/sh
$PASS genphrase Test/len 15
[ "$($PASS Test/len | wc -w )" -eq 15 ]
