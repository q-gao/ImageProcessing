#!/usr/bin/python

from __future__ import print_function



import rawpy

import imageio

import numpy as np

import os.path

import re

def DomasicRawImage(dngTemplate, rawFile):
    try:
        raw = np.fromfile(rawFile, dtype=np.uint16)
        fext = os.path.splitext(rawFile)[1]
        m = re.search(r'(\d+)$', fext)
        if m:
            nbits = int(m.group(1))
            print("nbits ", nbits)
            if nbits > 10:
                raw >>= (nbits-10);
            elif nbits < 10:
                raw <<= (10-nbits);

        raw1 = np.zeros((dng.sizes.raw_height, dng.sizes.raw_width), dtype = 'uint16')
        raw1[0:3000, 0:4000] = raw.reshape(3000, 4000);

        # raw = raw1
        # raw = raw.reshape(dng.sizes.raw_height, dng.sizes.raw_width)
        # np.copyto(dngTemplate.raw_image, raw)
        np.copyto(dngTemplate.raw_image, raw1)

        rgb = dngTemplate.postprocess()
        return rgb

    except Exception as e:
        print(e)
        return None


import sys

if __name__ == '__main__':

    if len(sys.argv) < 3:

        print('Usage: DomasicRawImage.py <dngTemplateFile> <rawFile> [<rawFile>, ...]')



    try:
        with rawpy.imread(sys.argv[1]) as dng:
            for i in xrange(2, len(sys.argv) ):
                print("Demosaicing ", sys.argv[i], "...")
                rgb = DomasicRawImage(dng, sys.argv[i])
                if rgb is None:
                    continue
                tiffFile = sys.argv[i]+ '.tiff'
                #tiffFile = sys.argv[i]+ '.jpg'
                print('Saving demosaiced {} to {} ...\n'.format( sys.argv[i], tiffFile))
                imageio.imsave(tiffFile, rgb)

    except Exception as e:
        print(e)
        #print('FAILED top load DNG or raw file\n')

