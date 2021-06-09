#ifndef uboot_args_H__
#define uboot_args_H__

#include <map>
#include <string>
#include <vector>

class uboot_args
{
public:
    enum error : unsigned int {
        file_permission = (1 << 0),
        crc_inconsistent = (1 << 1),
        access_crc = (1 << 2),
        access_content = (1 << 3),
        seek_fail = (1 << 4),
    };
public:
    uboot_args();
    unsigned int load(
            std::string dev_name,
            unsigned int env_offset,
            int env_size,
            char delimiter = '\0',
            char assign = '=');
    friend std::ostream & operator<<(std::ostream & s, const uboot_args & v);
    unsigned int save(
        std::string dev_name,
        unsigned int env_offset,
        int env_size,
        char delimiter = '\0',
        char assign = '=');

    unsigned int loadFile(
        std::string dev_name,
        char delimiter = '\0',
        char assign = '=');
    unsigned int saveFile(
        std::string dev_name,
        char delimiter = '\0',
        char assign = '=');

    void parse(
            const std::vector<char> &buf,
            char delimiter = '\0',
            char assign = '=');
    void toBuf(
            std::vector<char> &buf,
            char delimiter = '\0',
            char assign = '=');

private:
    std::map<std::string,std::string> args;
};

#endif

