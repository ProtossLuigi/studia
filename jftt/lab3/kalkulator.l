%option noyywrap
%{
    #include "kalkulator_y.hpp"
    #include <string>
    int yylex();
%}
%x CANTNEG
%%
<*>\#(.|\\\n)*$    {BEGIN(INITIAL);}
<*>[ \t]+
<*>(\\\n)+
<INITIAL>\-?[0-9]+  {yylval=std::stoi(yytext,nullptr); BEGIN(CANTNEG); return VAL;}
<CANTNEG>[0-9]+     {yylval=std::stoi(yytext,nullptr); BEGIN(CANTNEG); return VAL;}
<*>\+       {BEGIN(INITIAL); return ADD;}
<*>\-       {BEGIN(INITIAL); return SUB;}
<*>\*       {BEGIN(INITIAL); return MUL;}
<*>\/       {BEGIN(INITIAL); return DIV;}
<*>\^       {BEGIN(INITIAL); return POW;}
<*>\%       {BEGIN(INITIAL); return MOD;}
<*>\(       {BEGIN(INITIAL); return LNAW;}
<*>\)       {BEGIN(CANTNEG); return RNAW;}
<*>\n       {BEGIN(INITIAL); return END;}
<*>.        {return ERROR;}
%%