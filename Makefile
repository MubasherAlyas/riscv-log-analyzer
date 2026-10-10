
SHELL := /bin/bash

ANALYZER := ./scripts/analyze.sh
REPORTER := ./scripts/generate_report.sh
LOGS := $(wildcard test_data/*.log)

.PHONY: all test report clean help setup

all:
	@for log in $(LOGS); do \
		echo "Analyzing $$log"; \
		status=0; $(ANALYZER) "$$log" || status=$$?; \
		if [ $$status -gt 1 ]; then exit $$status; fi; \
	done

test:
	@echo "Running analyzer tests..."
	@bash -n scripts/*.sh
	@$(ANALYZER) test_data/sample_pass.log > /dev/null
	@status=0; $(ANALYZER) test_data/sample_fail.log > /dev/null || status=$$?; \
	[ $$status -eq 1 ] || exit 1
	@$(ANALYZER) test_data/sample_pass.log --format csv | grep -q '^PASSED,5,'
	@$(ANALYZER) --help | grep -q 'Usage:'
	@echo "All checks passed!"

report:
	@$(REPORTER)

clean:
	@find output -type f ! -name '.gitkeep' -delete
	@echo "Generated reports removed."

help:
	@echo "Available Makefile targets:"
	@echo "  all     - Analyze all simulation logs"
	@echo "  test    - Run analyzer tests"
	@echo "  report  - Generate simulation reports"
	@echo "  clean   - Remove generated reports"
	@echo "  help    - Show available targets"
	@echo "  setup   - Check required tools"

setup:
	@./scripts/setup_env.sh