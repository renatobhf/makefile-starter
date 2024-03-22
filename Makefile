# Compilation target
TARGET=your_target

# Directories
SRC_DIR := src
OBJ_DIR := obj

# Recursively find all .cpp and .c files in the project
SRCS := $(shell find . \( -name "*.cpp" -o -name "*.c" \) -printf "%P\n")
OBJS := $(shell find . \( -name "*.cpp" -o -name "*.c" \) -exec basename {} \;)
OBJS := $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(patsubst %.c,$(OBJ_DIR)/%.o,$(OBJS)))
DEBUG_OBJS := $(patsubst %.cpp,$(OBJ_DIR)/debug_%.o,$(patsubst %.c,$(OBJ_DIR)/debug_%.o,$(SRCS)))

# Kindly tell make to recursively look into subdirectories for cpp and c files
vpath %.cpp $(shell find $(SRC_DIR) -type d)
vpath %.c $(shell find $(SRC_DIR) -type d)

# C++ specific configs
CXX 			:=$(CXX)# Set C++ compiler
CXXFLAGS 		+=-std=c++20
# You should pay attention to the order of the includes, there can be a tail sort of dependency
# For example, if a depends on b, then b should come first
CXXINCLUDES 	:= 		# Add your include paths here
LIB_PATHS 		:=  	# Add your library paths here
LIBS 			:=		# Add your libraries here (i.e., if you have a library called libexample.a, you should add -lexample)
# If your library is a .so file, you need to set LD_LIBRARY_PATH during runtime

# C specific configs
CC			:= $(CC) # Change here if you want to use any other C compiler different from the system default
CCFLAGS  	+=-std=c11
CCINCLUDES 	:=	# Add your include paths here
LIB_PATHS 	+=  # Add your library paths here
LIBS		+=  # Add your libraries here

# Compilation flags common to C and C++
COMMON_FLAGS  := -Wall -Wextra -pedantic -I$(CXXINCLUDES) -I$(CCINCLUDES)
RELEASE_FLAGS := $(COMMON_FLAGS) -O2 -pipe -flto=auto -march=native
DEBUG_FLAGS   := $(COMMON_FLAGS) -Og -g3 -fsanitize=address,undefined

all: $(TARGET)

$(OBJ_DIR):
	@mkdir -p obj/

# Compile CXX objects
$(OBJ_DIR)/debug_%.o: %.cpp $(OBJ_DIR) Makefile
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS)  -c $< -o $@
$(OBJ_DIR)/%.o: %.cpp $(OBJ_DIR) Makefile
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) -c $< -o $@

# Compile CC objects
$(OBJ_DIR)/debug_%.o: %.c $(OBJ_DIR) Makefile
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) -c $< -o $@
$(OBJ_DIR)/%.o: %.c $(OBJ_DIR) Makefile
	$(CC) $(CFLAGS) $(RELEASE_FLAGS) -c $< -o $@

$(TARGET)-debug: $(DEBUG_OBJS)
	$(CXX)  $(CXXFLAGS) $(DEBUG_FLAGS) -o $@ $^ -L$(LIB_PATHS) $(LIBS)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) -o $@ $^ -L$(LIB_PATHS) $(LIBS)

clean:
	rm -vf $(TARGET) $(TARGET)-debug  \
		$(DEBUG_OBJS) \
		$(OBJS)

# Phony rules that do not generate files
.PHONY: all clean
