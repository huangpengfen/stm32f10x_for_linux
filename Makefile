
CROSS_COMPILE    ?= arm-none-eabi-
CC               =  $(CROSS_COMPILE)gcc
CP               =  $(CROSS_COMPILE)objcopy
AS               =  $(CROSS_COMPILE)as
HEX              =  $(CP) -O ihex
BIN              =  $(CP) -O binary -S

# mcu
MCU          = cortex-m3

# all the files will be generated with this name (main.elf, main.bin, main.hex, etc)
TARGET ?= stm32f10x

# specify define
DDEFS       =

# define root dir
ROOT_DIR     = .

# define include dir
INCLUDE_DIRS = .

# define stm32f10x lib dir
STM32F10x_LIB_DIR      = $(ROOT_DIR)/stm32f10x_lib

# define user dir
USER_DIR     = $(ROOT_DIR)/user

# link file
LINK_SCRIPT  = $(ROOT_DIR)/stm32_flash.ld

# stm32f10x lib src
STM32F10X_LIB_SRC      =

# user specific
SRC         =
SRC         += $(USER_DIR)/main.c
SRC         += $(USER_DIR)/uart.c

ASM_SRC      =

# user include
INCLUDE_DIRS  += $(USER_DIR)
INCLUDE_DIRS  += $(ROOT_DIR)/stm32f10x_lib/STM32F10x_StdPeriph_Driver
# include sub makefiles
include makefile_std_lib.mk  # STM32 Standard Peripheral Library

INC_DIR  = $(patsubst %, -I%, $(INCLUDE_DIRS))

# run from Flash
DEFS	 = $(DDEFS) -DRUN_FROM_FLASH=1

OBJECTS  = $(ASM_SRC:.s=.o) $(SRC:.c=.o) $(STM32F10X_LIB_SRC:.c=.o)

# Define optimisation level here
OPT = -Os

MC_FLAGS = -mcpu=$(MCU)

AS_FLAGS = $(MC_FLAGS) -g -gdwarf-2 -mthumb 
CP_FLAGS = $(MC_FLAGS) $(OPT) -g -gdwarf-2 -mthumb -fomit-frame-pointer -Wall -fverbose-asm $(DEFS)
LD_FLAGS = $(MC_FLAGS) -g -gdwarf-2 -mthumb -nostartfiles -Xlinker --gc-sections -T$(LINK_SCRIPT) -Wl,-Map=$(TARGET).map,--cref,--no-warn-mismatch

#
# makefile rules
#
all: $(OBJECTS) $(TARGET).elf  $(TARGET).hex $(TARGET).bin
	$(CROSS_COMPILE)size $(TARGET).elf

%.o: %.c
	$(CC) $(CP_FLAGS) $(INC_DIR) -c $< -o $@

%.o: %.s
	$(AS) $(AS_FLAGS) -c $< -o $@

%.elf: $(OBJECTS)
	$(CC) $(OBJECTS) $(LD_FLAGS) -o $@

%.hex: %.elf
	$(HEX) $< $@

%.bin: %.elf
	$(BIN)  $< $@

flash: $(TARGET).bin
	st-flash write $(TARGET).bin 0x8000000

erase:
	st-flash erase

clean:
	-rm -rf $(OBJECTS)
	-rm -rf $(TARGET).elf
	-rm -rf $(TARGET).map
	-rm -rf $(TARGET).hex
	-rm -rf $(TARGET).bin
	-rm -rf $(SRC:.c=.lst)
	-rm -rf $(ASM_SRC:.s=.lst)

