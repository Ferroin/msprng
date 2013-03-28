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

uint16_t s = 0;
uint16_t t = 0;
uint16_t u = 0;
uint16_t v = 0;
uint16_t w = 0;
uint16_t x = 0;
uint16_t y = 0;
uint16_t z = 0;

uint16_t swpb(uint16_t value) {
    return (((value & 0xff00) >> 8) | ((value & 0x00ff) << 8));
}

void main() {
    read(0, ((char *) &z), 1);
    read(0, ((char *) &y), 1);
    while (1) {
        s = t ^ (s << 3);
        t = u;
        u = v;
        v = w;
        w = x;
        x = y;
        y = z;
        z = swpb(z) ^ (s >> 5) ^ (v << 2);
        printf("%c%c", ((s & 0xFF00) >> 8), (s & 0xFF));
    }
}
