%{
    #include<stack>
    #include<iostream>
    #include<cmath>

    std::stack<int> stk;
%}
%x CLEANUP
%%
-?[0-9]+|[\+\-\*\/\^\%] stk.push(yytext);
<<EOF>>                 calculate(); return 0;
\n                      calculate();
[ \t]
.                       wrong_symbol(yytext); BEGIN(CLEANUP);
.*\n                    BEGIN(INITIAL);
%%
int yywrap(){}
int main(){
    yyout = stdout;
    yylex();
    return 0;
}