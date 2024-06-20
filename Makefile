# Phony targets
.PHONY: all check asan clang-analyze clang-tidy complexity cppcheck coverage dependency-check format flawfinder frama-c fuzz infer leaks lsan llvm-coverage sonar-scanner splint tsan ubsan valgrind clean clean-test

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

# Add C++14 standard to the compilation flags
CXXFLAGS = -std=c++20

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
                -Wswitch-default -Wswitch-enum

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
ASAN_FLAGS = -fsanitize=address -fno-omit-frame-pointer
CLANG_ANALYZER = clang --analyze
CLANG_FORMAT = clang-format
CLANG_TIDY = clang-tidy
COCCI = coccinelle
COVERAGE_FLAGS = -fprofile-arcs -ftest-coverage
CPPCHECK = cppcheck
DEPENDENCY_CHECK = dependency-check
FLAWFINDER = flawfinder
FRAMA_C = frama-c
FUZZER_FLAGS = -fsanitize=fuzzer
GCOV = gcov
GTEST_DIR = /opt/homebrew/Cellar/googletest/1.14.0
GTEST_INCLUDE = -I$(GTEST_DIR)/include
GTEST_LIBS = -L$(GTEST_DIR)/lib -lgtest -lgtest_main -pthread
INFER = infer
LEAKS = leaks
LIZARD = lizard
LLVM_COV = llvm-cov
LLVM_PROFDATA = llvm-profdata
LSAN_FLAGS = -fsanitize=leak
PVS_ERR = $(SRC_DIR)/$(EXEC_NAME).err
PVS_LOG = $(SRC_DIR)/$(EXEC_NAME).log
PVS_STUDIO_ANALYZE = pvs-studio-analyzer
PVS_STUDIO_CONVERT = plog-converter
SONARQUBE_SCANNER = sonar-scanner
SPLINT = splint
TSAN_FLAGS = -fsanitize=thread
UBSAN_FLAGS = -fsanitize=undefined
VALGRIND_CACHEGRIND = valgrind --tool=cachegrind
VALGRIND_CALLGRIND = valgrind --tool=callgrind
VALGRIND_DRD = valgrind --tool=drd
VALGRIND_HELGRIND = valgrind --tool=helgrind
VALGRIND_MASSIF = valgrind --tool=massif
VALGRIND_MEMCHECK = valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes
VALGRIND_SGCHECK = valgrind --tool=exp-sgcheck

# Code Tests
CHECK_LIBS = -lcheck
TEST_DIR = tests
EX_NAME = example-test
TEST_EXEC = $(TEST_DIR)/$(EX_NAME)/test_$(EX_NAME)
TEST_SRCS = $(wildcard $(TEST_DIR)/$(EX_NAME)/*.cpp)
TEST_OBJS = $(TEST_SRCS:.cpp=.o)

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

# Main executable target
$(EXEC): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(EXEC) $(LDFLAGS) $(LDLIBS)

# Compile target for unit tests with Google Test
$(TEST_EXEC): $(TEST_OBJS) $(OBJS)
	$(CXX) $(CXXFLAGS) $(GTEST_INCLUDE) -o $@ $(TEST_OBJS) $(OBJS) $(GTEST_LIBS) $(LDLIBS)

# Object file compilation
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Object file compilation for C++ test files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(GTEST_INCLUDE) -c $< -o $@

# Run unit tests
run-tests: $(TEST_EXEC)
	$(TEST_EXEC)

# Comprehensive analysis target
check: cppcheck clang-analyze clang-tidy flawfinder splint frama-c infer pvs-studio

# Run AddressSanitizer
asan: CFLAGS += $(ASAN_FLAGS)
asan: clean $(EXEC)
	$(EXEC)

# Run Clang Static Analyzer
clang-analyze:
	$(CLANG_ANALYZER) $(SRCS)

# Run Clang-Tidy
clang-tidy:
	$(CLANG_TIDY) $(SRCS) -- -std=c17

# Run coccinelle
coccinelle:
	$(COCCI) --dir $(SRC_DIR) --recursive --all-includes --use-git grep

# Check cyclomatic complexity with lizard
complexity:
	$(LIZARD) $(SRC_DIR)

# Code coverage with gcov
coverage: CFLAGS += $(COVERAGE_FLAGS)
coverage: clean $(EXEC)
	$(EXEC)
	$(GCOV) $(SRCS)

# Run cppcheck
cppcheck:
	$(CPPCHECK) --enable=all --inconclusive --std=c17 --suppress=missingIncludeSystem --quiet $(SRCS)

# Check dependencies for vulnerabilities
dependency-check:
	$(DEPENDENCY_CHECK) --project myproject --scan . --out report

# Run Flawfinder
flawfinder:
	$(FLAWFINDER) $(SRCS)

# Format code with clang-format
format:
	$(CLANG_FORMAT) -i $(SRCS)

# Run frama-c
frama-c:
	$(FRAMA_C) -wp -wp-rte $(SRCS)

fuzz: CFLAGS += $(FUZZER_FLAGS)
fuzz: clean $(EXEC)
	$(EXEC)

# Run Infer
infer:
	$(INFER) run -- make

# Run leaks on macOS
leaks: $(EXEC)
	$(LEAKS) --atExit -- $(EXEC)

# Code coverage with llvm-cov
llvm-coverage: CFLAGS += $(COVERAGE_FLAGS)
llvm-coverage: clean $(EXEC)
	LLVM_PROFILE_FILE="$(EXEC).profraw" $(EXEC)
	$(LLVM_PROFDATA) merge -sparse $(EXEC).profraw -o $(EXEC).profdata
	$(LLVM_COV) show $(EXEC) -instr-profile=$(EXEC).profdata

# Compile target with LeakSanitizer
lsan: CFLAGS += $(LSAN_FLAGS)
lsan: clean debug
	$(EXEC)

# Run PVS-Studio
pvs-studio:
	bear --output $(SRC_DIR)/compile_commands.json -- make rebuild SRC_DIR=$(SRC_DIR) EXEC_NAME=$(EXEC_NAME)
	@[ -f "$(SRC_DIR)/compile_commands.json" ] && \
		$(PVS_STUDIO_ANALYZE) analyze -o $(PVS_LOG) --file "$(SRC_DIR)/compile_commands.json" || \
		(echo "Error: Couldn't find compile_commands.json" && exit 1)
	$(PVS_STUDIO_CONVERT) -t json -t csv -a 'GA:1,2;OWASP:1;MISRA:1,2;AUTOSAR:1' -o $(SRC_DIR)/Logs \
		-r $(SRC_DIR) -m cwe -m owasp -m misra -m autosar -n PVS-Log $(PVS_LOG) || \
		(echo "Error during log conversion. Check $(SRC_DIR)/Logs for details." && exit 1)

# Run splint
splint:
	$(SPLINT) $(SRCS)

# Run SonarQube Scanner
# Be sure sonarqube is running before running the scanner.
sonar-scanner:
	$(SONARQUBE_SCANNER) \
		-Dsonar.projectKey=$(SONARQUBE_PROJECT_KEY) \
		-Dsonar.host.url=$(SONARQUBE_HOST_URL) \
		-Dsonar.login=$(SONARQUBE_TOKEN)

# Compile target with ThreadSanitizer
tsan: CFLAGS += $(TSAN_FLAGS)
tsan: clean debug
	$(EXEC)

# Compile target with
ubsan: CFLAGS += $(UBSAN_FLAGS)
ubsan: clean debug
	$(EXEC)

# Run valgrind
valgrind-cachegrind: $(EXEC)
	$(VALGRIND_CACHEGRIND) $(EXEC)

valgrind-callgrind: $(EXEC)
	$(VALGRIND_CALLGRIND) $(EXEC)

valgrind-drd: $(EXEC)
	$(VALGRIND_DRD) $(EXEC)

valgrind-helgrind: $(EXEC)
	$(VALGRIND_HELGRIND) $(EXEC)

valgrind-massif: $(EXEC)
	$(VALGRIND_MASSIF) $(EXEC)

valgrind-memcheck: $(EXEC)
	$(VALGRIND_MEMCHECK) $(EXEC)

valgrind-sgcheck: $(EXEC)
	$(VALGRIND_SGCHECK) $(EXEC)

# Clean up
clean:
	@[ -d "$(SRC_DIR)/infer-out" ] && rm -rf "$(SRC_DIR)/infer-out" || true
	@[ -d "$(SRC_DIR)/.scannerwork" ] && rm -rf "$(SRC_DIR)/.scannerwork" || true
	@[ -d "$(SRC_DIR)/Logs" ] && rm -rf "$(SRC_DIR)/Logs" || true
	rm -f $(OBJS) $(EXEC) $(SRC_DIR)/*.plist $(SRC_DIR)/compile_commands.json $(SRC_DIR)/*.log

clean-test:
	rm -f $(TEST_OBJS) $(TEST_EXEC) $(OBJS)
