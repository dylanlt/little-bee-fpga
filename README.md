# little-bee-fpga

This is a demo project for the 480x272 LCD, updated to use rPLL instead of PLL IP core. 

It is intended for users who need to test the FPGA board and LCD.

The provided examples are for the 800x480 LCD and flicker on the the smaller LCD. There is a block of code in VGAMod.v that needs to be uncommented to fix this, and the block below it needs to be commented. This project has this edit already done, so you can simply run through the steps of the process in the GOWIN IDE and program the FPGA. In addition, the scaling logic for the colour bars has been updated to better match the small LCD. There is no blue shown when only uncommenting/commenting out the previously-mentioned code blocks.

All the settings are saved in the project, but the device is a GW1N-LV1QN48C6/I5. 

The main code is in VGAMod.v and there is an OSC IP core (gowin_osc.v) that performs /10 division and an rPLL IP core (gowin_rpll.v) that creates the 33.33MHz LCD clock from the 24MHz board oscillator.
