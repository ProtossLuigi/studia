import sys
from math import log2


def s1(nw, n, w):
    return w


def s2(nw, n, w):
    return n


def s3(nw, n, w):
    return nw


def s4(nw, n, w):
    return n + w - nw


def s5(nw, n, w):
    return n + (w - nw) // 2


def s6(nw, n, w):
    return w + (n - nw) // 2


def s7(nw, n, w):
    return (n + w) // 2


def ns(nw, n, w):
    if nw >= max(n, w):
        return max(n, w)
    elif nw <= min(n, w):
        return min(n, w)
    else:
        return w + n - nw


def finder(width, height, order):
    if order == 0:
        return lambda x, y: width * (height - 1 - y) + x
    elif order == 1:
        return lambda x, y: width * (height - 1 - y) + width - 1 - x
    elif order == 2:
        return lambda x, y: width * y + x
    elif order == 3:
        return lambda x, y: width * y + width - 1 - x


def entropy(total, counts):
    return -sum((count / total) * (log2(count) - log2(total)) for count in counts if count > 0)


standards = {
    'standard 1': s1,
    'standard 2': s2,
    'standard 3': s3,
    'standard 4': s4,
    'standard 5': s5,
    'standard 6': s6,
    'standard 7': s7,
    'nowy standard': ns
}


def main(argv):
    in_pixel_counts = [0 for _ in range(256 ** 3)]
    in_color_counts = [[0 for _ in range(256)] for _ in range(3)]
    out_pixel_counts = {}
    out_color_counts = {}
    for key in standards.keys():
        out_pixel_counts[key] = [0 for _ in range(256 ** 3)]
        out_color_counts[key] = [[0 for _ in range(256)] for _ in range(3)]
    in_file = open(argv[1], 'rb')
    header = in_file.read(18)
    width = int.from_bytes(header[12:14], 'little')
    height = int.from_bytes(header[14:16], 'little')
    order = (header[17] >> 4) % 4
    coords = finder(width, height, order)
    pixel_count = width * height
    pixels = []
    for _ in range(pixel_count):
        data = in_file.read(3)
        pixels.append((data[0], data[1], data[2]))
        in_pixel_counts[int.from_bytes(data, 'big')] += 1
        for i in range(3):
            in_color_counts[i][data[i]] += 1
    in_file.close()
    for y in range(height):
        for x in range(width):
            pixel = pixels[coords(x, y)]
            if x:
                w = pixels[coords(x - 1, y)]
            else:
                w = (0, 0, 0)
            if y:
                n = pixels[coords(x, y - 1)]
            else:
                n = (0, 0, 0)
            if x and y:
                nw = pixels[coords(x - 1, y - 1)]
            else:
                nw = (0, 0, 0)
            for key in standards.keys():
                new_pixel = 0
                for i in range(3):
                    color = pixel[i] - standards[key](nw[i], n[i], w[i])
                    out_color_counts[key][i][color] += 1
                    new_pixel = new_pixel * 256 + color
                out_pixel_counts[key][new_pixel] += 1
    results_pixels = {'plik wejściowy': entropy(pixel_count, in_pixel_counts)}
    results_red = {'plik wejściowy': entropy(pixel_count, in_color_counts[2])}
    results_green = {'plik wejściowy': entropy(pixel_count, in_color_counts[1])}
    results_blue = {'plik wejściowy': entropy(pixel_count, in_color_counts[0])}
    best_pixels = None
    best_red = None
    best_green = None
    best_blue = None
    for key in standards.keys():
        results_pixels[key] = entropy(pixel_count, out_pixel_counts[key])
        if not best_pixels or results_pixels[key] < results_pixels[best_pixels]:
            best_pixels = key
        results_red[key] = entropy(pixel_count, out_color_counts[key][2])
        if not best_red or results_red[key] < results_red[best_red]:
            best_red = key
        results_green[key] = entropy(pixel_count, out_color_counts[key][1])
        if not best_green or results_green[key] < results_green[best_green]:
            best_green = key
        results_blue[key] = entropy(pixel_count, out_color_counts[key][0])
        if not best_blue or results_blue[key] < results_blue[best_blue]:
            best_blue = key
    print('Entropia')
    for key in results_pixels.keys():
        print(key, ':', results_pixels[key])
        print(key, 'czerwony:', results_red[key])
        print(key, 'zielony:', results_green[key])
        print(key, 'niebieski:', results_blue[key])
    print('najlepsza metoda:', best_pixels)
    print('najlepsza metoda (czerowny):', best_red)
    print('najlepsza metoda (zielony):', best_green)
    print('najlepsza metoda (niebieski):', best_blue)


if __name__ == '__main__':
    main(sys.argv)
