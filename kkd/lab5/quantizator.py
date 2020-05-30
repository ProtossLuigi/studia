import sys
from math import inf
from struct import pack
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


def avg_color(bitmap):
    return [sum(p[i] for p in bitmap) // len(bitmap) for i in range(3)]


def norm(vec1, vec2):
    return sum(abs(vec1[i] - vec2[i]) for i in range(3))


def norms(ref, bitmap):
    return [norm(ref, p) for p in bitmap]


def clamp(val, min, max):
    if val < min:
        return min
    elif val > max:
        return max
    else:
        return val


def offset_vec(vec, offset):
    return [clamp(val + offset, 0, 255) for val in vec]


def create_codebook(bitmap, no_colors):
    codebook = [avg_color(bitmap)]
    avg_norm = sum(norms(codebook[0], bitmap)) / len(bitmap)
    while len(codebook) < no_colors:
        new_codebook = []
        for color in codebook:
            new_codebook.append(offset_vec(color, EPS))
            new_codebook.append(offset_vec(color, -EPS))
        # print(new_codebook)
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
            # for g in groups:
            #     print(g[:10])
            new_codebook = [avg_color(group) for group in groups]
            new_avg_norm = sum(min_dists) / len(groups)
            delta = (avg_norm - new_avg_norm) / avg_norm
            avg_norm = new_avg_norm
        # print(new_codebook)
        codebook = new_codebook
    return codebook


def quantify_bitmap(bitmap, codebook):
    new_bitmap = []
    for pixel in bitmap:
        min_norm = norm(codebook[0], pixel)
        approx = codebook[0]
        for centroid in codebook[1:]:
            if norm(centroid, pixel) < min_norm:
                min_norm = norm(centroid, pixel)
                approx = centroid
        new_bitmap.append(approx)
    return new_bitmap


def mse(old, new):
    mse_r = []
    for i in range(len(old)):
        mse_r.append(norm(old[i], new[i])**2)
    return sum(mse_r)/len(old)


def snr(mse_res, old):
    snr_r = []
    for i in range(len(old)):
        snr_r.append(norm(old[i], (0, 0, 0))**2)
    return (sum(snr_r)/len(old))/mse_res


def main(argv):
    assert len(argv) >= 4
    no_colors = 1 << int(argv[3])
    width, height, src_bitmap = from_tga(argv[1])
    codebook = create_codebook(src_bitmap, no_colors)
    dst_bitmap = quantify_bitmap(src_bitmap, codebook)
    to_tga(width, height, dst_bitmap, argv[2])
    mse_res = mse(src_bitmap, dst_bitmap)
    print('mse: ', mse_res)
    print('snr: ', snr(mse_res, src_bitmap))


if __name__ == '__main__':
    main(sys.argv)
