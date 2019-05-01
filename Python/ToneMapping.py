#!/usr/bin/python
import cv2
import numpy as np

def LutToneRgb(rgb, lut):
#     n = lut.shape[0]
#     uvRatio = np.float64(np.sum(lut)) / np.float64( n * (n-1) /2)
#     yuv = cv2.cvtColor(rgb, cv2.COLOR_RGB2YUV)
#     # LUT Map numpy matrix: 
#     # https://stackoverflow.com/questions/14448763/is-there-a-convenient-way-to-apply-a-lookup-table-to-a-large-array-in-numpy
#     y, u, v = cv2.split(yuv)  # costly operation
    
#     y_mapped = lut[y]
    
#     # handle divide by zero
#     y_mapped[y==0] = 1    
#     y[y==0] = 1
    
#     ratio = y_mapped.astype(np.float64) / y.astype(np.float64)

#     u_mapped = u.astype(np.float64) * uvRatio
#     u_mapped[u_mapped>255] = 255
#     u_mapped = u_mapped.astype(np.uint8)
    
#     v_mapped = v.astype(np.float64) * uvRatio
#     v_mapped[v_mapped>255] = 255
#     v_mapped = v_mapped.astype(np.uint8)    

#     # cv2.merge and split are costly according to
#     # https://docs.opencv.org/3.0-beta/doc/py_tutorials/py_core/py_basic_ops/py_basic_ops.html
#     return cv2.cvtColor(cv2.merge((y_mapped, u_mapped, v_mapped),-1), cv2.COLOR_YUV2RGB)
#     #return cv2.cvtColor(cv2.merge((y_mapped, u, v),-1), cv2.COLOR_YUV2RGB)
    hsv = cv2.cvtColor(rgb, cv2.COLOR_RGB2HSV)
    v = hsv[:,:,2]
    v_mapped = lut[v]
    return cv2.cvtColor(
                np.stack((hsv[:,:,0],hsv[:,:,1],v_mapped),-1), 
                cv2.COLOR_HSV2RGB
            )   

def GammaToneMappingLut(gamma, maxVal = 255):
    '''
    Return: uint8 LUT
    '''
    lut = np.array(range(maxVal+1))
    gamma_inv = 1.0/gamma
    scale = maxVal / np.power(maxVal, gamma_inv)
    lut[1:] = np.power( lut[1:], gamma_inv ) * scale
    lut = lut.astype(np.uint8)
    # lut = np.array([0., 4., 8., 12., 16., 19., 22., 24., 27., 29., 32., 34., 36., 38., 40., 42., 44.,
                    # 46., 48., 49., 51., 53., 55., 56., 58., 60., 61., 63., 64., 66., 68., 69., 70.,
                    # 72., 73., 75., 76., 77., 79., 80., 82., 83., 84., 85., 87., 88., 89., 90., 92.,
                    # 93., 94., 95., 96., 98., 99., 100., 101., 102., 104., 105., 106., 107., 108., 109.,
                    # 110., 111., 112., 113., 114., 116., 117., 118., 119., 120., 121., 122., 123., 124.,
                    # 125., 126., 127., 128., 129., 130., 131., 132., 133., 134., 134., 135., 136., 137.,
                    # 138., 139., 140., 141., 142., 143., 144., 145., 146., 147., 148., 148., 149., 150.,
                    # 151., 152., 153., 154., 154., 155., 156., 157., 158., 159., 160., 160., 161., 162.,
                    # 163., 164., 164., 165., 166., 167., 168., 169., 170., 170., 171., 172., 172., 173.,
                    # 174., 175., 176., 176., 177., 178., 179., 180., 180., 181., 182., 183., 184., 184.,
                    # 185., 186., 186., 187., 188., 189., 190., 190., 191., 192., 192., 193., 194., 194.,
                    # 195., 196., 197., 197., 198., 199., 200., 200., 201., 202., 202., 203., 204., 205.,
                    # 205., 206., 207., 207., 208., 209., 209., 210., 211., 211., 212., 213., 214., 214.,
                    # 215., 216., 216., 217., 218., 218., 219., 219., 220., 221., 222., 222., 223., 223.,
                    # 224., 225., 225., 226., 227., 227., 228., 229., 229., 230., 230., 231., 232., 232.,
                    # 233., 234., 234., 235., 236., 236., 237., 237., 238., 239., 239., 240., 240., 241.,
                    # 242., 242., 243., 244., 244., 245., 246., 246., 247., 247., 248., 248., 249., 250.,
                    # 250., 251., 252., 252., 253., 253., 254., 254., 255., 255.]).astype(np.uint8)

    return lut