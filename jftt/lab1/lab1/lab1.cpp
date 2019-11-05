// lab1.cpp: definiuje punkt wejścia dla aplikacji.
//

#include "lab1.h"

using namespace std;

vector<int> kmp(string text, string pattern)
{
	vector<int> prefixes;
	prefixes.resize(pattern.length());
	prefixes[0] = 0;
	int length = 0;
	for (int i = 1; i < pattern.length(); i++)
	{
		if (pattern[i] == pattern[length])
		{
			length++;
			prefixes[i] = length;
		}
		else if (length == 0)
		{
			prefixes[i] = 0;
		}
		else
		{
			length = prefixes[length - 1];
			i--;
		}
	}
	vector<int> found;
	int i = 0, j = 0;
	while (i < text.length())
	{
		if (j == pattern.length())
		{
			found.push_back(i - j);
			j = prefixes[j - 1];
		}
		else if (text[i] == pattern[j])
		{
			i++;
			j++;
		}
		else if (j == 0)
		{
			i++;
		}
		else
		{
			j = prefixes[j - 1];
		}
	}
	if (j == pattern.length())
	{
		found.push_back(i - j);
	}
	return found;
}

vector<int> automat(string text, string pattern)
{
	vector<vector<int>> delta;
	for (int i = 0; i < pattern.length() + 1; i++)
	{
		delta.emplace_back(vector<int>(256,0));
		for (int j = 0; j < 256; j++)
		{
			int k = pattern.length() < i + 1 ? pattern.length() : i + 1;
			string s = string(pattern.substr(0,i));
			s.push_back(j);
			while (k > 0 && pattern.substr(0, k).compare(s.substr(s.length() - k, k)) != 0)
			{
				k--;
			}
			delta[i][j] = k;
		}
	}
	int state = 0;
	vector<int> found;
	for (int i = 0; i < text.length(); i++)
	{
		state = delta[state][text[i]];
		if (state == pattern.length())
		{
			found.push_back(i - pattern.length() + 1);
		}
	}
	return found;
}

int main(int argc, char** argv)
{
	bool mode = 0;
	if (argc > 1 && strcmp(argv[1], "-kmp") == 0)
	{
		mode = 0;
	}
	string text, pattern;
	cout << "text: ";
	cin >> text;
	cout << "pattern: ";
	cin >> pattern;
	vector<int> found = mode ? kmp(text, pattern) : automat(text, pattern);
	for (int num : found)
	{
		cout << num << endl;
	}
	system("PAUSE");
	return 0;
}
