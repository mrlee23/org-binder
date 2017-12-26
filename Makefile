.PHONY = install clean test run
CC = gcc


SRC_DIR = ./src
BUILD_DIR = ./build
BIN_DIR = ./bin
NAME = $(addprefix $(BIN_DIR)/, org-binder)
FILES = simple-org-parser
SRCS = $(addprefix $(SRC_DIR)/, $(addsuffix .c, $(FILES)))
DEPS = $(addprefix $(SRC_DIR)/, $(addsuffix .h, $(FILES)))
OBJS = $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(FILES)))

install: $(BUILD_DIR) $(NAME)

$(BUILD_DIR):
	mkdir -p $@

$(NAME): $(OBJS)
	$(CC) -o $(NAME) $^

$(BUILD_DIR)/%.o:$(SRC_DIR)/%.c
	$(CC) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(NAME)

test:
	make install
	# --------------------
	$(NAME)

run:
	$(NAME)
