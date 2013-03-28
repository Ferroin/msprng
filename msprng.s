; msprng.s: A PRNG for the MSP430
; Copyright 2013 Austin S. Hemmelgarn
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

.text
.org 0xfc00
; Start of execution

; Disable the WDT
        mov     #0x5a88,&0x0120

; Initialize SP
        mov     #0x027f, r1

; USI Initialization
        bis.b   #0x01,  &0x0078
        mov     #0x01f3,&0x0078
        mov     #0x4000,&0x007A
        clr     &0x007c

; P1 Initialization
        clr.b   &0x0021
        mov.b   #0xff,  &0x0022
        mov.b   #0x13,  &0x0027
        bic.b   #0x08,  &0x0022
        clr.b   &0x0024
        bis.b   #0x08,  &0x0025

; Alogarithmic Initialization
        clr      r4     ; s in algotest
        clr      r5     ; t in algotest
        clr      r6     ; u in algotest
        clr      r7     ; v in algotest
        clr      r8     ; w in algotest
        clr      r9     ; x in algotest
        clr      r10    ; y in algotest
        clr      r11    ; z in algotest
        clr      r12    ; Temporary storage
        clr      r15
        inc      r15

; Jump to main program
        br      #0xfc80

.org 0xfc80
; Start of main program
        eint
        cmp     #0x0000, r15
        jeq     -0x0006
        rla      r4
        rla      r4
        rla      r4
        xor      r5,     r4
        mov      r6,     r5
        mov      r7,     r6
        mov      r8,     r7
        mov      r9,     r8
        mov      r10,    r9
        mov      r11,    r10
        swpb     r11
        mov      r4,     r12
        clrc
        rrc      r12
        clrc
        rrc      r12
        clrc
        rrc      r12
        clrc
        rrc      r12
        clrc
        rrc      r12
        xor      r12,    r11
        mov      r7,     r12
        rla      r12
        rla      r12
        xor      r12,    r11
        br      #0xfc82

.org 0xfd00
; Port 1 Pin Change Interrupt Handler
; Used to emulate chip select on P1.4, this pin needs to be normally low,
; and needs to be held high during SPI communication.
        cmp.b   #0x08,  &0x0024
        jne      0x0016
        bic.b   #0x1f,  &0x007b
        bis.b   #0x08,  &0x007b
        bic.b   #0x01,  &0x0078
        bic.b   #0x08,  &0x0024
        jmp      0x0008
        bis.b   #0x01,  &0x0078
        bis.b   #0x08,  &0x0024
        reti

.org 0xfd80
; USI Interrupt Handler
; This is used for SPI communication.  Note that P1.3 will be held high
; when we can't recieve any data, the SPI master should check this pin
; after each byte, and only transmit the next byte when it is low.
        bis.b   #0x04,  &0x0021
        bis.b   #0x01,  &0x0078
        cmp.b   #0x50,  &0x007c
        jeq      0x0054
        cmp.b   #0x51,  &0x007c
        jeq      0x0050
        cmp.b   #0x52,  &0x007c
        jeq      0x004c
        cmp.b   #0x53,  &0x007c
        jeq      0x0048
        bic.b   #0x1f,  &0x007b
        bis.b   #0x08,  &0x007b
        bic.b   #0x01,  &0x0078
        bic.b   #0x04,  &0x0021
        reti

.org 0xfde0
; Command Jump Table
        br      #0xfe00
        br      #0xfe10
        br      #0xfe20
        br      #0xfe40

.org 0xfe00
; Function for command 0x50 (STOP)
; When we recieve the command 0x50, we stop iterating the random number
; generator.
        clr      r15
        br      #0xfda8

.org 0xfe10
; Function for command 0x51 (START)
; When we recieve the command 0x51, we start iterating the RNG.
; This command needs to be issued before we can get any random data.
        inc      r15
        br      #0xfda8

.org 0xfe20
; Function for command 0x52 (GET)
; When we recieve the command 0x52, we send the contents of r11 (the
; output of the RNG algorithm).  For this to return anything useful,
; you need to first seed the RNG (see the next command) and have
; previously sent a START (0x51) command.  For best results, this should
; be issued with a freqency of no more than 100Hz.
        mov      r11,   &0x007c
        bic.b   #0x1f,  &0x007b
        bis.b   #0x10,  &0x007b
        br      #0xfdb2

.org 0xfe40
; Function for command 0x53 (SEED)
; When we recieve the command 0x53, we wait listen (with no timeout)
; for the next 2 bytes, then use those bytes to ressed the generator.
; For good quality entropy, the seed should be from a reliable entropy
; source.
        bic.b   #0x1f,  &0x007b
        bis.b   #0x10,  &0x007b
        bic.b   #0x01,  &0x0078
        bic.b   #0x04,  &0x0021
        cmp.b   #0x40,  &0x007b
        jne     -0x0006
        bis.b   #0x04,  &0x0021
        bis.b   #0x01,  &0x0078
        mov.b   &0x007c, r5
        mov.b   &0x007d, r6
        br      #0xfda8

.org 0xffe0
; Start of interrupt vector table
.word 0x0000 ; Unused
.word 0x0000 ; Unused
.word 0xfd00 ; P1
.word 0x0000 ; Unused (P2)
.word 0xfd80 ; USI
.word 0x0000 ; Unused (ADC10)
.word 0x0000 ; Unused
.word 0x0000 ; Unused
.word 0x0000 ; Unused (Timer_A2)
.word 0x0000 ; Unused (Timer_A2)
.word 0x0000 ; Unused (WDT+)
.word 0x0000 ; Unused
.word 0x0000 ; Unused
.word 0x0000 ; Unused
.word 0x0000 ; Unused (NMI)
.word 0xfc00 ; System Reset
