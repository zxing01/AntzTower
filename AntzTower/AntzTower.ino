//
// AntzTower
//
// Antz Framework
// Developed with [embedXcode](http://embedXcode.weebly.com)
//
// Author 		Zhi Xing
// 				Zhi Xing
//
// Date			1/22/15 12:49 PM
// Version		<#version#>
//
// Copyright	© Zhi Xing, 2015
// Licence		<#license#>
//
// See         ReadMe.txt for references
//

#include "Sender.h"

using namespace Antz;

Sender sender;

////////////////////////////////////////////////////////////////
void setup() {
    randomSeed(analogRead(0));
}

////////////////////////////////////////////////////////////////
void loop() {
    sender.send1(1, 5000);
    delay(1000);
    sender.send2(2, 5000);
    delay(1000);
}
