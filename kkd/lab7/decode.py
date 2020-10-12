import sys

import numpy as np
from bitarray import bitarray

from encode import flatten

H = np.array([[1, 0, 0, 1],
              [0, 1, 0, 1],
              [1, 1, 0, 1],
              [0, 0, 1, 1],
              [1, 0, 1, 1],
              [0, 1, 1, 1],
              [1, 1, 1, 1],
              [0, 0, 0, 1]])


def main(argv):
    with open(argv[1], 'rb') as f_in:
        with open(argv[2], 'wb') as f_out:
            encoded = bitarray()
            encoded.fromfile(f_in)
            decoded = bitarray()
            doubles = 0
            for i in range(len(encoded) // 8):
                block = np.array(list(encoded[8 * i: 8 * i + 8]))
                errs = flatten(block.dot(H))
                if sum(errs[:3]):
                    if errs[3]:
                        pos = errs[0] + 2 * errs[1] + 4 * errs[2] - 1
                        block[pos] = not block[pos]
                    else:
                        doubles += 1
                decoded.extend([block[2], block[4], block[5], block[6]])
            decoded.tofile(f_out)
            print(doubles, 'bytes with double error')


if __name__ == '__main__':
    main(sys.argv)
