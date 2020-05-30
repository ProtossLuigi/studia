import sys
from math import inf
from bitarray import bitarray

EPS = 1


def from_tga(filename):
    with open(filename, 'rb') as img:
        id_len = int.from_bytes(img.read(1), 'little')
        col_map_type = int.from_bytes(img.read(1), 'little')
        img_type = int.from_bytes(img.read(1), 'little')

        # colormap
        first_entr_idx = int.from_bytes(img.read(2), 'little')
        col_map_len = int.from_bytes(img.read(2), 'little')
        col_map_entr_size = int.from_bytes(img.read(1), 'little')

        # img info
        start_x = int.from_bytes(img.read(2), 'little')
        start_y = int.from_bytes(img.read(2), 'little')
        width = int.from_bytes(img.read(2), 'little')
        height = int.from_bytes(img.read(2), 'little')
        pix_depth = int.from_bytes(img.read(1), 'little')
        img_descr = int.from_bytes(img.read(1), 'little')

        attrs_per_prixel = img_descr & 0x00001111
        order = (img_descr & 0x00110000) >> 4
        zero = (img_descr & 0x11000000) >> 6

        if (order & 0x10) != 0:
            vert = range(height)
        else:
            vert = reversed(range(height))

        if (order & 0x01) == 0:
            horiz = range(width)
        else:
            horiz = reversed(range(width))

        bitmap = [0] * (width * height)
        for y in vert:
            for x in horiz:
                b = int.from_bytes(img.read(1), 'little')
                g = int.from_bytes(img.read(1), 'little')
                r = int.from_bytes(img.read(1), 'little')
                bitmap[y * width + x] = (r, g, b)

    return width, height, bitmap


def int_to_bits(n, length):
    if n < 0:
        n += 1 << length
    bits = bin(n)[2:]
    return bitarray('0' * (length - len(bits)) + bits)


def to_file(filename, width, height, bits, lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps):
    arr = bitarray()
    arr.frombytes(width.to_bytes(8, byteorder='big'))
    arr.frombytes(height.to_bytes(8, byteorder='big'))
    arr += int_to_bits(bits, 3)
    for codebook in lo_codebooks:
        for val in codebook:
            arr += int_to_bits(val, 9)
    for codebook in hi_codebooks:
        for val in codebook:
            arr += int_to_bits(val + 127, 8)
    for codemap in lo_codemaps + hi_codemaps:
        for val in codemap:
            arr += int_to_bits(val, bits)
    with open(filename, 'wb') as out_file:
        arr.tofile(out_file)


def filter_pixels(bitmap):
    lo, hi = [], []
    for i in range(len(bitmap) // 2):
        x1 = bitmap[i * 2]
        x2 = bitmap[i * 2 + 1]
        y, z = [], []
        for c in range(3):
            y.append((x1[c] + x2[c]) // 2)
            z.append(x2[c] - y[c])
        lo.append(tuple(y))
        hi.append(tuple(z))
    return lo, hi


def diffs(data):
    new_data = [data[0]]
    for i in range(1, len(data)):
        new_data.append(data[i] - data[i-1])
    return new_data


def quantized_diffs(data, codebook):
    last_val = find_closest(data[0], codebook)
    encoded = [last_val]
    for i in range(1, len(data)):
        encoded.append(find_closest(data[i] - last_val, codebook))
        last_val += codebook[encoded[-1]]
    return encoded


def quantized_diffs2(data, codemap, codebook):
    data1 = list(data)
    data2 = list(data)
    for i in range(1, len(data)):
        data1[i] -= data2[i-1]
        codemap[i] = find_closest(data1[i], codebook)
        if i > 1:
            last = data2[i-2]
        else:
            last = 0
        for j in range(i-1, len(data)):
            last += codebook[codemap[j]]
            data2[j] = last


def avg_color(bitmap):
    if bitmap:
        return sum(p for p in bitmap) // len(bitmap)
    else:
        return 0


def norm(vec1, vec2):
    return abs(vec1 - vec2)


def norms(ref, bitmap):
    return [norm(ref, p) for p in bitmap]


def clamp(val, min, max):
    if val < min:
        return min
    elif val > max:
        return max
    else:
        return val


def offset_vec(val, offset, min, max):
    return clamp(val + offset, min, max)


def find_closest(val, codebook):
    closest = 0
    min_norm = norm(val, codebook[0])
    for i in range(1, len(codebook)):
        if norm(val, codebook[i]) < min_norm:
            closest = i
            min_norm = norm(val, codebook[i])
    return closest


def create_codebook(bitmap, no_colors, min, max):
    codebook = [avg_color(bitmap)]
    avg_norm = sum(norms(codebook[0], bitmap)) / len(bitmap)
    while len(codebook) < no_colors:
        new_codebook = []
        for color in codebook:
            new_codebook.append(offset_vec(color, EPS, min, max))
            new_codebook.append(offset_vec(color, -EPS, min, max))
        delta = inf
        while delta > EPS:
            dists = [norms(color, bitmap) for color in new_codebook]
            groups = [[] for _ in range(len(new_codebook))]
            min_dists = []
            for i in range(len(bitmap)):
                min_dist = dists[0][i]
                group = 0
                for j in range(1, len(dists)):
                    if dists[j][i] < min_dist:
                        min_dist = dists[j][i]
                        group = j
                groups[group].append(bitmap[i])
                min_dists.append(min_dist)
            new_codebook = [avg_color(group) for group in groups]
            new_avg_norm = sum(min_dists) / len(groups)
            delta = (avg_norm - new_avg_norm) / avg_norm
            avg_norm = new_avg_norm
        codebook = new_codebook
    return codebook


def quantize(bitmap, codebook):
    return [find_closest(pixel, codebook) for pixel in bitmap]


def to_quantized(bitmap, codebook):
    return [codebook[find_closest(pixel, codebook)] for pixel in bitmap]


def unzip(zipped):
    return [list(t) for t in zip(*zipped)]


def encode(bitmap, k):
    lo, hi = filter_pixels(bitmap)
    lo = unzip(lo)
    hi = unzip(hi)
    lo_diffs = [diffs(color) for color in lo]
    lo_codebooks = [create_codebook(color, 1 << k, -255, 255) for color in lo_diffs]
    # lo_codemaps = [quantized_diffs(lo[i], lo_codebooks[i]) for i in range(len(lo))]
    lo_codemaps = [quantize(lo_diffs[i], lo_codebooks[i]) for i in range(len(lo))]
    for i in range(3):
        quantized_diffs2(lo[i], lo_codemaps[i], lo_codebooks[i])
    hi_codebooks = [create_codebook(color, 1 << k, -127, 128) for color in hi]
    hi_codemaps = [quantize(hi[i], hi_codebooks[i]) for i in range(len(hi))]
    return lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps


def main(argv):
    k = int(argv[3])
    width, height, bitmap = from_tga(argv[1])
    lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps = encode(bitmap, k)
    to_file(argv[2], width, height, k, lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps)


if __name__ == '__main__':
    main(sys.argv)
