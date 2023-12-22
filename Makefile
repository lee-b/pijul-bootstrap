ARCH=$(shell uname -m)
VERSION=1.0.0-alpha

TAG=${ARCH}-${VERSION}

all: dist/pijul-${TAG} dist/pijul-serve-${TAG}.tar.gz

dist/pijul dist/pijul-${TAG} dist/pijul-${TAG}.tar : .image build/pijul-${TAG}
	rm -rf dist
	mkdir dist
	cp build/pijul-${TAG} dist/pijul-${TAG}
	rm -rf build
	docker save -o dist/pijul-serve-${TAG}.tar pijul-serve:${TAG}
	gzip dist/pijul-serve-${TAG}.tar

build/pijul-${TAG}: .image
	rm -rf build && mkdir -p build
	docker run -v "$(PWD)/build:/build:rw" --entrypoint /bin/cp pijul-serve:${TAG} /usr/local/bin/pijul /build/pijul-${TAG}

.image: Dockerfile
	docker build -t pijul-serve:${TAG} .
	docker tag pijul-serve:${TAG} pijul-serve:latest
	touch .image

run: .image
	docker run -ti pijul-serve:${TAG} pijul

clean:
	rm -rf dist build .image

.PHONY: dist

