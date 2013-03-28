/****************************************************************************/
/* algotest.c: Algorithm test program for msprng                            */
/* Copyright 2013 Austin S. Hemmelgarn                                      */
/*                                                                          */
/* Licensed under the Apache License, Version 2.0 (the "License");          */
/* you may not use this file except in compliance with the License.         */
/* You may obtain a copy of the License at                                  */
/*                                                                          */
/*     http://www.apache.org/licenses/LICENSE-2.0                           */
/*                                                                          */
/* Unless required by applicable law or agreed to in writing, software      */
/* distributed under the License is distributed on an "AS IS" BASIS,        */
/* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. */
/* See the License for the specific language governing permissions and      */
/* limitations under the License.                                           */
/****************************************************************************/

#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

uint16_t x = 0;
uint16_t y = 0;
uint16_t z = 0;
uint16_t w = 0;
uint16_t t = 0;

uint16_t _rotr(const unsigned int value, int shift) {
    if ((shift &= sizeof(value)*8 - 1) == 0)
        return value;
    return (value >> shift) | (value << (sizeof(value)*8 - shift));
}

uint16_t _swpb(uint16_t value) {
    return (((value & 0xff00) >> 8) | ((value & 0x00ff) << 8));
}

void main() {
    read(0, ((char *) &x), 1);
    read(0, ((char *) &y), 1);
    while (1) {
        t = x ^ (x << 2);
        x = y; y = z; z = w;
        w = w ^ _rotr(w, 3) ^ (_swpb(t) ^ (t << 5));
        printf("%c%c", ((w & 0xFF00) >> 8), (w & 0xFF));
    }
}
