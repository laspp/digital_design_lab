/*
 * lab08 - show the seconds since start-up on the seven-segment display.
 *
 * The display peripheral sits at 0x2000_3000. Its registers are listed
 * in the lab text. Fill in the TODOs.
 */

#include "bsp.h"

#define SEG7_BASE     0x20003000u
#define SEG7_CONFIG   REG32(SEG7_BASE + 0x00)
#define SEG7_DIGIT(i) REG32(SEG7_BASE + 0x04 + 4u * (i))   /* i = 0 ... 7 */

#define NUM_DIGITS 8

/* Show an unsigned number in decimal on the display. */
static void seg7_show_dec(uint32_t value)
{
    /* TODO 2: write the decimal digits of value to the eight digit
     *         registers, least significant digit first, using
     *         % 10 and / 10.                                        */
    (void)value;
}

int main(void)
{
    uart_init(BAUD);
    timer_start();

    /* TODO 1: enable the display.                                   */

    uint32_t seconds = 0;

    while (1) {
        seg7_show_dec(seconds);

        uart_puts("seconds = ");
        print_udec(seconds);
        uart_putc('\n');

        /* TODO 3: wait one second and count it. Use delay_cycles()
         *         first, then try the version with timer_get().     */
    }

    return 0;
}
