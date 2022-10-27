#include <iostream>
#include <utility>
#include <bitset>
#include <cstdlib>
#include <cmath>
#include <fstream>
using namespace std;
pair<string, string> generateNumber()
{
    pair<string, string> number;
    number.first = "";
    number.second = "";
    int min = 0, max = 1;
    for (int i = 1; i <= 32; i++)
    {
        if (i <= 8)
        {
            number.first += to_string(rand() % (max - min + 1) + min);
        }
        else
        {
            number.second += to_string(rand() % (max - min + 1) + min);
        }
    }
    return number;
}

double toDecimal(string a, string b = "0")
{

    double temp;
    for (int i = a.length() - 1; i >= 0; i--)
    {
        temp += (a[i] - '0') * pow(2, a.length() - 1 - i);
    }
    for (int i = 0; i < b.length(); i++)
    {
        // cout << (b[i] - '0') * pow(0.5, i + 1) << " ";
        temp += (b[i] - '0') * pow(0.5, i + 1);
    }
    return temp;
}

string toFixed(double temp)
{

    double decimals = temp - floor(temp);
    int integer, time = 24, a = 1;
    string s = bitset<8>(int(temp)).to_string();
    while (s.length() < 8)
        s = '0' + s;
    // cout << s << endl;
    while (a <= time)
    {
        decimals = decimals * 2;
        // s += to_string(floor(decimals));
        integer = floor(decimals);
        s += to_string(integer);
        decimals = decimals - integer;
        a++;
        if (decimals == 0)
        {
            break;
        }
    }
    // cout << s << endl;

    return s;
}
int main()
{
    pair<string, string> temp;
    double theta;
    double x, y;
    for (int i = 0; i < 200; i++)
    {
        temp = generateNumber();
        ofstream myfile("x.dat", ios::app);
        if (myfile.is_open())
        {
            x = toDecimal(temp.first, temp.second);
            myfile << temp.first << "_" << temp.second << "\n";
            myfile.close();
        }
        temp = generateNumber();
        ofstream yfile("y.dat", ios::app);
        if (yfile.is_open())
        {
            y = toDecimal(temp.first, temp.second);
            yfile << temp.first << "_" << temp.second << "\n";
            yfile.close();
        }
        theta = atan(y / x) * (180 / 3.14159);
        // cout << theta << endl;
        string temp = toFixed(theta);
        ofstream tfile("theta.dat", ios::app);
        if (tfile.is_open())
        {
            tfile << temp << " //" << theta << "\n";
            tfile.close();
        }
    }
}