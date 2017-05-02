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
CUL_ALL=0   # Counting all tests.
# Order of arguments: description, script_name
expect_true () {
    echo "TEST: ${1}: ${2}"
    if { "${2}" ; }; then
	printf "$TERM_PASS: ${2}\n"
	TEST_ST=0
    else
	printf "$TERM_FAIL: ${2}\n"
	TEST_ST=1
    fi
    CUL_ALL=$((CUL_ALL + 1))
    CUL_ST=$((CUL_ST + TEST_ST))
    echo --------------------
}

expect_false () {
    echo "TEST: ${1}"
    if { "${2}" ; }; then
	printf "$TERM_FAIL: ${2}\n"
	TEST_ST=1
    else
	printf "$TERM_PASS: ${2}\n"
	TEST_ST=0
    fi
    CUL_ALL=$((CUL_ALL + 1))
    CUL_ST=$((CUL_ST + TEST_ST))
    echo --------------------
}

# Set up extension directory and the password store.
PASS="$(which pass)"
if ! [ -e "$PASS" ]; then
    printf "$TERM_FAIL: cannot locate 'pass' command.\n"
    exit 1
fi
export PASS
export GNUPGHOME="./gnupg"
export PASSWORD_STORE_DIR="./password-store"
export PASSWORD_STORE_ENABLE_EXTENSIONS="true"
export PASSWORD_STORE_EXTENSIONS_DIR="../"
export PASSWORD_STORE_KEY="F539FA5D1679367F5130C2E1F9861873C7290993"
if ! { "$PASS" init "$PASSWORD_STORE_KEY" ; } ; then
    printf "$TERM_FAIL: cannot initialize password storage directory.\n"
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
expect_false "conflict options" "./test_conflict.sh"
expect_false "bad length" "./test_bad_length.sh"
expect_false "bad dictionary" "./test_bad_dict.sh"
echo "Total run: $CUL_ALL"
echo "Total failed: $CUL_ST"

# Clean up.
rm -rf "$PASSWORD_STORE_DIR"
# In case this file gets sourced ...
unset PASS
unset GNUPGHOME
unset PASSWORD_STORE_DIR
unset PASSWORD_STORE_ENABLE_EXTENSIONS
unset PASSWORD_STORE_EXTENSIONS_DIR
unset PASSWORD_STORE_KEY

exit "$CUL_ST"
