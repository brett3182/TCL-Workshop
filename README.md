# TCL Workshop - VLSI System Design, 16th May 2025 - 25th May 2025

## Module 1 - Introduction to TCL and VSDSYNTH Toolbox usage

This part of the workshop involves completing a task where we develop a TCL interface (TCL box) that accepts a CSV file as input, processes it through a shell script, then transfers it to a TCL script, and ultimately generates a timing report.
This main 'Task' can be achieved by dividing it into several 'sub-tasks' which are:
1. To create a command ('vsdsynth' in this project) and pass the CSV file from UNIX shell to TCL script
2. To convert all inputs to Format 1 and SDC format and pass it to the synthesis tool Yosys. Format 1 over here is the format which is understood by the synthesis tool, in our case, Yosys.
3. To convert Format 1 and SDC to Format 2 and pass it to the timing tool Opentimer. Format 2 is the formart which is understood by the STA engine.
4. To generate the output report


