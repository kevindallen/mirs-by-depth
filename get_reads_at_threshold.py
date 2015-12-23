import sys
import csv
in_file = str(sys.argv[1])
thresh = float(sys.argv[2])
mirs_discovered = 0
with open(in_file, 'rb') as f:
    reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
    for row in reader:
    	if str(row[2]) != "count":
        	if int(row[2]) >= thresh:
        		mirs_discovered += 1
print mirs_discovered