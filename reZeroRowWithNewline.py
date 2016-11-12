import sys

if len(sys.argv) != 2:
    print "Need exactly one command line argument!"

infile = sys.argv[1]
outfile = sys.argv[1].replace('.csv', '') + 'NoZero.csv'
print outfile

fw = open(outfile, 'w')
for line in open(infile, 'r'):
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
#    else:
        #print line

