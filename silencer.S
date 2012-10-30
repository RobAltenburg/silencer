/*
Example program to read analog input and
display the results in a series of led flashes.
*/

#if defined(__AVR_ATtiny45__)

#include <avr/io.h>

/* define registers */
#define delay_steps r16
#define tmp r17
#define test_source r18
#define test_register r3
#define counter r19

/* define constants*/
#define led1 PB0
#define led2 PB4

.section .text

/* delay function */
.extern qrpc_delay
long_delay:
	ldi delay_steps, 0x3
	rjmp delay
short_delay:
	ldi delay_steps, 0x1
delay:
	rcall qrpc_delay
	ret	

quick_flash:						// flash led1 and led2
	sbi _SFR_IO_ADDR(PORTB), led1
	sbi _SFR_IO_ADDR(PORTB), led2
	rcall short_delay
	cbi _SFR_IO_ADDR(PORTB), led1
	cbi _SFR_IO_ADDR(PORTB), led2
	rcall short_delay
ret

/* -------------------------------- main */
.global main
main:

	// set up the stack pointers
	ldi tmp, hi8(RAMEND)
	out _SFR_IO_ADDR(SPH), tmp
	ldi tmp, lo8(RAMEND)
	out _SFR_IO_ADDR(SPL), tmp

	sbi _SFR_IO_ADDR(DDRB), led1	// set PB0 as output
	sbi _SFR_IO_ADDR(DDRB), led2	// set PB4 as output

	// signal start with 3 quick flashes
	rcall quick_flash
	rcall quick_flash
	rcall quick_flash
	rcall long_delay
	rcall long_delay
	
/* Start the Analog-to-Digital Conversion */
	
	// Configure the ADMUX Register
	// 0b00101111: set 1.1v ref, ADLAR, & Muxes for Temperature input
	ldi tmp, _BV(REFS1) | _BV(ADLAR) | _BV(MUX0) | _BV(MUX1) | _BV(MUX2) | _BV(MUX3)
	out _SFR_IO_ADDR(ADMUX), tmp

	
	// Configure the ADCSRA Register
	// 0b11000011: Turn on ADC, trigger a single sample, and
	// set the ADC Prescalar to div by 8.  @1MHz this gives 125kHz sampling
sample_temp:
	ldi tmp, _BV(ADEN) | _BV(ADSC) | _BV(ADPS1) | _BV(ADPS0)
	out _SFR_IO_ADDR(ADCSRA), tmp	
	
	// wait for the conversion to complete
wait_loop:
	in tmp, _SFR_IO_ADDR(ADCSRA)	
	sbrc tmp, 6
	rjmp wait_loop

	// turn off the ADC
	ldi tmp, _BV(ADPS1) | _BV(ADPS0)
	out _SFR_IO_ADDR(ADCSRA), tmp	

	// read the results of the ADC to test_source
	in test_source, _SFR_IO_ADDR(ADCH)


/*  simple 2-led output
 *	For each bit in a register flash led1.
 *	If the bit is set, also flash led2.
 *	ldi test_source, 0x55 // 0x55 = 0b01010101
*/
reg_reset:	
	mov test_register, test_source
	ldi counter, 0x7
reg_loop:
	sbi _SFR_IO_ADDR(PORTB), led1 // on
	sbrc test_register, 7
	sbi _SFR_IO_ADDR(PORTB), led2 // on
	
	rcall long_delay
	cbi _SFR_IO_ADDR(PORTB), led1 // off
	cbi _SFR_IO_ADDR(PORTB), led2 // off
	rcall long_delay
		
	lsl test_register	
	dec counter
	brpl reg_loop // loop while counter is positive
	
	// when done, signal the break with two quick flashes
	rcall long_delay	
	rcall quick_flash
	rcall quick_flash
	rcall long_delay
	
	// resample and repeat
	rjmp sample_temp

/* catch uncaught interrupts */
.global __vector_default
__vector_default:
	reti
	
	.end

#endif //AVR_ATtiny45
