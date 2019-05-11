#!/usr/bin/python
from __future__ import print_function
import sys
import rawpy
import imageio
import os
import ToneMapping as TM
if os.name == 'nt':
    import glob

#import cv2
# def LutToneRgb(rgb, lut):
#     yuv = cv2.cvtColor(rgb, cv2.COLOR_RGB2YUV)
#     # LUT Map numpy matrix:
#     # https://stackoverflow.com/questions/14448763/is-there-a-convenient-way-to-apply-a-lookup-table-to-a-large-array-in-numpy
#     y_mapped = lut[yuv[:,:,0]]
#     ratio = y_mapped.astype(np.float) / yuv[:,:,0].astype(np.float)
#
#     u_mapped = yuv[:,:,1].astype(np.float) * ratio
#     u_mapped = u_mapped.astype(np.uint8)
#
#     v_mapped = yuv[:,:,2].astype(np.float) * ratio
#     v_mapped = v_mapped.astype(np.uint8)
#
#     return cv2.cvtColor(np.stack((y_mapped, u_mapped, v_mapped),-1), cv2.COLOR_YUV2RGB)
    
def main(args):    
    if os.name == 'nt':
        lDngFiles = []
        for p in args.dng_files:
            lDngFiles.extend(glob.glob(p))
    else:
        lDngFiles = args.dng_files

    gspec = ''
    for g in args.gammas:
        gspec += '_{}'.format(g)
    imgFileSuffix = '.gamma{}.{}'.format(gspec, args.img_type)
    nab = not args.auto_bright
    for dngFile in lDngFiles:
        try:
            with rawpy.imread(dngFile) as r:
                imgFile = dngFile + imgFileSuffix
                print("{} => {}".format(dngFile, imgFile))
                rgb = r.postprocess( no_auto_bright=nab )

                for g in args.gammas:
                    if g == 1.0:
                        continue
                    lut = TM.GammaToneMappingLut(g)
                    rgb = TM.LutToneRgb(rgb, lut)
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
    parser.add_argument("-g", "--gammas", nargs='+', type=float, default=[1.0],
                        help="list of gammas for gamma correction to brighten image. "
                             "Multiple gamma can be specified so that multiple rounds gamma "
                             "corrections can be applied"
                        )

    parser.add_argument("-a", "--auto_bright", action='store_true', default=False,
                        help="Auto brightening during demosaicing or not")        
    args = parser.parse_args()

    main(args)

