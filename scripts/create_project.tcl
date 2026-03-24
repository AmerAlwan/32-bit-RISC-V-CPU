# ============================================================
# Vivado Project Creation Script
# Robust against empty directories and Windows glob issues
# ============================================================

# Disable command echoing
set ::tcl_interactive 0

# --------------------------------
# Project settings
# --------------------------------
set PROJECT_NAME risc_v_cpu
set PROJECT_DIR  ./build
set PART xc7k325tffg900-2    ;# CHANGE if needed

# --------------------------------
# Helper: recursive glob (Vivado-safe)
# --------------------------------
proc rglob {dir pattern} {
    set results {}
    if {![file exists $dir]} {
        return $results
    }

    foreach item [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $item]} {
            lappend results {*}[rglob $item $pattern]
        } elseif {[string match $pattern [file tail $item]]} {
            lappend results $item
        }
    }
    return $results
}

# --------------------------------
# Create project
# --------------------------------
puts "Creating project $PROJECT_NAME in $PROJECT_DIR"
create_project $PROJECT_NAME $PROJECT_DIR -part $PART -force

# --------------------------------
# Language settings
# --------------------------------
set_property target_language Verilog [current_project]
set_property source_mgmt_mode All [current_project]

# --------------------------------
# Add RTL sources
# --------------------------------
# --------------------------------
# Add RTL sources (Package first!)
# --------------------------------
# 1. Find and add packages specifically
set PKG_FILES [rglob ./src *pkg.sv]

if {[llength $PKG_FILES] > 0} {
    puts "Adding Packages first:"
    foreach f $PKG_FILES { puts "  $f" }
    add_files -fileset sources_1 $PKG_FILES
    # Force Vivado to recognize the package structure immediately
    update_compile_order -fileset sources_1
}

# 2. Add the rest of the RTL
set RTL_FILES [rglob ./src *.sv]
if {[llength $RTL_FILES] > 0} {
    add_files -fileset sources_1 $RTL_FILES
}

# Ensure RTL is visible to simulation
set_property used_in_simulation true [get_files -of_objects [get_filesets sources_1]]

# --------------------------------
# Add simulation sources (testbenches)
# --------------------------------
set TB_FILES [rglob ./testbench *.sv]

if {[llength $TB_FILES] > 0} {
    puts "Adding testbench sources:"
    foreach f $TB_FILES { puts "  $f" }
    add_files -fileset sim_1 $TB_FILES
} else {
    puts "WARNING: No testbench files found in ./testbench"
}

# --------------------------------
# Add constraints
# --------------------------------
set XDC_FILES [glob -nocomplain ./constraints/*.xdc]

if {[llength $XDC_FILES] > 0} {
    puts "Adding constraint files:"
    foreach f $XDC_FILES { puts "  $f" }
    add_files -fileset constrs_1 $XDC_FILES
} else {
    puts "WARNING: No constraint files found in ./constraints"
}

# --------------------------------
# Set top modules
# --------------------------------
# CHANGE these names to match your design
set_property top cpu_top [get_filesets sources_1]
set_property top CPU_tb [get_filesets sim_1]

# --------------------------------
# Update compile order
# --------------------------------
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# --------------------------------
# Finalize
# --------------------------------
puts "--------------------------------------------"
puts "Project created successfully."
puts "RTL files       : [llength $RTL_FILES]"
puts "Testbench files : [llength $TB_FILES]"
puts "Constraint files: [llength $XDC_FILES]"
puts "--------------------------------------------"

exit 0