cmake_minimum_required(VERSION 3.15)

project(CORE VERSION 0.0 DESCRIPTION "Core" LANGUAGES CXX C)

file(GLOB_RECURSE _SRC ${PROJECT_SOURCE_DIR}/Src/*.cpp ${PROJECT_SOURCE_DIR}/Inc/*.h)

#target_include_directories(Core PUBLIC Inc ../Vorbis/vorbis/include ../Vorbis/ogg/include)
#target_compile_definitions(Core PRIVATE DO_CHECK=1 DO_CHECK_SLOW=0)

add_library(Core SHARED ${_SRC})
target_link_libraries(Core PRIVATE winmm)
target_include_directories(Core PUBLIC Inc ../Vorbis/vorbis/include ../Vorbis/ogg/include)
