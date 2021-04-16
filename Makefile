.PHONY: list test spec deps run
list:
	@echo available tasks
	@cat Makefile | grep -v PHONY | grep -v list | grep -Eo '^[^:]+: ?' | sed 's/:.*$$//' | sed 's/^/  - /'

test:
	bundle exec rspec

spec: test

deps:
	bundle install

run:
	bundle exec rackup

console:
	./bin/console
