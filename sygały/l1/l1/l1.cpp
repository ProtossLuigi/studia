// l1.cpp : Ten plik zawiera funkcję „main”. W nim rozpoczyna się i kończy wykonywanie programu.
//

#include "pch.h"
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
#include <queue>
using namespace cv;
using namespace std;

struct pixelData {
	uchar* ptr;
};

int main(int argc, char** argv)
{
	String imageName("..\\connected.jpg");
	if (argc > 1)
	{
		imageName = argv[1];
	}
	Mat image;
	image = imread(samples::findFile(imageName), IMREAD_COLOR);
	if (image.empty())
	{
		cout << "Could not open or find the image" << std::endl;
		return -1;
	}
	namedWindow("Display window", WINDOW_AUTOSIZE);
	imshow("Display window", image);
	uchar *blue;
	for (int y = 0; y < image.rows; y++)
	{
		blue = image.ptr<uchar>(y);
		for (int x = 0; x < image.cols; x++)
		{
			if (*blue < 20)
			{
				*blue = 0;
			}
			else if (*blue <= 220)
			{
				*blue -= 20;
			}
			else
			{
				*blue = 255;
			}
			blue += 3;
		}
	}
	namedWindow("Display window2", WINDOW_AUTOSIZE);
	imshow("Display window2", image);
	Mat greyImg;
	cvtColor(image, greyImg, COLOR_BGR2GRAY);
	namedWindow("Display window3", WINDOW_AUTOSIZE);
	imshow("Display window3", greyImg);
	uchar i = greyImg.at<uchar>(0, 0);
	uchar min = floor((unsigned int)i * 0.8);
	uchar max = floor((unsigned int)i * 1.1);
	vector<vector<bool>> visited(greyImg.rows, vector<bool>(greyImg.cols, false));
	queue<pair<int,int>> q;
	q.push(pair<int,int>(0, 0));
	int row, col;
	while (!q.empty())
	{
		row = q.front().first;
		col = q.front().second;
		q.pop();
		if (row < greyImg.rows && col < greyImg.cols && !visited[row][col])
		{
			visited[row][col] = true;
			i = greyImg.at<uchar>(row, col);
			if (i >= min && i <= max)
			{
				//neighbours.push_back(pair<int,int>(row,col));
				greyImg.at<uchar>(row, col) = 0;
				q.push(pair<int, int>(row, col + 1));
				q.push(pair<int, int>(row + 1, col));
				q.push(pair<int, int>(row + 1, col + 1));
			}
		}
	}
	namedWindow("Display window4", WINDOW_AUTOSIZE);
	imshow("Display window4", greyImg);
	waitKey(0);
	return 0;
}

// Uruchomienie programu: Ctrl + F5 lub menu Debugowanie > Uruchom bez debugowania
// Debugowanie programu: F5 lub menu Debugowanie > Rozpocznij debugowanie

// Porady dotyczące rozpoczynania pracy:
//   1. Użyj okna Eksploratora rozwiązań, aby dodać pliki i zarządzać nimi
//   2. Użyj okna programu Team Explorer, aby nawiązać połączenie z kontrolą źródła
//   3. Użyj okna Dane wyjściowe, aby sprawdzić dane wyjściowe kompilacji i inne komunikaty
//   4. Użyj okna Lista błędów, aby zobaczyć błędy
//   5. Wybierz pozycję Projekt > Dodaj nowy element, aby utworzyć nowe pliki kodu, lub wybierz pozycję Projekt > Dodaj istniejący element, aby dodać istniejące pliku kodu do projektu
//   6. Aby w przyszłości ponownie otworzyć ten projekt, przejdź do pozycji Plik > Otwórz > Projekt i wybierz plik sln
