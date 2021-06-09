#!/usr/bin/env python

import argparse
import distutils.spawn
import os
import platform
import shutil
import subprocess
import sys

DEFAULT_BUILD_DIR = ".build"
STAGE_LIST = [
    "clean",
    "config",
    "clean_config",
    "build",
    "clean_config_build",
    "install"
]

def clean(args):
    if os.path.exists(args.dir) :
        shutil.rmtree(args.dir, True)

def config( args ) :
    if not args.desktop and \
       not args.prosense:
        raise RuntimeError(
            "Need to specify platform flag.")

    if not os.path.exists( args.dir ) :
        os.mkdir( args.dir )

    if not distutils.spawn.find_executable( "cmake" ) :
        raise RuntimeError( "Failed to find CMake" )

    cmake_args = []
    
    if args.prefix is not None:
        cmake_args += [
            "-DCMAKE_INSTALL_PREFIX={0}".format(args.prefix)
        ]

    if args.prosense:
        if "LINARO_TOOLCHAIN_PREFIX" not in os.environ:
            raise RuntimeError("Environment variable "
                "LINARO_TOOLCHAIN_PREFIX is not defined")
        if "PROSENSE_ROOTFS_DIR" not in os.environ:
            raise RuntimeError("Environment variable PROSENSE_ROOTFS_DIR "
                "is not defined")

        os.environ["PKG_CONFIG_LIBDIR"] = \
            "{0}/usr/lib/pkgconfig".format(
                os.environ["PROSENSE_ROOTFS_DIR"])
        os.environ["PKG_CONFIG_SYSROOT_DIR"] = \
            os.environ["PROSENSE_ROOTFS_DIR"]

        cmake_args += [
                "-DTARGET_ROOTFS_DIR={0}".format(
                    os.environ["PROSENSE_ROOTFS_DIR"]),
        ]

        cmake_args += [
                "-DCMAKE_BUILD_TYPE=Debug",
        ]
        
        cmake_args += [
            "-DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/linaro.cmake",
        ]
        
    #if args.desktop:
    #    raise RuntimeError( "desktop is not supported" )

    os.chdir( args.dir )
    subprocess.call( [ "cmake" ] + cmake_args + [ ".." ] )
    os.chdir( ".." )

def clean_config( args ) :
    clean(args)
    config(args)

def build( args ) :
    cmdLine = [ "cmake", "--build", args.dir ]
    if args.target != None :
        cmdLine += [ "--target", args.target ]
    if int(args.jobs) > 0:
        cmdLine += ["--", "-j", args.jobs]
    subprocess.call( cmdLine )

def install( args ) :
    os.chdir(args.dir)
    cmdLine = [ "make", "install"]
    subprocess.call( cmdLine )

def clean_config_build( args ) :
    clean_config( args )
    build( args )

def main() :
    parser = argparse.ArgumentParser()
    parser.add_argument( "stage",
        metavar="<stage>",
        choices=STAGE_LIST,
        help="Which stage to proceed with. \
            Available stages: " + str( STAGE_LIST ).strip( "[]" ) )
    parser.add_argument( "-t", "--target",
        help="Name of the target that need to be processed." )
    parser.add_argument( "-d", "--dir",
        help="Build directory. Defult: " + DEFAULT_BUILD_DIR,
        default=DEFAULT_BUILD_DIR )
    parser.add_argument( "--desktop",
        help="Build desktop application.",
        action="store_true" )
    parser.add_argument("--prosense",
        help="Build prosense application",
        action="store_true")
    parser.add_argument("--prefix",
        help="Installation prefix")
    parser.add_argument("--develop",
        help="Enable development features",
        action="store_true")
    parser.add_argument("--jobs", "-j",
        help="Number of parallel jobs",
        default=0)
    
    if len( sys.argv ) == 1 :
        parser.print_help()
        sys.exit( 1 )

    args = parser.parse_args()

    globals()[ args.stage ]( args )

if __name__ == '__main__' :
    main()
