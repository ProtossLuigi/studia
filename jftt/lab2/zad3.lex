%x STRING
%x MULTI_UNDOC
%x SINGLE_UNDO
%x MULTI_DOC
%%
\"                                  ECHO; BEGIN(STRING);
<STRING>\"                          ECHO; BEGIN(INITIAL);
<STRING>[^\\]$                      ECHO; BEGIN(INITIAL);
\/(\\\n)*\/(\\\n)*[!\/](.|\\\n)*$   ECHO;
\/(\\\n)*\/(.|\\\n)*$
\/(\\\n)*"*"(\\\n)*[!\*]            ECHO; BEGIN(MULTI_DOC);
<MULTI_DOC>"*"(\\\n)*\/             ECHO; BEGIN(INITIAL);
\/(\\\n)*"*"                        BEGIN(MULTI_UNDOC);
<MULTI_UNDOC>"*"(\\\n)*\/           BEGIN(INITIAL);
<MULTI_UNDOC>.|\n
%%
int yywrap(){}
int main(){
    yylex();
    return 0;
}