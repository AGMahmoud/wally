/**
   @file voxel_grid.cpp
   @brief downsampling a PointCloud

   @author TagerillWong<buaaben@163.com>
   @version 1.0
   @date 2016-01-06
*/


#include <iostream>
#include <pcl-1.7/pcl/io/pcd_io.h>
#include <pcl-1.7/pcl/point_types.h>
#include <pcl-1.7/pcl/filters/voxel_grid.h>

int main(int argc, char *argv[])
{
  pcl::PCLPointCloud2::Ptr cloud(new pcl::PCLPointCloud2());
  pcl::PCLPointCloud2::Ptr cloud_filtered(new pcl::PCLPointCloud2());

  pcl::PCDReader reader;
  reader.read("../data/table_scene_lms400.pcd", *cloud);

  std::cerr << "Points before filtering: " << cloud->width * cloud->height
	    << " data points(" << pcl::getFieldsList(*cloud) << ").";

  pcl::VoxelGrid<pcl::PCLPointCloud2> sor;
  sor.setInputCloud(cloud);
  sor.setLeafSize(0.01f, 0.01f, 0.01f);
  sor.filter(*cloud_filtered);

  std::cerr << "PointCloud after filtering: " << cloud_filtered->width * cloud_filtered->height
	    << " data points(" << pcl::getFieldsList(*cloud_filtered) << ").";

  pcl::PCDWriter writer;
  writer.write("../data/table_scene_lms400_downsampled.pcd", *cloud_filtered,
	       Eigen::Vector4f::Zero(), Eigen::Quaternionf::Identity(), false);

  return 0;
}
