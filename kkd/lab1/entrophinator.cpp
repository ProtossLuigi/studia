#include<array>
#include<iostream>
#include <fstream>
#include <math.h>
#include <vector>
//#include <unistd.h>

#define CHAR_SIZE 1<<8
#define CHAR2_SIZE 1<<16

int main(int argc, char** argv){
    std::string filename;

    if (argc > 1)
    {
        filename = std::string(argv[1]);
    }

    int total_char_count = 0;
    unsigned char prev_char = 0;
    std::vector<int> char_count(CHAR_SIZE, 0), prev_char_count(CHAR2_SIZE,0);
    long double char_prob[CHAR_SIZE], prev_char_prob[CHAR2_SIZE];
    
    //std::ifstream ifs (filename, std::ios::binary | std::ios::in);
    // FILE *f = fopen(filename.c_str(), "rb");
    // std::array<uint8_t, 8192> buf;
    // for (size_t len; len = fread(&buf[0], 1, buf.size(), f); len != 0) {
    //     for (size_t i=0; i < len;i++) {
    //         curr = buf[i];
    //         std::cout << ".";
    //         total_char_count++;
    //         char_count[curr]++;
    //         prev_char_count[(curr << 8) + prev_char]++;
    //         prev_char = curr;
    //     }
    // }
    

    /*std::cout << "cos dziala";

    for (int i=0; i<len; i++)
    {
        curr = buf[i];
        //std::cout << ".";
        total_char_count++;
        char_count[curr]++;
        prev_char_count[(curr << 8) + prev_char]++;
        prev_char = curr;
    }
    std::cout << ",";
*/
    std::ifstream input(filename, std::ios::binary);

    std::vector<char> bytes(
         (std::istreambuf_iterator<char>(input)),
         (std::istreambuf_iterator<char>()));

    input.close();

    //std::cout << "Dupa1" << std::endl;

    for (unsigned char byte : bytes)
    {
        total_char_count++;
        char_count[byte]++;
        prev_char_count[(byte << 8) + prev_char]++;
        prev_char = byte;
    }

    if (total_char_count == 0)
    {
        return 1;
    }
    
    for (int i = 0; i < CHAR_SIZE; i++)
    {
        char_prob[i] = char_count[i]/(long double)total_char_count;
        if (char_prob[i] > 0.0)
        {
            std::cout << "P( " << i << " ) = " << char_prob[i] << std::endl;
        }
    }
    for (int i = 0; i < CHAR2_SIZE; i++)
    {
        if (char_count[i % (CHAR_SIZE)] > 0){
            prev_char_prob[i] = prev_char_count[i]/(long double)char_count[i % (CHAR_SIZE)];
        } else {
            prev_char_prob[i] = 0.0;
        }
        if (prev_char_prob[i] > 0.0)
        {
            std::cout << "P( " << (i>>8) << " | " << i%(CHAR_SIZE) << " ) = " << prev_char_prob[i] << std::endl;
        }
    }
    
    long double H = 0,Hc;
    for (int i = 0; i < CHAR_SIZE; i++)
    {
        if (char_prob[i] > 0.0)
        {
            H -= char_prob[i] * log2(char_prob[i]);
        }
    }
    std::cout << "Entropia: " << H << std::endl;

    H = 0;
    for (int i = 0; i < CHAR_SIZE; i++)
    {
        Hc = 0;
        for (int j = 0; j < CHAR_SIZE; j++)
        {
            if (prev_char_prob[(j << 8) + i] > 0.0)
            {
                Hc -= prev_char_prob[(j << 8) + i] * log2(prev_char_prob[(j << 8) + i]);
            }
        }
        H += char_prob[i] * Hc;
    }
    std::cout << "Entropia warunkowa: " << H << std::endl;

    //delete[] buf;
}