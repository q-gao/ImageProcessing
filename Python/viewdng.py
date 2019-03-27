#!/usr/bin/python
from __future__ import print_function
#import sys
# import glob
import rawpy
from matplotlib import pyplot as plt
# import imageio

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("dng_files", #nargs='+',
                        help="list of DNG files")
    # parser.add_argument("-t", "--img_type", default='tiff',
    #                     help="output image type, e.g., jpg, tiff and etc. Default tiff")    
    args = parser.parse_args()

    try:
        print("Reading dng file...")
        with rawpy.imread(args.dng_files) as r:
            print("Demosaicing raw image...")
            rgb = r.postprocess( no_auto_bright=True )
            print("Showing image")
            plt.imshow(rgb)
            plt.show()
    except Exception as e:
        print(e)
