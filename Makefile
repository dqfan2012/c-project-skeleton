# Phony targets
.PHONY: all cppcheck valgrind leaks clang-analyze clang-tidy flawfinder pvs-studio coverity sonarqube infer asan clean

# Windows has $OS env var set by default
OS := $(OS)
ifeq ($(OS),)
    OS := $(shell uname)
endif

CC = gcc
COMMON_CFLAGS = -std=c17 -Wall -Werror -Wextra -Wno-sign-compare \
                -Wno-unused-parameter -Wno-unused-variable -Wshadow

# You may use the following CFLAGS, if you want to be stricter
#COMMON_CFLAGS = -std=c17 -Wall -Werror -Wextra -pedantic -Wno-sign-compare \
                -Wno-unused-parameter -Wno-unused-variable -Wshadow \
                -Wconversion -Wformat=2 -Wmissing-include-dirs -Wswitch-enum \
                -Wfloat-equal -Wredundant-decls -Wlogical-op -Wnull-dereference \
                -Wold-style-definition

DEBUG_CFLAGS = -ferror-limit=1 -gdwarf-4 -g3 -O0 $(COMMON_CFLAGS) -Wno-gnu-folding-constant
PROD_CFLAGS = -O2 $(COMMON_CFLAGS)
LDLIBS = 
LDFLAGS =

# For Windows use MSYS2, cygwin, or WSL 2
ifeq ($(OS), Windows_NT)
    COMMON_CFLAGS += -D_WIN32
    LDLIBS += -lws2_32
    # Add Windows-specific flags or libraries if needed
else ifeq ($(OS), Linux)
    IS_LINUX = 1
    # Add Linux-specific flags or libraries if needed
    # Example: LDLIBS += -lsomeLinuxSpecificLib
    # Uncomment the following line if you prefer clang to gcc
    # If using clang, be sure to use llvm and lldb
    # CC = clang
else ifeq ($(OS), Darwin)
    IS_MACOS = 1
    CC = clang
    DEBUG_CFLAGS += -Wno-gnu-folding-constant
    PROD_CFLAGS +=
    LDFLAGS =
    # Example: LDLIBS += -lsomeMacSpecificLib
endif

# Static analysis tools
CPPCHECK = cppcheck
VALGRIND = valgrind
LEAKS = leaks
CLANG_ANALYZER = clang --analyze
CLANG_TIDY = clang-tidy
FLAWFINDER = flawfinder
# PVS_STUDIO = pvs-studio-analyzer
# COVERITY = cov-build --dir cov-int
SONARQUBE_SCANNER = sonar-scanner
INFER = infer
ASAN_FLAGS = -fsanitize=address -fno-omit-frame-pointer

# Default target
all: $(EXEC)

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
valgrind: $(EXEC)
    $(VALGRIND) --leak-check=full --show-leak-kinds=all --track-origins=yes ./$(EXEC)

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
