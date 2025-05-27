# TCL Workshop - VLSI System Design, 16th May 2025 - 25th May 2025

## Module 1 - Introduction to TCL and VSDSYNTH Toolbox usage

This part of the workshop involves completing a task where we develop a TCL interface (TCL box) that accepts a CSV file as input, processes it through a shell script, then transfers it to a TCL script, and ultimately generates a timing report.

This main 'Task' can be achieved by dividing it into several 'sub-tasks' which are:
1. To create a command ('vsdsynth' in this project) and pass the CSV file from UNIX shell to TCL script
2. To convert all inputs to Format 1 and SDC format and pass it to the synthesis tool Yosys. Format 1 over here is the format which is understood by the synthesis tool, in our case, Yosys.
3. To convert Format 1 and SDC to Format 2 and pass it to the timing tool Opentimer. Format 2 is the format which is understood by the STA engine.
4. To generate the output report

This module will focus on the first sub-task:

### Create a command ('vsdsynth') and pass the CSV file from UNIX shell to TCL script

Before starting this sub-task, we need to handle some general unexpected events that might occur, which our shell script should be able to manage.
1. User does not provide a CSV file as an input.
2. User provides a CSV file which doesn't exist.
3. User requests '-help'.

With that said, we will now move on to the shell script. It includes a logo featuring my name, followed by some basic details.  


```
#!/bin/tcsh -f

echo "   *********      *********       *********       ***********     ***********     "
echo "   *        *     *        *      *                    *               *          "
echo "   *        *     *        *      *                    *               *          "
echo "   *        *     *        *      *                    *               *          "
echo "   *        *     *        *      *                    *               *          "
echo "   *********      *********       *********            *               *          "
echo "   *        *     * *             *                    *               *          "
echo "   *        *     *   *           *                    *               *          "
echo "   *        *     *     *         *                    *               *          "
echo "   *        *     *       *       *                    *               *          "
echo "   *********      *         *     *********            *               *          "
echo "                                                                                  "
echo "                                                                                  "
echo "                                Author: Brett Stephen Pinto                       "
echo "                  Script created in accordance with TCL workshop organized        "
echo "                                  by VLSI System Design                           "
echo "                                   Date: 16th May 2025                            "

set my_work_dir = 'pwd'

#**************************************************
#*******         INITIALIZATION         ***********
#**************************************************

#This script checks for three scenarios dicussed in the lectures. The first 'if-then' loop checks whether there is a csv file provided as an input argument. 
#The two nested 'if-then' loops then check for the condition of incorrect CSV files provided by the user (incorrect name or path, basically the file doesn't exist)
# and the condition if the user requests '-help'
# Finally if no error is present, the CSV file will be passed on to the TCL script


#Checks if csv file is provided as input
if ($#argv != 1) then
        echo "ERROR"
        echo "Error Info: No CSV file provided as an input"
        exit 1
endif

#Checks if file not present OR user requests help 
if (! -f $argv[1] || $argv[1] == "-help") then

        if ($argv[1] != "-help") then
                echo "Error: Cannot find csv file $argv[1]. Exiting......."
                exit 1
        else
                echo USAGE: ./vsdsynth \<csv file\>
                echo
                echo where \<csv file\> consists of 2 columns
                echo
                echo \<Design Name\> is the name of top level module
                echo
                echo \<Output Directory\> is the name of output directory where you want to dump synthesis script, synthesized netlist and timing reports
                echo
                echo \<Netlist Directory\> is the name of directory where all RTL netlist are present
                echo
                echo \<Early Library Path\> is the file path of the early cell library to be used for STA
                echo
                echo \<Late Library Path\> is the file path of the late cell library to be used for STA
                echo
                echo \<Constraints file\> is csv file path of constraints to be used for STA
                echo
                exit 1
        endif

#If no errors are present pass CSV (argv[1]) into tcl script vsdsynth.tcl
else
        tclsh vsdsynth.tcl $argv[1]
endif
```

***Brief description of the shell script:***

The three events are handled by the if-then blocks.

1. If user does not provide a CSV file, display an error
```
if ($#argv != 1) then
        echo "ERROR"
        echo "Error Info: No CSV file provided as an input"
        exit 1
endif
```

2. If user provides an incorrect CSV file:
```
if (! -f $argv[1] || $argv[1] == "-help") then

        if ($argv[1] != "-help") then
                echo "Error: Cannot find csv file $argv[1]. Exiting......."
                exit 1
```
3. User requests help
```
else
                echo USAGE: ./vsdsynth \<csv file\>
                echo
                echo where \<csv file\> consists of 2 columns
                echo
                echo \<Design Name\> is the name of top level module
                echo
                echo \<Output Directory\> is the name of output directory where you want to dump synthesis script, synthesized netlist and timing reports
                echo
                echo \<Netlist Directory\> is the name of directory where all RTL netlist are present
                echo
                echo \<Early Library Path\> is the file path of the early cell library to be used for STA
                echo
                echo \<Late Library Path\> is the file path of the late cell library to be used for STA
                echo
                echo \<Constraints file\> is csv file path of constraints to be used for STA
                echo
                exit 1
        endif
```
4. If everything is correct, pass the CSV to the TCL script
```
else
        tclsh vsdsynth.tcl $argv[1]
endif
```




The results are as follows:

**'vsdsynth' command created and the three events discussed above handled**

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/4.png?raw=true)
![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/5.png?raw=true)

**Event 1: User does not provide a CSV file**

Here after the command 'vsdsynth' no csv file is provided as an argument. The shell script notices this and flags an error. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/1.png?raw=true)

**Event 2: User provides incorrect CSV file**

Here a CSV file my.csv is provided after the command but this file doesn't exist. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/2.png?raw=true)

**Event 3: User requests help**

Information regarding the parameters are provided. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/3.png?raw=true)


This completes the first module and the first sub-task. 




## Module 2 - Variable Creation and Processing Constraints from CSV File

In this module, we will start writing the actual TCL script. 

As discussed in Module 1, if everything functions correctly, the CSV file is successfully passed on to the TCL script for further processing.

This module is divided into three sub-parts:
1. Creating variables using the variable names present in the CSV file.
2. Verifying path existence by checking whether the specified file and directory paths exist.
3. Converting the constraints from CSV format to SDC format.

**2.1 Creating variables**

We have two CSV files with us, one of which contains the basic design details. This file includes the paths to important files and directories that will be required for processing. The file is named openMSP430_design_details.csv. Below is a snapshot of the CSV file:

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_2/2.png?raw=true)

To create variables, we reuse the element values present in the CSV file by removing any spaces between them. For instance, the element at cell (1, A), which is "Output Directory", becomes the variable OutputDirectory. This transformation is applied only to the parameter names, which are then assigned to their respective paths. The code snippet below performs this task. It is well-commented to give a good understanding of how it works. This TCL script also converts relative paths (eg. ~/verilog) to absolute paths (/home/vsduser/vsdsynth/verilog).


```
#-----------------------------------------------------------------------------------:---------------------------------------------------------------------#
#---------------This section of the code is used to auto-create variables. This is done using the pre-existent variable names in the CSV file. ----------#
#-------------------------We are just removing the spaces between variable names eg: Output Directory becomes OutputDirectory. --------------------------#
#--------------------------------------------------------------------------------------------------------------------------------------------------------#


#This command accesses contents present at index 0 of argv. argv is our csv file which is passed from the shell script. It is stored as variable 'filename' 
set filename [lindex $argv 0]

#These two packages are required for processing csv and matrix operations
package require csv
package require struct::matrix

#This command creates a new matrix object named 'm'
struct::matrix m

#This command opens the csv file and stores the opened file in variable f. Similar to vim command. 
set f [open $filename]

#This command converts our csv cell values into matirx format and stores it in matrix 'm'. auto is used to automatically assign the rows and columns
csv::read2matrix $f m , auto

#Close the opened csv file because now we have the contents in matrix 'm'
close $f

#Sets the number of columns to variable 'columns'
set columns [m columns]

#m add columns $columns. This commented command is used to add more columns if required. Not needed in our case

#We convert matrix 'm' into an array called 'my_arr'. This is done to access individual elements of the matrix
m link my_arr

#Setting the numnber of rows
set num_of_rows [m rows]

#------------------This ends the process of accessing contents of the csv file. Now the next section creates variables using pre-existent names present in the csv file----#

#Initialize a variable i.
set i 0

#This part loops over column 0, removes it spaces to create variable name and then assigns it to a value which is present in column 1

while {$i < $num_of_rows} {
        puts "\nInfo: Setting $my_arr(0,$i) as '$my_arr(1,$i)'"
        if {$i==0} {
                #Since the first object is just a name 
                set [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
        } else {
                #The second part of the command normalizes the entire paths. eg ~/Desktop becomes /home/user/Desktop
                set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
        }
        #Increment count. expr is evalute an expression
        set i [expr {$i+1}]
}

#Below messages to print to make the user informed about the variabe names and paths
puts "\nInfo: Below are the list of initial variables and their values. These can be used for debugging"
puts "DesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"
```

The result is shown in the image below. The corresponding variables and their respective paths have been printed.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_2/1.png?raw=true)


**2.2 Verifying path existence**

The CSV file contains the paths to various files and directories, but we need to validate their existence before proceeding further in the script. For example, if the netlist directory does not exist, we won't have access to the RTL netlists required for further processing. Therefore, it is essential to check whether the paths specified in the CSV file actually exist. This is done by the below code snippet. 

```
#----------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-------------------This section of the script checks whether the files and directories mentioned in the CSV file exists or not----------------------------------#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------#

#Checking if early cell library .lib file exists or not. If not, then exit from TCL script
if {! [file exists $EarlyLibraryPath]} {
        puts "\nError: Cannot find early cell library in path $EarlyLibraryPath. Exiting..."
        exit
} else {
        puts "\nInfo: Early cell library found in path $EarlyLibraryPath"
}

#Checking if late cell library .lib file exists or not. If not, then exit from TCL script
if {! [file exists $LateLibraryPath]} {
        puts "\nError: Cannot find late cell library in path $LateLibraryPath. Exiting..."
        exit
} else {
        puts "\nInfo: Late cell library found in path $LateLibraryPath"
}

#Checking if Output directory exists or not. If not, then create the output directory.
if {! [file isdirectory $OutputDirectory]} {
        puts "\nError: Cannot find output directory $OutputDirectory. Creating $OutputDirectory"
        file mkdir $OutputDirectory
} else {
        puts "\nInfo: Output directory found in path $OutputDirectory"
}

#Checking if netlist directory exists or not. If not, then exit from TCL script
if {! [file isdirectory $NetlistDirectory]} {
        puts "\nError: Cannot find RTL netlist directory in path $NetlistDirectory. Exiting..."
        exit
} else {
        puts "\nInfo: Netlist directory found in path $EarlyLibraryPath"
}

#Checking if constraints file exists or not. If not, then exit from TCL script
if {! [file exists $ConstraintsFile]} {
        puts "\nError: Cannot find constraints file in path $ConstraintsFile. Exiting..."
        exit
} else {
        puts "\nInfo: Constraints file found in path $ConstraintsFile"
}
```

If all files and directories exist then the script produces the below output. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_2/3.png?raw=true)

If the output directory does not exist, then the script flags an error and then creates the output directory. This is done only in case of output directory because it is where the final report would be stored. It does not have pre-existent files that would be required for processing. 
 
![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_2/4.png?raw=true)

If any file or directory does not exist, the script displays an error message and stops execution without proceeding further.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_2/5.png?raw=true)


**2.3 Converting constraints file into SDC**

The second CSV file we have is the constraints file, named openMSP430_design_constraints.csv. This file contains information about various design constraints and is divided into three main sections: CLOCKS, INPUTS, and OUTPUTS. Below is a snippet of the CSV file.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_2/7.png?raw=true)

Converting these constraint values into SDC format involves several steps. In this module, we will focus on the first part: extracting the positions or sections in the CSV file where it is divided into CLOCKS, INPUTS, and OUTPUTS. The code snippet below performs this task:

```
#------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-------------------------This part of the script converts the constraints file openMSP430_design_constraints.csv into SDC format----------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------------------------#


puts "\nInfo: Dumping SDC constraints for $DesignName"

#Create a matrix named 'constraints' where the openMSP430_design_constraints.csv elements would be stored
::struct::matrix constraints

#Open the constraint file and store the elements in a variable 'chan'
set chan [open $ConstraintsFile]

#Convert csv elements into matrix format and store then in matrix 'constraints'. The individual elements can be identified using comma ','. auto is used to automatically detect number of rows and columns
csv::read2matrix $chan constraints , auto

#Close opened csv because we have the elements in matrix 'constraints' now
close $chan

#Extracting number of rows and storing it in variable 'number_of_rows'
set number_of_rows [constraints rows]
puts "number_of_rows = $number_of_rows"

#Extracting number of columns and storing it in variable 'number_of_columns'
set number_of_columns [constraints columns]
puts "number_of_columns = $number_of_columns"

#Extracting the position of the cell where clock parameters start
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts "clock_start = $clock_start"
puts "clock_start_column = $clock_start_column"

#Extracting the position of the cell where input and output parameters begin. It searches for keyword INPUT and OUTPUT
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
puts "input_ports_start = $input_ports_start"
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
puts "output_ports_start = $output_ports_start"
```

We can see that the corresponding positions have been successfully extracted.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_2/6.png?raw=true)

This completes our second module. 

## Module 3 - Processing Clock and Input Constraints

Until the second module, we identified the positions where the clock, input, and output ports begin in the CSV file. In this module, we will work on writing the actual SDC file using the constraints defined in the constraints.csv file (2nd csv file). We will process each part, clock, input, and output separately.

This module would cover the first two parts, clock and input. 

**Clock constraints**

The code snippet below converts the parameters given in the constraints.csv file into the SDC format. The TCL script first identifies the column numbers where the parameters (e.g., early_rise_delay, late_fall_delay) begin. It also creates an SDC file if one is not already present in the output directory. Based on the identified column numbers, we loop over that section and write the values in SDC format. Note that this script is only to process the clock constraints. 

```
#-----------------------------------------------------------------  Clock constraints---------------------------------------------------------------------#

#-----------------------------------------------------------------Clock latency constraints---------------------------------------------------------------#

#The four commands below find the position where the clock delay constraint parameters - refer csv file (eg. early_rise_delay, late_fall_delay) are present in the matrix 'constraints'
#It then assigns the position to that variable
set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_delay] 0] 0]

set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_delay] 0] 0]

set clock_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_delay] 0] 0]

set clock_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_delay] 0] 0]

#------------------------------------------------------------------Clock transition constraints------------------------------------------------------------#

#The four commands below find the position where the clock slew constraint parameters - refer csv file (eg. early_rise_slew, late_fall_slew) are present in the matrix 'constraints'
set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_rise_slew] 0] 0]

set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] early_fall_slew] 0] 0]

set clock_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_rise_slew] 0] 0]

set clock_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$number_of_columns-1}] [expr {$input_ports_start-1}] late_fall_slew] 0] 0]

#Creating the sdc file in the output directory
set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]

#Initialize a variable 'i' and increment it to 1 since the parameter values start from second row
set i [expr {$clock_start+1}]

#Position where the clock ports end
set end_of_ports [expr {$input_ports_start-1}]

#Info statement to print out 
puts "\nInfo-SDC: Working on clock constraints...."

#This loop writes the constraints in the sdc file
while { $i < $end_of_ports } {
        puts "Starting clock SDC writing for [constraints get cell 0 $i]"
        puts -nonewline $sdc_file "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}]\} \[get_ports [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [constraints get cell $clock_late_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [constraints get cell $clock_late_fall_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]"
        set i [expr {$i+1}]
}
```

After executing this script we can see that both clocks have been processed.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/1.png?raw=true)

An SDC file has also been created.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/2.png?raw=true)

After opening the SDC file, we can see that our CSV constraints have been converted into SDC format.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/3.png?raw=true)

We can verify the parameter values by validating them against the CSV file. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/4.png?raw=true)

This completes processing our clock constraints. 

**Input constraints**

As we did for the clock constraints, we also need to convert our input constraints into SDC format. However, there are some changes here. Earlier, our clock was a single-bit bus, but in the case of inputs, the ports can be either single-bit or multi-bit (bussed). For bussed ports, we have to add an asterisk '*' after the port name in the SDC file, as required by the SDC format. Our constraints.csv file does not indicate whether a port is single-bit or bussed. Therefore, we need to go through each Verilog file to check whether a given port is single-bit or bussed.

Now, the first step is to search for the port name in all the Verilog files. The following TCL script performs this task. This code will also store only the input port names and eliminate any comments.
```
#----------------------------------------------------------------------------------------Input constraints----------------------------------------------------------------------------------------#
#Setting delay parameters (extracting the position in  the matrix 'constraints'
set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_delay] 0] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_delay] 0] 0]
set input_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_delay] 0] 0]
set input_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_delay] 0] 0]

#Setting slew parameters (extracting the position in the matrix 'constraints'
set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_rise_slew] 0] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] early_fall_slew] 0] 0]
set input_late_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_rise_slew] 0] 0]
set input_late_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] late_fall_slew] 0] 0]

#Setting the clock parameter for input
set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_ports_start [expr {$number_of_columns-1}] [expr {$output_ports_start-1}] clocks] 0] 0]

#Initialize i to loop over
set i [expr {$input_ports_start+1}]

#Set end of input ports 
set end_of_ports [expr {$output_ports_start-1}]

#Info messages to be printed
puts "\nInfo-SDC: Working on SDC constraints...."
puts "\nInfo-SDC: Categorizing input ports as bits and bussed"

while { $i < $end_of_ports } {
        #Differentiating input ports as bussed and bits
        #Select each and every netlist one by one
        set netlist [glob -dir $NetlistDirectory *.v]
        #To store the final result in a temporary file with write access
        set tmp_file [open /tmp/1 w]
        #Loop to identify input  port names
        foreach f $netlist {
                set fd [open $f]
                #puts "reading file $f"
                while {[gets $fd line] != -1} {
                        set pattern1 " [constraints get cell 0 $i];"
                        if {[regexp -all -- $pattern1 $line]} {
                                #puts "pattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
                                set pattern2 [lindex [split $line ";"] 0]
                                #puts "creating pattern2 by splitting pattern1 using semi-colon as delimeter => \"$pattern2\""
                                if {[regexp -all {input} [lindex [split $pattern2 "\S+"] 0]]} {
                                #puts "out of all patterns, \"$pattern2\" has matching string \"input\". So preserving this line and ignoring others"
                                set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
                                #puts "printing first 3 elements of pattern2 as \"$s1\" using space as delimeter"
                                puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
                                #puts "replace multiple spaces in s1 by single space and reformat as \"[regsub -all {\s+} $s1 " "]\""
                                }
                }
}
close $fd
}
close $tmp_file
```

For the first input port, cpu_en, we can see that it was found in multiple modules, as shown in the output below.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/5.png?raw=true)

After processing all the Verilog files, all the port names are stored in a temporary file. Since ports appear in multiple modules, their names are repeated in this file. To remove duplicates, we “uniqify” the list using four stages: read, split, sort, and join. A specific command in our script reads the entire content of the file, splits it into a list of lines based on newline characters, sorts the list alphabetically while removing duplicates, and then joins the sorted unique lines back into a single string separated by newlines. This process is performed by the TCL script below. The script also identifies whether ports are bussed or single-bit by counting the number of elements in the declaration: single-bit ports have two elements (e.g., input cpu_en), while bussed ports have three elements (e.g., input [3:0] cpu_en). We use this method to differentiate bussed ports from single-bit ports. 

```
#Opening our temporary file 1 in read mode
set tmp_file [open /tmp/1 r]

#Creating and opening another temporary file 2 in write mode. This temp2 file will have our unique (non-redundant) ports
set tmp2_file [open /tmp/2 w]

#The below 4 puts statements are info messages just to check whether the operations of read, split, sort and join are happening properly. 
#We can't use them together because TCL allows only command to read the file. If all 4 of them are used together only read for first one will work and may lead to errors later on.
#puts "reading [read $tmp_file]"
#puts "splitting /tmp/1 file as [split [read $tmp_file] \n]"
#puts "sorting /tmp/1 file as [lsort -unique [split [read $tmp_file] \n]]"
#puts "joining /tmp/1 file as [join [lsort -unique [split [read $tmp_file] \n]] ]"

#Final unique ports present in tmp2 file
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file

#Opening temp2 file in read mode
set tmp2_file [open /tmp/2 r]

#Counting the number of elements in each individal port of temp2. If count is 2 then it is not bussed, if 3 then bussed
set count [llength [read $tmp2_file]]
#puts "Count is $count"

#This if-then loops helps to put * over multi-bit (bussed ports)
if {$count >2} {
        set inp_ports [concat [constraints get cell 0 $i]*]
        #puts "\nBussed"
} else {
        set inp_ports [constraints get cell 0 $i]
        #puts "\nNot Bussed"
}

#Info to print to the user. This will also tell whether the port is bused or not by noticing the *
puts "output port name is $inp_ports since count is $count\n"
```

The results at each individual stage are as follows:

1. Reading the temporary file

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/6.png?raw=true)

2. Splitting the individual ports

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/7.png?raw=true)

3. Sorting or uniquely identifying the elements

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/8.png?raw=true)

4. Joining the strings

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/9.png?raw=true)

5. Identifying ports as single bit or bussed

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/10.png?raw=true)

6. Final result

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/11.png?raw=true)

Now that we have our input ports, the next step is to write them into the SDC file. The TCL script below performs this task.

```
#These puts statements write the output port parameters in SDC format to the .sdc file present in the output directory
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_late_fall_delay_start $i] \[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\nset_output_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_output_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_fall_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_output_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_late_rise_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_output_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_late_fall_slew_start $i] \[get_ports $inp_ports\]"

#Incrementing to loop over all output ports
set i [expr {$i+1}]
}
close $tmp2_file
```

After executing this, we will see the input constraints written to the SDC file.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/12.png?raw=true)

We can validate them with respect to the csv file.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_3/13.png?raw=true)

This completes processing our input constraints. 



## Module 4 - Complete Scripting and Yosys Synthesis Introduction 

This module completes the final part of SDC constraints generation by processing the output ports. After this, the next step is to create a synthesis script for the Yosys synthesis tool. The script involves several steps, one of which is hierarchy checking, and that will be discussed in this module. 

**Output Constraints**

The script for output constraints complements the one used for input constraints, as the underlying algorithm remains the same. Below is the script used to process the output constraints.

```
#----------------------------------------------------------------------------------------Output constraints----------------------------------------------------------------------------------------#

#Setting delay parameters (extracting the position in  the matrix 'constraints'
set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}]  load] 0 ] 0]
set output_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_rise_delay] 0] 0]
set output_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] early_fall_delay] 0] 0]
set output_late_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_rise_delay] 0] 0]
set output_late_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] late_fall_delay] 0] 0]

#Setting the clock parameter for output
set related_clock [lindex [lindex [constraints search rect $clock_start_column $output_ports_start [expr {$number_of_columns-1}] [expr {$number_of_rows-1}] clocks] 0] 0]

#Initialize i to loop over
set i [expr {$output_ports_start+1}]

#Set end of output ports 
set end_of_ports [expr {$number_of_rows}]

#Info messages to be printed
puts "\nInfo-SDC: Working on SDC constraints...."
puts "\nInfo-SDC: Categorizing output ports as bits and bussed"

while { $i < $end_of_ports } {
        #Differentiating output ports as bussed and bits
        #Select each and every netlist one by one
        set netlist [glob -dir $NetlistDirectory *.v]
        #To store the final result in a temporary file with write access
        set tmp_file [open /tmp/1 w]
        #Loop to identify output  port names
        foreach f $netlist {
                set fd [open $f]
                #puts "reading file $f"
                while {[gets $fd line] != -1} {
                        set pattern1 " [constraints get cell 0 $i];"
                        if {[regexp -all -- $pattern1 $line]} {
                                #puts "pattern1 \"$pattern1\" found and matching line in verilog file \"$f\" is \"$line\""
                                set pattern2 [lindex [split $line ";"] 0]
                                #puts "creating pattern2 by splitting pattern1 using semi-colon as delimeter => \"$pattern2\""
                                if {[regexp -all {output} [lindex [split $pattern2 "\S+"] 0]]} {
                                #puts "out of all patterns, \"$pattern2\" has matching string \"output\". So preserving this line and ignoring others"
                                set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
                                #puts "printing first 3 elements of pattern2 as \"$s1\" using space as delimeter"
                                puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
                                #puts "replace multiple spaces in s1 by single space and reformat as \"[regsub -all {\s+} $s1 " "]\""
                                }
                }
}
close $fd
}
close $tmp_file
#Opening our temporary file 1 in read mode
set tmp_file [open /tmp/1 r]

#Creating and opening another temporary file 2 in write mode. This temp2 file will have our unique (non-redundant) ports
set tmp2_file [open /tmp/2 w]

#The below 4 puts statements are info messages just to check whether the operations of read, split, sort and join are happening properly. 
#We can't use them together because TCL allows only command to read the file. If all 4 of them are used together only read for first one will work and may lead to errors later on.
#puts "reading [read $tmp_file]"
#puts "splitting /tmp/1 file as [split [read $tmp_file] \n]"
#puts "sorting /tmp/1 file as [lsort -unique [split [read $tmp_file] \n]]"
#puts "joining /tmp/1 file as [join [lsort -unique [split [read $tmp_file] \n]] ]"

#Final unique ports present in tmp2 file
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file

#Opening temp2 file in read mode
set tmp2_file [open /tmp/2 r]

#Counting the number of elements in each individal port of temp2. If count is 2 then it is not bussed, if 3 then bussed
set count [llength [read $tmp2_file]]
#puts "Count is $count"

#This if-then loops helps to put * over multi-bit (bussed ports)
if {$count >2} {
        set op_ports [concat [constraints get cell 0 $i]*]
        #puts "\nBussed"
} else {
        set op_ports [constraints get cell 0 $i]
        #puts "\nNot Bussed"
}

#Info to print to the user. This will also tell whether the port is bused or not by noticing the *
puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports]"
puts "output port name is $op_ports since count is $count\n"
#These puts statements write the output port parameters in SDC format to the .sdc file present in the output directory
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"

#Incrementing to loop over all output ports
set i [expr {$i+1}]
}
close $tmp2_file
close $sdc_file

puts "\nInfo: SDC created. Please check constraints in path $OutputDirectory/$DesignName.sdc"
```

Finally, after processing all the constraints, we get the message: "SDC created."

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/1.png?raw=true)

We can see that the output constraints have been written successfully in the SDC file. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/2.png?raw=true)

We can validate it with respect to the csv file. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/3.png?raw=true)

This completes the processing of our output constraints and, with it, all the constraints. We have now successfully converted the constraints.csv file into an SDC file.

**Hierarchy Check**

The next step is to check whether all the Verilog modules have been included in the top-level module. This is part of the hierarchy check.

Before proceeding with the hierarchy check, we first need to create the synthesis script. The Yosys tool expects the synthesis script in a specific format. The initial part of this process is handled by the script shown below. It creates a file named openMSP430.hier.ys and writes the appropriate synthesis commands into it, including specifying the paths to all the Verilog files. This is accomplished by the code below.

```
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------------Hierarchy Check----------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#Info message to be printed
puts "\nInfo: Creating hierarchy check script to be used by Yosys"

#This command is required for synthesis script. The late library file is set to variable data
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"

#Printing out path of late library file
puts "data is \"$data\""

#Create a new file openMSP430.hier.ys and store it in variable filename
set filename "$DesignName.hier.ys"

#Print out the filename
puts "filename is \"$filename\""

#Open the hierarchy.ys file in write mode to write all the things which would be required by synthesis script
set fileId [open $OutputDirectory/$filename "w"]
puts "open \"$OutputDirectory/$filename\" in write mode"

#First line to be written in synthesis script
puts -nonewline $fileId $data

#Go through all the netlists 
set netlist [glob -dir $NetlistDirectory *.v]
puts "netlist is \"$netlist\""

#Loop through each of the .v file one by one and enter the loop
foreach f $netlist {
        set data $f
        #Print out for user info
        puts "data is \"$f\""
        #Each of the .v file path to be written in .hier.ys synthesis script file
        puts -nonewline $fileId "\nread_verilog $f"
}

#Add this line in synthesis script file .hier.ys after all netlist files have been added
puts -nonewline $fileId "\nhierarchy -check"
close $fileId
```

The code is well-commented to help understand the underlying process, and the outputs at various steps are shown below.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/4.png?raw=true)

The synthesis script file for Yosys is also created.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/5.png?raw=true)

The contents of the file are the commands required by Yosys to perform syntheis. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/6.png?raw=true)

The next step is to perform the actual hierarchy check, which is handled by the script below.

```
#Info messages to be printed
puts "\nclose \"$OutputDirectory/$filename\"\n"
puts "\nChecking hierarchy...."

#This command checks for any 'ERROR' in the synthesis script. If there is an error it flags a logic 1
#It executes a shell command 'yosys' in the TCL script. Our yosys runs our synthesis script and stores the logs as mentioned in the command
set my_err [catch {exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "err flag is $my_err"

#If there is an error in hierarchy do this
if { $my_err } {
        #Our log file
        set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
        puts "log file name is $filename"
        #Whenever an error occurs yosys prints 'referenced in module'. So we will be searching for this keyword
        set pattern {referenced in module}
        puts "pattern is $pattern"
        set count 0
        #Opening our log file in read mode
        set fid [open $filename r]
        #Go through all the lines
        while {[gets $fid line] != -1} {
                #redundant ststement. Does same functionality as 'if-then' then in the next line
                incr count [regexp -all -- $pattern $line]
                #Checks whether the pattern 'referenced in module' which occurs during error is present in any line
                if {[regexp -all -- $pattern $line]} {
                        #If error occurs print out this
                        puts "\nError: module [lindex $line 2] is not part of design $DesignName. Please correct RTL in the path '$NetlistDirectory'"
                        puts "\nInfo: Hierarchy check FAIL"
                }
        }
        close $fid
} else {
        puts "\nInfo: Hierarchy check PASS"
}
puts "\nInfo: Please find hierarchy check details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info"
```

If everything is properly connected, there will be no hierarchy errors, and we will get the output 'Hierarchy check PASS'

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/7.png?raw=true)

If the hierarchy is not maintained, such as when the module omsp_alu is not instantiated properly in the top module, we get the output 'Hierarchy check FAIL'

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/8.png?raw=true)

The error is mentioned in the terminal itself but we can also check the log file to validate it. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_4/9.png?raw=true) 

This completes our hierarchy check. 



## Module 5 - Advanced Scripting Techniques and Quality of Results of Generation

This module involves creating the synthesis script, utilizing procedures (procs) in the TCL script, analyzing the final timing results, and generating the final report.

**Synthesis Script**

Our synthesis tool, Yosys, requires a script file (.ys) to carry out synthesis. The TCL script below generates this synthesis script file (openMSP430.ys) and then executes the synthesis process.

```
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------Synthesis Script-----------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#This section is used to create the synthesis script '.ys' file required by yosys to perform synthesis. The fileId over here refers to the synthesis script. 
#Basically, we are dumping all the commands and verilog files that would be required to perform synthesis.
puts "\nInfo: Creating main synthesis script to be used for yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
puts "\nfilename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
puts "open \"$OutputDirectory/$filename\" in write mode"
puts -nonewline $fileId $data
puts "netlist is \"$netlist\""
set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
        set data $f
        puts "data is \"$f\""
        puts -nonewline $fileId "\n read_verilog $f"
}

puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format __\ndfflibmap -liberty ${LateLibraryPath}\nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt \nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis script created and can be accessed from the path $OutputDirectory/$filename"
puts "\nInfo: Running Synthesis...."

#----------------------------------------------------------------Run synthesis script using yosys-----------------------------------------------------------------------------------------#

#This command 'catches' for any error present while performing synthesis
#It executes synthesis using the .ys script we created earlier and stores the output messages in the log file and scans it for any error messages
#If error is present, it stops synthesis
if {[catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
        puts "\nError: Synthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors"
        exit
} else {
        puts "\nInfo: Synthesis finished successfully"
}
puts "\nInfo: Please refer to log $OutputDirectory/$DesignName.synthesis.log"
```

Synthesis script file created:

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/2.png?raw=true)

If there are no errors, then our synthesis is executed successfully. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/1.png?raw=true)

If there are errors while executing synthesis, the script stops and we get a error message. We can check the log file for error details or do a 'grep -i error' in our terminal to list out all the errors. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/3.png?raw=true) 

Now, the synthesized file (.synth.v) from Yosys contain some unwanted characters such as asterisks '*' and backslashes. These are shown in the image below:

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/4.png?raw=true)

We have around 6000 such characters in our openMSP430.synth.v file. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/5.png?raw=true)

These characters are not accepted by our timing tool, OpenTimer, so we need to remove them. The script below handles this task.

```
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------Edit .synth.v file to be usable by Opentimer----------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#This section is used to remove all the asterisks '*' and backslashes '\' from the synthesized .v file. 
#This is done because the Opentimer tool doesn't accept these characters.
set fileId [open /tmp/1 "w"]
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]

while {[gets $fid line] != -1} {
        puts -nonewline $output [string map {"\\" ""} $line]
        puts -nonewline $output "\n"
}
close $fid
close $output

puts "\nInfo: Please find the synthesized netlist for $DesignName at below path. You can use this netlist for STA or PNR"
puts "\n$OutputDirectory/$DesignName.final.synth.v"
```

After executing this, all the unwanted characters are removed. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/7.png?raw=true)

The count now is 0. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/6.png?raw=true)



**Procs**

A proc in TCL is a reusable block of code that performs a specific task. We have used five procs for our script. They are briefly explained as follows:

**1. reopenStdout proc** - This proc is used to close our current screen log and dump out the messages in a new file.

```
#This proc is used to dump all our puts in a new file
proc reopenStdout {file} {
    #Close the screen log
    close stdout
    #Open a new filename 'file' in write mode
    open $file w
}
```

**2. set_multi_cpu_usage proc** - This proc enables multi-threading to achieve faster execution.

```
proc set_multi_cpu_usage {args} {
        array set options {-localCpu <num_of_threads> -help "" }
        #foreach {switch value} [array get options] {
        #puts "Option $switch is $value"
        #}
        while {[llength $args]} {
        #puts "llength is [llength $args]"
        #puts "lindex 0 of \"$args\" is [lindex $args 0]"
                switch -glob -- [lindex $args 0] {
                -localCpu {
                           #puts "old args is $args"
                           set args [lassign $args - options(-localCpu)]
                           #puts "new args is \"$args\""
                           puts "set_num_threads $options(-localCpu)"
                          }
                -help {
                           #puts "old args is $args"
                           set args [lassign $args - options(-help) ]
                           #puts "new args is \"$args\""
                           puts "Usage: set_multi_cpu_usage -localCpu <num_of_threads>"
                      }
                }
        }
}
```

If we set the arguments as '-localCpu 8 -help', we get the results as shown below. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/8.png?raw=true)

In our main vsdsynth.tcl script, we have defined a configuration file (.conf) to store all the parameters required by the timing tool. This proc, along with the ones that follow, stores their key results in the .conf file.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/9.png?raw=true)

After executing set_multi_cpu_usage proc, our configuration file is updated.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/10.png?raw=true)


**3. read_lib proc** - This proc is used to read our early and late cell libraries. 

```
proc read_lib args {
        array set options {-late <late_lib_path> -early <early_lib_path> -help ""}
        while {[llength $args]} {
                switch -glob -- [lindex $args 0] {
                -late {
                        set args [lassign $args - options(-late) ]
                        puts "set_late_celllib_fpath $options(-late)"
                      }
                -early {
                        set args [lassign $args - options(-early) ]
                        puts "set_early_celllib_fpath $options(-early)"
                       }
                -help {
                        set args [lassign $args - options(-help) ]
                        puts "Usage: read_lib -late <late_lib_path> -early <early_lib_path>"
                        puts "-late <provide late library path>"
                        puts "-early <provide early library path>"
                      }
                default break
                }
        }
}
```

Our configuration file is updated as shown below. 
![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/11.png?raw=true)

**4. read_verilog proc** - This proc is used to read the verilog file(s) as passed in the arguments. 

```
proc read_verilog {arg1} {
puts "set_verilog_fpath $arg1"
}
```

The configuration file is updated with the final synthesized verilog file. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/12.png?raw=true)

**5. read_sdc proc** - This proc is used to convert our SDC file into a format which is accepted by the timing tool, Opentimer. 

This involves several steps since our SDC consists of several parameters and each of them need to handled differently. First, we need to remove all the square braces '[' ']' from our SDC file. 

```
proc read_sdc {arg1} {
set sdc_dirname [file dirname $arg1]
set sdc_filename [lindex [split [file tail $arg1] .] 0 ]
set sdc [open $arg1 r]
set tmp_file [open /tmp/1 w]

puts -nonewline $tmp_file [string map {"\[" "" "\]" " "} [read $sdc]]
close $tmp_file
```

Our SDC file now looks like this:

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/13.png?raw=true)

There are three main clock SDC parameters, create_clock, set_clock_latency and set_clock_transition. All of these would be handled separately and the results would be stored in a temporary file. 

Handing create_clock constraints. 

```
#-----------------------------------------------------------------------------#
#----------------converting create_clock constraints--------------------------#
#-----------------------------------------------------------------------------#

set tmp_file [open /tmp/1 r]
set timing_file [open /tmp/3 w]
set lines [split [read $tmp_file] "\n"]
set find_clocks [lsearch -all -inline $lines "create_clock*"]
foreach elem $find_clocks {
        set clock_port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        set clock_period [lindex $elem [expr {[lsearch $elem "-period"]+1}]]
        set duty_cycle [expr {100 - [expr {[lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period}]}]
        puts $timing_file "clock $clock_port_name $clock_period $duty_cycle"
        }
close $tmp_file
```

Output results:

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/14.png?raw=true)

Handing set_clock_latency constraints.

```
#-----------------------------------------------------------------------------#
#----------------converting set_clock_latency constraints---------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_clock_latency*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
                set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
                set delay_value ""
                foreach new_elem $delays_list {
                        set port_index [lsearch $new_elem "get_clocks"]
                        lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
                }
                puts -nonewline $tmp2_file "\nat $port_name $delay_value"
        }
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```

Output results:

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/15.png?raw=true)

Handling set_clock_transition constraints.

```
#-----------------------------------------------------------------------------#
#----------------converting set_clock_transition constraints------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_clock_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
                set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
                set delay_value ""
                foreach new_elem $delays_list {
                        set port_index [lsearch $new_elem "get_clocks"]
                        lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
                }
                puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
        }
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```

Output results:

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/16.png?raw=true)

This completes our clock constraints. They are converted into the format as required by Opentimer. 

Now, the input constraints follow a similar trend. The script below handles the input constraints. 

```
#-----------------------------------------------------------------------------#
#----------------converting set_input_delay constraints-----------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_input_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
                set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
                set delay_value ""
                foreach new_elem $delays_list {
                        set port_index [lsearch $new_elem "get_ports"]
                        lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
                }
                puts -nonewline $tmp2_file "\nat $port_name $delay_value"
        }
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#----------------converting set_input_transition constraints------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_input_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
                set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
                set delay_value ""
                foreach new_elem $delays_list {
                        set port_index [lsearch $new_elem "get_ports"]
                        lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
                }
                puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
        }
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```

All the input constraints are converted into our required format. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/17.png?raw=true)

The output SDC constraints are handled in a similar fashion.

```
#-----------------------------------------------------------------------------#
#---------------converting set_output_delay constraints-----------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_output_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
                set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
                set delay_value ""
                foreach new_elem $delays_list {
                        set port_index [lsearch $new_elem "get_ports"]
                        lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
                }
                puts -nonewline $tmp2_file "\nrat $port_name $delay_value"
        }
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file

#-----------------------------------------------------------------------------#
#-------------------converting set_load constraints---------------------------#
#-----------------------------------------------------------------------------#

set find_keyword [lsearch -all -inline $lines "set_load*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
                set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*" ] ""]]
                set delay_value ""
                foreach new_elem $delays_list {
                set port_index [lsearch $new_elem "get_ports"]
                lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
                }
                puts -nonewline $timing_file "\nload $port_name $delay_value"
        }
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file  [read $tmp2_file]
close $tmp2_file
```

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/18.png?raw=true)

Now, the bussed input and output ports are converted into their bit-blasted versions and also the final timing file (.timing) is generated

```
#-----------------------------------------------------------------------------#
close $timing_file

set ot_timing_file [open $sdc_dirname/$sdc_filename.timing w]
set timing_file [open /tmp/3 r]
while {[gets $timing_file line] != -1} {
        if {[regexp -all -- {\*} $line]} {
                set bussed [lindex [lindex [split $line "*"] 0] 1]
                set final_synth_netlist [open $sdc_dirname/$sdc_filename.final.synth.v r]
                while {[gets $final_synth_netlist line2] != -1 } {
                        if {[regexp -all -- $bussed $line2] && [regexp -all -- {input} $line2] && ![string match "" $line]} {
                        puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
                        } elseif {[regexp -all -- $bussed $line2] && [regexp -all -- {output} $line2] && ![string match "" $line]} {
                        puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"
                        }
                }
        } else {
        puts -nonewline $ot_timing_file  "\n$line"
        }
}

close $timing_file
puts "set_timing_fpath $sdc_dirname/$sdc_filename.timing"
}
```

Timing file created:

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/19.png?raw=true)

This timing file contains the SDC parameters converted into a format compatible with OpenTimer. All the bussed ports have also been converted into their bit blasted versions (eg. dbg_i2c_addr* transforms to its 7-bit-blasted version dbg_i2c_addr_0, dbg_i2c_addr_1 ..... till dbg_i2c_addr_6)

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/20.png?raw=true)

All of these procs have been sourced in our main TCL script and have been called during execution.

```
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------STA using Opentimer----------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#This section sources the procs that we have created and uses them to create the .conf and .timing file
puts "\nInfo: Timing Analysis Started ... "
puts "\nInfo: Initializing number of threads, libraries, sdc, verilog netlist path..."

source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4

source /home/vsduser/vsdsynth/procs/read_lib.proc
read_lib -early /home/vsduser/vsdsynth/osu018_stdcells.lib
read_lib -late /home/vsduser/vsdsynth/osu018_stdcells.lib

source /home/vsduser/vsdsynth/procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v

source /home/vsduser/vsdsynth/procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty
```

This completes handling procs.

**Scripts for Opentimer**

Opentimer requires spef file as an input, it is created in the step below. Also, the configuration file is updated with more details. 

```
#-------------------------------------------------------------------------------SPEF file------------------------------------------------------------------------------------------------------#

#Generating .spef file
if {$enable_prelayout_timing == 1} {
        puts "\nInfo: enable prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
        set spef_file [open $OutputDirectory/$DesignName.spef w]
        puts $spef_file "*SPEF \"IEEE 1481-1998\""
        puts $spef_file "*DESIGN \"$DesignName\""
        puts $spef_file "*DATE \"Mod May 26 11:59:00 2025\""
        puts $spef_file "*VENDOR \"VLSI System Design\""
        puts $spef_file "*PROGRAM \"TCL Workshop\""
        puts $spef_file "*DATE \"0.0\""
        puts $spef_file "*DESIGN FLOW \"NETLIST_TYPE_VERILOG\""
        puts $spef_file "*DIVIDER /"
        puts $spef_file "*DELIMITER : "
        puts $spef_file "*BUS_DELIMITER [ ]"
        puts $spef_file "*T_UNIT 1 PS"
        puts $spef_file "*C_UNIT 1 FF"
        puts $spef_file "*R_UNIT 1 KOHM"
        puts $spef_file "*L_UNIT 1 UH"
}
close $spef_file

#Dumping details required by opentimer into .conf file
set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer"
puts $conf_file "report_timer"
puts $conf_file "report_wns"
puts $conf_file "report_tns"
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file
```

SPEF file created.

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/21.png?raw=true)

Contents of .spef file

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/22.png?raw=true)


Updated and final configuration file as required by timing analyzer. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/23.png?raw=true)

Now, STA is performed by our timing tool and it's runtime is calculted as follows:

```
#-------------------------------------------------------------STA runtime calculation-----------------------------------------------------------------------------------------#
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} ]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warings and errors"
```

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/24.png?raw=true)

After STA is complete, specific reports are analyzed to extract key results such as Worst Negative Slack (WNS) and the number of setup/hold violations.

```
#-------------------------------------------------------------------------Quality of results generation----------------------------------------------------------------------------------#

#-------------------------------------------------------------STA runtime calculation-----------------------------------------------------------------------------------------#
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results} ]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/100000}]sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warings and errors"


#------------------------------------------------------------ Worst output violation------------------- --------------------------#
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
                continue
        }
}
close $report_file
#------------------------------------------------------------Number of output violations------------------- ------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file

#--------------------------------------------------------------Worst setup violation -------------------------#
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Setup}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
                continue
        }
}
close $report_file


#-------------------------------------------------------Number of setup violations--------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file

#-------------------------------------------------------Worst hold violation--------------------------------#
set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Hold}
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
                break
        } else {
                continue
        }
}
close $report_file

#---------------------------------------------------Number of hold violations--------------------------------#
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
        incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file

#----------------------------------------------------Number of instances-------------------------------------------#

set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r]
while {[gets $report_file line] != -1} {
        if {[regexp $pattern $line]} {
                set Instance_count "[lindex [join $line " "] 4 ]"
                break
        } else {
                continue
        }
}
close $report_file

#----------------------------------------------------Final report--------------------------------------------------#
puts "DesignName is \{$DesignName\}"
puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
puts "Instance_count is \{$Instance_count\}"
puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
puts "worst_RAT_slack is \{$worst_RAT_slack\}"
puts "Number_output_violations is \{$Number_output_violations\}"
```

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/25.png?raw=true)

This report is formatted to present it in a industry preferred format. 

```
#------------------------------------------------Report displayed in industry preferred form-------------------------------#


puts "\n"
puts "                                          ****PRELAYOUT TIMING RESULTS****                                        "
set formatStr "%15s %15s %15s %15s %15s %15s %15s %15s %15s"

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "DesignName" "Runtime" "Instance Count" "WNS Setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $Number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $Number_output_violations {
        puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}

puts [format $formatStr "----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------END---------------------------------------------------------------------------------------------#
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
```

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/26.png?raw=true)

This completes our task. 

The files generated at the end of this process are shown below. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/Module_5_Outputs/27.png?raw=true)
