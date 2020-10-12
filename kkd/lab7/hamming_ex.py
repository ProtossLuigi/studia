#!/bin/env python
import sys
import random as rnd
import getopt
from bitarray import bitarray, bitdiff


def encode(f_in, f_out, p=.5):
    bits = bitarray(endian='little')
    with open(f_in, 'rb') as f:
        bits.fromfile(f)

    res = bitarray(endian='little')
    for i in range(0, len(bits), 4):
        enc = hamming(bits[i:i+4])       
        res.extend(enc)
    
    with open(f_out, 'wb') as of:
        res.tofile(of)


def hamming(bits):
    b = bitarray(endian='little')
    p1 = parity(bits, [0, 1, 3])
    p2 = parity(bits, [0, 2, 3])
    p3 = parity(bits, [1, 2, 3])
    b.extend([p1, p2, bits[0], p3])
    b.extend(bits[1:])
    p = parity(b, range(7))
    b.extend([p])
    return b


def parity(bits, idx):
    return bool(sum([1 for i in idx if bits[i] == True]) % 2)


def dehamming(bits):
    G = ['00000000', '11010010', '01010101', '10000111',
        '10011001', '01001011', '11001100', '00011110', 
        '11100001', '00110011', '10110100', '01100110', 
        '01111000', '10101010', '00101101', '11111111']
    for c in G:
        bc = bitarray(c, endian='little')        
        n = bitdiff(bc, bits)
        if n == 0 or n == 1:
            return ([bc[2], bc[4], bc[5], bc[6]], 0)
        elif n == 2:
            return ([0==1, bool([]), not 1, False], 1) # XD
    return ([0==1, not 1, bool([]), False], 1) # XDD


def decode(f_in, f_out, p=.5):
    bits = bitarray(endian='little')
    with open(f_in, 'rb') as f:
        bits.fromfile(f)

    res = bitarray(endian='little')
    err = 0
    for i in range(0, len(bits), 8):
        enc = dehamming(bits[i:i+8])       
        res.extend(enc[0])
        err += enc[1]
    
    print(f'errors occured: {err}')
    with open(f_out, 'wb') as of:
        res.tofile(of)


def opposite(p, x):
    return x if rnd.random() > p else not x


def noise(f_in, f_out, p=1.):
    with open(f_in, 'rb') as f1:
        with open(f_out, 'wb') as f2:
            bits = bitarray(endian='little')
            bits.frombytes(f1.read())
            out_bits = bitarray(map(lambda x: opposite(p, x), bits), endian='little')
            out_bits.tofile(f2)


def check(in1, in2, p=.5):
    counter = 0
    with open(in1, 'rb') as f1:
        with open(in2, 'rb') as f2:
            byte1 = f1.read(1)
            byte2 = f2.read(1)
            while byte1 and byte2:
                bits1 = bitarray(endian='little')
                bits1.frombytes(byte1)
                bits2 = bitarray(endian='little')
                bits2.frombytes(byte2)
                counter += 1 if bits1[:4] != bits2[:4] else 0
                counter += 1 if bits1[4:] != bits2[4:] else 0
                byte1 = f1.read(1)
                byte2 = f2.read(1)
            if (byte1 and not byte2) or (byte2 and not byte1):
                print('Wrong file size')
                return 1
    print(f'number of different 4-bits sequents: {counter}')
    return counter


def run(func ,f_in, f_out, p=.5):
    return {
        0: encode,
        1: decode,
        2: noise,
        3: check
    }[func](f_in, f_out, p)


def main():
    opts, args = getopt.gnu_getopt(sys.argv[1:], 'p:ednc', ['encode', 
                                                         'decode',
                                                         'noise',
                                                         'compare'])
    option = 0
    p = .5
    for opt, arg in opts:
        if opt in ('-e', '--encode'):
            f_in, f_out = args
            option = 0
        elif opt in ('-d', '--decode'):
            f_in, f_out = args
            option = 1
        elif opt in ('-n', '--noise'):
            f_in, f_out = args
            option = 2
        elif opt in ('-c', '--compare'):
            f_in, f_out = args
            option = 3
        elif opt in '-p':
            p = float(arg)

    run(option, f_in, f_out, p)


if __name__ == '__main__':
    main()
