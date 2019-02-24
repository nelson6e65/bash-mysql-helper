NAME          = mysql-helper
VERSION       = $(shell git describe)
HORA          = $(shell date --iso=second)
hora          = $(shell date +'%F %T')
F_ARGS_PARSER = src/args-parser.sh

BASHER        = bashers


# User-friendly check for sphinx-build
ifeq ($(shell which basher >/dev/null 2>&1; echo $$?), 1)
$(error The 'basher' command was not found. Make sure you have Basher installed (https://github.com/basherpm/basher))
endif

$(info ${NAME} (${hora}))


build:
	@echo
	@echo '[ BUILD ] ============================================================='
	@echo '[ Update version file ] -----------------------------------------------'
	@echo "Version: ${VERSION}"
	@echo "# ARG_OPTIONAL_ACTION([version], , [Display the version you are using.], [echo '${NAME} ${VERSION}'])" > version.m4
	@echo "Done!"
	@echo
	@echo '[ Generate arguments parser ]-----------------------------------------'
	argbash .argbash.m4 -o "${F_ARGS_PARSER}"
	@echo "Done!"

dependencies:
	@echo
	@echo '[ DEPENDENCIES ] ======================================================'
	@echo '[ Install Argbash ] ---------------------------------------------------'
	basher install matejak/argbash


.PHONY: build dependencies
