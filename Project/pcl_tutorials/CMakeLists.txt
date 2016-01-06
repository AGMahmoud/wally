cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

project(pcl_guide)

find_package(PCL 1.7 REQUIRED)

include_directories(${PCL_INCLUDE_DIRS})
link_directories(${PCL_LIBRARY_DIRS})
add_definitions(${PCL_DEFINITIONS})

add_executable(pcd_write src/pcd_write.cpp)
target_link_libraries(pcd_write ${PCL_COMMON_LIBRARIES} ${PCL_IO_LIBRARIES})

add_executable(voxel_grid src/voxel_grid.cpp)
target_link_libraries(voxel_grid ${PCL_LIBRARIES})