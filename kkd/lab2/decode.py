import sys
import bitarray
from encode import M, MAX, HALF, L_QUARTER, U_QUARTER
BUFFER = 1024


def main(argv):
    freqs = [i for i in range(258)]
    in_file = open(argv[1], 'rb')
    out_file = open(argv[2], 'wb')
    low = 0
    high = MAX
    val = 0
    code = bitarray.bitarray()
    code.frombytes(in_file.read(BUFFER))
    for _ in range(M):
        val <<= 1
        if code:
            val += code[0]
            code = code[1:]
    while code:
        d = high - low + 1
        sval = ((val - low + 1) * freqs[-1] - 1) // d
        c = 256
        for i in range(len(freqs)-1):
            if sval < freqs[i+1]:
                c = i
                break
        if c == 256:
            break
        out_file.write(bytes([c]))
        high = low + d * freqs[c + 1] // freqs[-1] - 1
        low += d * freqs[c] // freqs[-1]
        if freqs[-1] < L_QUARTER:
            for i in range(c+1, len(freqs)):
                freqs[i] += 1
        while True:
            if high < HALF:
                pass
            elif low >= HALF:
                val -= HALF
                low -= HALF
                high -= HALF
            elif low >= L_QUARTER and high < U_QUARTER:
                val -= L_QUARTER
                low -= L_QUARTER
                high -= L_QUARTER
            else:
                break
            low <<= 1
            high <<= 1
            high += 1
            val <<= 1
            if not code:
                code.frombytes(in_file.read(BUFFER))
            try:
                val += code[0]
                code = code[1:]
            except IndexError:
                pass
        if not code:
            code.frombytes(in_file.read(BUFFER))
    in_file.close()
    out_file.close()


if __name__ == '__main__':
    main(sys.argv)
