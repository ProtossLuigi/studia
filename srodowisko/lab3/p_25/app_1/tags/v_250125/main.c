#include "program.h"

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        program_usage();
        exit(EXIT_FAILURE);
    }

    {
        int idx = atoi(argv[1]);
        switch (idx)
        {
        case 0:
            s0_podprogram(); // podprogram studenta o numerze indeksu 0
            break;
        case 999:
            s999_podprogram(); // podprogram studenta o numerze indeksu 999
            break;
        case 250332:
            s250332_podprogram(); // student 250332
            break;
        case 250345:
            s250345_podprogram(); // podprogram studenta o numerze indeksu
                                  // 250345
            break;
        case 250346:
            s250346_podprogram(); // student 250346
            break;
            // KOD TEGO STUENDA SIĘ NIE KOMPILUJE NA TRUNKU (-1 byczq)
            //      case 250347:
            //	s250347_podprogram(); // student 250347
            //	break;
        case 244932:
            s244932_podprogram(); // student 244932
            break;
        case 250134:
            s250134_podprogram();
            break;
        case 250338:
            s250338_podprogram(); // student 250338
            break;
        case 244947:
            s244947_podprogram(); // student 244947
            break;
        case 250339:
            s250339_podprogram(); // student 250339
            break;
        case 244748:
            s244748_podprogram();
            break;
        case 250335:
            s250335_podprogram(); // student 250335
            break;
        case 250337:
            s250337_podprogram();
            break;
        case 250138:
            s250138_podprogram();
            break;
        case 250136:
            s250136_podprogram();
            break;
        case 250125:
            s250125_podprogram();
            break;
        default:
            printf(
                "\nStudent o numerze indeksu %d nie wykonał jeszcze "
                "zadania\n\n",
                idx);
            break;
        }
    }
    exit(EXIT_SUCCESS);
}
