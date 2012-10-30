CC=/opt/local/bin/avr-gcc
CFLAGS=-g -Os -mcall-prologues -Wall -mmcu=attiny45
OBJ2HEX=/opt/local/bin/avr-objcopy


silencer.hex : silencer.obj
	$(OBJ2HEX) c $< $@

silencer.obj: silencer.o delay.o
	$(CC) $(CFLAGS) -o silencer.obj *.o

silencer.o : silencer.S
	$(CC) $(CFLAGS) -c silencer.S

delay.o : delay.S
	$(CC) $(CFLAGS) -c delay.S

clean :
	rm *.obj *.o *.hex 