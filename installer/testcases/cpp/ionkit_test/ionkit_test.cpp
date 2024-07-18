/*

g++ ionkit_test.cpp -o ionkit_test  \
-I /opt/sensing-dev/include \
-L /opt/sensing-dev/lib \
-lHalide -lion-core

*/

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
