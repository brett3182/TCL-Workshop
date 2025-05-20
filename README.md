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

To create variables, we reuse the element values present in the CSV file by removing any spaces between them. For instance, the element at cell (1, A), which is "Output Directory", becomes the variable OutputDirectory. This transformation is applied only to the parameter names, which are then assigned to their respective paths. The code snippet below performs this task. It is well-commented a good understanding of how it works.


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

