// This checks if ion-kit installed under SENSING_DEV_ROOT directory.

#include <ion/ion.h>

int main(int argc, char *argv[])
{
    try {
        ion::Builder b;
        b.set_target(ion::get_host_target());
        b.with_bb_module("ion-bb");
    }
    catch(std::exception& e) {
         std::cout << e.what() << std::endl;
         return 1;
    }
    return 0;
}
