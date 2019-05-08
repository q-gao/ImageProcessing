#!/usr/bin/python
from __future__ import print_function
import rawpy
import numpy as np
import imageio

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("dng_files", nargs='+',
                        help="list of dng files")    
    parser.add_argument("-t", "--img_type", default='tiff',
                        help="output image type, e.g., jpg, tiff and etc. Default tiff")    
    parser.add_argument("-a", "--auto_bright", action='store_true', default=False,
                        help="Auto brightening during demosaicing or not")    

    args = parser.parse_args()  

    import glob
    listDngFile = []
    for rfs in args.dng_files:
        lRawFiles = glob.glob(rfs)
        listDngFile.extend(lRawFiles) 

    if len( listDngFile) < 1:
        print("No dng file found by the specified file name pattern")
        exit(-1)

    try:
        dng = rawpy.imread(listDngFile[0])
    except Exception as e:        
        print("FAILED to load ", listDngFile[0], " : ", e)
        exit(-1)

    img_height, img_width = dng.sizes.raw_height, dng.sizes.raw_width
    burstRaw = np.empty( (len(listDngFile), img_height, img_width))

    for i, rawFile in enumerate(listDngFile):
        try:
            print("Loading ", rawFile)
            dng = rawpy.imread( rawFile )
        except Exception as e:        
            print("FAILED to load ", rawFile, " : ", e)
            exit(-1)

        burstRaw[i,:,:] = dng.raw_image

    print("Median denoising the burst ...")
    medianDenoised = np.median(burstRaw, axis=0).astype(np.uint16)

    np.copyto(dng.raw_image, medianDenoised)
    rgb = dng.postprocess(no_auto_bright=args.auto_bright)
    saveImgFile = "medianDenoised.tiff"
    print('Saving median-denoised to {} ...\n'.format( saveImgFile ))
    imageio.imsave(saveImgFile, rgb)

    print("Mean denoising the burst ...")
    meanDenoised   = np.mean(burstRaw, axis=0).astype(np.uint16)

    np.copyto(dng.raw_image, meanDenoised)
    rgb = dng.postprocess(no_auto_bright=args.auto_bright)
    saveImgFile = "meanDenoised.tiff"
    print('Saving mean-denoised to {} ...\n'.format( saveImgFile ))
    imageio.imsave(saveImgFile, rgb)


