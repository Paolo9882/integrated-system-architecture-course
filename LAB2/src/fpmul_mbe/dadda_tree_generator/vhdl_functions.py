'''
Created on 29 nov 2021

@author: paolo

This module contains the parameters and the functions specific to generate the 
port maps in a VHDL code.
'''

entity_name_HA = "half_adder"
input1_HA = "a"
input2_HA = "b"
sum_HA = "s"
carry_HA = "cout"

entity_name_FA = "full_adder"
input1_FA = "a"
input2_FA = "b"
input3_FA = "cin"
sum_FA = "s"
carry_FA = "cout"

def HA_portmap(indent, port_map_file, port_name, input1, input2, sum, carry):
    port_map_file.write(indent + "HA" + port_name + ": " + entity_name_HA + " port map(\n")
    port_map_file.write(indent + "\t" + input1_HA + " => " + input1 + ",\n")
    port_map_file.write(indent + "\t" + input2_HA + " => " + input2 + ",\n")
    port_map_file.write(indent + "\t" + sum_HA + " => " + sum + ",\n")
    port_map_file.write(indent + "\t" + carry_HA + " => " + carry + "\n" + indent + "\t);\n\n")
    
def FA_portmap(indent, port_map_file, port_name, input1, input2, input3, sum, carry):
    port_map_file.write(indent + "FA" + port_name + ": " + entity_name_FA + " port map(\n")
    port_map_file.write(indent + "\t" + input1_FA + " => " + input1 + ",\n")
    port_map_file.write(indent + "\t" + input2_FA + " => " + input2 + ",\n")
    port_map_file.write(indent + "\t" + input3_FA + " => " + input3 + ",\n")    
    port_map_file.write(indent + "\t" + sum_FA + " => " + sum + ",\n")
    port_map_file.write(indent + "\t" + carry_FA + " => " + carry + "\n" + indent + "\t);\n\n")
    
def declare_components(indent):
    list = []
    list.append(indent + "--components declaration\n")    
    #half adder lines
    list.append(indent + "component " + entity_name_HA + " is\n")
    list.append(indent + "\tport(\n")
    list.append(indent + "\t\t" + input1_HA + ", " + input2_HA + " : in std_logic; --addends\n")
    list.append(indent + "\t\t" + sum_HA + ", " + carry_HA + " : out std_logic --sum and carry out\n")
    list.append(indent + "\t);\n")
    list.append(indent + "end component;\n\n")
    #full adder lines
    list.append(indent + "component " + entity_name_FA + " is\n")
    list.append(indent + "\tport(\n")
    list.append(indent + "\t\t" + input1_FA + ", " + input2_FA + ", " + input3_FA + " : in std_logic; --addends\n")
    list.append(indent + "\t\t" + sum_FA + ", " + carry_FA + " : out std_logic --sum and carry out\n")
    list.append(indent + "\t);\n")
    list.append(indent + "end component;\n\n")
    
    list.append(indent + "begin\n\n")
    return list

    
def write_on_vhd_file (indent, port_map_file, output_file_name, signals_name,
                       number_of_signals, levels_number, final_parallelism):
    
    with open(output_file_name, "r+") as fd:
        content = fd.readlines()
        for index, line in enumerate(content):
            if "architecture" in line and "of" in line and "is" in line:
                
                del content[index+1:len(content)] #delete all lines after that line
                break 
            
        content.append("\n" + indent + "--partial signals and port map described by dadda_tree_generator.py\n")
        for i in range(levels_number, number_of_signals):
            content.append(indent + "signal " + signals_name + str(i) + "\t: std_logic_vector(" + 
                  str(final_parallelism-1) + " downto 0);\n")
        content.append("\n")
        
        #adding declaration of components
        content.extend(declare_components(indent))
        
        port_map_file.seek(0)
        port_maps = port_map_file.readlines()
        
        content.extend(port_maps) #concatenation of file contents
        
        content.append("\nend structural;")
        fd.seek(0)
        fd.writelines(content)
            
