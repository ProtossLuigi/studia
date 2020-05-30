import sys

from decode import decode
from encode import from_tga, encode


def norm(val1, val2):
    return abs(val1 - val2)


def norm3(vec1, vec2):
    return sum(abs(vec1[i] - vec2[i]) for i in range(3))


def mse(old, new):
    mse_r = []
    for i in range(len(old)):
        mse_r.append(norm(old[i], new[i])**2)
    return sum(mse_r)/len(old)


def mse3(old, new):
    mse_r = []
    for i in range(len(old)):
        mse_r.append(norm3(old[i], new[i])**2)
    return sum(mse_r)/len(old)


def snr(mse_res, old):
    snr_r = []
    for i in range(len(old)):
        snr_r.append(norm3(old[i], (0, 0, 0))**2)
    return (sum(snr_r)/len(old))/mse_res


def main(argv):
    width, height, bitmap = from_tga(argv[1])
    for k in range(1, 8):
        lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps = encode(bitmap, k)
        decoded = decode(lo_codebooks, hi_codebooks, lo_codemaps, hi_codemaps)
        mse_ = [mse3(bitmap, decoded)]
        mse_ += [mse([pix[c] for pix in bitmap], [pix[c] for pix in decoded]) for c in range(3)]
        snr_ = snr(mse_[0], bitmap)
        print(k, 'bit')
        print('mse:', mse_[0])
        print('mse red:', mse_[1])
        print('mse green:', mse_[2])
        print('mse blue:', mse_[3])
        print('snr:', snr_)


if __name__ == '__main__':
    main(sys.argv)
