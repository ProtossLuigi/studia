%{
    #include<stack>
    #include<iostream>
    #include<cmath>

    std::stack<int> stk;

    void reset_stack(){
        stk = std::stack<int>();
    }

    void show_error(int e){
        switch(e){
        case 0:
            std::cout << "Error: Not enough arguments." << std::endl;
            break;
        case 1:
            std::cout << "Error: Cannot divide by 0." << std::endl;
            break;
        case 2:
            std::cout << "Error: Wrong symbol." << std::endl;
            break;
        default:
            std::cout << "Error: Error." << std::endl;
        }
    }
%}
%x CLEANUP
%%
-?[0-9]+    stk.push(std::stoi(yytext,nullptr));
<<EOF>>     {if (stk.size() == 1) {std::cout << "= " << stk.top() << std::endl;} else {show_error(0);} return 0;}
\n          {if (stk.size() == 1) {std::cout << "= " << stk.top() << std::endl;} else {show_error(0);} reset_stack();}
\+          {if (stk.size() < 2) {show_error(0); reset_stack(); BEGIN(CLEANUP);} else {int arg1,arg2; arg2 = stk.top(); stk.pop(); arg1 = stk.top(); stk.pop(); stk.push(arg1 + arg2);}}
\-/[^0-9]   {if (stk.size() < 2) {show_error(0); reset_stack(); BEGIN(CLEANUP);} else {int arg1,arg2; arg2 = stk.top(); stk.pop(); arg1 = stk.top(); stk.pop(); stk.push(arg1 - arg2);}}
\*          {if (stk.size() < 2) {show_error(0); reset_stack(); BEGIN(CLEANUP);} else {int arg1,arg2; arg2 = stk.top(); stk.pop(); arg1 = stk.top(); stk.pop(); stk.push(arg1 * arg2);}}
\/          {if (stk.size() < 2) {show_error(0); reset_stack(); BEGIN(CLEANUP);} else if (stk.top() == 0) {show_error(1); reset_stack(); BEGIN(CLEANUP);} else {int arg1,arg2; arg2 = stk.top(); stk.pop(); arg1 = stk.top(); stk.pop(); stk.push(arg1 / arg2);}}
\%          {if (stk.size() < 2) {show_error(0); reset_stack(); BEGIN(CLEANUP);} else if (stk.top() == 0) {show_error(1); reset_stack(); BEGIN(CLEANUP);} else {int arg1,arg2; arg2 = stk.top(); stk.pop(); arg1 = stk.top(); stk.pop(); stk.push(arg1 % arg2);}}
\^          {if (stk.size() < 2) {show_error(0); reset_stack(); BEGIN(CLEANUP);} else {int arg1,arg2; arg2 = stk.top(); stk.pop(); arg1 = stk.top(); stk.pop(); stk.push((int)pow(arg1,arg2));}}
[ \t]
.           {show_error(2); reset_stack(); BEGIN(CLEANUP);}
<CLEANUP>.*\n   BEGIN(INITIAL);
%%
int yywrap(){}
int main(){
    yyout = stdout;
    yylex();
    return 0;
}