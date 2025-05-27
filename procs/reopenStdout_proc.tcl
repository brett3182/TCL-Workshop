#This proc is used to dump all our puts in a new file
proc reopenStdout {file} {
    #Close the screen log
    close stdout
    #Open a new filename 'file' in write mode
    open $file w
}
