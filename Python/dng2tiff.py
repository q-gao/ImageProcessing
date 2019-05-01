#!/usr/bin/python
from __future__ import print_function
import sys
import glob
import rawpy
import imageio
import dng2img

def main( lDngFiles, imgFileSuffix ):
    for dngFile in lDngFiles:
        try:
            with rawpy.imread(dngFile) as r:
                imgFile = dngFile + imgFileSuffix
                print("{} => {}".format(dngFile, imgFile))
                rgb = r.postprocess( no_auto_bright=True )
                imageio.imsave(imgFile, rgb)
        except Exception as e:
            print(e)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("dng_files", nargs='+',
                        help="list of DNG files")
    parser.add_argument("-g", "--gammas", nargs='+', type=float, default=[1.0],
                        help="list of gammas for gamma correction to brighten image. Multiple gamma can be specified so that multiple rounds gamma corrections can be applied")    

    parser.add_argument("-a", "--auto_bright", action='store_true', default=False,
                        help="Auto brightening during demosaicing or not")                                    
    args = parser.parse_args()
    args.img_type = 'tiff'

    dng2img.main(args)