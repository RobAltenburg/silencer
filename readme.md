#Silencer#

(This was part of a larger project for which the name "silencer" made sense)

This is an AVR assembly language program that reads an analog input from 
something like a thermocouple, and flashes out the results in binary on 
a pair of LEDs.

One of the LEDs flashes on when a bit is displayed, and the other LED will
be on or off, indicating the status of the bit.

For example, the number 4 would be displayed as:

 1 0  = bit not set 
 1 0  = bit not set 
 1 0  = bit not set 
 1 0  = bit not set 
 1 0  = bit not set 
 1 1  = bit set
 1 0  = bit not set 
 1 0  = bit not set

followed by two quick flashes of both LEDs