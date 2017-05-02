PASS-GENPHRASE(1)           PASS EXTENSION COMMANDS          PASS-GENPHRASE(1)



NAME
       pass-genphrase - passphrase generator extension for pass(1)


SYNOPSIS
       pass genphrase [ options ] pass-name [ word-count ]


DESCRIPTION
       pass-genphrase  is an extension for pass(1) that provides the pass gen-
       phrase command for securely  creating  memorable  passphrases  using  a
       Diceware[(TM)]-compatible dictionary file.  It is a drop-in replacement
       for the pass generate command.

       By default, the dictionary file is the `EFF Long Word List' <https://
       www.eff.org/files/2016/07/18/eff_large_wordlist.txt>  created by Joseph
       Bonneau / The Electronic Frontier Foundation, based on linguistic stud-
       ies  of the English language.  The user can also specify an alternative
       dictionary using the -d/--dict option.


OPTIONS AND ARGUMENTS
       The options closely follow those of pass generate. They are  listed  as
       follows.


       -h, --help
              Display help and exit.


       -c, --clip
              Write  the generated passphrase to clipboard, to be erased later
              automatically by pass(1).


       -f, --force
              Replace existing password entry without prompt.


       -i, --in-place
              Generate non-interactively.  Only replace the first line of  the
              stored  password file with the newly generated passphrase.  This
              is useful for non-interatively  editing  a  multi-line  password
              file.


       -q, --qrcode
              Encode  the  generated  passphrase  as QR code using qrencode(1)
              without echoing the text to  terminal.   See  pass(1)  for  more
              information about using QR code.


       In addition, the following option is specific to pass genphrase:


       -d path, --dict=path
              Specify the path to a dictionary file.


       The default word count in the passphrase is 6.  To change this, specify
       a number as the word-count positional  argument  after  the  pass-name.
       You  can  specify  the word count as low as 1, although this is clearly
       not recommended.


NOTES
       In many cases one could simply generate a passphrase using any tool and
       pipe it to pass insert. However, this might be problematic when editing
       an existing password, because pass insert uses the standard  input  for
       interactive prompts and confirmations.

       The  command  uses a helper script written in Python for securely shuf-
       fling the dictionary file.  Please make sure Python (either version 2.7
       or 3.6) is installed.


BUGS
       Please report bugs to the Issues page on Github <https://github.com/
       congma/pass-genphrase/issues>


SEE ALSO
       pass(1)


COPYRIGHT
       Copyright (C) 2017 Cong Ma and contributors. License  GPLv3+:  GNU  GPL
       version 3 or later <https://gnu.org/licenses/gpl.html>

       This  is  free  software:  you  are free to change and redistribute it.
       There is NO WARRANTY, to the extent permitted by law.

       See the file CONTRIBUTORS for the source of contributions.

       Diceware[(TM)] is a trademark of Arnold G. Reinhold.



PASS                              2017 May 1                 PASS-GENPHRASE(1)
