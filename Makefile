.PHONY: list test spec deps run console
list:
	@echo available tasks
	@cat Makefile | grep -v PHONY | grep -v list | grep -Eo '^[^:]+: ?' | sed 's/:.*$$//' | sed 's/^/  - /'

test:
	bundle exec rspec

spec: test

deps:
	bundle install
	yarn install

run:
	bundle exec thin start -R config.ru -C config/thin.yml -p 9292

console:
	./bin/console
