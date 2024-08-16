# Compiler
CC ?= gcc

# Compiler flags
CFLAGS = -Wall -Wextra -O2

# Target executable
TARGET = vsock_ping

# Source files
SRC = src/vsock_ping.c

# Default target
all: $(TARGET)

# Build the target executable
$(TARGET): $(SRC)
	$(CC) -static $(CFLAGS) -o $@ $^

# Clean up object files and the target executable
clean:
	rm -f $(TARGET)

# Print some useful commands
.PHONY: help
help:
	@echo "Usage:"
	@echo "  make          Compile the program"
	@echo "  make clean    Remove object files and the executable"
	@echo "  make help     Display this help message"
