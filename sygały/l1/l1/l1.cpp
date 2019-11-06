// l1.cpp : Ten plik zawiera funkcję „main”. W nim rozpoczyna się i kończy wykonywanie programu.
//

#include "pch.h"
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
using namespace cv;
using namespace std;
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
	Vec3b color;
	for (int y = 0; y < image.rows; y++)
	{
		for (int x = 0; x < image.cols; x++)
		{
			color = image.at<Vec3b>(Point(x, y));
			if (color[0] < 20)
			{
				color[0] = 0;
			}
			else if (color[0] <= 220)
			{
				color[0] -= 20;
			}
			else
			{
				color[0] = 255;
			}
			image.at<Vec3b>(Point(x, y)) = color;
		}
	}
	namedWindow("Display window2", WINDOW_AUTOSIZE);
	imshow("Display window2", image);
	Mat greyImg;
	cvtColor(image, greyImg, COLOR_BGR2GRAY);
	namedWindow("Display window3", WINDOW_AUTOSIZE);
	imshow("Display window3", greyImg);
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
