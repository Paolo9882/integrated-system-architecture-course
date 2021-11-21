#IIR filter - Python checker script

import sys

#variable used to check if "open" operation is performed correctly
file_opened = 0

try:
	#open results from C
	fC = open(sys.argv[1], "r")

	#open results from VHDL
	fVHD = open(sys.argv[2], "r")

	#open error log file
	log = open("log_check.txt", "w")
	
	#"open" operation performed correctly
	file_opened = 1
	
except:
	#"open" operation fails
	print("Unable to open files")
	
#if open succeeds
if (file_opened == 1):
	
	#total number of errors founded
	tot_error = 0
	
	#log file title
	log.write("#IIR filter - Error log file\n\n")
	log.write("Expected\t\tSimulated\t\tError\n")
	
	#check the differences
	for lineC in fC:
		lineVHD = fVHD.readline()
		error = int(lineC) - int(lineVHD)
		if (int(lineC) > 999 or int(lineC) < -99):
			log.write(lineC.strip("\n")+"\t\t\t"+lineVHD.strip("\n")+"\t\t\t"+str(error)+"\n")
		else:
			log.write(lineC.strip("\n")+"\t\t\t\t"+lineVHD.strip("\n")+"\t\t\t\t"+str(error)+"\n")
		if (error != 0):
			tot_error += 1

	#print on file and on screen total number of errors
	log.write("\nTotal error : " + str(tot_error) + "\n")
	print("\nTotal error : " + str(tot_error))
	
	#close files
	fC.close()
	fVHD.close()
	log.close()

print("Check completed!\n")
