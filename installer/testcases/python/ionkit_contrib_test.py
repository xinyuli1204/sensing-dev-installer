from ionpy import Param, Buffer, Builder
import os
import sys
import numpy as np

try:
    os.environ["GENICAM_FILENAME"] = sys.argv[1]
except Exception as err:
    print(err)
    print('Download {} and run python {} <file path>'.format('https://github.com/AravisProject/aravis/blob/main/src/arv-fake-camera.xml', os.path.basename(__file__)))
    sys.exit(1)

builder = Builder()
builder.set_target(target='host')
builder.with_bb_module(path='ion-bb')

num_device = 1
width = 128
height = 128

node = builder.add('image_io_u3v_cameraN_u8x2') \
        .set_params([Param('num_devices', num_device),
                     Param("force_sim_mode", True),
                     Param('width', width),
                     Param('height', height)])
output_p = node.get_port('output')

output_size = (height, width, )
output_data = np.full(output_size, fill_value=0, dtype=np.uint8)
output = Buffer(array= output_data)

output_p[0].bind(output)

for n in range(10):
    # running the builder
    builder.run()
    for i in range(num_device):
        print(output_data)
    