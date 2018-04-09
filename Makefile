## =========
## erlang.mk
## =========

PROJECT		= switchboard
PROFILE		?= dev

SITE_DIR	= site
SITE_DOCS_DIR	= $(SITE_DIR)/doc

ERLC_COMPILE_OPTS = -I include +'{parse_transform, lager_transform}' \
            +debug_info +warn_export_all +warn_shadow_vars +warn_obsolete_guard

ERLC_OPTS += $(ERLC_COMPILE_OPTS)
TEST_ERLC_OPTS += $(ERLC_COMPILE_OPTS)
TEST_ERL_OPTS = -s switchboard

EDOC_OPTS = {dir, "$(SITE_DOCS_DIR)"}, no_packages, {subpackages, false}, {preprocess, true}

ifeq ($(PROFILE), dev)
	RELX_OPTS = --dev-mode
endif

DEPS	= lager gproc cowboy jsx poolboy

include erlang.mk


## ====================
## Switchboard specific
## ====================

.PHONY += markdown-docs site-docs


## ==========
## Site Guide
## ==========

update-docs: DOCS_BRANCH = gh-pages
update-docs: docs
	git subtree push --prefix $(SITE_DIR) origin $(DOCS_BRANCH)


## ==============================
## Release tarballing + uploading
## ==============================

S3CMD_CONF	= .s3cmd
S3CMD		= s3cmd -c $(S3CMD_CONF)

$(PROJECT).tar.gz: _rel
	tar -s/_rel// -cvf $@ $<

$(S3CMD_CONF):
	$(S3CMD) --configure

push: switchboard.tar.gz $(S3CMD_CONF)
	$(S3CMD) push
