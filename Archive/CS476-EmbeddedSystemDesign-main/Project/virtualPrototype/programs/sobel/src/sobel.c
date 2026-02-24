#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>
#include <stdbool.h>
#define bad_sobel
#define CycleCounter
int main () { 

  const uint32_t writeBit = 1<<11;
  const uint32_t busStartAddress = 1 << 12;
  const uint32_t memoryStartAddress = 2 << 12;
  const uint32_t blockSize = 3 << 12;
  const uint32_t burstSize = 4 << 12;
  const uint32_t statusControl = 5 << 12;
  const uint32_t usedCiRamAddress = 50;
  const uint32_t usedBlocksize = 160;
  const uint32_t usedBurstSize = 32;
  const uint32_t Height = 480;
  const uint32_t Witdh = 640;
  const uint32_t nbr_loop = 480;
  volatile uint16_t rgb565[Height*Witdh];
  volatile uint8_t grayscale[Height*Witdh];
  volatile uint8_t sobelscale[Height*Witdh];
  volatile uint32_t result, cycles,stall,idle;
  volatile unsigned int *vga = (unsigned int *) 0X50000020;
  volatile unsigned int *gpio = (unsigned int *) 0x40000000;
  camParameters camParams;
  vga_clear();

  /* set up the generic dma parameters */
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(burstSize | writeBit),[in2] "r"(usedBurstSize));
  asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(blockSize | writeBit),[in2] "r"((usedBlocksize) << 1));

  printf("Initialising camera (this takes up to 3 seconds)!\n" );
  camParams = initOv7670(VGA);
  printf("Done!\n" );
  printf("NrOfPixels : %d\n", camParams.nrOfPixelsPerLine );
  result = (camParams.nrOfPixelsPerLine <= 320) ? camParams.nrOfPixelsPerLine | 0x80000000 : camParams.nrOfPixelsPerLine;
  vga[0] = swap_u32(result);
  printf("NrOfLines  : %d\n", camParams.nrOfLinesPerImage );
  result =  (camParams.nrOfLinesPerImage <= 240) ? camParams.nrOfLinesPerImage | 0x80000000 : camParams.nrOfLinesPerImage;
  vga[1] = swap_u32(result);
  printf("PCLK (kHz) : %d\n", camParams.pixelClockInkHz );
  printf("FPS        : %d\n", camParams.framesPerSecond );
  uint32_t grayPixels;
  uint32_t sobelPixel, sobelPixels1, sobelPixels2;
  vga[2] = swap_u32(2);
  vga[3] = swap_u32((uint32_t) &sobelscale[0]);

  /* full black screen */

  while(1) {
    takeSingleImageBlocking((uint32_t) &rgb565[0]);
    #ifdef CycleCounter
    asm volatile ("l.nios_rrr r0,r0,%[in2],0xC"::[in2]"r"(7));
    #endif
    uint32_t * rgb = (uint32_t *) &rgb565[0];
    uint32_t * gray = (uint32_t *) &grayscale[0];
    uint32_t * sbl = (uint32_t *) &sobelscale[0];
    uint32_t colorBuffer1 = usedBlocksize * 0;
    uint32_t colorBuffer2 = usedBlocksize * 2;
    uint32_t sobelBuffer1 = usedBlocksize * 4;
    uint32_t sobelBuffer2 = usedBlocksize * 5;
    uint32_t sobelBuffer3 = usedBlocksize * 6;
    uint32_t sobelBuffer4 = usedBlocksize * 7;
    uint32_t status;
    uint32_t Index = 0;
    uint32_t pixel1, pixel2, pixel3, sbl1, sbl2;
    uint32_t rgbpointer = (uint32_t) &rgb[0];
    uint32_t graypointer = (uint32_t) &gray[0];
    uint32_t sobelpointer = (uint32_t) &sbl[0];


    for (int loop = 0 ; loop < nbr_loop + 4; loop++) {

      /* first color*/
      if (loop < nbr_loop) {
        asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(busStartAddress | writeBit),[in2] "r"(rgbpointer));
        rgbpointer += (usedBlocksize)*8;
        asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(memoryStartAddress | writeBit),[in2] "r"(colorBuffer1));
        asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(1));
      }

      /* compute of grayscale */
      
        for (int pixel = 0 ; pixel < usedBlocksize*2+1; pixel += 2) {
          if ((loop > 0) && (loop < nbr_loop + 1) && (pixel < usedBlocksize*2)) {
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(colorBuffer2+pixel));
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(colorBuffer2+pixel+1));
            pixel1 = swap_u32(pixel1);
            pixel2 = swap_u32(pixel2);
            asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xA":[out1]"=r"(grayPixels):[in1]"r"(pixel1),[in2]"r"(pixel2));
            grayPixels = swap_u32(grayPixels);
            asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"((sobelBuffer1+(pixel>>1))| writeBit),[in2]"r"(grayPixels));
          }
          /* compute of Sobel */
          if ((loop > 3) && (loop < nbr_loop + 4)) {
            
            if (pixel < usedBlocksize*2) {
              #ifdef bad_sobel
                sobelPixels1 = perform_sobel((pixel>>1), Index, Height, Witdh, sobelBuffer2, sobelBuffer3, sobelBuffer4, pixel1, pixel2, pixel3);
              #else
              sobelPixels1 = 0;
              for (int i = 0; i < 4; ++i){
                /* load line for sobel*/
                asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(sobelBuffer2+(pixel>>1)-1));
                asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(sobelBuffer3+(pixel>>1)-1));
                asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel3):[in1] "r"(sobelBuffer4+(pixel>>1)-1));

                /*rearange the pixel*/
                asm volatile("l.nios_rrr %[out1],%[in1],%[in2],22" :[out1] "=r" (sbl1):[in1] "r"(pixel1),[in2]"r"(pixel2));
                
                asm volatile("l.nios_rrr %[out1],%[in1],%[in2],23" :[out1] "=r" (sbl2):[in1] "r"(pixel2),[in2]"r"(pixel3));

                /*compute sobel*/
                asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],21":[out1]"=r"(sobelPixel):[in1]"r"(sbl1),[in2]"r"(sbl2));
                sobelPixels1 |= ((sobelPixel >> (8 * i)) & 0xFF) << (8 * i); 
              }
            #endif

            }
            if (pixel > 0) {
              // Wait for DMA to finish before writing
              do {
                asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(status):[in1] "r"(statusControl));
              } while (status != 0);
              asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"((sobelBuffer2+(pixel>>1)-1)| writeBit),[in2]"r"(sobelPixels2));  
            }
            sobelPixels2 = sobelPixels1;
          }
        }

     

      /* wait for the DMA to finish */
      do {
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(status):[in1] "r"(statusControl));
      } while (status != 0);

      /* perform DMA out */
      if ((loop > 3) && (loop < nbr_loop + 4)) {
        asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(blockSize | writeBit),[in2] "r"(usedBlocksize));
        asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(busStartAddress | writeBit),[in2] "r"(sobelpointer));
        sobelpointer += ((usedBlocksize) << 2);
        asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(memoryStartAddress | writeBit),[in2] "r"(sobelBuffer2));
        asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(2));
      }


      /* wait for the DMA to finish */
      do {
        asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(status):[in1] "r"(statusControl));
      } while (status != 0);
      asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(blockSize | writeBit),[in2] "r"((usedBlocksize) << 1));
    

      /* swap buffers */
      status       = colorBuffer1;
      colorBuffer1 = colorBuffer2;
      colorBuffer2 = status;

      if(loop > 0) {
        status = sobelBuffer1;
        sobelBuffer1 = sobelBuffer2;
        sobelBuffer2 = sobelBuffer3;
        sobelBuffer3 = sobelBuffer4;
        sobelBuffer4 = status;
      }
    }
    #ifdef CycleCounter
    // Read cycle, stall, idle counters
    asm volatile ("l.nios_rrr %[out1],r0,%[in2],0xC":[out1]"=r"(cycles):[in2]"r"(1<<8|7<<4));
    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(stall):[in1]"r"(1),[in2]"r"(1<<9));
    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(idle):[in1]"r"(2),[in2]"r"(1<<10));
    printf("nrOfCycles: %d %d %d\n", cycles, stall, idle);
    #endif
  }
}

