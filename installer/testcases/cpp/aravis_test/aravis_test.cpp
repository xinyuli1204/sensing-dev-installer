/*

g++ aravis_test.cpp -o aravis_test  \
-I /opt/sensing-dev/include -I /opt/sensing-dev/include/aravis-0.8 \
-L /opt/sensing-dev/lib \
-L /opt/sensing-dev/lib/x86_64-linux-gnu \
-ldl -lpthread \
-laravis-0.8 -lgobject-2.0 \
`pkg-config --cflags --libs glib-2.0`

*/

#include <exception>
#include <iostream>
#include "arv.h"

int main(int argc, char *argv[])
{
    try {
       arv_update_device_list ();
    }
    catch(std::exception& e) {
         std::cout << e.what() << std::endl;
         return 1;
    }
    std::cout << "PASSED" << std::endl;
    return 0;
}
