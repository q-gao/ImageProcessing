#!/usr/bin/python
from __future__ import print_function

import numpy as np

def TranslateRawImage(in_raw_file, w, h, horizon_mv, vert_mv, out_raw_file):
    try:
        in_raw = np.fromfile(in_raw_file, dtype=np.uint16)
    except Exception as e:
        print(e)
        return -1

    in_raw = in_raw.reshape((h, w))  # (y, x)

    out_raw = np.zeros((h, w), dtype=np.uint16) # + 8000

    if horizon_mv >= 0:
        if vert_mv >= 0:
            out_raw[vert_mv:, horizon_mv:] = in_raw[0: -vert_mv, 0: -horizon_mv ]
        else:
            out_raw[0:vert_mv, horizon_mv:] = in_raw[-vert_mv:, 0: -horizon_mv]
    else:
        if vert_mv >= 0:
            out_raw[vert_mv:, 0:horizon_mv] = in_raw[0: -vert_mv, -horizon_mv:]
        else:
            out_raw[0:vert_mv, 0:horizon_mv] = in_raw[-vert_mv:, -horizon_mv:]

    try:
        out_raw.tofile(out_raw_file)
    except Exception as e:
        print(e)
        return -2

    return 0

def main(args):
    import glob
    import os.path

    for p in args.in_raw_files:
        for f in glob.glob(p):
            b, ext = os.path.splitext(f)
            outf = '{}_shifted{}'.format(b, ext)
            horizon_mv = np.random.randint(args.lower_motion_limit, args.upper_motion_limit)
            vert_mv = np.random.randint(args.lower_motion_limit, args.upper_motion_limit)
            print('{} => {}: {} {}'.format(f, outf, horizon_mv, vert_mv))
            TranslateRawImage(f, args.width, args.tall, horizon_mv, vert_mv, outf)

if __name__ == '__main__':
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('-l', '--lower_motion_limit', type=int, help="max abs translation - should be even for Bayer")
    ap.add_argument('-u', '--upper_motion_limit', type=int, help="min abs translation - should be even for Bayer")
    ap.add_argument('-w', '--width', type=int, help="image width")
    ap.add_argument('-t', '--tall', type=int, help="image tall/height")
    ap.add_argument('in_raw_files', nargs='+', help="input raw files")

    args = ap.parse_args()

    main(args)