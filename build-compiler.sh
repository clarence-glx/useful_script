#!/usr/bin/bash
# compile llvm and gcc
# ./build-compiler.sh <llvm15/gcc7/gcc8/gcc9> <debug/release/rel(only for llvm)>

ROOT_PATH=$(pwd)
GCC7_SRC=$ROOT_PATH/gcc-7.3.0
GCC8_SRC=$ROOT_PATH/gcc-8.3.0
GCC9_SRC=$ROOT_PATH/gcc-9.3.0
LLVM15_SRC=$ROOT_PATH/llvm-project-llvmorg-15.0.5

LLVM15_DOWNLOAD_LINK="https://codeload.github.com/llvm/llvm-project/tar.gz/refs/tags/llvmorg-15.0.5"
GCC7_DOWNLOAD_LINK="https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz"
GCC8_DOWNLOAD_LINK="https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-8.3.0/gcc-8.3.0.tar.gz"
GCC9_DOWNLOAD_LINK="https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-9.3.0/gcc-9.3.0.tar.gz"

function check_file
{
    echo $1
    if [[ $1 == "llvm15" ]]; then
	if [[ ! -f $LLVM15_SRC.tar.gz ]]; then
	    wget -O $LLVM15_SRC.tar.gz $LLVM15_DOWNLOAD_LINK
	    if [[ $? -ne 0 ]]; then
		echo "download $LLVM15_DOWNLOAD_LINK failed."
		exit 1
	    fi
	fi
    fi
    if [[ $1 == "gcc7" ]]; then
	if [[ ! -f $GCC7_SRC.tar.gz ]]; then
	    wget -O $GCC7_SRC.tar.gz $GCC7_DOWNLOAD_LINK
	    if [[ $? ]]; then
		echo "download $GCC7_DOWNLOAD_LINK failed."
		exit 1
	    fi
	fi
    fi
    if [[ $1 == "gcc8" ]]; then
	if [[ ! -f $GCC8_SRC.tar.gz ]]; then
	    wget -O $GCC8_SRC.tar.gz $GCC8_DOWNLOAD_LINK
	    if [[ $? ]]; then
		echo "download $GCC8_DOWNLOAD_LINK failed."
		exit 1
	    fi
	fi
    fi
    if [[ $1 == "gcc9" ]]; then
	if [[ ! -f $GCC9_SRC.tar.gz ]]; then
	    wget -O $GCC8_SRC.tar.gz $GCC9_DOWNLOAD_LINK
	    if [[ $? ]]; then
		echo "download $GCC9_DOWNLOAD_LINK failed."
		exit 1
	    fi
	fi
    fi
}

function check_del_tar_dir
{
    if [[ -d $1 ]]; then
	echo "rm $1"
	rm -rf $1
	tar -xf $1.tar.gz
    fi
}

function build_gcc_common
{
    echo "build_gcc_common"
}

function build_gcc7
{
    echo "build_gcc7 $1"
    check_file gcc7
    check_del_tar_dir $GCC7_SRC
    
}

function build_gcc8
{
    echo "build_gcc8 $1"
    check_file gcc8
    check_del_tar_dir $GCC8_SRC
}

function build_gcc9
{
    echo "build_gcc9 $1"
    check_file gcc9
    check_del_tar_dir $GCC9_SRC
}

function build_llvm15
{
    echo "build_llvm15 $1"
    check_file llvm15
    check_del_tar_dir $LLVM15_SRC
    tar -xf $LLVM15_SRC.tar.gz
    rm -rf ./build
    build_type=""
    if [[ $1 == "debug" ]]; then
	build_type="Debug"
    elif [[ $1 == "release" ]]; then
	build_type="Release"
    elif [[ $1 == "rel" ]]; then
	build_type="RelWithDebInfo"
    fi
    
    cmake -G "Ninja" -S $LLVM15_SRC -B ./build \
	  -DCMAKE_INSTALL_PREFIX=$LLVM15_SRC/../llvm15-$1-install \
	  -DCMAKE_BUILD_TYPE=$build_type \
	  -DCMAKE_CXX_COMPILER=`which clang++` \
	  -DCMAKE_C_COMPILER=`which clang ` \
	  -DLLVM_ENABLE_PROJECTS="clang;lld" \
	  -DLLVM_TARGETS_TO_BUILD=X86 \
	  -DBUILD_SHARED_LIBS=ON \
	  -DLLVM_USE_LINKER=lld \
	  -DLLVM_USE_SPLIT_DWARF=ON \
	  -DLLVM_OPTIMIZED_TABLEGEN=ON \
	  -Wno-dev \
	  $LLVM15_SRC/llvm
    pushd ./build > /dev/null
    ninja all
    ninja install
    popd > /dev/null
}

function echo_usage
{
    echo "Usage:
    	 $0 <llvm15/gcc7/gcc8/gcc9> <debug/release/rel>"
}

function main
{
    if [[ $# -eq 2 ]]; then
	if [[ $1 == "llvm15" || $1 == "gcc7" || $1 == "gcc8" || $1 == "gcc9" ]]; then
	    TO_BUILD="$1"
	else
	    echo_usage
	    exit 1
	fi
	if [[ $2 == "debug" || $2 == "release" || $2 == "rel" ]]; then
	    TO_BUILD_TY="$2"
	else
	    echo_usage
	    exit 1
	fi
    else
	echo_usage
	exit 1
    fi
    if [[ $TO_BUILD_TY == "rel" && $TO_BUILD != "llvm15" ]]; then
	echo "RelWithDebInfo is only for llvm"
	exit 1
    fi
    
    build_$1 $2
}

main $@
