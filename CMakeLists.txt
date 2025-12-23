cmake_minimum_required(VERSION 3.16)

project(QtYomi VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. FIND PACKAGES
# Added "QuickControls2" here
find_package(Qt6 REQUIRED COMPONENTS Quick Network Sql Concurrent QuickControls2)

qt_standard_project_setup()

# 2. DEFINE EXECUTABLE
qt_add_executable(appQtYomi
    src/main.cpp
    src/MangaController.h
    src/MangaController.cpp
    src/DatabaseManager.h
    src/DatabaseManager.cpp
    src/ChapterController.h
    src/ChapterController.cpp
)

# 3. LINK LIBRARIES
# Added "Qt6::QuickControls2" here
target_link_libraries(appQtYomi
    PRIVATE
    Qt6::Quick
    Qt6::Network
    Qt6::Sql
    Qt6::Concurrent
    Qt6::QuickControls2
)

# 4. REGISTER QML MODULE
qt_add_qml_module(appQtYomi
    URI QtYomi
    VERSION 1.0
    QML_FILES
        content/App.qml
        content/ReaderView.qml
)

# 5. WINDOWS SETTINGS
if(WIN32)
    set_property(TARGET appQtYomi PROPERTY WIN32_EXECUTABLE ON)
endif()

include(GNUInstallDirs)
install(TARGETS appQtYomi
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
