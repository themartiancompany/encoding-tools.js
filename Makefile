# SPDX-License-Identifier: GPL-3.0-or-later

#    ----------------------------------------------------------------------
#    Copyright © 2024, 2025, 2026  Pellegrino Prevete
#
#    All rights reserved
#    ----------------------------------------------------------------------
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

_NPM ?= false
SHELL ?= bash
PREFIX ?= /usr/local
_PROJECT_NPM=encoding-tools
_PROJECT=$(_PROJECT_NPM)
_NAMESPACE=themartiancompany
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/$(_PROJECT)
USR_DIR=$(DESTDIR)$(PREFIX)
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
LIB_DIR=$(DESTDIR)$(PREFIX)/lib/$(_PROJECT)
MAN_DIR?=$(DESTDIR)$(PREFIX)/share/man
NODE_DIR=$(DESTDIR)$(PREFIX)/lib/node_modules/$(_PROJECT)
BUILD_NPM_DIR=build

_INSTALL_FILE=\
  install \
    -vDm644
_INSTALL_EXE=\
  install \
    -vDm755
_INSTALL_DIR=\
  install \
    -vdm755

DOC_FILES=\
  $(wildcard \
      *.rst) \
  $(wildcard \
      *.md)
NPM_FILES=\
  "README.md" \
  "COPYING" \
  "AUTHORS.rst" \
  "dist" \
  "encoding-tools" \
  "eslint.config.mjs" \
  "fs-worker.webpack.config.cjs" \
  "libbin2txt" \
  "libtxt2bin" \
  "libbin2txt.webpack.config.cjs" \
  "libtxt2bin.webpack.config.cjs" \
  "package.json" \
  "bin2txt" \
  "txt2bin" \
  "bin2txt.webpack.config.cjs" \
  "txt2bin.webpack.config.cjs" \
  "webpack.config.cjs"

all: build-man build-npm

check: eslint

eslint:

	npm \
	  install \
	  --save-dev; \
	npx \
	  eslint \
	    "."

install: install-scripts install-doc install-examples install-man

install-scripts:

	if [[ "$(_NPM)" == "false" ]]; then \
	  $(_MAKE_EXE) \
	    "$(LIB_DIR)/nodejs/$(_PROJECT)"; \
	  if [[ ! -s "$(BIN_DIR)/$(_PROJECT)" && \
	        ! -e "$(BIN_DIR)/$(_PROJECT)"  ]]; then \
	    $(_MAKE_LINK) \
	      "$(PREFIX)/lib/$(_PROJECT)/nodejs/$(_PROJECT)" \
	      "$(BIN_DIR)/$(_PROJECT)"; \
	  fi; \
	  $(_MAKE_LINK) \
	    "$(PREFIX)/lib/$(_PROJECT)/nodejs/$(_PROJECT)" \
	    "$(BIN_DIR)/$(_PROJECT).js" || \
	    true; \
	  $(_INSTALL_DIR) \
	    "$(LIB_DIR)/nodejs"; \
	  rm \
	    -rf \
	    "$(LIB_DIR)/node_modules" || \
	    true; \
	  if [[ ! -s "$(LIB_DIR)/node_modules" ]]; then \
	    $(_MAKE_LINK) \
	      "$(PREFIX)/lib/node_modules" \
	      "$(LIB_DIR)/nodejs/node_modules"; \
	  fi; \
	  rm \
	    -rf \
	    "$(DESTDIR)$(PREFIX)/lib/node_modules/$(_PROJECT)" \
	    "$(DESTDIR)$(PREFIX)/lib/node_modules/$(_PROJECT_NPM)"; \
	  if [[ ! -s "$(DESTDIR)$(PREFIX)/lib/node_modules/$(_PROJECT).js" ]]; then \
	    $(_MAKE_LINK) \
	      "$(PREFIX)/lib/$(_PROJECT)/nodejs" \
	      "$(DESTDIR)$(PREFIX)/lib/node_modules/$(_PROJECT).js"; \
	  fi; \
	  if [[ ! -s "$(DESTDIR)$(PREFIX)/lib/node_modules/$(_PROJECT)" ]]; then \
	    $(_MAKE_LINK) \
	      "$(PREFIX)/lib/$(_PROJECT)/nodejs" \
	      "$(DESTDIR)$(PREFIX)/lib/node_modules/$(_PROJECT)" || \
	      true; \
	  fi; \
	  cp \
	    -r \
	    $$(printf \
	         "$${PWD}/%s " \
	         $$(cat \
	              "$${PWD}/package.json" | \
	              jq \
	                --raw-output \
	                '.files[]')) \
	    "$(LIB_DIR)/nodejs"; \
	elif [[ "$(_NPM)" == "true" ]]; then \
	  make \
	    install-npm; \
	  $(_MAKE_LINK) \
	    "$(PREFIX)/lib/node_modules/$(_PROJECT_NPM)" \
	    "$(LIB_DIR)/nodejs" || \
	  true; \
	fi

build-man:

	git \
	  submodule \
	    update \
	    --init \
	      "man"
	mkdir \
	  -p \
	  "build/man"
	cp \
	  "man/variables.rst" \
	  "build/man"
	cat \
	  "man/bin2txt.1.rst" | \
	  sed \
	    "s/bin2txt/bin2txt.js/g; \
	     s/bin2txt/bin2txt.js/g" > \
	    "build/man/bin2txt.js.1.rst"
	cat \
	  "man/txt2bin.1.rst" | \
	  sed \
	    "s/bin2txt/bin2txt.js/g; \
	     s/bin2txt/bin2txt.js/g" > \
	    "build/man/txt2bin.js.1.rst"
	rst2man \
	  "build/man/bin2txt.js.1.rst" \
	  "build/man/bin2txt.js.1"
	rm \
	  "build/man/bin2txt.js.1.rst"
	rst2man \
	  "build/man/txt2bin.js.1.rst" \
	  "build/man/txt2bin.js.1"
	rm \
	  "build/man/txt2bin.js.1.rst"
	rm \
	  "build/man/variables.rst"

build-npm:

	make \
	  build-man
	for _file in $(NPM_FILES); do \
	  if [[ -d "$${_file}" ]]; then \
	    mkdir \
	      -p \
	      "build/$${_file}"; \
	    cp \
	     -r \
	     "$${_file}/"* \
	     "build/$${_file}"; \
	  elif [[ -e "$${_file}" ]]; then \
	    cp \
	      -r \
	      "$${_file}" \
	      "build/$${_file}"; \
	  fi; \
	done
	cd \
	  "build"; \
	_version="$$( \
	  npm \
	    view \
	      "$${PWD}" \
	      "version")"; \
	npm \
	  install \
	  --save-dev; \
	npm \
	  install; \
	npm \
	  run \
	    "build"; \
	npm \
	  pack; \
	mv \
	  "$(_PROJECT_NPM)-$${_version}.tgz" \
	  ".."

install-npm:

	_npm_opts=( \
	  -g \
	  --prefix \
	    '$(USR_DIR)' \
	); \
	_version="$$( \
	  npm \
	    view \
	      "$${PWD}" \
	      "version")"; \
	npm \
	  install \
	    "$${_npm_opts[@]}" \
	    "$(_PROJECT_NPM)-$${_version}.tgz"; \
	$(_INSTALL_DIR) \
	  "$(DESTDIR)$(PREFIX)/lib"; \
	ln \
	  -s \
          "$(PREFIX)/lib/node_modules/$(_PROJECT_NPM)" \
	  "$(LIB_DIR)" || \
	true

publish-npm:

	cd \
	  "build"; \
	npm \
	  publish \
	  --access \
	    "public"

install-doc:

	$(_INSTALL_FILE) \
	  $(DOC_FILES) \
	  -t \
	  $(DOC_DIR)

install-man:

	$(_INSTALL_DIR) \
	  "$(MAN_DIR)/man1"
	$(_INSTALL_FILE) \
	  "build/man/bin2txt.js.1" \
	  "$(MAN_DIR)/man1/bin2txt.js.1"
	$(_INSTALL_FILE) \
	  "build/man/txt2bin.js.1" \
	  "$(MAN_DIR)/man1/txt2bin.js.1"

uninstall-scripts:
	rm \
	  -rf \
	  "$(NODE_DIR)"

.PHONY: check build-man build-npm install install-doc install-man install-npm install-scripts shellcheck
