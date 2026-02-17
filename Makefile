#Dockerfile vars
#vars
TAG=v3.1.7
UPDATE=
BRANCH=${TAG}${UPDATE}
IMAGENAME=docker-airflow
IMAGEFULLNAME=avhost/${IMAGENAME}
BUILDDATE=$(shell date -u +%Y%m%d)
LASTCOMMIT=$(shell git log -1 --pretty=short | tail -n 1 | tr -d " " | tr -d "UPDATE:")
BRANCHSHORT=$(shell echo ${TAG} | awk -F. '{ print $$1"."$$2 }')

build:
	@echo ">>>> Build docker image latest"
	docker build --progress=plain -t ${IMAGEFULLNAME}:latest .

push:
	@echo ">>>> Publish docker image" ${BRANCH} ${BRANCHSHORT}
	-docker buildx create --use --name buildkitd
	@docker buildx build --sbom=true --provenance=true --platform linux/amd64 --push -t ${IMAGEFULLNAME}:${BRANCH} .
	@docker buildx build --sbom=true --provenance=true --platform linux/amd64 --push -t ${IMAGEFULLNAME}:${BRANCHSHORT} .
	@docker buildx build --sbom=true --provenance=true --platform linux/amd64 --push -t ${IMAGEFULLNAME}:latest .

sboom:
	syft dir:. > sbom.txt
	syft dir:. -o json > sbom.json

seccheck:
	grype --add-cpes-if-none .

imagecheck:
	grype --add-cpes-if-none ${IMAGEFULLNAME}:latest > cve-report.md


check: sboom seccheck
all: check build imagecheck
