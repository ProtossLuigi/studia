import sys
import bitarray
from math import log
M = 16
MAX = (1 << M) - 1
HALF = MAX // 2 + 1
L_QUARTER = HALF // 2
U_QUARTER = HALF + L_QUARTER


def main(argv):
    freqs = [i for i in range(258)]
    code = bitarray.bitarray()
    low = 0
    high = MAX
    counter = 0
    total_count = 0
    counts = [0 for _ in range(256)]
    out_count = 0
    out_count2 = 0
    in_file = open(argv[1], 'rb')
    out_file = open(argv[2], 'wb')
    for byte in in_file.read():
        total_count += 1
        counts[byte] += 1

        d = high - low + 1
        high = low + d * freqs[byte+1] // freqs[-1] - 1
        low += d * freqs[byte] // freqs[-1]

        if freqs[-1] < L_QUARTER:
            for i in range(byte+1, len(freqs)):
                freqs[i] += 1

        while True:
            if high < HALF:
                low <<= 1
                high <<= 1
                high += 1
                code.extend('0' + '1' * counter)
                out_count += 1 + counter
                counter = 0
            elif low >= HALF:
                low = low - HALF << 1
                high = (high - HALF << 1) + 1
                code.extend('1' + '0' * counter)
                out_count += 1 + counter
                counter = 0
            elif low >= L_QUARTER and high < U_QUARTER:
                low = low - L_QUARTER << 1
                high = (high - L_QUARTER << 1) + 1
                counter += 1
            else:
                break

        while len(code) >= 8:
            code[:8].tofile(out_file)
            code = code[8:]
    in_file.close()
    low += (high - low + 1) * freqs[256] // freqs[-1]
    while True:
        if high < HALF:
            low <<= 1
            high <<= 1
            high += 1
            code.extend('0' + '1' * counter)
            counter = 0
        elif low >= HALF:
            low = low - HALF << 1
            high = (high - HALF << 1) + 1
            code.extend('1' + '0' * counter)
            counter = 0
        elif low >= L_QUARTER and high < U_QUARTER:
            low = low - L_QUARTER << 1
            high = (high - L_QUARTER << 1) + 1
            counter += 1
        else:
            break
    counter += 1
    if low < L_QUARTER:
        code.extend('0' + '1' * counter)
    else:
        code.extend('1' + '0' * counter)
    code.fill()
    out_count2 = out_count + len(code)
    code.tofile(out_file)
    out_file.close()
    ent = -sum(count/total_count * log(count/total_count, 256) for count in counts if count > 0)
    print('entropia danych wejściowych: ', ent)
    print('średnia długość kodowania: ', out_count/total_count)
    print('stopień kompresji: ', 8*total_count/out_count2)


if __name__ == '__main__':
    main(sys.argv)
