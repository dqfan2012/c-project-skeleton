# Phony targets
.PHONY: all cppcheck valgrind leaks clang-analyze clang-tidy flawfinder pvs-studio coverity sonarqube infer asan clean

# Set STRICT variable if you want to use stricter CFLAGS for compiling.
STRICT := false

# Windows has $OS env var set by default
OS := $(OS)
ifeq ($(OS),)
    OS := $(shell uname)
endif

CC = gcc
COMMON_CFLAGS = -std=c17 -Wall -Werror -Wextra -Wno-sign-compare \
                -Wno-unused-parameter -Wno-unused-variable -Wshadow

DEBUG_CFLAGS =
PROD_CFLAGS =
# Example: LDLIBS += -lsomeMacSpecificLib
LDLIBS = 
LDFLAGS =

# For Windows use MSYS2, cygwin, or WSL 2
ifeq ($(OS), Windows_NT)
    # Uncomment the following line if you prefer clang to gcc
    # If using clang, be sure to use llvm and lldb
    # clang is possible through WSL and *nix Windows environments
    # like cygwin or msys2
    # CC = clang
    # Add Windows-specific flags or libraries if needed
    COMMON_CFLAGS += -D_WIN32
    DEBUG_CFLAGS +=
    PROD_CFLAGS +=
    LDFLAGS +=
    LDLIBS += -lws2_32
else ifeq ($(OS), Linux)
    IS_LINUX = 1
    # Uncomment the following line if you prefer clang to gcc
    # If using clang, be sure to use llvm and lldb
    # CC = clang
    # Add Linux-specific flags or libraries if needed
    DEBUG_CFLAGS +=
    PROD_CFLAGS +=
    LDFLAGS +=
    LDLIBS +=
else ifeq ($(OS), Darwin)
    IS_MACOS = 1
    CC = clang
    # Add Mac-specific flags or libraries if needed
    DEBUG_CFLAGS += -Wno-gnu-folding-constant
    PROD_CFLAGS +=
    LDFLAGS +=
    LDLIBS +=
endif

# Set the stricter CFLAGS if the strict var has been set to true
ifeq ($(STRICT),true)
	COMMON_CFLAGS += -pedantic -Wconversion -Wformat=2 -Wmissing-include-dirs -Wswitch-enum \
                    -Wfloat-equal -Wredundant-decls -Wnull-dereference -Wold-style-definition

	ifeq ($(CC),gcc)
		COMMON_CFLAGS += -Wlogical-op
	else ifeq ($(CC),clang)
		COMMON_CFLAGS += -Wlogical-not-parentheses -Wlogical-op-parentheses
	endif
endif

DEBUG_CFLAGS += -ferror-limit=1 -gdwarf-4 -g3 -O0 $(COMMON_CFLAGS) -Wno-gnu-folding-constant
PROD_CFLAGS += -O2 $(COMMON_CFLAGS)

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

# Source files
SRCS = file1.c file2.c # List C files here.

# Object files
OBJS = $(SRCS:.c=.o)

# Executable
EXEC = file1

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
    $(CPPCHECK) --enable=all --inconclusive --std=c17 --quiet $(SRCS)

# Run valgrind
valgrind-memcheck: $(EXEC)
	$(VALGRIND_MEMCHECK) ./$(EXEC)

valgrind-helgrind: $(EXEC)
	$(VALGRIND_HELGRIND) ./$(EXEC)

valgrind-drd: $(EXEC)
	$(VALGRIND_DRD) ./$(EXEC)

valgrind-callgrind: $(EXEC)
	$(VALGRIND_CALLGRIND) ./$(EXEC)

valgrind-massif: $(EXEC)
	$(VALGRIND_MASSIF) ./$(EXEC)

valgrind-cachegrind: $(EXEC)
	$(VALGRIND_CACHEGRIND) ./$(EXEC)

valgrind-sgcheck: $(EXEC)
	$(VALGRIND_SGCHECK) ./$(EXEC)

# Run leaks on macOS
leaks: $(EXEC)
    $(LEAKS) --atExit -- ./$(EXEC)

# Run Clang Static Analyzer
clang-analyze:
    $(CLANG_ANALYZER) $(SRCS)

# Run Clang-Tidy
clang-tidy:
    $(CLANG_TIDY) $(SRCS) -- -std=c17

# Run Flawfinder
flawfinder:
    $(FLAWFINDER) $(SRCS)

# Run PVS-Studio
# pvs-studio:
#     $(PVS_STUDIO) analyze -o $(EXEC).log -e $(SRCS)
#     plog-converter -a GA:1,2 -t errorfile -o $(EXEC).err $(EXEC).log

# Run Coverity
# coverity:
#     $(COVERITY) make
#     cov-analyze --dir cov-int
#     cov-format-errors --dir cov-int --emacs-style

# Run SonarQube Scanner
sonarqube-scanner:
    $(SONARQUBE_SCANNER)

# Run SonarQube
# sonarqube:
#     ifeq ($(IS_MACOS), 1)
#         brew services start sonarqube
#     else ifeq ($(IS_LINUX), 1)
#         sudo systemctl start sonarqube
#     endif
#     # Ensure that SonarQube has time to start up
#     sleep 30
#     $(SONARQUBE_SCANNER)

# Run Infer
infer:
    $(INFER) run -- make

# Run AddressSanitizer
asan: CFLAGS += $(ASAN_FLAGS)
asan: clean $(EXEC)
    ./$(EXEC)

# Clean up
clean:
    rm -f $(OBJS) $(EXEC)
