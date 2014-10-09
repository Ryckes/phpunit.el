# Copyright (C) 2014 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


EMACS = emacs
EMACSFLAGS =
CASK = cask
VAGRANT = vagrant

OBJECTS = phpunit.elc

VERSION=$(shell \
        grep Version phpunit.el \
        |awk -F':' '{print $$2}' \
	|sed -e "s/[^0-9.]//g")

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

all: help

help:
	@echo -e "$(OK_COLOR) ==== phpunit.el [$(VERSION)]====$(NO_COLOR)"
	@echo -e "$(WARN_COLOR)- build$(NO_COLOR)    : make phpunit.el"
	@echo -e "$(WARN_COLOR)- test$(NO_COLOR)     : launch unit tests"
	@echo -e "$(WARN_COLOR)- clean$(NO_COLOR)    : cleanup"

elpa:
	@echo -e "$(OK_COLOR)[phpunit.el] Build$(NO_COLOR)"
	@$(CASK) install
	@$(CASK) update
	@touch $@

.PHONY: build
build : elpa $(OBJECTS)

.PHONY: test
test : build
	@echo -e "$(OK_COLOR)[phpunit.el] Unit tests$(NO_COLOR)"
	@${CASK} exec ert-runner # --no-win

.PHONY: ci
ci : build
	@${CASK} exec ert-runner --no-win < /dev/tty

.PHONY: virtual-test
virtual-test :
	@$(VAGRANT) up
	@$(VAGRANT) ssh -c "make -C /vagrant EMACS=$(EMACS) clean test"

.PHONY: clean
clean :
	@echo -e "$(OK_COLOR)[phpunit.el] Cleanup$(NO_COLOR)"
	@rm -fr $(OBJECTS) elpa *.pyc

reset : clean
	@rm -rf .cask # Clean packages installed for development

%.elc : %.el
	@$(CASK) exec $(EMACS) --no-site-file --no-site-lisp --batch \
		$(EMACSFLAGS) \
		-f batch-byte-compile $<
