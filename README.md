[![Build Status](https://travis-ci.org/congma/pass-genphrase.svg?branch=master)](https://travis-ci.org/congma/pass-genphrase)

`pass-genphrase` - passphrase generator extension for [`pass`(1)][pass]

----

## SYNOPSIS ##

```
pass genphrase [ options ] pass-name [ word-count ]
```

## DESCRIPTION ##

pass-genphrase is an extension for [`pass`(1)][pass] that provides the pass
gen- phrase command for securely  creating  memorable  passphrases  using  a
[Diceware(TM)][dw]-compatible dictionary file.  It is a drop-in replacement for
the `pass generate` command.

For further information, please run `make doc` and read the generated
`README.txt` file, or use `man` to view the `pass-genphrase.1` manual page.


[pass]: https://www.passwordstore.org/ "Password Store, the password manager"
[dw]: http://world.std.com/~reinhold/diceware.html "Diceware"
