#include <iostream>
#include <string>
#include <vector>

#include "uboot_args.h"

#define TRACE_DEBUG(...) \
    fprintf(stderr, "%d  ", __LINE__); \
    fprintf(stderr, __VA_ARGS__);

#define stoi(S) std::stoi((S),0,0)

std::string myname;

#define MyNameIs(A) myname = std::string(A)

void printHelp()
{
    const char *pgn = myname.c_str(); // program name
    printf("usage : %s [mode] [src] [dest]\n", pgn);
    printf("    [mode] : read or write\n");
    printf("    [src] : \"<dev> <offset> <size>\" or <file>\n");
    printf("    [dest] : \"<dev> <offset> <size>\" or <file>\n");
    printf("    [src] and [dest] must be different\n");
    printf("\n");
    printf("detail : \n");
    printf("    %s read <dev> <offset> <size> <file>\n", pgn);
    printf("        read args in <dev> and backup to <file>\n");
    printf("    %s write <file> <dev> <offset> <size>\n", pgn);
    printf("        restore args in <file> into <dev>\n");
    printf("    <dev> : device name\n");
    printf("    <offset> : offset of args, also CONFIG_ENV_OFFSET in *UbSrc\n");
    printf("    <size> : size of args, also CONFIG_ENV_SIZE in *UbSrc\n");
    printf("    <file> : text base args\n");
    printf("\n");
    printf("comment : \n");
    printf("    UbSrc : u-boot source code\n");
    printf("\n");
}

int main(int argc, char *argv[])
{
    MyNameIs(argv[0]);
    if (argc != 6)
        printHelp();
   
    enum class Mode { read, write, };
    Mode mode;
    if (std::string(argv[1]) == "read") mode = Mode::read;
    else if (std::string(argv[1]) == "write") mode = Mode::write;
    else
    {
        printf("error : mode is wrong...\n\n\n");
        printHelp();
        return -1;
    }

    std::string dev, file;
    int offset, size;
    if (mode == Mode::read)
    {
        dev = argv[2];
        offset = stoi(argv[3]);
        size = stoi(argv[4]);
        file = argv[5];
    }
    else // (mode == Mode::write)
    {
        file = argv[2];
        dev = argv[3];
        offset = stoi(argv[4]);
        size = stoi(argv[5]);
    }

    TRACE_DEBUG("device = %s, offset(%d), size(%d)\n",
        dev.c_str(), offset, size);    
    TRACE_DEBUG("file = %s\n", file.c_str());

    uboot_args args;
    if (mode == Mode::read)
    {   
        args.load(dev, offset, size);
        std::cout << args;
        args.saveFile(file, '\x0a');
    }
    else // (mode == Mode::write)
    {
        args.loadFile(file, '\x0a');
        std::cout << args;
        args.save(dev, offset, size);
    }
    return 0;
}
