
/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "xil_printf.h"
#include "sleep.h"
#include <stdint.h>


#define GPIO 0xC0000000
#define TIMER 0xC0000080
#define TIMER_CNTL 0xC0000084
#define TIMER_CNTH 0xC0000088
#define UART 0xC0000100
#define UART_CONFIG_OFF 0
#define UART_SPEED_OFF 4
#define UART_TX_OFF 8
#define PWM 0xC0000180

volatile uint32_t * uart_config = (uint32_t *) (UART+UART_CONFIG_OFF);
volatile uint32_t * uart_speed = (uint32_t *) (UART+UART_SPEED_OFF);
volatile uint32_t * uart_tx = (uint32_t *) (UART+UART_TX_OFF);

void uart_init(uint32_t speed) {
    // configure UART: enable, no parity, 1 stop bit, 8 data bits
    *uart_config = 0x00000001;
    // set speed
    int limit; 
    limit = 100000000 / speed;
    *uart_speed = limit;
}

void uart_print_char(char c) {
    *uart_tx = (uint32_t) c;
}

void uart_print_string(const char * str) {
    while (*str) {
        uart_print_char(*str++);
    }
}


void pwm_init(uint32_t frequency, uint32_t duty_cycle) {
    volatile uint32_t * pwm_config = (uint32_t *) (PWM + 0);
    volatile uint32_t * pwm_freq = (uint32_t *) (PWM + 4);
    volatile uint32_t * pwm_duty_cycle = (uint32_t *) (PWM + 8);

    // configure PWM: enable
    *pwm_config = 0x00000001;
    // set frequency
    *pwm_freq = 100000 / frequency; // our pwm prescaler is set to 100kHz
    // set duty cycle
    *pwm_duty_cycle = (100000 / frequency) * duty_cycle / 100; // duty cycle in percentage
}

int main()
{

    volatile uint32_t * led_device = (uint32_t *) (GPIO+4);
    volatile uint32_t * timer_config = (uint32_t *) TIMER ;
    volatile uint32_t * timer_count_low = (uint32_t *)(TIMER + 4); // second mistake: need to put parentheses around the addition
    volatile uint32_t * timer_count_high = (uint32_t *)(TIMER + 8);

    volatile uint64_t counter_new, counter_old, limit;

    volatile uint32_t led_value = 0x0000F0F0;
    *led_device = led_value;

    //reset counter
	*timer_config = 0x00000003;
	//start counter
	*timer_config = 0x00000001;
	// read counter
	limit = 50000000;
    // init UART
    uart_init(19200);
    // init PWM
    pwm_init(500, 75);

	while(1){
        
		led_value =  ~led_value;
	    *led_device = led_value;


		
    	counter_new = *timer_count_high;
    	counter_new = *timer_count_low + (counter_new << 32);
    	counter_old = counter_new;


    	while((counter_old + limit) > counter_new) {
    		counter_new = *timer_count_high;
    	    counter_new = *timer_count_low + (counter_new << 32);
    	}
        
        uart_print_string("LEDs toggled\r\n");
        //char myGrade = 'A';
        //uart_print_char(myGrade);

    }

    return 0;
}




