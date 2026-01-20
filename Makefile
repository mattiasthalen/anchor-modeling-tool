PYTHON ?= python
UV ?= uv
UV_LINK_MODE ?= copy

export UV_LINK_MODE

.PHONY: install bootstrap build lock test test-coverage ruff ruff-fix mypy full-test extract extract-source sources precommit-install precommit-run precommit-uninstall

install:
	$(PYTHON) -m pip install uv

bootstrap:
	$(UV) sync --dev
	$(UV) run pre-commit install

build:
	$(UV) build

lock:
	$(UV) lock

# Testing tasks
test:
	$(UV) run pytest

test-coverage:
	$(UV) run pytest --cov=src --cov-report=term-missing

ruff:
	$(UV) run ruff check

ruff-fix:
	$(UV) run ruff check --fix

mypy:
	$(UV) run mypy src

full-test: ruff mypy test

precommit-run:
	$(UV) run pre-commit run --all-files