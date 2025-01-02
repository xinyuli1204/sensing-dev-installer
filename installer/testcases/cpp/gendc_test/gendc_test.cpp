/*

g++ gendc_test.cpp -o gendc_test  \
-I /opt/sensing-dev/include

*/

#include <exception>
#include <iostream>
#include "gendc_common.h"

int main(int argc, char *argv[])
{
    try {
        // check tools
        int32_t Mono8 = gendc::pfnc::convert_pixelformat("Mono8");
        // check container
        char non_gendc[256] = "THIS_IS_INVALID_GENDC_BINARY_CONTENT";
        char* bin_non_gendc = nullptr;
        bin_non_gendc = non_gendc;
        
        if (gendc::isGenDC(bin_non_gendc)){
            std::cerr << "Wrong result.\n";
            return 1;
        }
    }
    catch(std::exception& e) {
         std::cout << e.what() << std::endl;
         return 1;
    }
    std::cout << "PASSED" << std::endl;
    return 0;
}