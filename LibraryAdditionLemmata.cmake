#[==[.md
# `LibraryAdditionLemma`

This module includes functions to add libraries

NOTE: required CMake version needs to be > 3.5, so that
it is not necessary to include any module as command
`cmake_parse_arguments` is already built in

## Usage

### Adding a header-only library

```
pl_add_header_only_library(
    <lib-name>
    NAMESPACE
        <namespace>
    BUILD_INTERFACE_VALUE
        <value>
    INSTALL_INTERFACE_VALUE
        <value>
    SOURCES
        <file-1>
        ...
        <file-n>
    LINKED_LIBS
        <lib-1>
        ...
        <lib-m>
    COMPILE_FEATURES
        <feat-1>
        ...
        <feat-k>

)
```
Note that `BUILD_INTERFACE_VALUE` will be set to `${CMAKE_CURRENT_SOURCE_DIR}/include`
and `INSTALL_INTERFACE_VALUE` to `include` if they are not present.

### Adding a static library

```
pl_add_static_library(
    <lib-name>
    NAMESPACE
        <namespace>
    BUILD_INTERFACE_VALUE
        <value>
    INSTALL_INTERFACE_VALUE
        <value>
    SOURCES
        <file-1>
        ...
        <file-n>
    PUBLIC_LINKED_LIBS
        <public-lib-1>
        ...
        <public-lib-m>
    PRIVATE_LINKED_LIBS
        <private-lib-1>
        ...
        <private-lib-k>
    COMPILE_FEATURES
        <comp-feature-1>
        ...
        <comp-feature-r>
    PUBLIC_COMPILE_OPT
        <public-comp-option-1>
        ...
        <public-comp-option-s>
    PRIVATE_COMPILE_OPT
        <private-comp-option-1>
        ...
        <private-comp-option-q>
)
```

#]==]

function (pl_add_header_only_library name)
    cmake_parse_arguments(
        _pl_header_only
        ""
        "NAMESPACE;BUILD_INTERFACE_VALUE;INSTALL_INTERFACE_VALUE"
        "SOURCES;LINKED_LIBS;COMPILE_FEATURES"
        ${ARGN}
    )
    if(NOT DEFINED _pl_header_only_BUILD_INTERFACE_VALUE)
        set(BUILD_INTERFACE_VALUE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    endif()
    if (NOT DEFINED _pl_header_only_INSTALL_INTERFACE_VALUE)
        set(INSTALL_INTERFACE_VALUE include)
    endif()

    add_library(${name} INTERFACE)

    target_sources(${name} INTERFACE ${_pl_header_only_SOURCES})

    target_include_directories(
        ${name}
        INTERFACE
        $<BUILD_INTERFACE:${_pl_header_only_BUILD_INTERFACE_VALUE}>
        $<INSTALL_INTERFACE:${_pl_header_only_INSTALL_INTERFACE_VALUE}>
    )

    target_link_libraries(${name} INTERFACE ${_pl_header_only_LINKED_LIBS})

    target_compile_features(
        ${name}
        INTERFACE ${_pl_header_only_COMPILE_FEATURES}
    )

    add_library(${_pl_header_only_NAMESPACE}::${name} ALIAS ${name})
endfunction()


function (pl_add_static_library name)
    cmake_parse_arguments(
        _pl_static_lib
        ""
        "NAMESPACE;BUILD_INTERFACE_VALUE;INSTALL_INTERFACE_VALUE"
        "SOURCES;PUBLIC_LINKED_LIBS;PRIVATE_LINKED_LIBS;COMPILER_FEATURES;PUBLIC_COMPILER_OPT;PRIVATE_COMPILER_OPT"
        ${ARGN}
    )
    if(NOT DEFINED _pl_static_lib_BUILD_INTERFACE_VALUE)
        set(BUILD_INTERFACE_VALUE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    endif()
    if (NOT DEFINED _pl_static_lib_INSTALL_INTERFACE_VALUE)
        set(INSTALL_INTERFACE_VALUE include)
    endif()

    add_library(${name} STATIC ${_pl_static_lib_SOURCES})

    target_include_directories(
        ${name}
        PUBLIC
        $<BUILD_INTERFACE:${_pl_static_lib_BUILD_INTERFACE_VALUE}>
        $<INSTALL_INTERFACE:${_pl_static_lib_INSTALL_INTERFACE_VALUE}>
    )

    target_link_libraries(
        ${name}
        PUBLIC ${_pl_static_lib_PUBLIC_LINKED_LIBS}
        PRIVATE ${_pl_static_lib_PRIVATE_LINKED_LIBS}
    )

    target_compile_features(${name} PUBLIC ${_pl_static_lib_COMPILE_FEATURES})

    target_compile_options(
        ${name}
        PUBLIC ${_pl_static_lib_PUBLIC_COMPILE_OPT}
        PRIVATE ${_pl_static_lib_PRIVATE_COMPILE_OPT}
    )

    add_library(${_pl_static_lib_NAMESPACE}::${name} ALIAS ${name})
endfunction()
