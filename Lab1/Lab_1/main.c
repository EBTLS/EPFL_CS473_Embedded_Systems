#include "msp.h"

/**
 * code for Exercise 1
 */

void PwmGenerator(float ratio){

    uint16_t i=0;

    uint16_t threshold=ratio*1000;

    P6->DIR= 0xFF;         //set Port 6 to output direction
    P6->OUT= (1<<0);       //set bit 1 of port 6, clear others bits
    while(1)
    {
//        solution with high precision
        i++;

        if (i==1000)
        {
            P6->OUT^=(1<<0);
            i=0;
            continue;
        }
        if (i==threshold)
        {
            P6->OUT^=(1<<0);
            continue;
        }

//        solution with lower precision

//        if (i<=threshold)
//        {
//            P6->OUT=(1<<0);
//        }
//        else if (i>threshold && i<1000)
//        {
//            P6->OUT=(0<<0);
//        }
//        else if (i==1000)
//        {
//            i=0;
//            P6->OUT=(1<<0);
//        }
    }

}

/**
 * EXERCISE 2
 */

void StrobeGpio()
{

    uint32_t i;
//    LED Version

    P2->DIR=0xFF;
    P2->OUT=(1<<0);

    while (1)
    {
        i++;
        if (i<=10000) {
            P2->OUT=(1<<0);
        }
        else if (i<=20000) {
            P2->OUT=(1<<1);
        }
        else if (i<=30000) {
            P2->OUT=(1<<2);
        }
        else if (i==40000) {
            i=0;
        }
    }

}

/*
 * Exercise 3
 */

void Exercise3TimerInitialize()
{
//    Initialize Clock (ACLK)
    CS->KEY =CS_KEY_VAL;
    CS->CTL1 |=CS_CTL1_DIVA_0 | CS_CTL1_SELA__REFOCLK;  // set to REFOCLK and divided by 1, ACLK will output 32768Hz Clock

//    Initialize Timer
    TIMER_A0->CTL |= TIMER_A_CTL_ID_0 | TIMER_A_CTL_TASSEL_1 | TIMER_A_CTL_MC_1;   //divide by 1 and set the source to ACLK and set to up mode
    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CAP; //set to compare mode
}

void TimerDelay(uint16_t delay_setting)
{

    uint16_t delay_tick=delay_setting*32768/100;

//   Initialize Timer
    TIMER_A0->CCR[0]=delay_tick;
    TIMER_A0->R &=0x0000;

    while (!(TIMER_A0->CCTL[0] & TIMER_A_CCTLN_CCIFG)){

    }

    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CCIFG;

}

/*
 * Exercise 4
 */

void Exercise4TimerInitialize(uint16_t period)
{
//    Initialize Clock (ACLK)
    CS->KEY =CS_KEY_VAL;
    CS->CTL1 |=CS_CTL1_DIVA_0 | CS_CTL1_SELA__REFOCLK;  // set to REFOCLK and divided by 1, ACLK will output 32768Hz Clock


////    Initialize Timer
//    TIMER_A2->CTL |= TIMER_A_CTL_ID_0 | TIMER_A_CTL_TASSEL_1 | TIMER_A_CTL_MC_3;   //divide by 1 and set the source to ACLK and set to up/down mode
//    TIMER_A2->CCTL[0] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
//    TIMER_A2->CCTL[1] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
//    TIMER_A2->CCTL[1] |= TIMER_A_CCTLN_OUTMOD_2; //set compare/capture block 2's output to Toggle/Reset Mode
//
////    set given period
//    uint16_t period_tick=period*32768/1000/2;
//
//    TIMER_A2->CCR[0]=period_tick;

//    P5->SEL0 |=0x40;
//    P5->SEL1 |=0x00;
//    P5->DIR=0xFF;

//    Initialize Timer
    TIMER_A0->CTL |= TIMER_A_CTL_ID_0 | TIMER_A_CTL_TASSEL_1 | TIMER_A_CTL_MC_3;   //divide by 1 and set the source to ACLK and set to up/down mode
    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
    TIMER_A0->CCTL[1] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
    TIMER_A0->CCTL[1] |= TIMER_A_CCTLN_OUTMOD_2; //set compare/capture block 2's output to Toggle/Reset Mode

//    set given period
    uint16_t period_tick=period*32768/1000/2;

    TIMER_A0->CCR[0]=period_tick;


//    Initialize P2.4 as its secondary function
    P2->SEL0 |=0x10;
    P2->SEL1 |=0x00;
    P2->DIR=0xFF;

}

void TimerPWM(float ratio, uint16_t period)
{
//    set given ratio

    uint16_t period_tick=ratio*period*32768/1000/2;

    TIMER_A0->CCR[1]=period_tick;

}



/*
 * Exercise 5
 */
void Exercise5Initialization(uint16_t period)
{
//    Initialize Clock (ACLK)
    CS->KEY =CS_KEY_VAL;
    CS->CTL1 |=CS_CTL1_DIVA_0 | CS_CTL1_SELA__REFOCLK;  // set to REFOCLK and divided by 1, ACLK will output 32768Hz Clock

//    Initialize Timer
    TIMER_A0->CTL |= TIMER_A_CTL_ID_0 | TIMER_A_CTL_TASSEL_1 | TIMER_A_CTL_MC_1;   //divide by 1 and set the source to ACLK and set to up mode
    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode

//    Initialize Timer interrupt
    TIMER_A0->CCTL[0] |= TIMER_A_CCTLN_CCIE;

//    set given period
    uint16_t period_tick=period*32768/1000/2;

    TIMER_A0->CCR[0]=period_tick;

//    Enable Interrupt
    NVIC_EnableIRQ(TA0_0_IRQn);
    NVIC_SetPriority(TA0_0_IRQn,4);
}

// Interrupt Handler
//void TA0_0_IRQHandler()
//{
//
////    clear interrupt
//    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CCIFG;
//
//    P6->OUT^=(1<<1);
//    P2->OUT^=(1<<0);
//}

/*
 * Exercise 6
 */
void Exercise6Initialize(uint16_t period)
{
//    Initialize Clock (ACLK)
    CS->KEY =CS_KEY_VAL;
    CS->CTL1 |=CS_CTL1_DIVA_0 | CS_CTL1_SELA__REFOCLK;  // set to REFOCLK and divided by 1, ACLK will output 32768Hz Clock

//    Initialize ADC
    ADC14->CTL0 &= ~ADC14_CTL0_ENC; //disable configuration
    ADC14->CTL0 |= ADC14_CTL0_DIV__1 | ADC14_CTL0_PDIV__1 | ADC14_CTL0_SSEL_2; //set ACLK as clock input with no division and no pre-division
    ADC14->CTL0 |= ADC14_CTL0_CONSEQ_2; //set to single channel repeat sample
    ADC14->CTL0 |= ADC14_CTL0_SHP | ADC14_CTL0_SHT0_1; //set to pulse sample mode and t_sample=8;
    ADC14->CTL1 |= ADC14_CTL1_RES__8BIT; //set to 8 bit precision
    ADC14->CTL1 |= (0<<ADC14_CTL1_CSTARTADD_OFS); //set memory 0 as the register to write in
    ADC14->MCTL[0] |= ADC14_MCTLN_INCH_13;  //set memory 0 restore the result of input channel 13

//    use TA0_C1 to periodically triggered ADC
    TIMER_A0->CTL |= TIMER_A_CTL_ID_0 | TIMER_A_CTL_TASSEL_1 | TIMER_A_CTL_MC_1;   //divide by 1 and set the source to ACLK and set to up/down mode
    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
    TIMER_A0->CCTL[1] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
    TIMER_A0->CCTL[1] |= TIMER_A_CCTLN_OUTMOD_3; //set compare/capture block 2's output to Toggle/Reset Mode

    //    set given period
    uint16_t period_tick=period*32768/1000/2;
    TIMER_A0->CCR[0]=period_tick;
    TIMER_A0->CCR[1]=period_tick/2;

    ADC14->CTL0 |= ADC14_CTL0_SHS_1;

//    configure the P4.0 as ADC input and set the direction
    P4->SEL0 |=0x01;
    P4->SEL1 |=0X00;
    P4->DIR  &=(0<<0);

//   start ADC core
    ADC14->CTL0 |= ADC14_CTL0_ON;
    ADC14->CTL0 |= ADC14_CTL0_ENC; //disable configuration

}

void ADCResultRead()
{
    while (1)
    {
        if (ADC14->IFGR0 & ADC14_IFGR0_IFG0 )
        {
            uint16_t ADCResult=ADC14->MEM[0];

            printf("joystick input = %u \n",ADCResult);
        }

    }

}

/*
 * Exercise 7
 */

void SystemIntialization(){

//    close the watch dog timer
    WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;

//    CPU clock initialization
    CS->KEY =CS_KEY_VAL;
    CS->CTL1 |=CS_CTL1_DIVM__1 | CS_CTL1_SELM__MODOSC; //set to MODOSC Clock and divided by 1.
    CS->KEY=CS_KEY_VAL+1;

}

void Exercise7Initialization(uint16_t period){

//    Initialize Clock (ACLK)
    CS->KEY =CS_KEY_VAL;
    CS->CTL1 |=CS_CTL1_DIVA_0 | CS_CTL1_SELA__REFOCLK;  // set to REFOCLK and divided by 1, ACLK will output 32768Hz Clock

//    Initialize ADC
    ADC14->CTL0 &= 0x0000;
    ADC14->CTL0 &= ~ADC14_CTL0_ENC; //enable configuration
    ADC14->CTL0 &= ADC14_CTL0_SHS_0; //set SC signal as control signal
    ADC14->CTL0 |= ADC14_CTL0_DIV__1; //set ACLK as clock input
    ADC14->CTL0 |= ADC14_CTL0_PDIV__1 | ADC14_CTL0_SSEL_2;           // no division and no pre-division

    ADC14->CTL0 |= ADC14_CTL0_CONSEQ_0; //set to single channel single sample
    ADC14->CTL0 |= ADC14_CTL0_SHP | ADC14_CTL0_SHT0_3; //set to pulse sample mode and t_sample=32;
    ADC14->CTL1 |= ADC14_CTL1_RES__14BIT; //set to 14 bit precision
    ADC14->CTL1 |= (0<<ADC14_CTL1_CSTARTADD_OFS); //set memory 0 as the register to write in
    ADC14->MCTL[0] |= ADC14_MCTLN_INCH_13;  //set memory 0 restore the result of input channel 13
    ADC14->IER0 |= ADC14_IER0_IE0;       //enable memory 0 interrupt

//   start ADC core
    ADC14->CTL0 |= ADC14_CTL0_ON;
    ADC14->CTL0 |= ADC14_CTL0_ENC; //disable configurations

//    Initialize Timer
    TIMER_A0->CTL |= TIMER_A_CTL_ID_0 | TIMER_A_CTL_TASSEL_1 | TIMER_A_CTL_MC_1;   //divide by 1 and set the source to ACLK and set to up mode
    TIMER_A0->CCTL[0] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
    TIMER_A0->CCTL[1] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
    TIMER_A0->CCTL[1] |= TIMER_A_CCTLN_OUTMOD_6; //set compare/capture block 2's output to Toggle/Reset Mode
    TIMER_A0->CCR[1]=0;

//    Disable Timer CCR0 interrupt
//    TIMER_A0->CCTL[0] ^= TIMER_A_CCTLN_CCIE;

//    Initialize Timer CCR2 Interrupt
    TIMER_A0->CCTL[2] &= ~TIMER_A_CCTLN_CAP ; //set to compare mode
    TIMER_A0->CCTL[2] |= TIMER_A_CCTLN_CCIE;

//    set given pwm period
    uint16_t period_tick=period*32768/1000;
    TIMER_A0->CCR[0]=period_tick;

//   set given sampling period
    period_tick=period*3/4*32768/1000;
    TIMER_A0->CCR[2]=period_tick;

//   Initialize P2.4 as its secondary function
    P2->SEL0 |=0x10;
    P2->SEL1 |=0x00;
    P2->DIR=0xFF;
    P2->OUT=(0<<4);

//    Enable Interrupt
//    NVIC_EnableIRQ(TA0_0_IRQn);
//    NVIC_SetPriority(TA0_0_IRQn,4);

    NVIC_EnableIRQ(TA0_N_IRQn);
    NVIC_SetPriority(TA0_N_IRQn,4);

    NVIC_EnableIRQ(ADC14_IRQn);
    NVIC_SetPriority(ADC14_IRQn,5);

//    LPM settings
    SCB->SCR |= SCB_SCR_SLEEPONEXIT_Msk;
}


//Interrupt Handler
void TA0_N_IRQHandler()
{
    if (TIMER_A0->IV & 0x0004) {
    //    Enable ADC
            ADC14->CTL0 |= ADC14_CTL0_SC;
            P6->OUT^=(1<<6);
    }

}

// ADC Interrupt Handler
void ADC14_IRQHandler()
{
//    reset the control signal (the interrupt signal is reset automatically when be read)
//    ADC14->CTL0 &= ~ADC14_CTL0_SC;

    uint16_t ADCResult=ADC14->MEM[0];

//    printf("joystick input = %u \n",ADCResult);

    uint16_t period_tick=TIMER_A0->CCR[0];
//    float ratio=ADCResult/0x3FFF;

    float ratio=(1.0+(float)ADCResult/(float)0x3FFF)/20.0;
//    printf("ratio = %f \n",ratio);
    uint16_t pwm_tick=period_tick*ratio;
//    printf("pwm_tick = %u \n",pwm_tick);

    TIMER_A0->CCR[1]=pwm_tick;


}



/**
 * main.c
 */

void main(void)
{
//    WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD;              // stop watchdog timer


    /*
     * Exercise 1
     */

//    PwmGenerator(0.6);

    /*
     * Exercise 2
     */

//    StrobeGpio();

    /*
     * Exercise 3
     */

//    P2->DIR=0xFF;
//    P2->OUT=(1<<0);
//
//    Exercise3TimerInitialize();
//
//    uint16_t i=0;
//
//    for (i=0;i<=10;i++) {
//        TimerDelay(50);
//    }
//
//    while (1){
//        P2->OUT=(0<<0);
//    }

    /*
     * Exercise 4
     */

//    Exercise4TimerInitialize(20);
//    TimerPWM(0.8, 20);

    /*
     * Exercise 5
     */
//    P6->DIR = 0xFF;
//    P6->OUT |= (1<<1);
//    P2->DIR =0xFF;
//    P2->OUT |=(1<<0);
//
//    Exercise5Initialization(50);


//    while (1)
//    {
//        ;
//    }

    /*
     * Exercise 6
     */
//    Exercise6Initialize(100);
//    ADCResultRead();

    /*
     * Exercise 7
     */
    SystemIntialization();

    Exercise7Initialization(20);

    while(1)
    {
        ;
    }
}



