#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>
#include <stdbool.h>


uint8_t get_border_direction(uint32_t index, uint32_t height, uint32_t width) {
    int row = index / width;
    int col = index % width;

    bool top = (row == 0);
    bool bottom = (row == height - 1);
    bool left = (col == 0);
    bool right = (col == width - 1);

    if (top && !left && !right) return 1;
    if (top && right)          return 2; 
    if (!top && !bottom && right) return 3;
    if (bottom && right)       return 4;
    if (bottom && !left && !right) return 5; 
    if (bottom && left)        return 6;
    if (!top && !bottom && left) return 7; 
    if (top && left)           return 8;

    return 0;
}

uint32_t perform_sobel(int pixel, uint32_t Index, uint32_t Height, uint32_t Width, uint32_t sobelBuffer2, 
  uint32_t sobelBuffer3, uint32_t sobelBuffer4, uint32_t pixel1, uint32_t pixel2, uint32_t pixel3) 
{

  
   uint32_t sobelPixels1, sobelPixel;
  for (int i = 0; i < 4; ++i) {
    uint8_t p1[4] = {0, 0, 0, 0};
    uint8_t p2[4] = {0, 0, 0, 0};
    uint8_t p3[4] = {0, 0, 0, 0};

    uint8_t dir = 0;
    //uint8_t dir = get_border_direction(Index + i, Height, Width);

    switch (dir) {
      case 1: // North
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel-1));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel3):[in1] "r"(sobelBuffer4+pixel-1));
        p2[0] = (pixel2 >> 0) & 0xFF;
        p2[2] = (pixel2 >> 16) & 0xFF;
        p3[0] = (pixel3 >> 0) & 0xFF;
        p3[1] = (pixel3 >> 8) & 0xFF;
        p3[2] = (pixel3 >> 16) & 0xFF;
        break;

      case 2: // North-East
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel-1));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel3):[in1] "r"(sobelBuffer4+pixel-1));
        p2[0] = (pixel2 >> 0) & 0xFF;
        p3[0] = (pixel3 >> 0) & 0xFF;
        p3[1] = (pixel3 >> 8) & 0xFF;
        break;

      case 3: // East
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(sobelBuffer2+pixel-3));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel-3));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel3):[in1] "r"(sobelBuffer4+pixel-3));
        p1[0] = (pixel1 >> 16) & 0xFF;
        p1[1] = (pixel1 >> 24) & 0xFF;
        p2[0] = (pixel2 >> 16) & 0xFF;
        p3[0] = (pixel3 >> 16) & 0xFF;
        p3[1] = (pixel3 >> 24) & 0xFF;
        break;

      case 4: // South-East
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(sobelBuffer2+pixel-3));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel-3));
        p1[0] = (pixel1 >> 16) & 0xFF;
        p1[1] = (pixel1 >> 24) & 0xFF;
        p2[0] = (pixel2 >> 16) & 0xFF;
        break;

      case 5: // South
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(sobelBuffer2+pixel-1));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel-1));
        p1[0] = (pixel1 >> 0) & 0xFF;
        p1[1] = (pixel1 >> 8) & 0xFF;
        p1[2] = (pixel1 >> 16) & 0xFF;
        p2[0] = (pixel2 >> 0) & 0xFF;
        p2[2] = (pixel2 >> 16) & 0xFF;
        break;

      case 6: // South-West
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(sobelBuffer2+pixel));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel));
        p1[1] = (pixel1 >> 0) & 0xFF;
        p1[2] = (pixel1 >> 8) & 0xFF;
        p2[2] = (pixel2 >> 8) & 0xFF;
        break;

      case 7: // West
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(sobelBuffer2+pixel-3));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel-3));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel3):[in1] "r"(sobelBuffer4+pixel-3));
        p1[1] = (pixel1 >> 0) & 0xFF;
        p1[2] = (pixel1 >> 8) & 0xFF;
        p2[2] = (pixel2 >> 8) & 0xFF;
        p3[1] = (pixel3 >> 0) & 0xFF;
        p3[2] = (pixel3 >> 8) & 0xFF;
        break;

      case 8: // North-West
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(sobelBuffer2+pixel));
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel));
        p2[2] = (pixel2 >> 8) & 0xFF;
        p3[1] = (pixel3 >> 0) & 0xFF;
        p3[2] = (pixel3 >> 8) & 0xFF;
        break;

      default: // Inside
          for (int j = 0; j < 4; ++j) {
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(sobelBuffer2+pixel-1));
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+pixel-1));
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel3):[in1] "r"(sobelBuffer4+pixel-1));
            p1[j] = (pixel1 >> (8 * j)) & 0xFF;
            p2[j] = (pixel2 >> (8 * j)) & 0xFF;
            p3[j] = (pixel3 >> (8 * j)) & 0xFF;
          }
          break;
    }

    pixel1 = ((uint32_t)p2[1] << 24) |
            ((uint32_t)p1[2] << 16) |
            ((uint32_t)p1[1] <<  8) |
            ((uint32_t)p1[0] <<  0);

    pixel2 = ((uint32_t)p3[2] << 24) |
              ((uint32_t)p3[1] << 16) |
              ((uint32_t)p3[0] <<  8) |
              ((uint32_t)p2[2] <<  0);

    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],21":[out1]"=r"(sobelPixel):[in1]"r"(pixel1),[in2]"r"(pixel2));
    sobelPixels1 |= ((sobelPixel >> (8 * i)) & 0xFF) << (8 * i); 
  }

  return sobelPixels1;
}