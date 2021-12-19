'''
Created on 25 nov 2021

@author: paolo

This code generates the list of adder instantiations used to perform the sum of the 
partial products coming from a multiplication of unsigned data, with a booth encoding
algorithm and a radix-4 approach. The algorithm that decide when instantiate full 
adders or half adders is the DADDA TREE architecture (ALAP).
The dot notation is represented with a matrix, and each step is printed on the terminal 
to check the correctness of the execution
'''
import vhdl_functions as vhd

'''
User can modify the parameters below
'''
#Architecture parameters
data_parallelism = 32

#vhd file parameters
#other parameters are in vhdl_functions.py (too much parameters to pass between functions :( )
signals_name = "pp" #prefix of the signals that contain the partial products
final_signal_name_1 = "final0" #output signal 1
final_signal_name_2 = "final1" #output signal 2
indent = "\t" #number of tabs that you want in the vhd code

#graphical representation of the dot, the blanks and the instantiation of the adders
dot = "O"
empty = " "
full_adder_simbol = "F"
half_adder_simbol = "H"

#output file
file_name = "dadda_tree.vhd"
'''
User can modify the parameters above
'''

#file generated
port_map_file = open("port_map.txt", "w+")

#intialization
pp_parallelism = data_parallelism + 1 #partial product have one bit more
levels_number = int(data_parallelism/2)+1 #initial number of rows of the matrix
elements_in_level = [] #number of lines to reach in each step
elements_in_level.append(2) #number of element of the last step
final_line = 0 #index of the first of the two last partial results

#compute the list of level required at each step
while elements_in_level[-1] < levels_number:
    elements_in_level.append(int(elements_in_level[-1]*3/2))
    
#reverse the list in a decrescent order
elements_in_level.pop(-1)
elements_in_level = elements_in_level[::-1]

#declaration of a "empty" matrix
partial_matrix = [[empty for x in range(pp_parallelism*2)] for y in range(levels_number)] 


#indexes to keep track of the index to print in vhdl
FA_count = 0
HA_count = 0
   

def dadda(pp_parallelism):
    matrix_filling()
    
    #print the recap of what will be done
    print_header()

    #print the matrix
    print("Initial partial product matrix:\n")
    print_matrix(len(partial_matrix))
    
    #steps of the reduction of the rows
    for i in elements_in_level:
        empty_line = len(partial_matrix) #index of the first empty line
        final_line = empty_line
        line_to_add = [empty]*pp_parallelism*2 #new line to be added
        partial_matrix.append(line_to_add) #adding of that line
        print("\n\nPARTIAL STEP:\n\n\tmaximum number of levels at the end of this step: " + str(i) + "\n")
        print("Operations done:")
        compute_reduction(i, empty_line)
        
        print_matrix(empty_line)
        
        #substitute F and H with empty spaces
        for i in range(len(partial_matrix)):
            for j in range(pp_parallelism*2):
                if partial_matrix[i][j] == full_adder_simbol or partial_matrix[i][j] == half_adder_simbol:
                    partial_matrix[i][j] = empty
        
        print("\tRESULT MATRIX:\n")
        print_matrix(empty_line)

    search_and_move_dots(final_line) #assign last dots to the final vectors    
    print("\tFINAL MATRIX:\n")
    print_matrix(final_line)
    
    print("\nThen these signals are assigned to two final signals on " + str(data_parallelism * 2) + " bits:\n")
    print("\t-" + final_signal_name_1)
    print("\t-" + final_signal_name_2)
    print("\n")
    
    #assignment to the final signals
    to_final_signal()
    
    print("Total number of full adder: " + str(FA_count))
    print("Total number of half adder: " + str(HA_count) + "\n")
    
    vhd.write_on_vhd_file(indent, port_map_file, file_name, signals_name,
                           len(partial_matrix), levels_number, data_parallelism*2)
    print("VHD file correctly filled")

    
    
def print_header():
    print("-------------------------------------------------")
    print("||       DADDA TREE GENERATION ALGORITHM       ||")
    print("-------------------------------------------------\n")
    print("Parallelism of data:\t\t" + str(data_parallelism) + " bits\n")
    print("Radix order:\t\t\t" + "radix-4\n")
    print("Required number of iteration:\t" + str(len(elements_in_level)) + "\n")
    print("Representation:\n")
    print("\t-Useful bit:\t" + dot + "\n")
    print("\t\t\t" + full_adder_simbol)
    print("\t-Full adder:\t" + full_adder_simbol)
    print("\t\t\t" + full_adder_simbol + "\n")
    print("\t-Half adder:\t" + half_adder_simbol)
    print("\t\t\t" + half_adder_simbol + "\n")
    print("\t-Rows represent the signals\n")
    print("\t-Columns represent the bit of the signals\n\n")


#This matrix is specific for a radix-4 approach
def matrix_filling (): 

        #first partial product
    for i in range(pp_parallelism+3):
        partial_matrix[0][i] = dot 
    
    #intermediate partial products
    for j in range(1,levels_number-1):
        partial_matrix[j][2*j-2] = dot
        for i in range(2*j, pp_parallelism+2*j+2):
            if i < data_parallelism*2:
                partial_matrix[j][i] = dot
    
    #last partial product
    partial_matrix[levels_number-1][2*(levels_number-1)-2] = dot
    for i in range(2*(levels_number-1), pp_parallelism*2-2):
        partial_matrix[levels_number-1][i] = dot

#Single reduction step of the matrix (DADDA)
def compute_reduction(aimed_levels, empty_line):  
    global FA_count
    global HA_count
    for col in range(pp_parallelism*2):
        count = 0
        where_are_dots = [] #vector that contains the position of the dots
        for row in range(len(partial_matrix)):
            if partial_matrix[row][col] == dot: 
                count+=1
                where_are_dots.append(row)
        
        while count >= aimed_levels + 2: #add full adder until there is maximum 1 line more 
            new_dot = full_adder_instantiation(where_are_dots.pop(0), 
                                               where_are_dots.pop(0), 
                                               where_are_dots.pop(0), 
                                               col, empty_line)
            count = count - 2
            FA_count += 1
            where_are_dots.append(new_dot)
        if count >= aimed_levels + 1: #add 1 half adder in case full adder is not required
            new_dot = half_adder_instantiation(where_are_dots.pop(0), 
                                               where_are_dots.pop(0), 
                                               col, empty_line)
            HA_count += 1
            where_are_dots.append(new_dot)

def full_adder_instantiation (first, second, third, col, empty_line):
    #print("full adder in column " + str(col))
    partial_matrix[first][col] = full_adder_simbol
    partial_matrix[second][col] = full_adder_simbol
    partial_matrix[third][col] = full_adder_simbol
    where_sum = add_dot(empty_line, col)
    where_carry = add_dot(empty_line, col+1)
    col_first = col
    col_second = col
    col_third = col
    '''
    Since in the vhd the partial product are represented on data_parallelism+5 bits
    it is necessary to shift these data according to the structure of the dots
    This decision comes from the semplicity to generalize this behaviour in python
    counter the complexity of this operation in vhdl
    '''
    if first < levels_number and first > 0:
        col_first = col - (2*first - 2)
    if second < levels_number:
        col_second = col - (2*second - 2)
    if third < levels_number:
        col_third = col - (2*third - 2)
    '''
    End of the adjustment caused by the pp_parallelism of vhdl
    All the signals different from the initials are created on pp_parallelism*2 instead
    '''
    if col+1 < data_parallelism*2:
        vhd.FA_portmap(indent, port_map_file, str(FA_count), 
                   signals_name + str(first) + "(" + str(col_first) + ")",
                   signals_name + str(second) + "(" + str(col_second) + ")",
                   signals_name + str(third) + "(" + str(col_third) + ")", 
                   signals_name + str(where_sum) + "(" + str(col) + ")",
                   signals_name + str(where_carry) + "(" + str(col+1) + ")")
    else:
        vhd.FA_portmap(indent, port_map_file, str(FA_count), 
                   signals_name + str(first) + "(" + str(col_first) + ")",
                   signals_name + str(second) + "(" + str(col_second) + ")",
                   signals_name + str(third) + "(" + str(col_third) + ")", 
                   signals_name + str(where_sum) + "(" + str(col) + ")",
                   "open")
    return where_sum

def half_adder_instantiation (first, second, col, empty_line):
    #print("half adder in column " + str(col))
    partial_matrix[first][col] = half_adder_simbol
    partial_matrix[second][col] = half_adder_simbol
    where_sum = add_dot(empty_line, col)
    where_carry = add_dot(empty_line, col+1)
    col_first = col
    col_second = col
    '''
    Since in the vhd the partial product are represented on data_parallelism+5 bits
    it is necessary to shift these data according to the structure of the dots
    This decision comes from the semplicity to generalize this behaviour in python
    counter the complexity of this operation in vhdl
    '''
    if first < levels_number and first > 0:
        col_first = col - (2*first - 2)
    if second < levels_number:
        col_second = col - (2*second - 2)
    '''
    End of the adjustment caused by the pp_parallelism of vhdl
    All the signals different from the initials are created on pp_parallelism*2 instead
    '''

    if col+1 < data_parallelism*2:
        vhd.HA_portmap(indent, port_map_file, str(HA_count),
                   signals_name + str(first) + "(" + str(col_first) + ")",
                   signals_name + str(second) + "(" + str(col_second) + ")",
                   signals_name + str(where_sum) + "(" + str(col) + ")",
                   signals_name + str(where_carry) + "(" + str(col+1) + ")")
    else:
        vhd.HA_portmap(indent, port_map_file, str(HA_count),
                   signals_name + str(first) + "(" + str(col_first) + ")",
                   signals_name + str(second) + "(" + str(col_second) + ")",
                   signals_name + str(where_sum) + "(" + str(col) + ")",
                   "open")
    return where_sum

#Function that add the dots of sum and carry 
def add_dot (empty_line, col): 
    line_to_add = [empty]*pp_parallelism*2
    while (empty_line < len(partial_matrix)):
        if (partial_matrix[empty_line][col] == empty):
            break
        empty_line +=1
    if (empty_line == len(partial_matrix)):
        partial_matrix.append(line_to_add)
    partial_matrix[empty_line][col] = dot
    return empty_line #line in which I added the dot

def search_and_move_dots (final_line): #Look for the dots not yet assigned to adders
    for i in range(final_line):
        for j in range(pp_parallelism*2):
            if partial_matrix[i][j] == dot:
                move_dot(i, final_line, j)

def move_dot (original_line, new_line, col): #
    partial_matrix[original_line][col] = empty
    if partial_matrix[new_line][col] == empty:
        partial_matrix[new_line][col] = dot
        shifted_col = col
        if original_line < levels_number and original_line > 0:
            shifted_col = col - (2*original_line - 2)
        port_map_file.write("\t" + signals_name + str(new_line) + "(" + str(col) + ")" +
                          " <= " +
                          signals_name + str(original_line) + "(" + str(shifted_col) + ");\n")
    else:
        partial_matrix[new_line+1][col] = dot  
        shifted_col = col      
        if original_line < levels_number and original_line > 0:
            shifted_col = col - (2*original_line - 2)
        port_map_file.write("\t" + signals_name + str(new_line+1) + "(" + str(col) + ")" +
                          " <= " +
                          signals_name + str(original_line) + "(" + str(shifted_col) + ");\n")
        
#assign the final partial product of the matrix to the 2 output signals
#Where there is no dot, a zero is assigned
def to_final_signal ():
    #for loop until data_parallelism*2 to keep only the significant bits
    for i in range (data_parallelism*2):
        if partial_matrix[-2][i] == dot:
            port_map_file.write(indent + final_signal_name_1 + "(" + str(i) + ")" +
                              " <= " +
                              signals_name + str(len(partial_matrix)-2) + "(" + str(i) + ");\n")
        else:
            port_map_file.write(indent + final_signal_name_1 + "(" + str(i) + ")" +
                              " <= '0'\n")
        if partial_matrix[-1][i] == dot:
            port_map_file.write(indent + final_signal_name_2 + "(" + str(i) + ")" +
                              " <= " +
                              signals_name + str(len(partial_matrix)-1) + "(" + str(i) + ");\n")
        else:
            port_map_file.write(indent + final_signal_name_2 + "(" + str(i) + ")" +
                              " <= '0';\n")
        
def print_matrix (empty_line):
    #print the matrix
    print("\t", end='')
    for i in reversed(range(pp_parallelism*2)):
        if i > 9: print(i, end='')
        else: print(str(i) + " ", end='')
    print("")
    for i in range(len(partial_matrix)):
        if i == empty_line: 
            print("\t", end='')
            for k in range(pp_parallelism*4): 
                print("-", end='')
            print("")
        print(signals_name + str(i) + "\t", end='')
        for j in range(pp_parallelism*2):
            print(partial_matrix[i][pp_parallelism*2-1-j] + "|", end='')
        print("") 
    for i in range(pp_parallelism*5):
        print("_", end='')
    print("\n")


dadda(pp_parallelism)

port_map_file.close()
        
