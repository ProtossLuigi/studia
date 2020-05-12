import sys


def main(argv):
    assert len(argv) >= 4
    no_colors = int(argv[3])
    src_img = open(argv[1], 'rb')

    src_img.close()
    out_img = open(argv[2], 'wb')

    out_img.close()


if __name__ == '__main__':
    main(sys.argv)
