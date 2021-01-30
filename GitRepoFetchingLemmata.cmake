#[==[.md
# `GitRepoFetchingLemmata`

This module defines functions to fetch git repos and make
them available to the project.

NOTE: required CMake version needs to be >= 3.14, since we are
using FetchContent_MakeAvailable

## Usage

### Checkout a tag in a git repo without caching.
This means that the tag will be checked out inside the build
directory, so every time we clean that directory for a clean
build, the clone+checkout will take place
```
pl_fetch_git_repo_tag(
    <name>
    GIT_REPO <link to repo>
    GIT_TAG <tag>
)
```

### Checkout a tag from a git repo and keep local cache.
In this case, the git tag will be checked out in
${CACHE_ROOT}/${name}/${GIT_TAG}, and if that directory
exists, no clone+checkout will happen.

```
pl_fetch_git_repo_tag_cached(
    <name>
    GIT_REPO <link to repo>
    GIT_TAG <tag>
    CACHE_ROOT <path/to/local/cache>
)
```

#]==]

function (pl_fetch_git_repo_tag_cached name)
    cmake_parse_arguments(
        _pl_git_tag_cached
        ""
        "GIT_REPO;GIT_TAG;CACHE_ROOT"
        ""
        ${ARGN}
    )

    set(_pl_git_tag_cached_source_dir 
        ${_pl_git_tag_cached_CACHE_ROOT}/${name}/${_pl_git_tag_cached_GIT_TAG}
    )

    if (EXISTS ${_pl_git_tag_cached_source_dir})
        # In this case, we only need to declare the contents of the already
        # existing directory
        FetchContent_Declare(
            ${name}
            SOURCE_DIR ${_pl_git_tag_cached_source_dir}
            BINARY_DIR ${_pl_git_tag_cached_source_dir}/build
            TEST_EXCLUDE_FROM_MAIN True
        )
    else()
        FetchContent_Declare(
            ${name}
            GIT_REPOSITORY  
                ${_pl_git_tag_cached_GIT_REPO}
            GIT_TAG
                ${_pl_git_tag_cached_GIT_TAG}
            SOURCE_DIR
                ${_pl_git_tag_cached_source_dir}
            BINARY_DIR
                ${_pl_git_tag_cached_source_dir}/build
            TEST_EXCLUDE_FROM_MAIN True
        )
    endif()
    
    FetchContent_MakeAvailable(${name})
endfunction()

function (pl_fetch_git_repo_tag name)
    cmake_parse_arguments(
        _pl_git_tag
        ""
        "GIT_REPO;GIT_TAG"
        ${ARGN}
    )

    FetchContent_Declare(
        ${name}
        GIT_REPOSITORY  ${_pl_git_tag_GIT_REPO}
        GIT_TAG         ${_pl_git_tag_GIT_TAG}
    )

    FetchContent_MakeAvailable(${name})
endfunction()
