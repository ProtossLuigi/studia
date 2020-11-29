#include <stdio.h>
#include <string.h>

const char* L_1(int a)
{
	switch (a)
	{
	case 1:
	{
		return "I";
	}
	break;
	case 2:
	{
		return "II";
	}
	break;
	case 3:
	{
		return "III";
	}
	break;
	case 4:
	{
		return "IV";
	}
	break;
	case 5:
	{
		return "V";
	}
	break;
	case 6:
	{
		return "VI";
	}
	break;
	case 7:
	{
		return "VII";
	}
	break;
	case 8:
	{
		return "VIII";
	}
	break;
	case 9:
	{
		return "IX";
	}
	break;
	default:
		break;
	}

	return "";
}

const char* L_2(int a)
{
	switch (a)
	{
	case 10:
	{
		return "X";
	}
	break;
	case 20:
	{
		return "XX";
	}
	break;
	case 30:
	{
		return "XXX";
	}
	break;
	case 40:
	{
		return "XL";
	}
	break;
	case 50:
	{
		return "L";
	}
	break;
	case 60:
	{
		return "LX";
	}
	break;
	case 70:
	{
		return "LXX";
	}
	break;
	case 80:
	{
		return "LXXX";
	}
	break;
	case 90:
	{
		return "XC";
	}
	break;
	default:
		break;
	}

	return "";
}

const char* L_3(int a)
{
	switch (a)
	{
	case 100:
	{
		return "C";
	}
	break;
	case 200:
	{
		return "CC";
	}
	break;
	case 300:
	{
		return "CCC";
	}
	break;
	case 400:
	{
		return "CD";
	}
	break;
	case 500:
	{
		return "D";
	}
	break;
	case 600:
	{
		return "DC";
	}
	break;
	case 700:
	{
		return "DCC";
	}
	break;
	case 800:
	{
		return "DCCC";
	}
	break;
	case 900:
	{
		return "CM";
	}
	break;
	default:
		break;
	}

	return "";
}

const char* L_4(int a)
{
	switch (a)
	{
	case 1000:
	{
		return "M";
	}
	break;
	case 2000:
	{
		return "MM";
	}
	break;
	case 3000:
	{
		return "MMM";
	}
	break;
	default:
		break;
	}

	return "";
}

int isRomanNumeral(char* numeral)
{
	size_t length = strlen(numeral);

	for (size_t i = 0; i < length; i++)
	{
		if (numeral[i] != 'I' && numeral[i] != 'V' && numeral[i] != 'X' && numeral[i] != 'L' && numeral[i] != 'C' && numeral[i] != 'D' && numeral[i] != 'M')
			return 0;
	}

	return 1;
}

/*
Prosty kalkulator dla liczb Rzymskich
LICZBA1 (+,-,*,/) LICZBA2
np.: 	"II + XC"
np.: 	"MMXX - DCCIX"
		"III * DXLVIII"
		"XXXIII / XI"
Aby zakończyć <q>
*/
void s250344_podprogram()
{
	puts("Artur Czajka, nr indeksu 250344");
	puts("Program jest prostym kalkulatorem dla liczb rzymskich");
	puts("Użycie:");
	puts("<liczba> + <Liczba>");
	puts("<liczba> - <Liczba>");
	puts("<liczba> * <Liczba>");
	puts("<liczba> / <Liczba>");
	puts("Przykład: DCXXXII + MCMLXXIX");
	puts("Akceptowalne liczby: I - MMMCMXCIX");
	puts("\'q\' aby zakończyć");

	char character;
	char roman_num[101];
	int a, b, d;
	int number1 = 0, number2 = 0, number3 = 0;
	size_t length; 

	while (scanf("%100s", roman_num) != EOF)
	{
		if (!isRomanNumeral(roman_num))
		{
			puts("Niepoprawne dane, kończenie programu.");
			return;
		}

		number3 = 0; number1 = 0; number2 = 0;
		a = 0;
		b = 0;
		length = strlen(roman_num);

		for (int i = 0; i < length; i++)
		{
			character = roman_num[i];

			switch (character)
			{
			case 'I':
			{
				b = 1;
			}
			break;
			case 'V':
			{
				b = 5;
			}
			break;
			case 'X':
			{
				b = 10;
			}
			break;
			case 'L':
			{
				b = 50;
			}
			break;
			case 'C':
			{
				b = 100;
			}
			break;
			case 'D':
			{
				b = 500;
			}
			break;
			case 'M':
			{
				b = 1000;
			}
			break;
			default:
				break;
			}


			if (a >= b)
			{
				number1 += b;
			}
			else if (a < b)
			{
				number1 += (b - a);
				number1 -= a;
			}

			a = b;
		}

		char op = ' ';
		scanf(" %c ", &op);
		if (op != '+' && op != '-' && op != '*' && op != '/')
		{
			puts("Niewłąściwy operator!\nSpróbuj ponownie");
			continue;
		}


		scanf("%100s", roman_num);
		if (!isRomanNumeral(roman_num))
		{
			puts("Niepoprawne dane!\nSpróbuj ponownie");
			continue;
		}

		a = 0;
		b = 0;

		length = strlen(roman_num);

		for (int i = 0; i < length; i++)
		{
			character = roman_num[i];

			switch (character)
			{
			case 'I':
			{
				b = 1;
			}
			break;
			case 'V':
			{
				b = 5;
			}
			break;
			case 'X':
			{
				b = 10;
			}
			break;
			case 'L':
			{
				b = 50;
			}
			break;
			case 'C':
			{
				b = 100;
			}
			break;
			case 'D':
			{
				b = 500;
			}
			break;
			case 'M':
			{
				b = 1000;
			}
			break;
			default:
				break;
			}


			if (a >= b)
			{
				number2 += b;
			}
			else if (a < b)
			{
				number2 += (b - a);
				number2 -= a;
			}

			a = b;
		}

		if (op == '+')
		{
			number3 = number1 + number2;
		}
		else if (op == '-')
		{
			number3 = number1 - number2;
		}
		else if (op == '*')
		{
			number3 = number1 * number2;
		}
		else
		{
			number3 = number1 / number2;
		}

		if (number3 < 1 || number3 > 4000 - 1)
		{
			printf("Nie można wyświetlić liczby %d w zapisie Rzymskim\n", number3);
			continue;
		}

		memset(roman_num, '\0', 101);
		char *roman_num_rev = roman_num;

		d = number3 % 10;
		if (d != 0)
		{
			const char *text = L_1(d);

			for (int i = (int)strlen(text) - 1; i >= 0; i--)
			{
				*roman_num_rev = text[i];
				roman_num_rev++;
			}
		}
		number3 -= d;

		d = number3 % 100;

		if (d >= 10)
		{
			if (d != 0)
			{
				const char *text = L_2(d);

				for (int i = (int)strlen(text) - 1; i >= 0; i--)
				{
					*roman_num_rev = text[i];
					roman_num_rev++;
				}
			}
		}
		number3 -= d;

		d = number3 % 1000;
		if (d >= 100)
		{
			if (d != 0)
			{
				const char *text = L_3(d);

				for (int i = (int)strlen(text) - 1; i >= 0; i--)
				{
					*roman_num_rev = text[i];
					roman_num_rev++;
				}
			}
		}
		number3 -= d;

		d = number3 % 10000;
		if (d >= 1000)
		{
			if (d != 0)
			{
				const char *text = L_4(d);

				for (int i = (int)strlen(text) - 1; i >= 0; i--)
				{
					*roman_num_rev = text[i];
					roman_num_rev++;
				}
			}
		}

		*roman_num_rev = '\0';
		roman_num_rev--;

		length = roman_num_rev - roman_num;
		for (size_t i = 0; i <= length / 2; i++)
		{
			char a = roman_num[i];
			roman_num[i] = roman_num[length - i];
			roman_num[length - i] = a;
		}

		printf("%s\n", roman_num);
	}

	return;
}
