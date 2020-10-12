import sys

from bitarray import bitarray


def main(argv):
    with open(argv[1], 'rb') as f1:
        with open(argv[2], 'rb') as f2:
            arr1, arr2 = bitarray(), bitarray()
            arr1.fromfile(f1)
            arr2.fromfile(f2)
            diff = 0
            for i in range(len(arr1) // 4):
                if arr1[4 * i: 4 * i + 4] != arr2[4 * i: 4 * i + 4]:
                    diff += 1
            print(diff, 'different blocks')


if __name__ == '__main__':
    main(sys.argv)
