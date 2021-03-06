ARCH	= 68000
BASE	= m68k-elf
CC      = $(BASE)-gcc
LD      = $(BASE)-gcc
AS      = $(BASE)-as
CP      = $(BASE)-objcopy
DUMP    = $(BASE)-objdump
VASM	= vasmm68k_mot

# we use crt0.s from here
STARTUP_DIR = ../../Firmware_Common
COMMON_DIR = ../../Firmware_Common
LIB_DIR = ../../Firmware_Common/klibc

BUILD_DIR=m68k_obj

STARTUP_SRC = $(STARTUP_DIR)/startup_app.s $(STARTUP_DIR)/premain.s
STARTUP_OBJ = $(patsubst $(STARTUP_DIR)/%.s,$(BUILD_DIR)/%.o,$(STARTUP_SRC))

LIB_SRC = memcpy.c strcpy.c strcmp.c
LIB_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(LIB_SRC))

COMMON_SRC = vga.c uart.c interrupts.c small_printf.c
COMMON_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(COMMON_SRC))

MAIN_PRJ = Dhrystone
MAIN_C_SRC = dhry_1.c dhry_2.c main.c
MAIN_C_OBJ = $(patsubst %.c,$(BUILD_DIR)/%.o,$(MAIN_C_SRC))

MAIN_S_SRC = 
MAIN_S_OBJ = $(patsubst %.s,$(BUILD_DIR)/%.o,$(MAIN_S_SRC))

MAIN_OBJ = $(COMMON_OBJ) $(MAIN_C_OBJ) $(MAIN_S_OBJ) $(LIB_OBJ)

LINKMAP  = $(STARTUP_DIR)/ldscript_app.ld

# Commandline options for each tool.

CFLAGS  = -m$(ARCH) -fomit-frame-pointer -fno-common -I. -c -O6 -DDISABLE_UART_RX -I$(COMMON_DIR)

LFLAGS  = -m$(ARCH) -nostartfiles -nostdlib -Wl,--relax -O6 -Wl,--emit-relocs

LIBS = -lgcc

# Our target.
all: $(BUILD_DIR) $(MAIN_PRJ).sre $(MAIN_PRJ).rpt

clean:
	rm -f $(BUILD_DIR)/*.o *.elf *.sre *.rpt *.map *.lst *.srec *~ */*.o *.bin


# Convert ELF binary to bin file.
%.sre: %.elf
	$(CP) -O srec $< $@

%.rpt: %.elf
	echo >$@ -n "End of code:\t"
	$(DUMP) -x $< | grep >>$@ _romend
	echo >>$@ -n "Start of BSS:\t"
	$(DUMP) -x $< | grep  >>$@ __bss_start__
	echo >>$@ -n "End of BSS:\t"
	$(DUMP) -x $< | grep >>$@ __bss_end__
	cat $@

# Link - this produces an ELF binary.

$(MAIN_PRJ).elf: $(STARTUP_OBJ) $(MAIN_OBJ)
	$(LD) $(LFLAGS) -T $(LINKMAP) -o $@ $+ $(LIBS)

$(BUILD_DIR)/%.o: %.c Makefile
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: $(COMMON_DIR)/%.c Makefile
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: $(LIB_DIR)/%.c Makefile
	$(CC) $(CFLAGS)  -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(VASM) -Felf -o $@ $<

$(BUILD_DIR)/%.o: $(STARTUP_DIR)/%.s
	$(VASM) -Felf -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

