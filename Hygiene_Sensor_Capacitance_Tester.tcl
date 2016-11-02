#!/usr/bin/wish

# Folder location for GUI Images
set images "./Figures"

# Global Variables
global events
set programmated_events 0 

package require cmdline

# Packages useful for the GUI

# Img package required for screen captures
package require Img
# BWidget package used for comboboxes
package require BWidget
# TKtable package used for table widgets
package require Tktable
package require Tk

source eventDetection.tcl
source thresholdDetection.tcl

proc push {} {
	# Pocedure to store the ID of the selected port
	set port [.ent get] 
	set portnode $port

	# Set up the channel
	global portchan
	set portchan [port_init $portnode]

	psm_init $portchan

	# Updating the image, the selected port is correct!
	label .lbl2 -image img2
	place .lbl2 -x 350 -y 50
}

proc port_init {portnode} {
    # Return a channel to the instrument, or exit if there's a problem
    #
    # Arguments:
    #   portnode -- The filesystem node specified in the push procedure
    set mode "9600,n,8,1"
    try {
    set portchan [open $portnode r+]
    chan configure $portchan \
        -mode $mode \
        -blocking 0 \
        -buffering line \
        -handshake rtscts \
        -encoding binary \
        -translation {binary lf}
    chan puts $portchan "i"
    # There just needs to be some non-zero delay here
    after 100
    set data [read $portchan]
    puts $data
    if { [string first "Syscomp" $data] == -1 } {
        puts "Connected to $portnode, but this is not a CGR-201"
        exit 1
    } 
    } trap {POSIX ENOENT} {} {
	puts "Problem opening $portnode -- it doesn't exist"
	exit 1
    } trap {POSIX EACCES} {} {
	puts "Problem opening $portnode -- permission denied"
	exit 1
    }
    return $portchan
}

proc send_command {portchan command} {
    # Send a command to the PSM-101
    #
    # Arguments:
    #   portchan -- Communication channel
    #   command -- Command string to be sent
    puts $portchan $command
    after 1
}

proc psm_init {portchan} {
    # Initialize the PSM-101
    #
    # Arguments:
    #   portchan -- Communications channel
    send_command $portchan "V500"
    send_command $portchan "e"
}

## GUI label, insert your port here
label .lab -text "Enter port:"
entry .ent 
button .but -text "Check" -command "push"
pack .ent
pack .but
place .lab -x 10 -y 10
place .ent -x 10 -y 50 

# By default it is set to COM5, port of CGR-201
.ent insert end "COM5"
set portnode "COM5"
place .but -x 250 -y 50 

# Stop picture preloaded
image create photo img1 -file "$images/StopButton.gif"
image create photo img2 -file "$images/RecordButton.gif"
label .lbl1 -image img1
place .lbl1 -x 350 -y 50

label .title1 -text "Events Detection" -font bold -foreground blue
place .title1 -x 10 -y 90

# GUI label, insert your ID here
label .id -text "Programmated Events"
entry .idwin 
button .idbut -text "Set/Start" -command { progr_event $portchan }
pack .idwin
pack .idbut
place .id -x 10 -y 120
place .idwin -x 10 -y 160 
place .idbut -x 250 -y 160 

label .title2 -text "Threshold Detection" -font bold -foreground blue
place .title2 -x 10 -y 210

# Quit and Start button to start and conclude the execution
button .quit -text "Quit" -command { exit }
button .start -text "Start" -command { threshold_activation $portchan }
place .start -x 250 -y 250 
# place .quit -x 150 -y 280 

# Progression Bar
canvas .c -width 200 -height 20
.c create rectangle 0 0 0 20 -tags bar -fill navy
place .c -x 15 -y 250


# Window creation
wm title . "Capacitive Test" 
wm geometry . 400x350+100+100