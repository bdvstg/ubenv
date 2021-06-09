# ubenv, a tool to read/write uboot bootargs in linux user sapce

## build

I'm not sure cmake still works or not, if use cmake, it should be used by make.py  
Or just use gcc to direct compile it, like below:

    $CC -std=c++11 main.cpp crc32.cpp uboot_args.cpp -lstdc++ -o ubenv

## usage

First, you should know the position and size of bootargs, and in which device.
In my case, i.mx6, position is 0xc0000, size is 8192.  
I have touched two board, one is in /dev/mmcblk1, another is /dev/mmcblk3.  

    ubenv read /dev/mmcblk1 0xc0000 8192 /tmp/aaa # read ubootargs into /tmp/aaa
    # now you can edit /tmp/aaa, it just a text file
    ubenv write /tmp/aaa /dev/mmcblk1 0xc0000 8192 # write back the ubootargs

## get position, size

#### by source code

Trace the source code of uboot you are using, position should be a define named 'CONFIG_ENV_OFFSET'.  
size..., I'm forgot :)

#### by search

use tool to search string of bootargs in mmc device.  
