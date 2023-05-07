#!/usr/bin/bash

ROOT=$PWD
C_COMPILER_PATH="/usr/bin/clang"
CXX_COMPILER_PATH="/usr/bin/clang++"
LLVM_ENABLE_PROJECTS="clang"

declare -r LLVM_TAG="llvmorg-15.0.7"
LLVM_DOWNLOAD_LINK="https://codeload.github.com/llvm/llvm-project/tar.gz/refs/tags/$LLVM_TAG"
declare -r LLVM_SRC=$ROOT/llvm-project-$LLVM_TAG

function download_llvm
{
    if [[ ! -f $LLVM_SRC.tar.gz ]]; then
	echo "starting downloading llvm..."
	wget -O llvm-project-$LLVM_TAG.tar.gz $LLVM_DOWNLOAD_LINK
    fi
}

function build_llvm
{
    if [[ ! -d $LLVM_SRC ]]; then
	tar -xf $LLVM_SRC.tar.gz
    fi
    cd $LLVM_SRC
    if [[ -d build ]]; then
	rm -rf  build
    fi
    mkdir -p build && cd build
    cmake -G "Ninja" \
	  -DCMAKE_INSTALL_PREFIX="$ROOT/llvm_install" \
	  -DLLVM_USE_LINKER=lld \
	  -DLLVM_ENABLE_PROJECTS=$LLVM_ENABLE_PROJECTS \
	  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
	  -DLLVM_TARGETS_TO_BUILD="X86" \
	  -DBUILD_SHARED_LIBS=ON \
	  -DLLVM_USE_SPLIT_DWARF=ON \
	  -DLLVM_OPTIMIZED_TABLEGEN=ON \
	  -DCMAKE_CXX_COMPILER=$CXX_COMPILER_PATH \
	  -DCMAKE_C_COMPILER=$C_COMPILER_PATH \
	  ../llvm
    ninja all || exit 1
    ninja install || exit 1
}

function main
{
    download_llvm
    build_llvm
}

main $@
