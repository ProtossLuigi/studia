%option noyywrap
%{
    #include "kompilator_y.hpp"
    #include <string>
    int yylex();
%}

%%
\[[.\n]*\]
[ \t\n]+
\-?[0-9]+               {yylval.intval = std::stoll(yytext, nullptr); return num;}
[_a-z]+                 {yylval.str = std::string(yytext); return pidentifier;}
DECLARE                 {return DECLARE;}
BEGIN                   {return BEG;}
ENDIF                   {return ENDIF;}
ENDWHILE                {return ENDWHILE;}
ENDDO                   {return ENDDO;}
ENDFOR                  {return ENDFOR;}
END                     {return END;}
\,                      {return COMMA;}
\:                      {return COLON;}
ASSIGN                  {return ASSIGN;}
READ                    {return READ;}
WRITE                   {return WRITE;}
\;                      {return SEMICOLON;}
\(                      {return LPAR;}
\)                      {return RPAR;}
PLUS                    {return PLUS;}
MINUS                   {return MINUS;}
TIMES                   {return TIMES;}
DIV                     {return DIV;}
MOD                     {return MOD;}
EQ                      {return EQ;}
NEQ                     {return NEQ;}
LEQ                     {return LEQ;}
GEQ                     {return GEQ;}
LE                      {return LE;}
GE                      {return GE;}
IF                      {return IF;}
THEN                    {return THEN;}
ELSE                    {return ELSE;}
WHILE                   {return WHILE;}
DO                      {return DO;}
FOR                     {return FOR;}
FROM                    {return FROM;}
TO                      {return TO;}
DOWNTO                  {return DOWNTO;}
.
%%