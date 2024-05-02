// This checks if opencv installed under SENSING_DEV_ROOT directory.

#include <exception>
#include <iostream>
#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>

int main(int argc, char *argv[])
{
    try {
         cv::Mat Image(5,5,CV_8UC1);
    }
    catch(std::exception& e) {
         std::cout << e.what() << std::endl;
         return 1;
    }
    return 0;
   
}
