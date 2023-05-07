#!/usr/bin/env bash
# build gcc
CUR_PATH=$(pwd)
ROOT_PATH=$(realpath ${CUR_PATH}/..)

GCC7_SRC=${ROOT_PATH}/gcc-7.3.0
GCC8_SRC=${ROOT_PATH}/gcc-8.3.0
GCC9_SRC=${ROOT_PATH}/gcc-9.3.0
GCC10_SRC=${ROOT_PATH}/gcc-10.3.0
GCC13_SRC=${ROOT_PATH}/gcc-13.1.0
GCC_SRC=""
GCC_DOWNLOAD_LINK=""

GCC7_DOWNLOAD_LINK="https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-7.3.0/gcc-7.3.0.tar.gz"
GCC8_DOWNLOAD_LINK="https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-8.3.0/gcc-8.3.0.tar.gz"
GCC9_DOWNLOAD_LINK="https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-9.3.0/gcc-9.3.0.tar.gz"
GCC10_DOWNLOAD_LINK="https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.gz"
GCC13_DOWNLOAD_LINK="https://mirrors.sjtug.sjtu.edu.cn/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.gz"
BUILD_TYPE="debug"
BUILD_VERSION="10"

SUPPORT_VERSION="7 8 9 10 13"
SUPPORT_TYPE="debug release"
PREFIX=""

function download_compiler
{
    cd $ROOT_PATH
    declare -u upper_case="$1"

    if [[ ! -f ${upper_case}_SRC.tar.gz ]]; then
	wget -O ${upper_case}_SRC.tar.gz ${${upper_case}_DOWNLOAD_LINK}
	if [[ $? -ne 0 ]]; then
	    echo "download ${${upper_case}_DOWNLOAD_LINK} failed."
	    return 1
	fi
    fi
    return 0
}

function print_usage
{
    echo "Usage:
    	 $0 -v <7/8/9/10/12/13>  -t <debug/release>"
}

function check_args
{
    if [[ ! "$SUPPORT_VERSION" =~ "$BUILD_VERSION" ]]; then
	echo "not supoort version $BUILD_VERSION"
	return 1
    fi
    if [[ ! "$SUPPORT_TYPE" =~ "$BUILD_TYPE" ]]; then
	echo "not supoort type $BUILD_TYPE"
	return 1
    fi
    echo "check ok"
    return 0
}

function build_gcc
{
    check_args || return 1
    case $BUILD_VERSION in
	"7")
	    GCC_SRC="$GCC7_SRC"
	    GCC_DOWNLOAD_LINK="$GCC7_DOWNLOAD_LINK"
	    ;;
	"8")
	    GCC_SRC="$GCC8_SRC"
	    GCC_DOWNLOAD_LINK="$GCC8_DOWNLOAD_LINK"
	    ;;
	"9")
	    GCC_SRC="$GCC9_SRC"
	    GCC_DOWNLOAD_LINK="$GCC9_DOWNLOAD_LINK"
	    ;;
	"10")
	    GCC_SRC="$GCC10_SRC"
	    GCC_DOWNLOAD_LINK="$GCC10_DOWNLOAD_LINK"
	    ;;
	"13")
	    GCC_SRC="$GCC13_SRC"
	    GCC_DOWNLOAD_LINK="$GCC13_DOWNLOAD_LINK"
	    ;;
    esac
    PREFIX="$GCC_SRC-install"

    cd $ROOT_PATH
    if [[ ! -e $GCC_SRC.tar.gz ]]; then
	wget $GCC_DOWNLOAD_LINK || { echo "download failed, $GCC_DOWNLOAD_LINK"; return 1; }
    fi
    if [[ ! -d $GCC_SRC ]]; then
	tar -xf $GCC_SRC.tar.gz
    fi
    cd $GCC_SRC
    rm -rf build
    mkdir build
    cd build
    ../configure \
	--prefix=$PREFIX \
	--disable-nls \
	--with-gcc-major-version-only \
	--enable-languages=c,c++,lto \
	--enable-plugin \
	--enable-lto \
	--disable-bootstrap \
	--disable-multilib || return 1
    

    if [[ $BUILD_TYPE == "debug" ]]; then
	make -j16 STAGE1_CFLAGS="-g3 -O0" all-stage1 || return 1
	make -j16 CXXFLAGS="-g3 -O0" || return 1
	make install || return 1
    else
	make -j16 || return 1
	make install || return 1
    fi
    

    return 0
}

function main
{
    if [[ $# -ne 4 ]]; then
	print_usage
	exit 1
    fi
    
    while getopts ':t:v:' OPTION; do
	case "$OPTION" in
	    t)
		BUILD_TYPE="$OPTARG"
		echo "build type: $BUILD_TYPE"
		;;
	    v)
		BUILD_VERSION="$OPTARG"
		echo "build version: $BUILD_VERSION"
		;;
	    ?)
	    print_usage
	    exit 1
	    ;;
	esac
    done
    build_gcc || { print_usage; exit 1; }
}

main $@
