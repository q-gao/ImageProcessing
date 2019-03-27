#!/usr/bin/python
from __future__ import print_function
import sys
import glob
import rawpy
import imageio

def main( lDngFiles, imgFileSuffix, nab = True ):
    for dngFile in lDngFiles:
        try:
            with rawpy.imread(dngFile) as r:
                imgFile = dngFile + imgFileSuffix
                print("{} => {}".format(dngFile, imgFile))
                rgb = r.postprocess( no_auto_bright=nab )
                imageio.imsave(imgFile, rgb)
        except Exception as e:
            print(e)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("dng_files", nargs='+',
                        help="list of DNG files")
    parser.add_argument("-t", "--img_type", default='tiff',
                        help="output image type, e.g., jpg, tiff and etc. Default tiff")    
    parser.add_argument("-a", "--auto_bright", action='store_true', default=False,
                        help="Auto brightening during demosaicing or not")        
    args = parser.parse_args()

    lDngFiles = []
    for p in args.dng_files:
        ldf = glob.glob(p)
        for f in ldf:
            lDngFiles.append(f)

    main(lDngFiles, '.' + args.img_type, not args.auto_bright)

