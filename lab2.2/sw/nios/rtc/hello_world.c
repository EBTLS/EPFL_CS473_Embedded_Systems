/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <inttypes.h>
#include "system.h"
#include <stdio.h>
#include "rtc.h"

int main()
{
  printf("Hello from Nios II!\n");




/* function test 1: start counting from 0, and stop at a given value */

  /*IOWR_RTC_COUNT(REALTIMECLOCK_0_BASE, 0x01);
  printf("Start to count!\n");
  IOWR_RTC_SEC_THRESH(REALTIMECLOCK_0_BASE, 0x20);
  IOWR_RTC_MIN_THRESH(REALTIMECLOCK_0_BASE, 0x01);
  IOWR_RTC_HOUR_THRESH(REALTIMECLOCK_0_BASE, 0x00);
  printf("Set the stop value\n");
*/

  /* function test 2
   * start counting from an initial value by setting specific registers
   * stop at a given value
   */


  	IOWR_RTC_SEC(REALTIMECLOCK_0_BASE, 0x21);
    IOWR_RTC_MIN(REALTIMECLOCK_0_BASE, 0x0b);
    IOWR_RTC_HOUR(REALTIMECLOCK_0_BASE, 0x02);
    IOWR_RTC_SET(REALTIMECLOCK_0_BASE, 0x01);
    printf("Set the clock value successfully!\n");


    IOWR_RTC_COUNT(REALTIMECLOCK_0_BASE, 0x01);

    printf("Start to count!\n");

    IOWR_RTC_SEC_THRESH(REALTIMECLOCK_0_BASE, 0x26);
    IOWR_RTC_MIN_THRESH(REALTIMECLOCK_0_BASE, 0x0c);
    IOWR_RTC_HOUR_THRESH(REALTIMECLOCK_0_BASE, 0x02);
    printf("Set the stop value\n");



  return 0;


}
