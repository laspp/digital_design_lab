/*
 * lab07 - HIPV SoC introductory exercise.
 *
 * Every second:
 *   - toggle all eight LEDs,
 *   - read the eight switches,
 *   - print the LED state and the switch state over the UART.
 *
 * Fill in the three TODOs. Only the BSP functions declared in
 * sw/bsp/bsp.h are available: there is no libc, so no printf.
 */

#include "bsp.h"

/* One second on the board. For a quick simulation run, temporarily
 * set this to a small number such as 1000.                          */
#ifndef DELAY_CYCLES
#define DELAY_CYCLES CPU_HZ
#endif

int main(void)
{
    uart_init(BAUD);
    timer_start();

    uart_puts("lab07 started\n");

    uint32_t leds = 0;

    while (1) {
        /* TODO 1: toggle all eight LEDs (leds is 0x00 or 0xFF)
         *         and write the new value to the GPIO output.   */

        /* TODO 2: read the switches from the GPIO input.         */
        uint32_t sw = 0;

        /* TODO 3: print one line, for example
         *             LED=FF SW=A5
         *         using uart_puts, print_hex8 and uart_putc.    */

        (void)leds;
        (void)sw;

        delay_cycles(DELAY_CYCLES);
    }

    return 0;
}
