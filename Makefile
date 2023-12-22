ARCH=$(shell uname -m)
VERSION=1.0.0-alpha

TAG=${ARCH}-${VERSION}

all: dist/pijul-${TAG} dist/pijul-bootstrap-${TAG}.tar.gz

dist/pijul dist/pijul-${TAG} dist/pijul-${TAG}.tar : .image build/pijul-${TAG}
	rm -rf dist
	mkdir dist
	cp build/pijul-${TAG} dist/pijul-${TAG}
	rm -rf build
	docker save -o dist/pijul-bootstrap-${TAG}.tar pijul-bootstrap:${TAG}
	gzip dist/pijul-bootstrap-${TAG}.tar

build/pijul-${TAG}: .image
	rm -rf build && mkdir -p build
	docker run -v "$(PWD)/build:/build:rw" --entrypoint /bin/cp pijul-bootstrap:${TAG} /usr/local/bin/pijul /build/pijul-${TAG}

.image: Dockerfile
	docker build -t pijul-bootstrap:${TAG} .
	docker tag pijul-bootstrap:${TAG} pijul-bootstrap:latest
	touch .image

run: .image
	docker run -ti pijul-bootstrap:${TAG} pijul

clean:
	rm -rf dist build .image

# developers only
publish: .image ./publish.sh
	./publish.sh "${TAG}"

.PHONY: dist

