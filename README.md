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

***Brief description of the shell script***

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
4. If everything is correct, pass it on to the TCL script
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

Here after the command 'vsdsynth' no csv file is mentioned as an argument. The shell script notices this and flags an error. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/1.png?raw=true)

**Event 2: User provides incorrect CSV file**

Here a CSV file my.csv is mentioned after the command but this file doesn't exist. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/2.png?raw=true)

**Event 3: User requests help**

Information regarding the parameters are provided. 

![image alt](https://github.com/brett3182/TCL-Workshop/blob/main/Images/Module_1_Outputs/3.png?raw=true)


This completes the first module and the first sub-task. 




