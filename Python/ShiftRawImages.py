#!/usr/bin/python
from __future__ import print_function

import numpy as np

def TranslateRawImage(in_raw_file, w, h, vert_mv, horizon_mv, out_raw_file):
    in_raw = np.fromfile(in_raw_file, dtype=np.uint16)
    in_raw = in_raw.reshape((h, w))  # (y, x)

    out_raw = np.zeros((h, w))

    intersect_x = np.maximum(0, horizon_mv)
    intersect_y = np.maximum(0, vert_mv)


def main(args):
    import glob
    in_raw_files = []
    for p in args.in_raw_files:
        for f in glob.glob(p):
            in_raw_files.append(f)




if __name__ == '__main__':
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('-x', type=int, help="max abs translation on x/horizontal direction - should be even for Bayer")
    ap.add_argument('-y', type=int, help="max abs translation on y/vertical direction - should be even for Bayer")
    ap.add_argument('-w', type=int, help="image width")
    ap.add_argument('-t', type=int, help="image tall/height")
    ap.add_argument('in_raw_files', nargs='+', help="input raw files")

    args = ap.parse_args()

    main(args)