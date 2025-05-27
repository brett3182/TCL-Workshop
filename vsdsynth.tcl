set enable_prelayout_timing 1

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

#Extracting number of columns and storing it in variable 'number_of_columns'
set number_of_columns [constraints columns]

#Extracting the position of the cell where clock parameters start
set clock_start [lindex [lindex [constraints search all CLOCKS] 0] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]

#Extracting the position of the cell where input and output parameters begin. It searches for keyword INPUT and OUTPUT
set input_ports_start [lindex [lindex [constraints search all INPUTS] 0] 1]
set output_ports_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]

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
puts "input port name is $inp_ports since count is $count\n"

#These puts statements write the input port parameters in SDC format to the .sdc file present in the output directory
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"

#Incrementing to loop over all input ports
set i [expr {$i+1}]
}
close $tmp2_file

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


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------Synthesis Script-----------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#This section is used to create the synthesis script '.ys' file required by yosys to perform synthesis. The fileId over here refers to the synthesis script. 
#Basically, we are dumping all the commands and verilog files that would be required to perform synthesis.
puts "\nInfo: Creating main synthesis script to be used for yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
#puts "\nfilename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
#puts "open \"$OutputDirectory/$filename\" in write mode"
puts -nonewline $fileId $data
#puts "netlist is \"$netlist\""
set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
        set data $f
        #puts "data is \"$f\""
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
                                                                                                                                                                                          752,1         Bot
