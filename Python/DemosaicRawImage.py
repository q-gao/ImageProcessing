#!/usr/bin/python
from __future__ import print_function

import rawpy
import imageio
import numpy as np
import os.path
import re
def DomasicRawImage(dngTemplate, rawFile, nab = True):
    try:
        raw = np.fromfile(rawFile, dtype=np.uint16)
        
        fext = os.path.splitext(rawFile)[1]
        m = re.search(r'(\d+)$', fext)
        if m:
            nbits = int(m.group(1))
            if nbits > 10:
                raw >>= (nbits-10);
            elif nbits < 10:
                raw <<= (10-nbits);
        raw = raw.reshape(dng.sizes.raw_height, dng.sizes.raw_width)
        np.copyto(dngTemplate.raw_image, raw)
        rgb = dngTemplate.postprocess(no_auto_bright=nab)
        return rgb
    except Exception as e:
        print("ERROR demosaicing ", rawFile, " : ", e)
        return None

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("dng_tmplt_file", 
                        help="DNG template file")
    parser.add_argument("raw_files", nargs='+',
                        help="list of raw files")    
    parser.add_argument("-t", "--img_type", default='tiff',
                        help="output image type, e.g., jpg, tiff and etc. Default tiff")    
    parser.add_argument("-a", "--auto_bright", action='store_true', default=False,
                        help="Auto brightening during demosaicing or not")    

    args = parser.parse_args()  

    import glob
    try:
        dng = rawpy.imread(args.dng_tmplt_file)
    except Exception as e:        
        print("FAILED to load ", args.dng_tmplt_file, " : ", e)
        exit(-1)

    try:    
        imgFileSuffix = '.' + args.img_type
        for rfs in args.raw_files:
            lRawFiles = glob.glob(rfs)
            if len(lRawFiles) == 0:
                print("WRONG raw file spec: ", rfs)
                next
            for rawFile in lRawFiles:
                rgb = DomasicRawImage(dng, rawFile, not args.auto_bright)
                imgFile = rawFile + imgFileSuffix
                print('Saving demosaiced {} to {} ...\n'.format( rawFile, imgFile))
                imageio.imsave(imgFile, rgb)

        dng.close();
    except Exception as e:
        print(e)
