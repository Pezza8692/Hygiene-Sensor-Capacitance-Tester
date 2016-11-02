# Threshold detection functions
proc onEnd_threshold { value } {
    # Box popping at the very end of the threshold detection
    #
    # Argument: 
    # value -- threshold value on the ramp

    # COnverting the ramp value in a capacitance value. Analytic epression derived from calibration
    set limit [expr 0.06+($value-5)*0.00104]
    tk_messageBox -type ok -icon info -title Information \
    -message "Test completed: Threshold at $limit +/- 0.03 pF"
}

proc run_progressionBar {percent} { 
	# RUn for the progression bar
	.c coords bar 0 0 [expr {int($percent * 2)}] 20 
}

proc threshold_activation {portchan} {
    # Schedule the activation of the Syscomp CGR-201. Specifically:
    #
    # -- Power the light sensor circuit.
    # -- Set the frequency of the PWM to drive the switch. 
    # -- Chenge the duty cycle of the PSW output so to change the overall capacitance measured by the Hygiene Sensor. 
    # -- Define the timing to collect data from the light sensor circuit in the digital input.
    
    # Activate Digital Output for power light sensor
    chan puts $portchan "O 255" 
    after 5
    # Setting the frequency of the PWM
    chan puts $portchan "G 000 000 050 000"
    after 5

    # Starting collecting data from digital input
    set incomingData [read $portchan]

    # Convert the data bytes into signed integers
    if { [llength {$incomingData}] > 0 } {
        binary scan $incomingData c* signed
    }

    # Starting the progression bar
    focus -force .c
    
    for {set i 0} {$i < 255} {incr i} {
        #Setting Duty Cycle to 0
        chan puts $portchan "Y 255"
        after 250
        set value [expr 255-$i]
        # Increasing step by step the value of the Ducty Cycle
        chan puts $portchan "Y $value"
        after 10

        for {set j 2} {$j < 50} {incr j} {
            # Serial command to receive data from digital input
            chan puts $portchan "N"
            after 10
            set incomingData [read $portchan]
            if { [llength {$incomingData}] > 0 } {
                binary scan $incomingData c* signed
                set light 0
                # First charachter is capital I, which is the response type for digital input request.
                scan $incomingData "%c%c" out light
                # If it is not 0, it means that one of the digital input is 1
                if {$light != 0} {
                    # Value of the ramp that represent the Threshold
                    onEnd_threshold $i
                    break
                }
            }
        }
        if {$light != 0} {
            break
        }

        raise .c
        run_progressionBar [expr $i/2.55]
        update
    }   
}