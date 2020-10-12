import sys

import numpy as np
from bitarray import bitarray

G = np.array([[1, 1, 1, 0, 0, 0, 0, 1],
              [1, 0, 0, 1, 1, 0, 0, 1],
              [0, 1, 0, 1, 0, 1, 0, 1],
              [1, 1, 0, 1, 0, 0, 1, 0]])


def flatten(arr):
    return [val & 1 for val in arr]


def main(argv):
    with open(argv[1], 'rb') as f_in:
        with open(argv[2], 'wb') as f_out:
            data = bitarray()
            data.fromfile(f_in)
            encoded = bitarray()
            for i in range(len(data) // 4):
                block = np.array(list(data[4 * i: 4 * i + 4]))
                encoded.extend(flatten(block.dot(G)))
            encoded.tofile(f_out)


if __name__ == '__main__':
    main(sys.argv)
