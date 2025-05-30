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
