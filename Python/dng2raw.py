#!/usr/bin/python
from __future__ import print_function
import sys
import glob
import rawpy

def main( lDngFiles ):
    for dngFile in lDngFiles:
        try:
            with rawpy.imread(dngFile) as r:
                rawFile = dngFile + ".raw10"
                print("{} => {}".format(dngFile, rawFile))
                r.raw_image.tofile( rawFile )
        except Exception as e:
            print(e)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python dng2raw.py <dng_file> [<dng_file> ...]")
        exit(-1)
    lDngFiles = []
    for p in sys.argv[1:]:
        ldf = glob.glob(p)
        for f in ldf:
            lDngFiles.append(f)

    main(lDngFiles)


