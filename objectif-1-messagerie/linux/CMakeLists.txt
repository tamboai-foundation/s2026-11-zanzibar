cmake_minimum_required(VERSION 3.16)

project(NGoma VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appNGoma
    src/main.cpp
)

# Singletons QML : Theme (charte rouge) et MockBridge (mock du pont UI <-> TModeler)
set_source_files_properties(qml/Theme.qml qml/MockBridge.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appNGoma
    URI ai.tambo.foundation.ngoma
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/MockBridge.qml
        qml/SplashScreen.qml
        qml/AuthScreen.qml
        qml/HomeScreen.qml
        qml/ConversationView.qml
        qml/Avatar.qml
        qml/AppShell.qml
        qml/VideosScreen.qml
        qml/PeopleScreen.qml
        qml/ProfileScreen.qml
        qml/PostMiniature.qml
        qml/CommentLine.qml
    SOURCES
        src/models.h
        src/models.cpp
        src/viewmodels.hpp
)

# TModeler C++ via FetchContent (même schéma que cpp/tests/qtcreator)
include(FetchContent)

FetchContent_Declare(
    TModeler
    GIT_REPOSITORY https://github.com/TTT-GH/TModeler.git
    GIT_TAG main
    SOURCE_SUBDIR cpp
)
FetchContent_MakeAvailable(TModeler)

FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.11.2
)
FetchContent_MakeAvailable(nlohmann_json)

qt_add_resources(appNGoma "icon" PREFIX "/" FILES ngoma.png)

target_include_directories(appNGoma PRIVATE src)

set_target_properties(appNGoma PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appNGoma
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE TModeler
    PRIVATE TModelerQtAdapter
    PUBLIC nlohmann_json::nlohmann_json
)

include(GNUInstallDirs)
install(TARGETS appNGoma
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
