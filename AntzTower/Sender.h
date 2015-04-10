//
//  Sender.h
//  Antz
//
//  Created by Zhi Xing on 6/2/14.
//  Copyright (c) 2014 Zhi Xing. All rights reserved.
//

#ifndef __Antz__Sender__
#define __Antz__Sender__

#define SYSCLOCK        16000 // in KHz
#define IR_KHZ          56
/*#if defined(__AVR_ATmega2560__)
#define TIMER_PWM_PIN   12
#elif defined(__AVR_ATmega32U4__)
#define TIMER_PWM_PIN   10
#else
 */
#define TIMER_PWM_PIN1   12
#define TIMER_PWM_PIN2   2
//#endif

#include <avr/interrupt.h>
#include <Arduino.h>
#include "Communication.h"

namespace Antz {
    class Sender {
    public:
        Sender();
        void send1(uint32_t data, uint64_t duration);
        void send2(uint32_t data, uint64_t duration);
    private:
        void signal1(uint32_t time);
        void interval1(uint32_t time);
        void signal2(uint32_t time);
        void interval2(uint32_t time);
    };
}

#endif
