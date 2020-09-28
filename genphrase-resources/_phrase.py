#!/usr/bin/env python
"""Generate diceware-like passphrase."""
import sys
from math import log
from argparse import ArgumentParser
from random import SystemRandom


if sys.version_info.major >= 3:
    xrange = range  # pylint: disable=C0103


def posint(thing):
    """Parse strictly positive integer."""
    res = int(thing)
    if res <= 0:
        raise ValueError("negative input (%d)" % res)
    return res


def main():
    """Entry point."""
    words = []
    separator = "-" if ARGS_NS.no_spaces else " "
    with open(ARGS_NS.dict, "r") as dfile:
        # Diceware dictionary may not have a fixed format spec, but a) line
        # begins with numeral 1-6, b) there should be seperator(s) between
        # index and word, and c) word should come last.  No regex needed.
        for line in dfile:
            sline = line.strip().split()
            if len(sline) >= 2 and sline[0][0] in NUMS:
                words.append(sline[-1])
    lexicon_size = len(words)
    # Hard coded limit on wordlist size here!
    if not words or log(lexicon_size, 2) * ARGS_NS.count < 64:
        sys.stderr.write("Error: word list too short!\n")
        sys.exit(1)
    rand_indices = [RNG.randint(0, len(words) - 1) for _ in
                    xrange(ARGS_NS.count)]
    passphrase = separator.join((words[i] for i in rand_indices))
    sys.stdout.write("%s\n" % passphrase)


DEFAULT_LEN = 6
NUMS = frozenset("123456")
OPT_PARSER = ArgumentParser(description="Generate diceware-like passphrase.")
OPT_PARSER.add_argument("-d", "--dict", metavar="FILE", required=True,
                        help="path to diceware-like dictionary")
OPT_PARSER.add_argument("-n", "--no-spaces", action="store_true", dest="no_spaces",
                        help="separate words with spaces instead of dashes")
OPT_PARSER.add_argument("count", metavar="N", default=DEFAULT_LEN, type=posint,
                        nargs="?",
                        help="word count (default: %d)" % DEFAULT_LEN)
ARGS_NS = OPT_PARSER.parse_args()
RNG = SystemRandom()
if __name__ == "__main__":
    main()
