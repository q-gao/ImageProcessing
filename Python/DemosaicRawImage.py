#!/usr/bin/python
from __future__ import print_function

import rawpy
import imageio
import numpy as np
import os
import re
import ToneMapping as TM

def DomasicRawImage(dngTemplate, rawFile, gammas=[1.0], nab = True):
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

        for g in gammas:
            if g == 1.0:
                continue
            lut = TM.GammaToneMappingLut(g)
            rgb = TM.LutToneRgb(rgb, lut)

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
    parser.add_argument("-g", "--gammas", nargs='+', type=float, default=[1.0],
                        help="list of gammas for gamma correction to brighten image. Multiple gamma can be specified so that multiple rounds gamma corrections can be applied"
                        )    
    parser.add_argument("-a", "--auto_bright", action='store_true', default=False,
                        help="Auto brightening during demosaicing or not")    

    args = parser.parse_args()  


    if os.name == 'nt':
        import glob
        lRawFiles = []
        for rfs in args.raw_files:
            lRawFiles.extend( glob.glob(rfs) )
    else:
        lRawFiles = args.raw_files

    if len(lRawFiles) <= 0:
        print('ERROR: specified raw file patterns don\'t match any files')
        exit(-1)

    try:
        dng = rawpy.imread(args.dng_tmplt_file)
    except Exception as e:        
        print("FAILED to load ", args.dng_tmplt_file, " : ", e)
        exit(-1)

    try:    
        gspec = ''
        for g in args.gammas:
            gspec += '_{}'.format(g)

        for rawFile in lRawFiles:
            rgb = DomasicRawImage(dng, rawFile, args.gammas, not args.auto_bright)
            imgFile = '{}.gamma{}.{}'.format(rawFile, gspec, args.img_type)
            print('Saving demosaiced {} to {} ...\n'.format( rawFile, imgFile))
            imageio.imsave(imgFile, rgb)

        dng.close();
    except Exception as e:
        print(e)
