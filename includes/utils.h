#ifndef UTILS_H
#define UTILS_H

#include <stdint.h>

inline void outb(uint16_t port, uint8_t value);
inline uint8_t inb(uint16_t port);

#endif