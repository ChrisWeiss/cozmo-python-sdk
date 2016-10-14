.PHONY: copy-clad license sdist wheel examples dist

version = $(shell perl -ne '/__version__ = "([^"]+)/ && print $$1;' src/cozmo/version.py)

copy-clad:
	rm -rf src/cozmo/_internal/clad/*
	rm -rf src/cozmo/_internal/msgbuffers/*
	cp -r ../../generated/cladPython/clad src/cozmo/_internal/
	cp -r ../message-buffers/support/python/msgbuffers src/cozmo/_internal/


license_targets = src/cozmo/LICENSE.txt examples/LICENSE.txt

example_filenames = $(shell cd examples && find . -name '*.py' -o -name '*.txt' -o -name '*.png')

license: $(license_targets)

$(license_targets): LICENSE.txt
	for fn in $(license_targets); do \
		cp LICENSE.txt $$fn; \
	done

sdist: license
	python3 setup.py sdist

wheel: license
	python3 setup.py bdist_wheel

dist/cozmo_sdk_examples.zip: license examples/*.py
	rm -f dist/cozmo_sdk_examples.zip dist/cozmo_sdk_examples_$(version).zip
	rm -rf dist/cozmo_sdk_examples_$(version)
	mkdir dist/cozmo_sdk_examples_$(version)
	tar -C examples -c $(example_filenames) | tar -C dist/cozmo_sdk_examples_$(version)  -xv
	cd dist && zip -r cozmo_sdk_examples.zip cozmo_sdk_examples_$(version)
	cd dist && zip -r cozmo_sdk_examples_$(version).zip cozmo_sdk_examples_$(version)

dist/cozmo_sdk_examples.tar.gz: license examples/*.py
	rm -f dist/cozmo_sdk_examples.tar.gz dist/cozmo_sdk_examples_$(version).tar.gz
	rm -rf dist/cozmo_sdk_examples_$(version)
	mkdir dist/cozmo_sdk_examples_$(version)
	tar -C examples -c $(example_filenames) | tar -C dist/cozmo_sdk_examples_$(version)  -xv
	cd dist && tar -cvzf cozmo_sdk_examples.tar.gz cozmo_sdk_examples_$(version)
	cp -a dist/cozmo_sdk_examples.tar.gz dist/cozmo_sdk_examples_$(version).tar.gz

examples: dist/cozmo_sdk_examples.tar.gz dist/cozmo_sdk_examples.zip

dist/vagrant_bundle.tar.gz: sdist examples
	rm -rf dist/vagrant_bundle
	mkdir dist/vagrant_bundle
	cp dist/cozmo_sdk_examples.tar.gz dist/vagrant_bundle/
	cp dist/cozmo-$(version).tar.gz dist/vagrant_bundle/
	cp vagrant/Vagrantfile dist/vagrant_bundle/
	cp vagrant/setup-vm.sh dist/vagrant_bundle/
	cd dist && tar -czvf vagrant_bundle.tar.gz vagrant_bundle
	cp -a dist/vagrant_bundle.tar.gz dist/vagrant_bundle_$(version).tar.gz

dist/vagrant_bundle.zip: dist/vagrant_bundle.tar.gz
	cd dist && zip -r vagrant_bundle.zip vagrant_bundle/
	cp -a dist/vagrant_bundle.zip dist/vagrant_bundle_$(version).zip

vagrant: dist/vagrant_bundle.tar.gz dist/vagrant_bundle.zip

dist: sdist wheel examples vagrant
