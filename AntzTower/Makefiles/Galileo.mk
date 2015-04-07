#
# embedXcode
# ----------------------------------
# Embedded Computing on Xcode
#
# Copyright © Rei VILO, 2010-2015
# http://embedxcode.weebly.com
# All rights reserved
#
#
# Last update: Sep 06, 2014 release 176


# Galileo x86 specifics
# ----------------------------------
#
PLATFORM         := Galileo
BUILD_CORE       := x86
PLATFORM_TAG      = ARDUINO=153 __ARDUINO_X86__ EMBEDXCODE=$(RELEASE_NOW)
APPLICATION_PATH := $(GALILEO_PATH)

APP_TOOLS_PATH   := $(APPLICATION_PATH)/hardware/tools/x86/i386-pokysdk-darwin/usr/bin/i586-poky-linux-uclibc
CORE_LIB_PATH    := $(APPLICATION_PATH)/hardware/arduino/x86/cores/arduino
APP_LIB_PATH     := $(APPLICATION_PATH)/libraries
BOARDS_TXT       := $(APPLICATION_PATH)/hardware/arduino/x86/boards.txt

#
# Uploader bossac 
# Tested by Mike Roberts 
#
UPLOADER         = izmirdl
UPLOADER_PATH    = $(APPLICATION_PATH)/hardware/arduino/x86/tools/izmir
UPLOADER_EXEC    = $(UTILITIES_PATH)/uploader_izmir.sh
UPLOADER_OPTS    = $(APPLICATION_PATH)/hardware/tools/x86/bin

# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(USER_PATH)/Library/Arduino/preferences.txt,)
    $(error Error: run Arduino once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(USER_PATH)/Library/Arduino15/preferences.txt | cut -d = -f 2)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
   $(error Error: sketchbook path not found)
endif

USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)

# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"Arduino.h\"  

# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-gcc
CXX     = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-g++
AR      = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-ar
OBJDUMP = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-objdump
OBJCOPY = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-objcopy
SIZE    = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-size
NM      = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-nm
STRIP   = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-strip

# Specific AVRDUDE location and options
#
AVRDUDE_COM_OPTS  = -D -p$(MCU) -C$(AVRDUDE_CONF)

BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
#LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),build.ldscript)
VARIANT  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH = $(APPLICATION_PATH)/hardware/arduino/x86/variants/$(VARIANT)
VARIANT_CPP_SRCS  = $(wildcard $(VARIANT_PATH)/*.cpp) # */  $(VARIANT_PATH)/*/*.cpp #*/
VARIANT_OBJ_FILES = $(VARIANT_CPP_SRCS:.cpp=.cpp.o)
VARIANT_OBJS      = $(patsubst $(VARIANT_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))

#SYSTEM_LIB  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant_system_lib)
SYSTEM_PATH = $(VARIANT_PATH)
SYSTEM_OBJS = $(SYSTEM_PATH)/$(SYSTEM_LIB)


# Two locations for Arduino libraries
#
BUILD_APP_LIB_PATH  = $(APPLICATION_PATH)/hardware/arduino/$(BUILD_CORE)/libraries

ifndef APP_LIBS_LIST
    w1             = $(realpath $(sort $(dir $(wildcard $(APP_LIB_PATH)/*/*.h $(APP_LIB_PATH)/*/*/*.h $(APP_LIB_PATH)/*/*/*/*.h)))) # */
    APP_LIBS_LIST  = $(subst $(APP_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(w1)))

    w2             = $(realpath $(sort $(dir $(wildcard $(BUILD_APP_LIB_PATH)/*/*.h $(BUILD_APP_LIB_PATH)/*/*/*.h $(BUILD_APP_LIB_PATH)/*/*/*/*.h)))) # */
    BUILD_APP_LIBS_LIST = $(subst $(BUILD_APP_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(w2)))
else
    w2             = $(realpath $(sort $(dir $(wildcard $(BUILD_APP_LIB_PATH)/*/*.h $(BUILD_APP_LIB_PATH)/*/*/*.h $(BUILD_APP_LIB_PATH)/*/*/*/*.h)))) # */
    BUILD_APP_LIBS_LIST = $(subst $(BUILD_APP_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(w2)))
endif


# Arduino 1.5.x nightmare with src and arch/sam or arch/avr or arch/x86
# Another example of Arduino's quick and dirty job
#
ifneq ($(APP_LIBS_LIST),0)
    w3              = $(patsubst %,$(APP_LIB_PATH)/%/src,$(APP_LIBS_LIST))
    w3             += $(patsubst %,$(APP_LIB_PATH)/%/arch/$(BUILD_CORE),$(APP_LIBS_LIST))
    APP_LIBS        = $(realpath $(sort $(dir $(foreach dir,$(w3),$(wildcard $(dir)/*.h $(dir)/*/*.h $(dir)/*/*/*.h))))) # */

    APP_LIB_CPP_SRC = $(wildcard $(patsubst %,%/*.cpp,$(APP_LIBS))) # */
    APP_LIB_C_SRC   = $(wildcard $(patsubst %,%/*.c,$(APP_LIBS))) # */

    APP_LIB_OBJS    = $(patsubst $(APP_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(APP_LIB_CPP_SRC))
    APP_LIB_OBJS   += $(patsubst $(APP_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(APP_LIB_C_SRC))

    BUILD_APP_LIBS        = $(patsubst %,$(BUILD_APP_LIB_PATH)/%,$(BUILD_APP_LIBS_LIST))

    BUILD_APP_LIB_CPP_SRC = $(wildcard $(patsubst %,%/*.cpp,$(BUILD_APP_LIBS))) # */
    BUILD_APP_LIB_C_SRC   = $(wildcard $(patsubst %,%/*.c,$(BUILD_APP_LIBS))) # */

    BUILD_APP_LIB_OBJS    = $(patsubst $(BUILD_APP_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(BUILD_APP_LIB_CPP_SRC))
    BUILD_APP_LIB_OBJS   += $(patsubst $(BUILD_APP_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(BUILD_APP_LIB_C_SRC))
endif

#SYSTEM_FLAGS    = -I$(APPLICATION_PATH)/hardware/arduino/sam/system/libsam
#SYSTEM_FLAGS   += -I$(APPLICATION_PATH)/hardware/arduino/sam/system/libsam/include
#SYSTEM_FLAGS   += -I$(APPLICATION_PATH)/hardware/arduino/sam/system/CMSIS/CMSIS/Include/
#SYSTEM_FLAGS   += -I$(APPLICATION_PATH)/hardware/arduino/sam/system/CMSIS/Device/ATMEL/

MCU_FLAG_NAME   = march
EXTRA_LDFLAGS   = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu) -$(MCU_FLAG_NAME)=$(MCU)
EXTRA_LDFLAGS  += --sysroot=$(APPLICATION_PATH)/hardware/tools/x86/i586-poky-linux-uclibc
#EXTRA_LDFLAGS  += -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align
#EXTRA_LDFLAGS  += -Wl,--warn-unresolved-symbols

LDFLAGS         = -$(MCU_FLAG_NAME)=$(MCU) -Wl,--gc-sections $(OPTIMISATION) $(EXTRA_LDFLAGS)

EXTRA_CPPFLAGS  = $(addprefix -D, $(PLATFORM_TAG)) $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
EXTRA_CPPFLAGS += -$(MCU_FLAG_NAME)=$(MCU) -Xassembler -mquark-strip-lock=yes
EXTRA_CPPFLAGS += --sysroot=$(APPLICATION_PATH)/hardware/tools/x86/i586-poky-linux-uclibc -I$(VARIANT_PATH)

CPPFLAGS      = -MMD
CPPFLAGS     += $(SYS_INCLUDES) -g $(OPTIMISATION) $(WARNING_FLAGS) -ffunction-sections -fdata-sections -fno-exceptions
CPPFLAGS     += $(EXTRA_CPPFLAGS) -I$(CORE_LIB_PATH)

#OBJCOPYFLAGS  = -v -Obinary
TARGET_HEXBIN = $(TARGET_HEX)

# Arduino Due USB PID VID
#
#USB_VID   := $(call PARSE_BOARD,$(BOARD_TAG),build.vid)
#USB_PID   := $(call PARSE_BOARD,$(BOARD_TAG),build.pid)

#USB_FLAGS  = -DUSB_VID=$(USB_VID)
#USB_FLAGS += -DUSB_PID=$(USB_PID)
#USB_FLAGS += -DUSBCON

# Arduino Due serial 1200 reset
#
#USB_TOUCH := $(call PARSE_BOARD,$(BOARD_TAG),upload.protocol)
#USB_RESET  = python $(UTILITIES_PATH)/reset_1200.py

