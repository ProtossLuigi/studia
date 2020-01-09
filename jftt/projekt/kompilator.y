%{
    #include <iostream>
    int yylex();
%}

%%

int main(){
    yyparse();
    return 0;
}