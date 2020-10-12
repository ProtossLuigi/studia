import sys
from random import random

import bitarray


def main(argv):
    p = float(argv[1])
    with open(argv[2], 'rb') as f_in:
        with open(argv[3], 'wb') as f_out:
            arr = bitarray.bitarray()
            arr.fromfile(f_in)
            for i in range(len(arr)):
                if random() < p:
                    arr[i] = not arr[i]
            arr.tofile(f_out)


if __name__ == '__main__':
    main(sys.argv)
