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
            if nbits > 10:
                raw >>= (nbits-10);
            elif nbits < 10:
                raw <<= (10-nbits);
        raw = raw.reshape(dng.sizes.raw_height, dng.sizes.raw_width)
        np.copyto(dngTemplate.raw_image, raw)
        rgb = dngTemplate.postprocess()
        return rgb
    except:
        return None

import sys
if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('Usage: DomasicRawImage.py <dngTemplateFile> <rawFile> [<rawFile>, ...]')

    try:
        dng = rawpy.imread(sys.argv[1])

        for i in xrange(2, len(sys.argv) ):
            rgb = DomasicRawImage(dng, sys.argv[i])
            tiffFile = sys.argv[i]+ '.tiff'
            print('Saving demosaiced {} to {} ...\n'.format( sys.argv[i], tiffFile))
            imageio.imsave(tiffFile, rgb)

        dng.close();
    except:
        print('FAILED top load DNG or raw file\n')
