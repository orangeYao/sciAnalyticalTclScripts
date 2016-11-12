fw = open('zunlaFpkmNoZero.csv', 'w')
for line in open('zunlaFpkm.csv', 'r'):
    isZero = True
    lineS = line.split(',')
    del lineS[0] 
    del lineS[-1] #delete \n

    for element in lineS:
        if element != '0.0000000000':
            isZero = False
            break

    if isZero == False:
        fw.write(line)
    else:
        print line

