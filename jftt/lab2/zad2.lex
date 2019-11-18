%x STRING
%x COMMENT
%x BLOCK
%x STRING_IN_BLOCK
%%
\"              {ECHO; printf("SB\n"); BEGIN(STRING);}
<STRING>\"      {ECHO; printf("SE\n"); BEGIN(INITIAL);}
"<"             {ECHO; BEGIN(BLOCK);}
<BLOCK>">"      {ECHO; BEGIN(INITIAL);}
<BLOCK>\"       {ECHO; BEGIN(STRING_IN_BLOCK);}
<STRING_IN_BLOCK>\" {ECHO; BEGIN(BLOCK);}
"<!--" {yymore(); BEGIN(COMMENT);}
<COMMENT>"--"$  {ECHO; BEGIN(INITIAL);}
<COMMENT>"--"/[^\>]  {ECHO; BEGIN(INITIAL);}
<COMMENT>"-->"  {BEGIN(INITIAL);}
<COMMENT>.  {yymore();}
%%
int yywrap(){}
int main(){
    yylex();
    return 0;
}