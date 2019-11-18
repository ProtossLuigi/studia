//#include <foo/*bar*/baz.h> // this is a test
//#include "test/*asdf*/header.h"
//#include <stdio.h>

/** \brief DOC 1 Java style Doc String - Foo function */
int foo();
SHOW 1
int bar(); /**< Bar DOC 2 function */

/// .NET Style DOC 3 String
int g_global_var = 1;

/* Hello COM 1
/* World COM 2
// */
int baz();
SHOW 2
// COM 3 */

/*! Global variable DOC 4
 *  ... */
volatile int g_global; SHOW 3

//! Main DOC 5
int main(int argc, SHOW 4 const char* argv)
{
    printf("/* SHOW 5 foo bar");
    //*/ bar(); 

    // \
    /*
    baz();
    /*/
    foo();
    //*/

/\
/*
    baz();
/*/
    foo();
//*/

    char *a = "
dsa
/*
COM 4
*/
dsaasd
df
    ";

    char *b = "\""; //COM 5 " COM 6
    char *bb = "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\""; //COM 7
    char *bbb = "\\\\\\\\\\\\\\\\\\\\\\""; // SHOW 6

    char *a = " \
/* \
SHOW 7 \
*/ \
    ";

    // COM 8 \\
    COM 9


    \" // SHOW 8

    return 1;
    SHOW 9
    
    //  \\\\\\\\\\\\\\\\\\\\ 
    COM 10
    //  \\\\\\\\\\\\\\\\\\\\\ 
    COM 11

    // khfdshfksad \
    COM 12

/\
/\
/\
DOC 6

// tesesresrr \
    COM 13 \
    \
    \
    \
    COM 14 \
    dsaf

    char *c = " \\
    SHOW 10
    ";

/ / SHOW 11

}

