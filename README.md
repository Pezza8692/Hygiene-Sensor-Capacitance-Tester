# Hygiene-Sensor-Capacitance-Tester

TCL program to use SYSCOMP CGR-201 for a capacitance tester for Swipesense Hygiene Event Detector:

-- It drives a switch between two capacitance so to create a change in capacitance for the Hygiene Event Detector.
-- It drives and read the output of a light detector circuit. When the LED of the Hygiene Event Detector is blinking the digital input on the SYSCOMP CGR-201 is 1.
-- It presents a small GUI in which it is possible to insert:
    * the COM port the SYSCOMP CGR-201 is connected (this is varying with the OS). The program has been tested on Windows and by default COM5 port is written.
    * the number of events to check for this run of the program.
   At the end of the run a pop-up window will signal how many events were detected with respect to the one programmated by the user.
   
