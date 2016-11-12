import numpy as np
import statistics
import csv

temp = 275
while temp < 320:
	name = str(temp) + "K.out"
	print name
	a = []
	with open(name, 'r') as f:
		reader = csv.reader(f, dialect='excel', delimiter='\t')
		for row in reader:
			time, value = row[0].split()
			a.append(float(value))

	print statistics.mean(a)
	print statistics.pstdev(a)
	x = np.array(a)
	n = len(x)
	reps = 10000
	xb = np.random.choice(x, (n, reps))
	mb = xb.mean(axis=0)
	print mb.shape
	print mb.mean()
	print np.std(mb)
	#print statistics.pstdev(mb) same result as above
	print ""


	temp += 5
