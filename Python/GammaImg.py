#!/usr/bin/python
from __future__ import print_function
import re
import os
import ToneMapping as TM
import imageio

def GammaImage(imgFile, gammas=[1.0], method='hsv'):
    try:
        rgb = imageio.imread(imgFile)
        for g in gammas:
            if g == 1.0:
                continue
            lut = TM.GammaToneMappingLut(g)
            rgb = TM.LutToneRgb(rgb, lut, method)
        return rgb
    except Exception as e:
        print("ERROR gamma image ", imgFile, " : ", e)
        return None

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("img_files", nargs='+',
                        help="list of image files")    
    parser.add_argument("-t", "--img_type", default='tiff',
                        help="output image type, e.g., jpg, tiff and etc. Default tiff")    
    parser.add_argument("-m", "--gamma_methd", default='hsv',
                        help="How to apply gamma: hsv, rgb, yuv")    
    parser.add_argument("-g", "--gammas", nargs='+', type=float, default=[1.0],
                        help="list of gammas for gamma correction to brighten image. Multiple gamma can be specified so that multiple rounds gamma corrections can be applied"
                        )    
    args = parser.parse_args()  

    if os.name == 'nt':
        import glob
        lImgFiles = []
        for rfs in args.img_files:
            m = re.search(r'[\[\]]', rfs)
            if m:
                print('{} has \'[\' or \']\': not use glob with it'.format(rfs) )
                lImgFiles.append(rfs)
            else:
                lImgFiles.extend( glob.glob(rfs) )
    else:
        lImgFiles = args.img_files

    gspec = ''
    for g in args.gammas:
        gspec += '_{}'.format(g)

    for imgFile in lImgFiles:
        rgb = GammaImage(imgFile, args.gammas, args.gamma_methd)
        outFile = '{}.gamma{}_{}.{}'.format(imgFile, gspec, args.gamma_methd, args.img_type)
        print('Saving out to ', outFile)        
        imageio.imsave(outFile, rgb)