import sys

if len(sys.argv) != 2:
    print "Need exactly one command line argument!"

infile = sys.argv[1]
outfile = sys.argv[1].replace('.csv', '') + 'NoZero.csv'
print outfile

originLine = 0
afterLine = 0

fw = open(outfile, 'w')
for line in open(infile, 'r'):
    lineList = line.split('\r')
    for line in lineList:
        isZero = True
        lineS = line.split(',')
        del lineS[0] 
        del lineS[-1] #delete \n

        for element in lineS:
            if element != '0.0000000000' and element != '0':
                isZero = False
                break

        originLine += 1
        if isZero == False:
            afterLine += 1
            fw.write(line + '\n')
        #else:
            #print line
print "originLine is " + str(originLine)
print "afterLine is " + str(afterLine)

