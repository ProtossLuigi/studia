#!/usr/bin/env python

import methods
import sys
from math import log2, sqrt
from collections import Counter
import numpy as np
import random
from struct import pack


def read_tga(fn):
    with open(fn, 'rb') as f:
        id_len = int.from_bytes(f.read(1), 'little')
        col_map_type = int.from_bytes(f.read(1), 'little')
        img_type = int.from_bytes(f.read(1), 'little')

        # colormap
        first_entr_idx = int.from_bytes(f.read(2), 'little')
        col_map_len = int.from_bytes(f.read(2), 'little')
        col_map_entr_size = int.from_bytes(f.read(1), 'little')

        # img info
        start_x = int.from_bytes(f.read(2), 'little')
        start_y = int.from_bytes(f.read(2), 'little')
        width = int.from_bytes(f.read(2), 'little')
        height = int.from_bytes(f.read(2), 'little')
        pix_depth = int.from_bytes(f.read(1), 'little')
        img_descr = int.from_bytes(f.read(1), 'little')

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
                b = int.from_bytes(f.read(1), 'little')
                g = int.from_bytes(f.read(1), 'little')
                r = int.from_bytes(f.read(1), 'little')
                bitmap[y * width + x] = (r, g, b)

    return (width, height), bitmap


def get_avg_col(bitmap):
    size = len(bitmap)
    a_r = sum([b[0] for b in bitmap]) // size
    a_g = sum([b[1] for b in bitmap]) // size
    a_b = sum([b[2] for b in bitmap]) // size
    return (a_r, a_g, a_b)


def offset_color(color, eps):
    ro = max(min(color[0] + eps, 255), 0)
    go = max(min(color[1] + eps, 255), 0)
    bo = max(min(color[2] + eps, 255), 0)
    return (ro, go, bo)


def avg_dists(cb, bmap):
    all_dists = []
    for e in cb:
        all_dists.append(get_dists(e, bmap))
    return all_dists


def split_codebook(cb, bmap, all_dists_old, EPS):
    ncb = []
    for e in cb:
        ncb.append(offset_color(e, 1))
        ncb.append(offset_color(e, -1))

    # initial error
    err = 255 + EPS

    while err > EPS:
        all_dists = avg_dists(ncb, bmap)

        closers = [[] for _ in range(len(ncb))]
        d = []
        for i in range(len(bmap)):
            mi = all_dists[0][i]
            idx = 0
            for j in range(len(all_dists)):
                if all_dists[j][i] - mi < 0:
                    mi = all_dists[j][i]
                    idx = j
            closers[idx].append(bmap[i])
            d.append(mi)

        ncb = []
        for c in closers:
            ncb.append(get_avg_col(c))

        new_dists = sum([c for c in d]) // len(closers)

        err = (all_dists_old - new_dists) // all_dists_old
        all_dists_old = new_dists

    return new_dists, ncb


def get_dists(c, bmap):
    dists = []
    for p in bmap:
        dists.append(norm(c, p))
    return dists


def norm(c0, c1):
    return abs(c0[0] - c1[0]) + abs(c0[1] - c1[1]) + abs(c0[2] - c1[2])


def genCodebook(size, bmap, no_color):
    width, height = size
    avg_col = get_avg_col(bmap)

    EPS = 1
    codebook = [avg_col]  # offset_color(avg_col, -1), offset_color(avg_col, 1)]

    ado = get_dists(avg_col, bmap)
    all_dists_old = sum(ado) // len(ado)

    while len(codebook) != no_color:
        all_dists_old, codebook = split_codebook(codebook, bmap, all_dists_old, EPS)

    return codebook


def findClosest(c, cb):
    d = get_dists(c, cb)
    return d.index(min(d))


def genImage(cb, bmap):
    img = []
    for e in bmap:
        img.append(cb[findClosest(e, cb)])

    return img


def square_mis(old_img, new_img):
    mis = []
    for i in range(len(old_img)):
        mis.append(norm(old_img[i], new_img[i]) ** 2)

    return sqrt(sum(mis))


def save_tga(w, h, bitmap, file):
    with open(file, 'wb') as f:
        f.write(bytes([0]))
        f.write(bytes([0]))
        f.write(bytes([2]))

        f.write(pack('<H', 0))
        f.write(pack('<H', 0))
        f.write(bytes([0]))

        f.write(pack('<H', 0))
        f.write(pack('<H', 0))
        f.write(pack('<H', w))
        f.write(pack('<H', h))
        f.write(bytes([24]))
        f.write(bytes([32]))

        for r, g, b in bitmap:
            f.write(bytes([b]))
            f.write(bytes([g]))
            f.write(bytes([r]))

        for _ in range(26):
            f.write(bytes([0]))


def main():
    s, bmap = read_tga('./tests/example0.tga')
    cb = genCodebook(s, bmap, 8)
    print(cb)
    img = genImage(cb, bmap)
    # print(img)

    sm = square_mis(bmap, img)
    print(sm)
    save_tga(s[0], s[1], img, 'elo.tga')


main()

