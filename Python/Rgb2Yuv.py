import numpy as np

# * OpenCV based:
#   https://stackoverflow.com/questions/43983265/rgb-to-yuv-conversion-and-accessing-y-u-and-v-channels?rq=1
# * from https://gist.github.com/Quasimondo/c3590226c924a06b276d606f4f189639

#input is a RGB numpy array with shape (height,width,3), can be uint,int, float or double, values expected in the range 0..255
#output is a double YUV numpy array with shape (height,width,3), values in the range 0..255
def RGB2YUV( rgb ):
# the matrix is for use with numpy.dot (https://www.tutorialspoint.com/numpy/numpy_dot.htm)
#  dot(a,b)
#   ...sum product over the last axis of a and the second-last axis of b.
# So:
#  - each column of M corresponds a color (R, G, or B)
    m = np.array([[ 0.29900, -0.16874,  0.50000],
                  [ 0.58700, -0.33126, -0.41869],
                  [ 0.11400, 0.50000, -0.08131]])
    
    yuv = np.dot(rgb,m)
    yuv[:,:,1:]+=128.0  # 8-bit RGB => 8-bit YUV
    return yuv

#input is an YUV numpy array with shape (height,width,3) can be uint,int, float or double,  values expected in the range 0..255
#output is a double RGB numpy array with shape (height,width,3), values in the range 0..255
def YUV2RGB( yuv ):
      
    m = np.array([[ 1.0, 1.0, 1.0],
                 [-0.000007154783816076815, -0.3441331386566162, 1.7720025777816772],
                 [ 1.4019975662231445, -0.7141380310058594 , 0.00001542569043522235] ])
    
    rgb = np.dot(yuv,m)
     # the following offset = [0 -128 -128] * m
    rgb[:,:,0]-=179.45477266423404
    rgb[:,:,1]+=135.45870971679688
    rgb[:,:,2]-=226.8183044444304
    return rgb

