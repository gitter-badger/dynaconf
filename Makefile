SHELL := /bin/bash
.PHONY: all citest clean mypy dist docs install pep8 publish run-pre-commit run-tox setup-pre-commit test test_examples test_only test_redis test_vault help coverage-report

help:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: clean install run-pre-commit test test_examples coverage-report

test_examples:
	@echo '###############  Chdir to example directory  ###############'
	cd example/common;pwd;python program.py
	cd example/common-encoding;pwd;python program.py
	cd example/simple_ini_example;pwd;TEFLO_LOG_LEVEL=debug python app.py
	cd example/;pwd;python full_example.py
	cd example/;pwd;python compat.py
	cd example/app;pwd;python app.py
	cd example/apply_default_on_none;pwd;python app.py
	cd example/dunder;pwd;python app.py
	cd example/format;pwd;python app.py
	cd example/app_with_dotenv;pwd;python app.py
	cd example/dotenv_not_loaded_by_default;pwd;python app.py
	cd example/dotenv_loaded_if_enabled;pwd;python app.py
	cd example/merge_enabled;pwd;python app.py
	cd example/new_merge;pwd;python app.py
	cd example/overriding;pwd;python app.py
	cd example/dynaconf_merge;pwd;python app.py
	cd example/multiple_sources;pwd;python app.py
	cd example/multiple_folders;pwd;python app.py
	cd example/toml_example/;pwd;python app.py
	cd example/yaml_example/settings_file/;pwd;python app.py
	cd example/yaml_example/yaml_as_extra_config/;pwd;python app.py
	cd example/flask_with_dotenv;pwd;flask routes | grep -c flask_with_dotenv || exit 1
	cd example/flask_with_toml;pwd;flask routes | grep -c flask_with_toml || exit 1
	cd example/flask_with_yaml;pwd;flask routes | grep -c flask_with_yaml || exit 1
	cd example/flask_with_json;pwd;flask routes | grep -c flask_with_json || exit 1
	cd example/flask_with_commentjson;pwd;flask routes | grep -c flask_with_commentjson || exit 1
	cd example/flask_with_ini;pwd;flask routes | grep -c flask_with_ini || exit 1
	cd example/pytest_example/app;pwd;python app.py
	cd example/pytest_example/app;pwd;pytest tests/
	cd example/pytest_example/flask;pwd;pytest tests
	cd example/python_loader;pwd;python app.py
	cd example/python_loader_with_hooks;pwd;python app.py
	cd example/module_impersonation;pwd;python main.py
	cd example/validators/with_python/;pwd;python app.py
	cd example/validators/with_toml/;pwd;PYTHONPATH=. dynaconf -i config.settings validate
	cd example/toml_with_secrets/;pwd;python program.py
	cd example/envs;pwd;python app.py
	cd example/envless_mode;pwd;python app.py
	cd example/lower_read;pwd;python app.py
	cd example/custom_loader;pwd;python app.py
	cd example/get_fresh;pwd;python app.py
	cd example/includes;pwd;python app.py
	cd example/jenkins_secrets_file;pwd;python app.py
	cd example/specific_settings_files;pwd;python app.py
	cd example/django_example/;pwd;python manage.py test polls -v 2
	cd example/django_pytest/;pwd;pip install pytest-django;DJANGO_SETTINGS_MODULE=project.settings DJANGO_ENVIRONMENT=default pytest;pip uninstall -y pytest-django
	cd example/django_example_compat/;pwd;python manage.py test polls -v 2
	cd example/django_example/;pwd;PYTHONPATH=. DJANGO_SETTINGS_MODULE=foo.settings django-admin test polls -v 2
	cd example/project_root/;pwd;rm -rf /tmp/dynaconf_project_root_test/settings.py;mkdir -p /tmp/dynaconf_project_root_test/;echo "MESSAGE = 'Hello from tmp'" > /tmp/dynaconf_project_root_test/settings.py;python app.py;rm -rf /tmp/dynaconf_project_root_test/
	cd example/settings_file/;pwd;rm -rf /tmp/settings_file_test/settings.py;mkdir -p /tmp/settings_file_test/;echo "MESSAGE = 'Hello from tmp'" > /tmp/settings_file_test/settings.py;python app.py;rm -rf /tmp/settings_file_test/
	cd example/configure/;pwd;rm -rf /tmp/configure_test/settings.py;mkdir -p /tmp/configure_test/;echo "MESSAGE = 'Hello from tmp'" > /tmp/configure_test/settings.py;python app.py;rm -rf /tmp/configure_test/
	cd example/-m_case/;pwd;python -m module

	@echo '###############  Calling from outer folder  ###############'
	python example/common/program.py
	python example/common-encoding/program.py
	python example/full_example.py
	python example/compat.py
	python example/app/app.py
	python example/app_with_dotenv/app.py
	python example/merge_enabled/app.py
	python example/dynaconf_merge/app.py
	python example/multiple_sources/app.py
	python example/multiple_folders/app.py
	python example/toml_example/app.py
	python example/yaml_example/settings_file/app.py
	python example/yaml_example/yaml_as_extra_config/app.py
	python example/validators/with_python/app.py
	python example/toml_with_secrets/program.py
	python example/envs/app.py
	python example/custom_loader/app.py
	python example/get_fresh/app.py
	python example/includes/app.py
	python example/jenkins_secrets_file/app.py
	python example/specific_settings_files/app.py
	python example/django_example/manage.py test polls -v 2
	PYTHONPATH=example/django_example DJANGO_SETTINGS_MODULE=foo.settings python example/django_example/standalone_script.py
	PYTHONPATH=example/issues/449_django_lazy_path DJANGO_SETTINGS_MODULE=foo.settings python example/django_example/standalone_script.py
	PYTHONPATH=example/django_example_compat DJANGO_SETTINGS_MODULE=foo.settings python example/django_example_compat/standalone_script.py
	python example/envvar_prefix/app.py

	@echo '###############  Django Admin From root folder  ###############'
	PYTHONPATH=./example/django_example/ DJANGO_SETTINGS_MODULE=foo.settings django-admin test polls -v 2
	PYTHONPATH=./example/issues/449_django_lazy_path/ DJANGO_SETTINGS_MODULE=foo.settings django-admin test polls -v 2
	PYTHONPATH=./example/django_example_compat/ DJANGO_SETTINGS_MODULE=foo.settings django-admin test polls -v 2

	@echo '############ Issues  ##################'
	cd example/issues/160_path_traversal_fixed;pwd;./test.sh
	cd example/issues/166_renamed_global_env;pwd;python app.py
	cd example/issues/169_renamed_settings_module;pwd;python app.py
	cd example/issues/182_multiple_locations;pwd;python app.py
	cd example/issues/184_ipython;pwd;./test.sh
	cd example/issues/194_flask_config;pwd;python app.py
	cd example/issues/228_nested_toml_bool/python_app;pwd;python app.py
	cd example/issues/228_nested_toml_bool/django_app;pwd;python manage.py test
	cd example/issues/251_dotted_unexistent;pwd;python app.py
	cd example/issues/253_set;pwd;python app.py
	cd example/issues/266_envvar_from_env_override;pwd;python app.py
	cd example/issues/288_null_values;pwd;python app.py
	cd example/issues/306_merge_replace;pwd;python app.py
	cd example/issues/359_variable_reference;pwd;python app.py
	cd example/issues/384_dotted_set;pwd;python app.py
	cd example/issues/392_evaluate_nested_structures;pwd;DYNACONF_INITIAL='@merge [1,2,3]' python app.py
	cd example/issues/404_dup_validator_message;pwd;python app.py
	cd example/issues/434_setenv;pwd;python app.py --config development dynaconf
	cd example/issues/430_same_name;pwd;python app.py
	cd example/issues/443_object_merge;pwd;python app.py
	cd example/issues/445_casting;pwd;python app.py
	cd example/issues/467_load_from_parent_folder/src;pwd;python app.py
	cd example/issues/478_mispell_environments;pwd;python app.py
	cd example/issues/482_layered_format;pwd;python app.py
	cd example/issues/486_title_case_validation;pwd;python app.py
	cd example/issues/494_using_pathlib;pwd;python app.py
	cd example/issues/519_underscore_in_name;pwd;ATC_BLE__device_id=42 EXPECTED_VALUE=42 python app.py
	cd example/issues/519_underscore_in_name;pwd;ATC_BLE__DEVICE_ID=42 EXPECTED_VALUE=42 python app.py
	cd example/issues/685_disable_dotted_lookup;pwd;python app.py
	cd example/issues/709_yaml_merge_with_env;pwd;python app.py
	cd example/issues/718_dynaconf_dotted_lookup;pwd;python app.py
	cd example/issues/720_load_dotenv;pwd;python src/app/app.py
	cd example/issues/722_docs_example;pwd;python app.py
	cd example/issues/729_use_default_when_setting_is_blank;pwd;python app.py
	cd example/issues/741_envvars_ignored;pwd;sh recreate.sh

test_vault:
	# @cd example/vault;pwd;python write.py
	docker run --rm --name dynaconf_with_vault -d -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' -p 8200:8200 vault || true
	@sleep 5
	@cd example/vault;pwd;dynaconf -i dynaconf.settings write vault -s SECRET=vault_works_in_default -s FOO=foo_is_default
	@cd example/vault;pwd;dynaconf -i dynaconf.settings write vault -e dev -s SECRET=vault_works_in_dev
	@cd example/vault;pwd;dynaconf -i dynaconf.settings write vault -e prod -s SECRET=vault_works_in_prod
	@sleep 2
	@cd example/vault;pwd;python vault_example.py
	docker stop dynaconf_with_vault  || true

test_redis:
	# @cd example/redis_example;pwd;python write.py
	docker run --rm --name dynaconf_with_redis -d -p 6379:6379 redis:alpine || true
	@sleep 2
	@cd example/redis_example;pwd;dynaconf -i dynaconf.settings write redis -s FOO=foo_is_default
	@cd example/redis_example;pwd;dynaconf -i dynaconf.settings write redis -s SECRET=redis_works_in_default
	@cd example/redis_example;pwd;dynaconf -i dynaconf.settings write redis -e development -s SECRET=redis_works_in_development
	@cd example/redis_example;pwd;dynaconf -i dynaconf.settings write redis -e production -s SECRET=redis_works_in_production
	@sleep 2
	@cd example/redis_example;pwd;python redis_example.py
	docker stop dynaconf_with_redis || true

watch:
	ls **/**.py | entr py.test -m "not integration" -s -vvv -l --tb=long --maxfail=1 tests/

watch_django:
	ls {**/**.py,~/.virtualenvs/dynaconf/**/**.py,.venv/**/**.py} | PYTHON_PATH=. DJANGO_SETTINGS_MODULE=foo.settings entr example/django_example/manage.py test polls -v 2

watch_coverage:
	ls {**/**.py,~/.virtualenvs/dynaconf/**/**.py} | entr -s "make test;coverage html"

test_only:
	py.test -m "not integration" -v --cov-config .coveragerc --cov=dynaconf -l --tb=short --maxfail=1 tests/
	coverage xml

test_integration:
	py.test -m integration -v --cov-config .coveragerc --cov=dynaconf --cov-append -l --tb=short --maxfail=1 tests/
	coverage xml

coverage-report:
	coverage report --fail-under=100

mypy:
	mypy dynaconf/ --exclude '^dynaconf/vendor*'

test: pep8 mypy test_only

citest:
	py.test -v --cov-config .coveragerc --cov=dynaconf -l tests/ --junitxml=junit/test-results.xml

ciinstall:
	python -m pip install --upgrade pip
	python -m pip install -r requirements_dev.txt

test_all: test_examples test_integration test_redis test_vault test
	@coverage html

install:
	pip install --upgrade pip
	pip install -r requirements_dev.txt

run-pre-commit:
	rm -rf .tox/
	rm -rf build/
	pre-commit run --all-files

pep8:
	# Flake8 ignores
	#   F841 (local variable assigned but never used, useful for debugging on exception)
	#   W504 (line break after binary operator, I prefer to put `and|or` at the end)
	#   F403 (star import `from foo import *` often used in __init__ files)
	# flake8 dynaconf --ignore=F403,W504,W503,F841,E401,F401,E402 --exclude=dynaconf/vendor
	flake8 dynaconf --exclude=dynaconf/vendor*

dist: clean
	@python setup.py sdist bdist_wheel

publish:
	make run-tox
	@twine upload dist/*

clean:
	@find ./ -name '*.pyc' -exec rm -f {} \;
	@find ./ -name '__pycache__' -prune -exec rm -rf {} \;
	@find ./ -name 'Thumbs.db' -exec rm -f {} \;
	@find ./ -name '*~' -exec rm -f {} \;
	rm -rf .cache
	rm -rf build
	rm -rf dist
	rm -rf *.egg-info
	rm -rf htmlcov
	rm -rf .tox/
	rm -rf site

docs:
	rm -rf site
	mkdocs build --clean

run-tox:
	tox --recreate
	rm -rf .tox
