#!/bin/sh
# Black box test for run-time behaviors of pass-genphrase.

# Color keywords if stdout is a tty.
if [ -t 1 ]; then
    CBRed='\e[1;31m'
    CBGreen='\e[1;32m'
    CReset='\e[0m'
else
    CBRed=''
    CBGreen=''
    CReset=''
fi
TERM_PASS="${CBGreen}PASS${CReset}"
TERM_FAIL="${CBRed}FAIL${CReset}"

CUL_ST=0    # Counting failed tests.
CUL_ALL=0   # Counting run tests.
CUL_SKIP=0  # Skipped tests.

hrule () {
    echo --------------------
}

# Order of arguments: description, script_name, args
expect_true () {
    T_NAME="$1"
    shift
    echo "TEST: $T_NAME: $*"
    if { "$@" ; }; then
	printf "%b: %s\n" "$TERM_PASS" "$*"
	TEST_ST=0
    else
	printf "%b: %s\n" "$TERM_FAIL" "$*"
	TEST_ST=1
    fi
    CUL_ALL=$((CUL_ALL + 1))
    CUL_ST=$((CUL_ST + TEST_ST))
    hrule
}

expect_false () {
    T_NAME="$1"
    shift
    echo "TEST: $T_NAME: $*"
    if { "$@" ; }; then
	printf "%b: %s\n" "$TERM_FAIL" "$*"
	TEST_ST=1
    else
	printf "%b: %s\n" "$TERM_PASS" "$*"
	TEST_ST=0
    fi
    CUL_ALL=$((CUL_ALL + 1))
    CUL_ST=$((CUL_ST + TEST_ST))
    hrule
}

# args: conditional, expectation-kind, test-name, test-script, more-args
# neutralize code execution in conditional; expect non-empty string for true,
# and empty for false
with_cond () {
    if [ -n "$1" ]; then
	shift
	"$@"
    else
	CUL_SKIP=$((CUL_SKIP + 1))
	echo "SKIP: $*"
	hrule
    fi
}

if [ -n "$DISPLAY" ] && { type xclip > /dev/null 2>&1 ; }; then
    CLIP_P=1
    export PASTE_UTIL="xclip -o -selection clipboard"
elif { type pbcopy > /dev/null 2>&1 ; }; then
    CLIP_P=1
    export PASTE_UTIL="pbpaste"
fi

if { type qrencode > /dev/null 2>&1 ; }; then
    QR_P=1
fi

# Set up extension directory and the password store.
PASS="$(command -v pass)"
if ! [ -e "$PASS" ]; then
    printf "%b: cannot locate 'pass' command.\n" "$TERM_FAIL"
    exit 1
fi
export PASS
GPG="gpg"
type gpg2 &> /dev/null && GPG="gpg2"
export GPG
export GNUPGHOME="./gnupg"
export PASSWORD_STORE_DIR="./password-store"
export PASSWORD_STORE_ENABLE_EXTENSIONS="true"
export PASSWORD_STORE_EXTENSIONS_DIR="../"
export PASSWORD_STORE_KEY="F539FA5D1679367F5130C2E1F9861873C7290993"
mkdir "$GNUPGHOME" 2> /dev/null
chmod 700 "$GNUPGHOME"
"$GPG" --import < "${PASSWORD_STORE_KEY}.pub.asc"
"$GPG" --allow-secret-key-import --import < "${PASSWORD_STORE_KEY}.sec.asc"
"$GPG" --import-ownertrust < "${PASSWORD_STORE_KEY}.ownertrust"
if ! { "$PASS" init "$PASSWORD_STORE_KEY" ; } ; then
    printf "%b: cannot initialize password storage directory.\n" "$TERM_FAIL"
    exit 1
fi

# Run them.
expect_true "help" "./test_help.sh"
expect_true "generate default" "./test_default.sh"
expect_true "specify length" "./test_len.sh"
expect_true "alt. dictionary (Diceware English)" "./test_dict_en.sh"
expect_true "alt. dictionary (Diceware Czech)" "./test_dict_cz.sh"
expect_true "force" "./test_force.sh"
expect_true "inplace" "./test_inplace.sh"
with_cond "$CLIP_P" expect_true "clipboard" "./test_clip.sh"
with_cond "$CLIP_P" expect_true "clipboard expire" "./test_clip_wait.sh"
with_cond "$QR_P" expect_true "QR code" "./test_qr.sh"
expect_false "conflict options" "./test_conflict.sh"
expect_false "bad length" "./test_bad_length.sh"
expect_false "bad dictionary" "./test_bad_dict.sh"
echo "Total run: $CUL_ALL"
echo "Total failed: $CUL_ST"
echo "Total skipped: $CUL_SKIP"

# Clean up.
rm -rf "$PASSWORD_STORE_DIR"
rm -rf "$GNUPGHOME"
# In case this file gets sourced ...
unset PASS
unset GPG
unset GNUPGHOME
unset PASSWORD_STORE_DIR
unset PASSWORD_STORE_ENABLE_EXTENSIONS
unset PASSWORD_STORE_EXTENSIONS_DIR
unset PASSWORD_STORE_KEY

exit "$CUL_ST"
