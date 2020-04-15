import sys
from encode import fibonacci, encode_bin


def decoder_gamma():
    stage = 0
    counter = 0
    num = 0

    def decode_gamma(code):
        nonlocal stage, counter, num
        decoded = []
        for bit in code:
            if not stage:
                if bit:
                    stage = 1
                    num = 1
                else:
                    counter += 1
            else:
                num = num << 1
                num += bit
                counter -= 1
            if stage and not counter:
                decoded.append(num)
                stage = 0
                num = 0
        return decoded
    return decode_gamma


def decoder_delta():
    stage = 0
    counter1 = 0
    counter2 = 0

    def decode_delta(code):
        nonlocal stage, counter1, counter2
        decoded = []
        for bit in code:
            if stage == 0:
                if bit:
                    if not counter1:
                        decoded.append(1)
                    else:
                        stage = 1
                        counter2 = 1
                else:
                    counter1 += 1
            elif stage == 1:
                counter2 = counter2 << 1
                counter2 += bit
                counter1 -= 1
                if not counter1:
                    stage = 2
                    counter1 = 1
                    counter2 -= 1
            else:
                counter1 = counter1 << 1
                counter1 += bit
                counter2 -= 1
                if not counter2:
                    decoded.append(counter1)
                    counter1 = 0
                    counter2 = 0
                    stage = 0
        return decoded
    return decode_delta


def decoder_omega():
    counter = 0
    num = 1

    def decode_omega(code):
        nonlocal counter, num
        decoded = []
        for bit in code:
            if counter:
                num = num << 1
                num += bit
                counter -= 1
            else:
                if bit:
                    counter = num
                    num = 1
                else:
                    decoded.append(num)
                    counter = 0
                    num = 1
        return decoded
    return decode_omega


def decoder_fib():
    last_digit = 0
    index = 0
    num = 0

    def decode_fib(code):
        nonlocal last_digit, index, num
        decoded = []
        for bit in code:
            if bit:
                if last_digit:
                    decoded.append(num)
                    last_digit = 0
                    index = 0
                    num = 0
                else:
                    num += fibonacci(index+2)
                    last_digit = 1
                    index += 1
            else:
                last_digit = 0
                index += 1
        return decoded
    return decode_fib


def main(argv):
    if len(argv) >= 4 and argv[3] == '-gamma':
        decoder = decoder_gamma()
    elif len(argv) >= 4 and argv[3] == '-delta':
        decoder = decoder_delta()
    elif len(argv) >= 4 and argv[3] == '-fib':
        decoder = decoder_fib()
    else:
        decoder = decoder_omega()
    fragments = []
    for i in range(0, 256):
        fragments.append(bytes([i]))
    fragment = b''
    in_file = open(argv[1], 'rb')
    out_file = open(argv[2], 'wb')
    for b in in_file.read():
        code = encode_bin(b)
        code = [0 for _ in range(0, 8-len(code))] + code
        for i in decoder(code):
            if i <= len(fragments):
                msg = fragments[i-1]
                if not fragment:
                    fragment = msg
                else:
                    fragment += msg[:1]
                    fragments.append(fragment)
                    fragment = msg
                out_file.write(msg)
            elif i == len(fragments)+1 and len(fragment):
                fragment += fragment[:1]
                fragments.append(fragment)
                out_file.write(fragment)
            else:
                print('incorrect encoding')
                in_file.close()
                out_file.close()
                exit()
    in_file.close()
    out_file.close()


if __name__ == '__main__':
    main(sys.argv)
