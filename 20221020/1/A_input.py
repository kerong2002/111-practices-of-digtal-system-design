from random import randint
#==========<開檔案>=============
A_txt = open('A.txt', 'w')
B_txt = open('B.txt', 'w')
C_txt = open('C.txt', 'w')
sel_txt=open('sel.txt','w')
ans_txt=open('ans.txt','w')
#==========<清空>=============
print('', file=A_txt,end='')
print('', file=B_txt, end='')
print('', file=C_txt,end='')
print('', file=sel_txt,end='')
print('', file=ans_txt,end='')

max_size = 20000  # data

size9    = 9      # size 9
size8    = 8      # size 8
bit8_min = 0      # 8-bit small
bit8_max = 255    # 8-bit max

size5     = 5     # size 5
bit5_min = 0      # 5-bit small
bit5_max = 31     # 5-bit max

size2     = 2     # size 2
bit2_min  = 0     # 2-bit small
bit2_max  = 3     # 2-bit max

for i in range(max_size):
    A_int   = randint(bit8_min, bit8_max)
    B_int   = randint(bit8_min, bit8_max)
    C_int   = randint(bit5_min, bit5_max)
    sel_int = randint(bit2_min,bit2_max)
    takeA = str(bin(A_int))[2::]  # get take value A
    takeB = str(bin(B_int))[2::]  # get take value B
    takeC = str(bin(C_int))[2::]  # get take value C
    takesel = str(bin(sel_int))[2::]  # get take value sel
    if(sel_int == 0):
        ans_int = A_int + B_int
        if(ans_int<0):
            take_ans=str(bin(ans_int))[3::]
            for x in range(size9 - len(take_ans)):
                print('0', end='', file=ans_txt)  # ans-fill 0
            print(take_ans, file=ans_txt)
        else:
            take_ans = str(bin(ans_int))[2::]
            for x in range(size9 - len(take_ans)):
                print('0', end='', file=ans_txt)  # ans-fill 0
            print(take_ans, file=ans_txt)
    elif(sel_int == 1):
        if(C_int %2 == 0):
            A_list = []
            for x in range(size9 - len(takeA)):
                A_list.append('0')
            for x in range(len(takeA)):
                A_list.append(takeA[x])
            for x in range(size9):
                if(int(A_list[x])==1):
                    print('0', end='', file=ans_txt)
                else:
                    print('1', end='', file=ans_txt)
            print('', file=ans_txt)
        else:
            for x in range(size9 - len(takeA)):
                print('0', end='', file=ans_txt)  # A-fill 0
            print(takeA, file=ans_txt)
    elif(sel_int == 3):
        if(C_int % 4 > A_int % 4):
            for x in range(size9 - len(takeC)):
                print('0', end='', file=ans_txt)  # C-fill 0
            print(takeC, file=ans_txt)
        else:
            for x in range(size9 - len(takeA)):
                print('0', end='', file=ans_txt)  # A-fill 0
            print(takeA, file=ans_txt)
    else:
        if(C_int>5):
            A_list=[]
            B_list=[]
            for x in range(size9 - len(takeA)):
                A_list.append('0')
            for x in range(len(takeA)):
                A_list.append(takeA[x])
            for x in range(size9 - len(takeB)):
                B_list.append('0')
            for x in range(len(takeB)):
                B_list.append(takeB[x])
            for x in range(size9):
                print(int(B_list[x])^int(A_list[x]),end='',file=ans_txt)
            print('', file=ans_txt)
        else:
            A_list = []
            B_list = []
            for x in range(size9 - len(takeA)):
                A_list.append('0')
            for x in range(len(takeA)):
                A_list.append(takeA[x])
            for x in range(size9 - len(takeB)):
                B_list.append('0')
            for x in range(len(takeB)):
                B_list.append(takeB[x])
            # print(A_list)
            # print(B_list)
            ans=[]
            for x in range(size9):
                ans.append(int(B_list[x]) & int(A_list[x]))
            for x in range(size9):
               if(ans[x]==1):
                    print('0',end='',file=ans_txt)
               else:
                    print('1',end='',file=ans_txt)
            # print(ans)
            print('', file=ans_txt)
    for x in range(size8-len(takeA)):
        print('0',end='',file=A_txt)                    #A-fill 0
    print(takeA, file=A_txt)
    for x in range(size8 - len(takeB)):
        print('0', end='', file=B_txt)                  #B-fill 0
    print(takeB, file=B_txt)
    for x in range(size5 - len(takeC)):
        print('0', end='', file=C_txt)                  #C-fill 0
    print(takeC, file=C_txt)
    for x in range(size2 - len(takesel)):
        print('0', end='', file=sel_txt)                #sel-fill 0
    print(takesel, file=sel_txt)

A_txt.close()
B_txt.close()
C_txt.close()
sel_txt.close()
ans_txt.close()