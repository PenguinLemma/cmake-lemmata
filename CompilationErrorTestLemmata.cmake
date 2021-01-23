#[==[.md
# `CompilationErrorTestLemmata.cmake`

This module defines a function to add tests that ensure that the code in the
source files does not compile.

## Usage
For each source file (<name>.cpp) specified in SOURCES, we 
 - create a target with name = ${prefix}_<name>
 - add it as an executable isolated from the rest of the build
 - create a test with that name that will consist on building the executable
 and asserting that the compilation failed.

```
pl_add_compilation_error_test(
    <prefix>
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

#]==]

function(pl_add_compilation_error_test prefix)
    cmake_parse_arguments(
        _pl_comp_error_test
        ""
        ""
        "SOURCES;PUBLIC_LINKED_LIBS;PRIVATE_LINKED_LIBS;COMPILE_FEATURES;PUBLIC_COMPILE_OPT;PRIVATE_COMPILE_OPT"
        ${ARGN}
    )

    foreach (testfile ${_pl_comp_error_test_SOURCES})
        # For each source file specified (<name>.cpp), we create a target with
        # name = ${prefix}_<name>
        string(REPLACE .cpp "" target ${testfile})
        string(PREPEND target "${prefix}_")

        # Add target as executable isolated from the rest of build
        add_executable(${target} "${testfile}")
        set_target_properties(
            ${target}
            PROPERTIES
                EXCLUDE_FROM_ALL true
                EXCLUDE_FROM_DEFAULT_BUILD true
                CXX_EXTENSIONS NO
        )
        target_link_libraries(
            ${target}
            PUBLIC ${_pl_comp_error_test_PUBLIC_LINKED_LIBS}
            PRIVATE ${_pl_comp_error_test_PRIVATE_LINKED_LIBS}
        )
        target_compile_features(
            ${target}
            PUBLIC ${_pl_comp_error_test_COMPILE_FEATURES}
        )
        target_compile_options(
            ${target}
            PUBLIC ${_pl_comp_error_test_PUBLIC_COMPILE_OPT}
            PRIVATE ${_pl_comp_error_test_PRIVATE_COMPILE_OPT}
        )

        # The test will consist on building the executable and must fail
        add_test(
            NAME ${target}
            COMMAND 
                ${CMAKE_COMMAND} --build "${CMAKE_BINARY_DIR}" --target ${target} --config $<CONFIGURATION>
        )
        set_tests_properties(${target} PROPERTIES WILL_FAIL true)
    endforeach()
endfunction()
