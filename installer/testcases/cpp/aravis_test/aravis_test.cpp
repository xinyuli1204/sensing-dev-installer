// This checks if aravis and gobject are installed under SENSING_DEV_ROOT directory.

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
    return 0;
}
