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
		case 250127:
			s250127_podprogram(); // podprogram studenta o numerze indeksu 250127
			break;        
		case 250332:
            s250332_podprogram(); // student 250332
            break;
        case 242639:
            s242639_podprogram(); // student 242639
            break;
	case 250342:
	    s250342_podprogram(); // podprogram studenta o numerze indeksu 250127
	    break;
        case 250344:
            s250344_podprogram(); // podprogram studenta o numerze indeksu 250344
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
        case 243434:
            s243434_podprogram(); // student 243434
            break;
		case 244949:
            s244949_podprogram(); // student 244949
            break;
        case 231236:
            s231236_podprogram(); // student 231236
            break; 
        case 250135:
            s250135_podprogram(); // student 250135
            break;
	case 250349:
	    s250349_podprogram(); // student 250349
	    break;
        case 244931:
            s244931_podprogram(); // podprogram studenta o numerze indeksu 244931
            break;
	case 251536:
            s251536_podprogram(); // podprogram studenta o numerze indeksu 251536
            break;
      	case 245128:
            s245128_podprogram(); // sudent 245128
            break;
	case 244946:
            s244946_podprogram(); // student 244946
            break;
	case 250542:
	    s250542_podprogram(); 
	    break;
	case 244930:
	    s244930_podprogram(); // podprogram studenta o numerze indeksu 244930
	    break;
	case 244747:
	    s244747_podprogram();
	    break;
	case 250131:
	    s250131_podprogram();// podprogram studenta o numerze indeksu 250131
	    break;
	case 244941:
	    s244941_podprogram();
	    break;
	case 236542:
	    s236542_podprogram();
	    break;
	case 250130:
	    s250130_podprogram();
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
