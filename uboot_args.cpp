#include "uboot_args.h"

#include "crc32.h"

#include <algorithm>
#include <cassert>
#include <iostream>
#include <string.h>

static size_t get_file_size(FILE *f)
{
    auto pos = ftell(f); // backup position
    auto c1 = fseek(f, 0, SEEK_END); // jump to end
    auto filesize = ftell(f); // file size
    auto c2 = fseek(f, 0, SEEK_SET); // restore position
    return filesize;
}

uboot_args::uboot_args()
{
}

std::ostream & operator<<(std::ostream & s, const uboot_args & v)
{
    for(auto p : v.args)
        s << p.first << "=" << p.second << std::endl;
    return s;
}

void uboot_args::parse(
        const std::vector<char> &buf,
        char delimiter,
        char assign)
{
    std::vector<char> d = {delimiter}; // delimiter
    for(int i = 0 ; i < buf.size() ; i++)
    {
        auto end = std::find_first_of(buf.begin() + i, buf.end(),
                d.begin(), d.end());
        int len = end - buf.begin() - i;
        std::string record(&buf[i], len);
        if(record.size() <= 0) break;

        auto s = record.find_first_of(assign);
        auto key = record.substr(0, s);
        auto value = record.substr(s+1);
        args[key] = value;

        i += record.size();
    }
}

// convert args into buf
// if buf.size greater than zero
//     and if size of args smaller than buf.size
//         it will copy args into buf
//     else it will throw exception by assertion
// if buf.size is zero, args will push_back into buf
void uboot_args::toBuf(
    std::vector<char> &buf,
    char delimiter,
    char assign)
{
    enum class Mode { insert, copy };
    Mode mode = buf.size() <= 0 ? Mode::insert : Mode::copy; // insert : copy

    if (mode == Mode::copy) // if(copy)
    {// check buf.size is enough or not
        int totalSize = 0;
        for (auto var : args)
            totalSize += var.first.size() + var.second.size() + 2;
        assert(totalSize <= buf.size());
    }

    int i = 0;
    for (auto var : args)
    {
        auto key = var.first;
        auto value = var.second;
        auto record = key + assign + value + delimiter;
        if (mode == Mode::insert)
            buf.insert(buf.end(), record.begin(), record.end());
        else // (mode == Mode::copy)
            memcpy(&buf[i], record.data(), record.size());

        i += record.size();
    }
}

unsigned int uboot_args::loadFile(
    std::string filename,
    char delimiter,
    char assign)
{
    unsigned int ret = 0;
    auto f = fopen(filename.c_str(), "rb");
    if (f == nullptr) return error::file_permission;

    auto filesize = get_file_size(f);
    std::vector<char> buf(filesize);
    auto count = fread(buf.data(), buf.size(), 1, f);
    if (count != 1) ret += error::access_content;
    fclose(f);

    parse(buf, delimiter, assign);

    return ret;
}

unsigned int uboot_args::saveFile(
    std::string filename,
    char delimiter,
    char assign)
{
    unsigned int ret = 0;
    auto f = fopen(filename.c_str(), "wb");

    std::vector<char> buf;
    toBuf(buf, delimiter, assign);
    auto count = fwrite(buf.data(), buf.size(), 1, f);
    if (count != 1) ret += error::access_content;
    fclose(f);
    return ret;
}

unsigned int uboot_args::load(
        std::string dev_name,
        unsigned int env_offset,
        int env_size,
        char delimiter,
        char assign)
{   
    unsigned int ret = 0;

    int res;
    
    auto f = fopen(dev_name.c_str(), "rb");
    if( f == nullptr ) return error::file_permission;

    res = fseek(f, env_offset, SEEK_SET);
    if(res != 0) ret += error::seek_fail;

    unsigned int crc, ccrc;
    
    res = fread(&crc, 4, 1, f);
    if (res != 1) ret += error::access_crc;

    std::vector<char> buf(env_size - 4);
    res = fread(buf.data(), buf.size(), 1, f);
    if(res != 1) ret += error::access_content;
    fclose(f);

    ccrc = crc32buf(buf.data(), buf.size());
    if (ccrc != crc) ret += error::crc_inconsistent;

    parse(buf, delimiter, assign);

    return ret;
}

unsigned int uboot_args::save(
    std::string dev_name,
    unsigned int env_offset,
    int env_size,
    char delimiter,
    char assign)
{
    unsigned int ret = 0;

    int res;

    std::vector<char> buf(env_size - 4, 0);
    toBuf(buf, delimiter, assign);

    auto f = fopen(dev_name.c_str(), "r+b");
    if( f == nullptr ) return error::file_permission;

    res = fseek(f, env_offset, SEEK_SET);
    if(res != 0) ret += error::seek_fail;

    auto ccrc = crc32buf(buf.data(), buf.size());
    res = fwrite(&ccrc, 4, 1, f);
    if (res != 1) ret += error::access_crc;

    res = fwrite(buf.data(), buf.size(), 1, f);
    if(res != 1) ret += error::access_content;
    fclose(f);

    return ret;
}
