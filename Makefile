# Phony targets
.PHONY: all cppcheck valgrind leaks clang-analyze clang-tidy flawfinder sonar-scanner infer asan clean

# Set STRICT variable if you want to use stricter CFLAGS for compiling.
STRICT := false

# Define variables for the source directory and executable name
SRC_DIR ?= .
EXEC_NAME ?= main

# Windows has $OS env var set by default
OS := $(OS)
ifeq ($(OS),)
    OS := $(shell uname)
endif

CC = gcc
COMMON_CFLAGS = -std=c17 -Wall -Werror -Wextra -Wno-sign-compare \
                -Wno-unused-parameter -Wno-unused-variable -Wshadow 

# Set the stricter CFLAGS if the strict var has been set to true
ifeq ($(STRICT),true)
    COMMON_CFLAGS += -pedantic -Wconversion -Wformat=2 -Wmissing-include-dirs -Wswitch-enum \
                    -Wfloat-equal -Wredundant-decls -Wnull-dereference -Wold-style-definition \
                    -Wdouble-promotion -Wshadow -Wshift-overflow -Wstrict-aliasing=2
endif

# Example: LDLIBS += -lsomeMacSpecificLib
LDLIBS =
LDFLAGS =
PROD_CFLAGS = -O2

DEBUG_CFLAGS = -Wno-error=unused-result -fno-strict-aliasing -gdwarf-4 -g3 -O0 \
                -Wstack-protector -fstack-protector-all -Wformat -Wformat-security \
                -Wswitch-default -Wswitch-enum -fsanitize=undefined

COMMON_GCC_CFLAGS = -Wlogical-op  -Wstrict-overflow=5 -Wformat-overflow=2 \
					-Wformat-truncation=2 -Wstack-usage=1024
COMMON_CLANG_CFLAGS = -Wlogical-not-parentheses -Wlogical-op-parentheses
DEBUG_CFLAGS_GCC = -fmax-errors=1
DEBUG_CFLAGS_CLANG = -ferror-limit=1 -Wno-gnu-folding-constant

# For Windows use MSYS2, cygwin, or WSL 2
ifeq ($(OS), Windows_NT)
    # Uncomment the following line if you prefer clang to gcc
    # If using clang, be sure to use llvm and lldb
    # clang is possible through WSL and *nix Windows environments
    # like cygwin or msys2
    # CC = clang
    COMMON_CFLAGS += -D_WIN32
    LDLIBS += -lws2_32
    DEBUG_CFLAGS +=
    PROD_CFLAGS +=
    LDFLAGS +=
else ifeq ($(OS), Linux)
    IS_LINUX = 1
    # Uncomment the following line if you prefer clang to gcc
    # If using clang, be sure to use llvm and lldb
    # CC = clang
    # Add Linux-specific flags or libraries if needed
    COMMON_CFLAGS +=
    DEBUG_CFLAGS +=
    PROD_CFLAGS +=
    LDFLAGS +=
    LDLIBS +=
else ifeq ($(OS), Darwin)
    IS_MACOS = 1
    CC = clang
    COMMON_CFLAGS += 
    DEBUG_CFLAGS += 
    PROD_CFLAGS +=
    LDFLAGS +=
    LDLIBS +=
endif

ifeq ($(CC),gcc)
    COMMON_CFLAGS += $(COMMON_GCC_CFLAGS)
    DEBUG_CFLAGS += $(DEBUG_CFLAGS_GCC)
else ifeq ($(CC),clang)
    COMMON_CFLAGS += $(COMMON_CLANG_CFLAGS)
    DEBUG_CFLAGS += $(DEBUG_CFLAGS_CLANG)
endif

DEBUG_CFLAGS += $(COMMON_CFLAGS) 
PROD_CFLAGS += $(COMMON_CFLAGS)

# Static analysis tools
CPPCHECK = cppcheck
VALGRIND_MEMCHECK = valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes
VALGRIND_HELGRIND = valgrind --tool=helgrind
VALGRIND_DRD = valgrind --tool=drd
VALGRIND_CALLGRIND = valgrind --tool=callgrind
VALGRIND_MASSIF = valgrind --tool=massif
VALGRIND_CACHEGRIND = valgrind --tool=cachegrind
VALGRIND_SGCHECK = valgrind --tool=exp-sgcheck
LEAKS = leaks
CLANG_ANALYZER = clang --analyze
CLANG_TIDY = clang-tidy
FLAWFINDER = flawfinder
# PVS_STUDIO = pvs-studio-analyzer
# COVERITY = cov-build --dir cov-int
SONARQUBE_SCANNER = sonar-scanner
INFER = infer
ASAN_FLAGS = -fsanitize=address -fno-omit-frame-pointer
LSAN_FLAGS = -fsanitize=leak
TSAN_FLAGS = -fsanitize=thread

# Source files: All .c files in the exercise directory
SRCS = $(wildcard $(SRC_DIR)/*.c)

# Object files: Corresponding .o files in the exercise directory
OBJS = $(SRCS:.c=.o)

# Executable: Based on exercise name
EXEC = $(SRC_DIR)/$(EXEC_NAME)

# Default target
all: debug

# Compile target for debug build
debug: CFLAGS = $(DEBUG_CFLAGS)
debug: $(EXEC)

# Compile target for production build
release: CFLAGS = $(PROD_CFLAGS)
release: $(EXEC)

# Compile target
$(EXEC): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(EXEC) $(LDFLAGS) $(LDLIBS)

# Object file compilation
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Run cppcheck
cppcheck:
	$(CPPCHECK) --enable=all --inconclusive --std=c17 --suppress=missingIncludeSystem --quiet $(SRCS)

# Run valgrind
valgrind-memcheck: $(EXEC)
	$(VALGRIND_MEMCHECK) $(EXEC)

valgrind-helgrind: $(EXEC)
	$(VALGRIND_HELGRIND) $(EXEC)

valgrind-drd: $(EXEC)
	$(VALGRIND_DRD) $(EXEC)

valgrind-callgrind: $(EXEC)
	$(VALGRIND_CALLGRIND) $(EXEC)

valgrind-massif: $(EXEC)
	$(VALGRIND_MASSIF) $(EXEC)

valgrind-cachegrind: $(EXEC)
	$(VALGRIND_CACHEGRIND) $(EXEC)

valgrind-sgcheck: $(EXEC)
	$(VALGRIND_SGCHECK) $(EXEC)

# Run leaks on macOS
leaks: $(EXEC)
	$(LEAKS) --atExit -- $(EXEC)

# Run Clang Static Analyzer
clang-analyze:
	$(CLANG_ANALYZER) $(SRCS)

# Run Clang-Tidy
clang-tidy:
	$(CLANG_TIDY) $(SRCS) -- -std=c17

# Run Flawfinder
flawfinder:
	$(FLAWFINDER) $(SRCS)

# Run SonarQube Scanner
# Be sure sonarqube is running before running the scanner.
sonar-scanner:
	$(SONARQUBE_SCANNER) \
		-Dsonar.projectKey=$(SONARQUBE_PROJECT_KEY) \
		-Dsonar.host.url=$(SONARQUBE_HOST_URL) \
		-Dsonar.login=$(SONARQUBE_TOKEN)

# Run Infer
infer:
	$(INFER) run -- make

# Run AddressSanitizer
asan: CFLAGS += $(ASAN_FLAGS)
asan: clean $(EXEC)
	$(EXEC)

# Compile target with LeakSanitizer
lsan: CFLAGS += $(LSAN_FLAGS)
lsan: clean debug
	$(EXEC)

# Compile target with ThreadSanitizer
tsan: CFLAGS += $(TSAN_FLAGS)
tsan: clean debug
	$(EXEC)

# Clean up
clean:
	@[ -d "$(SRC_DIR)/infer-out" ] && rm -rf "$(SRC_DIR)/infer-out" || true
	@[ -d "$(SRC_DIR)/.scannerwork" ] && rm -rf "$(SRC_DIR)/.scannerwork" || true
	rm -f $(OBJS) $(EXEC) $(SRC_DIR)/*.plist
