import sys
from struct import pack

from bitarray import bitarray

from encode import clamp


def bits_to_int(arr, signed):
    if signed:
        neg = -arr[0]
        i = 0
        for bit in arr[1:]:
            i = (i << 1) | bit
            neg <<= 1
        return i + neg
    else:
        i = 0
        for bit in arr:
            i = (i << 1) | bit
        return i


def extract_file(filename):
    arr = bitarray()
    with open(filename, 'rb') as src:
        arr.fromfile(src)
    width = bits_to_int(arr[:64], False)
    height = bits_to_int(arr[64:128], False)
    k = bits_to_int(arr[128:131], False)
    pos = 131
    lo_codebooks = []
    for c in range(3):
        codebook = []
        for i in range(1 << k):
            codebook.append(bits_to_int(arr[pos:pos+9], True))
            pos += 9
        lo_codebooks.append(codebook)
    hi_codebooks = []
    for c in range(3):
        codebook = []
        for i in range(1 << k):
            codebook.append(bits_to_int(arr[pos:pos+8], False) - 127)
            pos += 8
        hi_codebooks.append(codebook)
    lo_codemaps = []
    for c in range(3):
        codemap = []
        for i in range(width * height // 2):
            codemap.append(bits_to_int(arr[pos:pos+k], False))
            pos += k
        lo_codemaps.append(codemap)
    hi_codemaps = []
    for c in range(3):
        codemap = []
        for i in range(width * height // 2):
            codemap.append(bits_to_int(arr[pos:pos+k], False))
            pos += k
        hi_codemaps.append(codemap)
    return width, height, k, lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps


def undiffs(data):
    new_data = [data[0]]
    for val in data[1:]:
        new_data.append(new_data[-1] + val)
    return new_data


def dequantize(data, codebook):
    return [codebook[index] for index in data]


def unfilter(lo, hi):
    # print(lo)
    # print(hi)
    # dimmest = [255, 255, 255]
    # brightest = [0, 0, 0]
    bitmap = []
    for i in range(len(lo)):
        x1, x2 = [], []
        for c in range(3):
            x2.append(lo[i][c] + hi[i][c])
            # if x2[-1] > brightest[c]:
            #     brightest[c] = x2[-1]
            # if x2[-1] < dimmest[c]:
            #     dimmest[c] = x2[-1]
            x2[-1] = clamp(x2[-1], 0, 255)
            x1.append(clamp(lo[i][c] * 2 - x2[-1], 0, 255))
            # if x1[-1] < 0:
            #     print(x1[-1])
            # if x2[-1] < 0:
            #     print(x2[-1])
            # if x1[-1] > 255:
            #     print(x1[-1])
            # if x2[-1] > 255:
            #     print(x2[-1])
        bitmap += [tuple(x1), tuple(x2)]
    # print(brightest)
    # print(dimmest)
    return bitmap


def to_tga(width, height, bitmap, file):
    with open(file, 'wb') as f:
        f.write(bytes([0]))
        f.write(bytes([0]))
        f.write(bytes([2]))

        f.write(pack('<H', 0))
        f.write(pack('<H', 0))
        f.write(bytes([0]))

        f.write(pack('<H', 0))
        f.write(pack('<H', 0))
        f.write(pack('<H', width))
        f.write(pack('<H', height))
        f.write(bytes([24]))
        f.write(bytes([32]))

        for r, g, b in bitmap:
            f.write(bytes([b]))
            f.write(bytes([g]))
            f.write(bytes([r]))

        for _ in range(26):
            f.write(bytes([0]))


def decode(lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps):
    lo_diffs = [dequantize(lo_codemaps[i], lo_codebooks[i]) for i in range(len(lo_codebooks))]
    lo_colors = [undiffs(color) for color in lo_diffs]
    hi_colors = [dequantize(hi_codemaps[i], hi_codebooks[i]) for i in range(len(hi_codebooks))]
    lo = list(zip(lo_colors[0], lo_colors[1], lo_colors[2]))
    hi = list(zip(hi_colors[0], hi_colors[1], hi_colors[2]))
    bitmap = unfilter(lo, hi)
    return bitmap


def main(argv):
    src = argv[1]
    dst = argv[2]
    width, height, k, lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps = extract_file(src)
    bitmap = decode(lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps)
    to_tga(width, height, bitmap, dst)


if __name__ == '__main__':
    main(sys.argv)
