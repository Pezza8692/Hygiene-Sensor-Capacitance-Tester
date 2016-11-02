proc progr_event { portchan } {
	# Collect the number of events that the user wants to test
	global programmated_events
	set programmated_events [.idwin get] 
    event_activation $portchan
}

proc onEnd_events { programmated_events events } {
	# Box popping at the very end with the numebr of attempted and succesfully detected events
	#
	# Arguments:
	# programmated_events -- NUmber of events that the user define for this run of the program
	# events -- NUmber of events detected by the system
    tk_messageBox -type ok -icon info -title Information \
    -message "Test completed: Detected $events out of $programmated_events"
}

proc event_activation {portchan} {
	# Schedule the activation of the Syscomp CGR-201. Specifically:
	#
	# -- Activate outputs to drive the switch and to power the light sensor circuit.
	# -- Define the timing to collect data from the light sensor circuit in the digital input.
	
	set events 0
	global programmated_events

    # Activate Digital Output to power light sensor
    chan puts $portchan "O 1" 
    after 5

    # Starting collecting data from digital input
    set incomingData [read $portchan]

    # Convert the data bytes into signed integers
    if { [llength {$incomingData}] > 0 } {
        binary scan $incomingData c* signed
    }
	
    for {set i 0} {$i < $programmated_events} {incr i} {
    	# Setting Duty Cycle to 0 (selecting a capacitance)
        chan puts $portchan "Y 254"
        after 2000
        # Setting Duty Cycle to 1 (selecting the other capacitance)
        chan puts $portchan "Y 1"
        after 100
        for {set j 0} {$j < 50} {incr j} {
        	# Serial command to receive data from digital input
            chan puts $portchan "N"
            after 100
            set incomingData [read $portchan]
            if { [llength {$incomingData}] > 0 } {
                binary scan $incomingData c* signed
                set light 0
                # First charachter is capital I, which is the response type for digital input request.
                scan $incomingData "%c%c" out light
                # If it is not 0, it means that one of the digital input is 1
                if {$light != 0} {
                	# Increasing the number of events detected. To avoid double detection the digital input is not checked anymore (the LED blinks to time)
                    incr events
                    break
                }
            }
        }
        set att [expr $i+1]
        puts "Attempted events: $att, Detected events: $events"
    }  
    onEnd_events $programmated_events $events
}
