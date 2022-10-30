#2022_10_30 kerong
#random input
from random import randint
import math
#==========<開檔案>=============
x_txt = open('x.dat', 'w')
y_txt = open('y.dat', 'w')
theta = open('theta.dat', 'w')
DATA_SIZE = 200
x_int = 0
y_int = 0
signed_y = 1
y_check = 0
for y in range(DATA_SIZE):
    y_list = []
    print(0, end='', file=x_txt)
    one_cnt = 0
    x_int = 0
    for x in range(1,32):
        get = randint(0,1)
        if(get==1):
            one_cnt+=1
        if(x==7 and one_cnt==0 and get==0):
            get=1
        print(get, end='', file=x_txt)
        x_int += (2**(7-x))*get
    print(file=x_txt)
    y_int = 0
    signed_y = 1
    y_check = 0
    for x in range(0,32):
        get = randint(0,1)
        if(x==0 and get==1):
            signed_y = -1
        print(get, end='', file=y_txt)
        if(signed_y==-1):
            y_list.append(get)
        if(x!=0 and signed_y == 1):
            y_int += (2 ** (7 - x))*get
    if(signed_y==-1):
        for x in range(31,0,-1):
            if (x != 0 and signed_y == -1):
                if (y_check == 1):
                    if (y_list[x] == 0):
                        y_int += (2 ** (-x+7))
                else:
                    if (y_list[x] == 1):
                        y_int += (2 ** (-x+7))
                if (y_list[x] == 1):
                    y_check = 1
    y_int = signed_y*y_int
    theta_get = math.atan(y_int/x_int)
    degree = 180.0 / math.pi
    ans_list = []
    power_degree =int(theta_get*degree *(2**24))
    # print(power_degree)
    ans_neg = 0
    if(power_degree<0):
        ans_neg = 1
        power_degree=abs(power_degree)
    for i in range(31):
        ans_list.insert(0,power_degree%2)
        power_degree//=2
    ans_list.insert(0,0)
    if(ans_neg==1):
        for i in range(32):
            if(ans_list[i]==1):
                ans_list[i]=0
            else:
                ans_list[i]=1
        carry = 1
        for i in range(31, 0, -1):
            ans_list[i] = (ans_list[i]+carry) % 2
            carry = (carry+ans_list[i])//2
   # print(ans_list)
    for i in range(32):
        print(ans_list[i],end='',file=theta)
    print('    //{:.2f}'.format(theta_get*degree),end='',file=theta)
    print(file=theta)

    # print(y_int,x_int,theta_get*degree,power_degree)
    print(file=y_txt)

x_txt.close()
y_txt.close()
theta.close()