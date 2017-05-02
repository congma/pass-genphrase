#!/usr/bin/env python
"""Generate diceware-like passphrase."""
from argparse import ArgumentParser
from random import SystemRandom


def posint(thing):
    """Parse strictly positive integer."""
    res = int(thing)
    if res <= 0:
        raise ValueError("negative input (%d)" % res)
    return res


def main():
    """Entry point."""
    words = []
    with open(ARGS_NS.dict, "r") as dfile:
        # Diceware dictionary may not have a fixed format spec, but a) line
        # begins with numeral 1-6, b) there should be seperator(s) between
        # index and word, and c) word should come last.  No regex needed.
        for line in dfile:
            sline = line.strip().split()
            if len(sline) >= 2 and sline[0][0] in NUMS:
                words.append(sline[-1])
    passphrase = " ".join(RNG.sample(words, ARGS_NS.count))
    print(passphrase)   # pylint: disable=C0325


DEFAULT_LEN = 6
NUMS = frozenset("123456")
OPT_PARSER = ArgumentParser(description="Generate diceware-like passphrase.")
OPT_PARSER.add_argument("-d", "--dict", metavar="FILE", required=True,
                        help="path to diceware-like dictionary")
OPT_PARSER.add_argument("count", metavar="N", default=DEFAULT_LEN, type=posint,
                        nargs="?",
                        help="word count (default: %d)" % DEFAULT_LEN)
ARGS_NS = OPT_PARSER.parse_args()
RNG = SystemRandom()
if __name__ == "__main__":
    main()
