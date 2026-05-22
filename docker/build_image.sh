#!/usr/bin/env bash

set -e

SCRIPT_PATH="$(
	cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
	pwd
)"
declare -r SCRIPT_PATH

arch="$(uname -m)"
if [[ "${arch}" == 'arm64' ]]; then
	arch='aarch64'
fi

if [[ "${arch}" == 'x86_64' ]]; then
	# shellcheck disable=2034
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/17.0.19.10.1/amazon-corretto-17.0.19.10.1-linux-${arch/86_/}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA512SUM='c2ec54f90191e99dc551e3c072d3ea9e4e20b938162bfbc79cd90ea1065e41705950998f89c134842c8957a8eab29a2a1539512f130d2e8f6370573af564bb7c'
	# shellcheck disable=2034
	declare -r HADOOP_URL='https://archive.apache.org/dist/hadoop/common/hadoop-3.5.0/hadoop-3.5.0.tar.gz'
	# shellcheck disable=2034
	declare -r HADOOP_SHA512SUM='04ab94496cc00c8b7a28d03f6308eff8d2a4e7f37a9da5e8e086e4d6fc990e7a94d661908f6a6136039536efb362614b8aecdef185b5fb8ed588f0b152c7aa16'
else
	# shellcheck disable=2034
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/17.0.19.10.1/amazon-corretto-17.0.19.10.1-linux-${arch}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA512SUM='b90dafc4aa4f1d4b26f7081330116b811e2ef3203cdaaf932ee8f7190a886e34cb49309395eceac1efc365312be3e113daa6eafc0e6dcfa594469608c1e7e279'
	# shellcheck disable=2034
	declare -r HADOOP_URL="https://archive.apache.org/dist/hadoop/common/hadoop-3.5.0/hadoop-3.5.0-${arch}.tar.gz"
	# shellcheck disable=2034
	declare -r HADOOP_SHA512SUM='feaa20fea4709050ee993aae23b05720383a0d65aeda97c68d042e52564e8e77a83196a5a6973abdc690a1e600a73308ade56ccf9baeec231d1cf0810703430f'
fi

function download() {
	local package
	package="$(echo "${1}" | awk '{print toupper($0)}')"
	local url_variable="${package}_URL"
	local sha512sum_variable="${package}_SHA512SUM"

	local url="${!url_variable}"
	local checksum="${!sha512sum_variable}"
	local checksum_command
	checksum_command="$(command -v gsha512sum || command -v sha512sum)"
	local filename
	filename="$(basename "${url}")"

	if [[ ! -f "${filename}" ]] || ! echo "${checksum} ${filename}" | "${checksum_command}" --check &>/dev/null; then
		curl -LO "${url}"
	fi
}

function build_hadoop() {
	download 'java'
	download 'hadoop'

	docker build -t local/hadoop .

	minikube image load --alsologtostderr local/hadoop:latest
}

function main() {
	pushd "${SCRIPT_PATH}"

	build_hadoop

	popd
}

main "${@}"
