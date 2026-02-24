#include <stdio.h>
#include <ov7670.h>
#include <swap.h>
#include <vga.h>


int main () {
  volatile uint16_t rgb565[640*480];
  volatile uint8_t grayscale[640*480];
  volatile uint32_t result, cycles,stall,idle;
  volatile uint32_t control;
  volatile unsigned int *vga = (unsigned int *) 0X50000020;
  camParameters camParams;
  vga_clear();

  printf("Initialising camera (this takes up to 3 seconds)!\n" );
  camParams = initOv7670(VGA);
  printf("Done!\n");

  printf("NrOfPixels : %d\n", camParams.nrOfPixelsPerLine);
  result = (camParams.nrOfPixelsPerLine <= 320) ? camParams.nrOfPixelsPerLine | 0x80000000 : camParams.nrOfPixelsPerLine;
  vga[0] = swap_u32(result);
  printf("NrOfLines  : %d\n", camParams.nrOfLinesPerImage );
  result =  (camParams.nrOfLinesPerImage <= 240) ? camParams.nrOfLinesPerImage | 0x80000000 : camParams.nrOfLinesPerImage;
  vga[1] = swap_u32(result);
  printf("PCLK (kHz) : %d\n", camParams.pixelClockInkHz );
  printf("FPS        : %d\n", camParams.framesPerSecond );
  uint32_t * rgb = (uint32_t *) &rgb565[0];
  uint32_t grayPixels;
  vga[2] = swap_u32(2);
  vga[3] = swap_u32((uint32_t) &grayscale[0]);
  while(1) {
    uint32_t * gray = (uint32_t *) &grayscale[0];

    // Start profiling
    control = 7;  // Enable counters
    asm volatile("l.nios_rrr r0, r0, %[in2], 0xB" : : [in2] "r"(control));

    takeSingleImageBlocking((uint32_t) &rgb565[0]);

    for (int line = 0; line < camParams.nrOfLinesPerImage; line++) {
      for (int pixel = 0; pixel < camParams.nrOfPixelsPerLine; pixel++) {
        uint16_t rgb = swap_u16(rgb565[line * camParams.nrOfPixelsPerLine + pixel]);
        uint32_t gray;

        // Standard grayscale conversion
        uint32_t red = ((rgb >> 11) & 0x1F) << 3;
        uint32_t green = ((rgb >> 5) & 0x3F) << 2;
        uint32_t blue = (rgb & 0x1F) << 3;
        gray = ((red * 54 + green * 183 + blue * 19) >> 8) & 0xFF;
        grayscale[line * camParams.nrOfPixelsPerLine + pixel] = gray;
      }
    }

      // Read profiling counters after conversion
      uint32_t counter_id;

      // Read CPU execution cycles
      counter_id = 0;
      asm volatile("l.nios_rrr %[out1], %[in1], r0, 0xB"
                    : [out1] "=r"(cycles)
                    : [in1] "r"(counter_id));
      printf("Raw Execution cycles: %u\n", cycles);  // Debugging print

      // Read stall cycles
      counter_id = 1;
      asm volatile("l.nios_rrr %[out1], %[in1], r0, 0xB"
                    : [out1] "=r"(stall)
                    : [in1] "r"(counter_id));
      printf("Raw Stall cycles: %u\n", stall);  // Debugging print

      // Read bus-idle cycles
      counter_id = 2;
      asm volatile("l.nios_rrr %[out1], %[in1], r0, 0xB"
                    : [out1] "=r"(idle)
                    : [in1] "r"(counter_id));
      printf("Raw Bus-idle cycles: %u\n", idle);  // Debugging print

      // Handle overflow (assuming 32-bit counters)
      uint32_t real_execution_cycles;
      if (cycles >= stall) {
          real_execution_cycles = cycles - stall;
      } else {
          // Handle overflow
          real_execution_cycles = (0xFFFFFFFF - stall + 1) + cycles;
      }

      // Debugging: Verify counter relationships
      if (stall > cycles) {
          printf("Warning: Stall cycles (%u) exceed Execution cycles (%u). Possible overflow.\n", stall, cycles);
      }
      if (idle > cycles) {
          printf("Warning: Bus-idle cycles (%u) exceed Execution cycles (%u). Possible overflow.\n", idle, cycles);
      }

      printf("Execution cycles: %u\n", cycles);
      printf("Stall cycles: %u\n", stall);
      printf("Bus-idle cycles: %u\n", idle);
      printf("Real execution cycles: %u\n", real_execution_cycles);
    }
}
