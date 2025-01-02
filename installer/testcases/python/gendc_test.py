import numpy as np
from gendc_python.gendc_separator import descriptor as gendc
from gendc_python.genicam import tool as genicam
import sys

Mono8 = genicam.pfnc_convert_pixelformat("Mono8")

non_gendc = 'THIS_IS_INVALID_GENDC_BINARY_CONTENT'
bin_non_gendc = ' '.join(format(ord(x), 'b') for x in non_gendc)

if __name__ == '__main__':
    try:
        if gendc.is_gendc(bin_non_gendc):
            sys.exit(1)
        else:
            sys.exit(0)
    except:
        sys.exit(1)
