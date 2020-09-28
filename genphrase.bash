#!/usr/bin/env bash
# pass genphrase - Password Store Extension (https://www.passwordstore.org/)
# Generate passphrase from dictionary file; similar to Diceware.
# Copyright (C) 2017 Cong Ma
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see
#    <https://www.gnu.org/licenses/gpl.html>.
#
# The EFF Long Word List file (eff_large_wordlist.txt) is created and
# copyrighted (C) by Joseph Bonneau / The Electronic Frontier Foundation, 2016,
# and licensed under the Creative Commons Attribution License (CC-BY,
# <https://creativecommons.org/licenses/by/3.0/us/>).  It is hereby
# redistributed verbatim as part of this program, in compliance with the
# origial CC-BY license.  The original file can be found at
# <https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt>, and the
# description found at
# <https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases>.
#
# The Diceware English Wordlist file (diceware.wordlist.asc) is created and
# copyrighted (C) by Arnold G. Reinhold, 1995--2017, and licensed under the
# Creative Commons Attribution License (CC-BY,
# <https://creativecommons.org/licenses/by/3.0/us/>).  It is hereby
# redistributed verbatim as part of this program, in compliance with the
# origial CC-BY license.  The original file can be found at
# <http://world.std.com/~reinhold/diceware.wordlist.asc>, and the description
# found at <http://world.std.com/~reinhold/diceware.html>.
#
# The Diceware Czech Wordlist file (diceware_wordlist_cz_nobom.txt) was
# originally created and copyrighted (C) by Vladimír Sedmík, and licensed under
# the GNU General Public License.  It is hereby redistributed, in the modified
# form with the UTF-8 BOM removed, as part of this program, in compliance with
# the origial GNU GPL.  The original file can be found at
# <http://world.std.com/~reinhold/diceware_wordlist_cz.txt>, and the
# description found at <http://world.std.com/~reinhold/diceware.html>.
#
# Diceware (tm) is a trademark of Arnold G. Reinhold.
GENPHRASE_RESOURCES="$EXTENSIONS/genphrase-resources"
GENPHRASE_DEFAULT_DICT="$GENPHRASE_RESOURCES/eff_large_wordlist.txt"
GENPHRASE_EXEC="$GENPHRASE_RESOURCES/_phrase.py"
GENPHRASE_DEFAULT_WORDCOUNT=6
CMD_GENPHRASE_USAGE="Usage: $PROGRAM $COMMAND [-h,--help] [-c,--clip] [-f,--force] [-i,--in-place] [-q,--qrcode] [-n, --no-spaces] [-d <PATH>,--dict=<PATH>] pass-name [word-count]"


cmd_genphrase_help () {
    cat << __genphrase_usage_097612_EOF
Usage:
    $PROGRAM $COMMAND [options] pass-name [word-count]

Similar to "$PROGRAM generate", but generate a passphrase of given word count
(default: $GENPHRASE_DEFAULT_WORDCOUNT).

Options:
    The options follow the interface of "$PROGRAM generate", except that the
    "-n / --no-symbols" option is replaced with "--no-spaces" option (see
    below).

    -h, --help		Show this help and exit.
    -c, --clip		Write generated passphrase to clipboard, to be erased
			$CLIP_TIME second(s) later, without echoing to terminal.
    -f, --force		Replace existing password without prompt.
    -i, --in-place	Generate non-interactively; only replace the first
			line of the password file with the newly generated
			passphrase.
    -q, --qrcode	Encode generated passphrase using qrencode, without
			echoing the text to terminal.

    In addition, the following option is specific to $COMMAND command:

    -d <PATH>, --dict=<PATH>
			Specify path to dictionary file.

    -n, --no-spaces
			Separate words with spaces instead of dashes.
__genphrase_usage_097612_EOF
}


cmd_genphrase_exec () {
    local opts wanthelp=0 qrcode=0 clip=0 force=0 inplace=0 nospaces=0 dict="$GENPHRASE_DEFAULT_DICT" passphrase
    opts="$($GETOPT -o "hcfiqnd:" -l "help,clip,force,in-place,qrcode,nospaces,dict:" -n "$PROGRAM $COMMAND" -- "$@")"
    local err=$?
    eval set -- "$opts"
    while true; do
	case "$1" in
	    -h|--help) wanthelp=1; shift ;;
	    -c|--clip) clip=1; shift ;;
	    -f|--force) force=1; shift ;;
	    -i|--in-place) inplace=1; shift ;;
	    -q|--qrcode) qrcode=1; shift ;;
        -n|--no-spaces) nospaces=1; shift ;;
	    -d|--dict) dict="$2"; shift 2 ;;
	    --) shift; break ;;
	esac
    done

    if [ "$wanthelp" = 1 ]; then
	cmd_genphrase_help
	exit 0
    fi

    if [[ "$err" -ne 0 || -z "${*}" || ( $force -eq 1 && $inplace -eq 1 ) || ( $qrcode -eq 1 && $clip -eq 1 ) ]]; then
	die "$CMD_GENPHRASE_USAGE"
    fi

    local path="$1"
    check_sneaky_paths "$path"
    local wcount="${2:-$GENPHRASE_DEFAULT_WORDCOUNT}"
    wcount="$((wcount))"
    if [ $wcount -le 0 ]; then
	die "Error: word-count does not appear to be a positive integer."
    fi

    # NOTE: lots of copypasta
    mkdir -p -v "$PREFIX/$(dirname -- "$path")"
    set_gpg_recipients "$(dirname -- "$path")"
    local passfile="$PREFIX/$path.gpg"
    set_git "$passfile"

    if [[ $inplace -eq 0 && $force -eq 0 && -e $passfile ]]; then
	yesno "An entry already exists for $path. Overwrite it?"
    fi

    nospaces_arg=${nospaces/0/} # substitution below would work only if the parameter is null
    if ! { passphrase="$("$GENPHRASE_EXEC" ${nospaces_arg:+-n} -d "$dict" "$wcount")" ; } ; then
	die "Error: passphrase generation failed."
    fi

    # if nospaces is set, translate dashes back to spaces so wc would understand us
    if [[ $nospaces -eq 0 ]]; then
        result_wcount="$(echo "$passphrase" | wc -w)";
    else
        result_wcount="$(echo "$passphrase" | tr '-' ' ' | wc -w)";
    fi

    if ! [[ "$result_wcount" -eq "$wcount" ]]; then
	die "Error: passphrase generation failed (word count mismatch)."
    fi

    if [[ $inplace -eq 0 ]]; then
	echo "$passphrase" | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" || die "Password encryption aborted."
    else
	local passfile_temp="${passfile}.tmp.${RANDOM}.${RANDOM}.${RANDOM}.${RANDOM}.--"
	if { echo "$passphrase"; $GPG -d "${GPG_OPTS[@]}" "$passfile" | tail -n +2; } | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile_temp" "${GPG_OPTS[@]}"; then
	    mv "$passfile_temp" "$passfile"
	else
	    rm -f "$passfile_temp"
	    die "Could not reencrypt new password."
	fi
    fi
    local verb="Add"
    [[ $inplace -eq 1 ]] && verb="Replace"
    git_add_file "$passfile" "$verb generated password for ${path}."

    if [[ $clip -eq 1 ]]; then
	clip "$passphrase" "$path"
    elif [[ $qrcode -eq 1 ]]; then
	qrcode "$passphrase" "$path"
    else
	printf '\e[1m\e[37mThe generated passphrase for \e[4m%s\e[24m is:\e[0m\n\e[1m\e[93m%s\e[0m\n' "$path" "$passphrase"
    fi
}


cmd_genphrase_exec "$@"
