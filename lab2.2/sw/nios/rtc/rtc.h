/*
 * rtc.h
 *
 *  Created on: 2021ùù11ùù26ùù
 *      Author: ù?
 */

#ifndef RTC_H_
#define RTC_H_
#include "io.h"

#define IORD_RTC_COUNT(base)        	IORD_8DIRECT(base, 0)
#define IOWR_RTC_COUNT(base, data)  	IOWR_8DIRECT(base, 0, data)

#define IORD_RTC_SET(base) 				IORD_8DIRECT(base, 1)
#define IOWR_RTC_SET(base,data) 		IOWR_8DIRECT(base, 1, data)


#define IOWR_RTC_SEC(base,data)				IOWR_8DIRECT(base,2,data)
#define IOWR_RTC_MIN(base,data)				IOWR_8DIRECT(base,3,data)
#define IOWR_RTC_HOUR(base,data)			IOWR_8DIRECT(base,4,data)

#define IOWR_RTC_SEC_THRESH(base,data)		IOWR_8DIRECT(base,5,data)
#define IOWR_RTC_MIN_THRESH(base,data)		IOWR_8DIRECT(base,6,data)
#define IOWR_RTC_HOUR_THRESH(base,data)		IOWR_8DIRECT(base,7,data)


/*
#define IORD_RTC_SEC(base) 				IORD_8DIRECT(base, 2)
#define IOWR_RTC_SEC(base, data) 		IOWR_8DIRECT(base, 2, data)

#define IORD_RTC_MIN(base) 				IORD_8DIRECT(base, 3)
#define IOWR_RTC_MIN(base, data) 		IOWR_8DIRECT(base, 3, data)

#define IORD_RTC_HR(base) 				IORD_8DIRECT(base, 4)
#define IOWR_RTC_HR(base, data) 		IOWR_8DIRECT(base, 4, data)

*/



#endif /* RTC_H_ */
