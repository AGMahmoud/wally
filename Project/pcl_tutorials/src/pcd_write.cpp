/**
   @file pcd_write.cpp
   @brief write random point cloud into a PCD file

   @author TagerillWong<buaaben@163.com>
   @version 1.0
   @date 2016-01-06
*/

#include <iostream>
#include <pcl-1.7/pcl/io/pcd_io.h>
#include <pcl-1.7/pcl/point_types.h>


int main(int argc, char *argv[])
{
  pcl::PointCloud<pcl::PointXYZ> cloud;

  cloud.width = 5;
  cloud.height = 1;
  cloud.is_dense = false;
  cloud.points.resize(cloud.width*cloud.height);

  for(size_t i = 0; i < cloud.points.size(); ++i){
    cloud.points[i].x = 1024 * rand() / (RAND_MAX + 1.0f);
    cloud.points[i].y = 1024 * rand() / (RAND_MAX + 1.0f);
    cloud.points[i].z = 1024 * rand() / (RAND_MAX + 1.0f);
  }

  pcl::io::savePCDFileASCII("test_pcd.pcd", cloud);
  std::cerr << "Saved" << cloud.points.size()
	    << "data points to test_pcd.pcd" << std::endl;
  for(size_t i = 0; i < cloud.size(); ++i){
    std::cerr << " " << cloud.points[i].x << cloud.points[i].y
	      << " " << cloud.points[i].z << std::endl;
  }

  return 0;
}
