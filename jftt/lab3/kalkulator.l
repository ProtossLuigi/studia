%option noyywrap
%{
    #include "kalkulator_y.h"
    #include <string>
    int yylex();
%}
%%
\#(.|\\\n)*$
[ \t]+
(\\\n)+
[0-9]+  {yylval=std::stoi(yytext,nullptr); return VAL;}
\+      {return ADD;}
\-      {return SUB;}
\*      {return MUL;}
\/      {return DIV;}
\^      {return POW;}
\%      {return MOD;}
\(      {return LNAW;}
\)      {return RNAW;}
\n      {return END;}
.       {return ERROR;}
%%