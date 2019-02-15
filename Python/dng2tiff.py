#!/usr/bin/python
from __future__ import print_function
import sys
import glob
import rawpy
import imageio

def main( lDngFiles ):
    for dngFile in lDngFiles:
        try:
            with rawpy.imread(dngFile) as r:
                imgFile = dngFile + ".tiff"
                print("{} => {}".format(dngFile, imgFile))
                rgb = r.postprocess( no_auto_bright=True )
                imageio.imsave(imgFile, rgb)
        except Exception as e:
            print(e)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python dng2tiff.py <dng_file> [<dng_file> ...]")
        exit(-1)
    lDngFiles = []
    for p in sys.argv[1:]:
        ldf = glob.glob(p)
        for f in ldf:
            lDngFiles.append(f)

    main(lDngFiles)

