%{
    bool doc = false;
%}
%x STRING
%x MULTI_UNDOC
%x SINGLE_UNDO
%x MULTI_DOC
%%
\"                                  ECHO; BEGIN(STRING);
<STRING>\"                          ECHO; BEGIN(INITIAL);
<STRING>[^\\]$                      ECHO; BEGIN(INITIAL);
\/(\\\n)*\/(\\\n)*[!\/](.|\\\n)*$   {if (doc) {ECHO;}}
\/(\\\n)*\/(.|\\\n)*$
\/(\\\n)*"*"(\\\n)*[!\*]            {if (doc) {ECHO;} BEGIN(MULTI_DOC);}
<MULTI_DOC>"*"(\\\n)*\/             {if (doc) {ECHO;} BEGIN(INITIAL);}
<MULTI_DOC>.|\n                     {if (doc) {ECHO;}}
\/(\\\n)*"*"                        BEGIN(MULTI_UNDOC);
<MULTI_UNDOC>"*"(\\\n)*\/           BEGIN(INITIAL);
<MULTI_UNDOC>.|\n
%%
int yywrap(){}
int main(int argc, char **argv){
    if (argc >= 2 && strcmp(argv[1],"-doc") == 0){
        doc = true;
    }
    yylex();
    return 0;
}