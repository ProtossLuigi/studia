%option noyywrap
%{
    #include "kompilator_y.hpp"
    #include <string>
    int yylex();
%}
%option yylineno
%x comment
%%
\[                      {BEGIN(comment);}
<comment>\]             {BEGIN(INITIAL);}
<comment>\n
<comment>.
[ \t\n]+
\-?[0-9]+               {yylval.lineno = yylineno; yylval.intval = std::stoll(yytext, nullptr); return num;}
[_a-z]+                 {yylval.lineno = yylineno; yylval.str = std::string(yytext); return pidentifier;}
DECLARE                 {yylval.lineno = yylineno; return DECLARE;}
BEGIN                   {yylval.lineno = yylineno; return BEG;}
ENDIF                   {yylval.lineno = yylineno; return ENDIF;}
ENDWHILE                {yylval.lineno = yylineno; return ENDWHILE;}
ENDDO                   {yylval.lineno = yylineno; return ENDDO;}
ENDFOR                  {yylval.lineno = yylineno; return ENDFOR;}
END                     {yylval.lineno = yylineno; return END;}
\,                      {yylval.lineno = yylineno; return COMMA;}
\:                      {yylval.lineno = yylineno; return COLON;}
ASSIGN                  {yylval.lineno = yylineno; return ASSIGN;}
READ                    {yylval.lineno = yylineno; return READ;}
WRITE                   {yylval.lineno = yylineno; return WRITE;}
\;                      {yylval.lineno = yylineno; return SEMICOLON;}
\(                      {yylval.lineno = yylineno; return LPAR;}
\)                      {yylval.lineno = yylineno; return RPAR;}
PLUS                    {yylval.lineno = yylineno; return PLUS;}
MINUS                   {yylval.lineno = yylineno; return MINUS;}
TIMES                   {yylval.lineno = yylineno; return TIMES;}
DIV                     {yylval.lineno = yylineno; return DIV;}
MOD                     {yylval.lineno = yylineno; return MOD;}
EQ                      {yylval.lineno = yylineno; return EQ;}
NEQ                     {yylval.lineno = yylineno; return NEQ;}
LEQ                     {yylval.lineno = yylineno; return LEQ;}
GEQ                     {yylval.lineno = yylineno; return GEQ;}
LE                      {yylval.lineno = yylineno; return LE;}
GE                      {yylval.lineno = yylineno; return GE;}
IF                      {yylval.lineno = yylineno; return IF;}
THEN                    {yylval.lineno = yylineno; return THEN;}
ELSE                    {yylval.lineno = yylineno; return ELSE;}
WHILE                   {yylval.lineno = yylineno; return WHILE;}
DO                      {yylval.lineno = yylineno; return DO;}
FOR                     {yylval.lineno = yylineno; return FOR;}
FROM                    {yylval.lineno = yylineno; return FROM;}
TO                      {yylval.lineno = yylineno; return TO;}
DOWNTO                  {yylval.lineno = yylineno; return DOWNTO;}
.
%%