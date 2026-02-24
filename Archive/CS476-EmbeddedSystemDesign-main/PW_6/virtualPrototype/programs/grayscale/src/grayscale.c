#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>

#define __WITH_CI

void DMA_trasnfert_finish(uint32_t statusControl) {
  uint32_t dmastatus;
  do {
    asm volatile ("l.nios_rrr %[out1],%[in1],r0,20":[out1]"=r"(dmastatus):[in1]"r"(statusControl));
  } while (dmastatus != 0);
  return;
}

int main () {
  // variable for DMA
  const uint32_t writeBit = 1<<9;
  const uint32_t busStartAddress = 1 << 10;
  const uint32_t memoryStartAddress = 2 << 10;
  const uint32_t blockSize = 3 << 10;
  const uint32_t burstSize = 4 << 10;
  const uint32_t statusControl = 5 << 10;
  const uint32_t usedCiRamAddress = 50;
  const uint32_t usedBlocksize = 512;
  const uint32_t usedBurstSize = 25;
  uint32_t ramAddress, ramData;

  // variable for grayscale
  volatile uint16_t rgb565[640*480];
  volatile uint8_t grayscale[640*480];
  uint32_t grayPixels;

  // variable for GPIO
  volatile unsigned int *gpio = (unsigned int *) 0x40000000;
  volatile uint32_t result, cycles,stall,idle;

  // variable for ping-pong buffer
  const uint32_t NBR_iteration = 600;

  // vga
  volatile unsigned int *vga = (unsigned int *) 0X50000020;
  camParameters camParams;
  vga_clear();

  // initialising
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
  vga[2] = swap_u32(2);
  vga[3] = swap_u32((uint32_t) &grayscale[0]);

  // infinite loop for treat the picture
  while(1) {
    takeSingleImageBlocking((uint32_t) &rgb565[0]);

    asm volatile ("l.nios_rrr r0,r0,%[in2],0xC"::[in2]"r"(7));  
    uint32_t * rgb = (uint32_t *) &rgb565[0];
    uint32_t * gray = (uint32_t *) &grayscale[0];

#ifdef __WITH_CI
      for(int package = 0; package < NBR_iteration + 1; ++package) {

        // initilise buffer
        uint32_t ping_buffer = 0;
        uint32_t pong_buffer = 256;
        uint32_t rgb_pointer = (uint32_t) &rgb[0];
        uint32_t grey_pointer = (uint32_t) &gray[0];

        // we dont use dma for last iteration
        if (package < NBR_iteration) {
          // dma operation memory to ciram
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(blockSize | writeBit),[in2] "r"(usedBlocksize));
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(burstSize | writeBit),[in2] "r"(usedBurstSize));
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(busStartAddress | writeBit),[in2] "r"(rgb_pointer));
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(memoryStartAddress | writeBit),[in2] "r"(ping_buffer));
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(1));
          rgb_pointer += usedBlocksize*4;
          DMA_trasnfert_finish(statusControl);
        }
        
        // operate grayscale
        if (package > 0) {
          for (int pixel = 0; pixel < usedBlocksize; pixel +=2) {
            uint32_t pixel1;
            uint32_t pixel2;

            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel1):[in1] "r"(pong_buffer+pixel));
            asm volatile("l.nios_rrr %[out1],%[in1],r0,20" :[out1]"=r"(pixel2):[in1] "r"(pong_buffer+pixel+1));
            pixel1 = swap_u32(pixel1);
            pixel2 = swap_u32(pixel2);
            asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],10":[out1]"=r"(grayPixels):[in1]"r"(pixel1),[in2]"r"(pixel2));
            grayPixels = swap_u32(grayPixels);
            asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"((pong_buffer+(pixel>>1))| writeBit),[in2]"r"(grayPixels));
          }

          DMA_trasnfert_finish(statusControl);

          // we write the grey pixel
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(blockSize | writeBit),[in2] "r"((usedBlocksize >> 1)));
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(burstSize | writeBit),[in2] "r"(usedBurstSize));
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(busStartAddress | writeBit),[in2] "r"(grey_pointer));
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(memoryStartAddress | writeBit),[in2] "r"(pong_buffer));
          asm volatile("l.nios_rrr r0,%[in1],%[in2],20" ::[in1] "r"(statusControl | writeBit),[in2] "r"(2));
          grey_pointer += (usedBlocksize << 1);

          DMA_trasnfert_finish(statusControl);
        }
        // invert ping-pong
        uint32_t transit = ping_buffer;
        ping_buffer = pong_buffer;
        pong_buffer = transit;
      }
      
#else
    for (int line = 0; line < camParams.nrOfLinesPerImage; line++) {
      for (int pixel = 0; pixel < camParams.nrOfPixelsPerLine; pixel++) {
        uint16_t rgb = swap_u16(rgb565[line*camParams.nrOfPixelsPerLine+pixel]);
        uint32_t red1 = ((rgb >> 11) & 0x1F) << 3;
        uint32_t green1 = ((rgb >> 5) & 0x3F) << 2;
        uint32_t blue1 = (rgb & 0x1F) << 3;
        uint32_t gray = ((red1*54+green1*183+blue1*19) >> 8)&0xFF;
        grayscale[line*camParams.nrOfPixelsPerLine+pixel] = gray;
      }
    }
#endif
    
    asm volatile ("l.nios_rrr %[out1],r0,%[in2],0xC":[out1]"=r"(cycles):[in2]"r"(1<<8|7<<4));
    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(stall):[in1]"r"(1),[in2]"r"(1<<9));
    asm volatile ("l.nios_rrr %[out1],%[in1],%[in2],0xC":[out1]"=r"(idle):[in1]"r"(2),[in2]"r"(1<<10));
    printf("nrOfCycles: %d %d %d\n", cycles, stall, idle);
  
  }
}
