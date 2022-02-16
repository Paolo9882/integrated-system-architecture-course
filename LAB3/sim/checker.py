#RISC-V LITE - Python checker script

import sys

#variable used to check if "open" operation is performed correctly
file_opened = 0

try:
	#open results from C
	fREF = open(sys.argv[1], "r")

	#open results from VHDL
	fOUT = open(sys.argv[2], "r")

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
	log.write("#RISC-V Lite - Error log file\n\n")
	log.write("Expected\t\t\t\t\t\t\t\t\tSimulated\t\t\t\t\t\t\t\t\tError\n")
	
	#check the differences
	for lineREF in fREF:
		lineOUT = fOUT.readline()
		error = int(lineREF, 2) - int(lineOUT, 2)
		log.write(lineREF.strip("\n")+"\t\t\t"+lineOUT.strip("\n")+"\t\t\t"+str(error)+"\n")
		if (error != 0):
			tot_error += 1

	#print on file and on screen total number of errors
	log.write("\nTotal error : " + str(tot_error) + "\n")
	print("\nTotal error : " + str(tot_error))
	
	#close files
	fREF.close()
	fOUT.close()
	log.close()

print("Check completed!\n")
