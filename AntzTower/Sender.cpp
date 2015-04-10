//
//  Sender.cpp
//  Antz
//
//  Created by Zhi Xing on 6/2/14.
//  Copyright (c) 2014 Zhi Xing. All rights reserved.
//

#include "Sender.h"

using namespace Antz;

////////////////////////////////////////////////////////////////
Sender::Sender() {
    TIMSK1 = 0; //Timer2 Overflow Interrupt
    TIMSK3 = 0;
    pinMode(TIMER_PWM_PIN1, OUTPUT);
    pinMode(TIMER_PWM_PIN2, OUTPUT);
    digitalWrite(TIMER_PWM_PIN1, HIGH); // When not sending PWM, we want it high (because the transistor will invert the output)
    digitalWrite(TIMER_PWM_PIN2, HIGH);
    randomSeed(analogRead(0));
}

////////////////////////////////////////////////////////////////
void Sender::send1(uint32_t data, uint64_t duration) {
    uint8_t original = EIMSK;
    EIMSK = 0; // disable external interrupts
    
    TCCR1A = (1 << WGM11) | (1 << WGM10); // fast PWM, TOP = OCR1A
    TCCR1B = (1 << WGM13) | (1 << WGM12) | (1 << CS10); // no prescaling
    OCR1A = SYSCLOCK / IR_KHZ;
    OCR1B = SYSCLOCK / IR_KHZ / 2;
    
    unsigned long cur = millis();
    do {
        signal1(LEN_SIGN);
        for (int i = 0; i < NUM_BITS; i++) {
            interval1(LEN_INTR);
            signal1(((uint32_t)1 << i) & data ? LEN_ONE : LEN_ZERO);
        }
        interval1(LEN_INTR * 5); // give a fixed interval first because random() has a big delay
        interval1(random(LEN_PRSV * 5)); // big interval between signals
    } while (millis() - cur < duration);
    
    EIMSK = original; // enable external interrupts
}

////////////////////////////////////////////////////////////////
void Sender::signal1(uint32_t time) {
    TCCR1A |= (1 << COM1B1);
    delayMicroseconds(time);
}

////////////////////////////////////////////////////////////////
void Sender::interval1(uint32_t time) {
    TCCR1A &= ~(1 << COM1B1);
    delayMicroseconds(time);
}

////////////////////////////////////////////////////////////////
void Sender::send2(uint32_t data, uint64_t duration) {
    uint8_t original = EIMSK;
    EIMSK = 0; // disable external interrupts
    
    TCCR3A = (1 << WGM31) | (1 << WGM30); // fast PWM, TOP = OCR1A
    TCCR3B = (1 << WGM33) | (1 << WGM32) | (1 << CS30); // no prescaling
    OCR3A = SYSCLOCK / IR_KHZ;
    OCR3B = SYSCLOCK / IR_KHZ / 2;
    
    unsigned long cur = millis();
    do {
        signal2(LEN_SIGN);
        for (int i = 0; i < NUM_BITS; i++) {
            interval2(LEN_INTR);
            signal2(((uint32_t)1 << i) & data ? LEN_ONE : LEN_ZERO);
        }
        interval2(LEN_INTR * 5); // give a fixed interval first because random() has a big delay
        interval2(random(LEN_PRSV * 5)); // big interval between signals
    } while (millis() - cur < duration);
    
    EIMSK = original; // enable external interrupts
}

////////////////////////////////////////////////////////////////
void Sender::signal2(uint32_t time) {
    TCCR3A |= (1 << COM3B1);
    delayMicroseconds(time);
}

////////////////////////////////////////////////////////////////
void Sender::interval2(uint32_t time) {
    TCCR3A &= ~(1 << COM3B1);
    delayMicroseconds(time);
}
