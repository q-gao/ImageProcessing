#!/usr/bin/python
from __future__ import print_function

import glob
import numpy as np

if __name__ == '__main__':
	import argparse
	ap = argparse.ArgumentParser()
	ap.add_argument("bin_files", nargs="+", help = "binary files")

	args = ap.parse_args()

	for fspec in args.bin_files:
		for bf in glob.glob(fspec):
			try:
				a = np.fromfile(bf, dtype=np.uint16)
				print(bf, ": ",np.min(a), np.max(a))
			except Exception as e:
				print(e)
