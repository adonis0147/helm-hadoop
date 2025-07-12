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
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/11.0.27.6.1/amazon-corretto-11.0.27.6.1-linux-${arch/86_/}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA256SUM='0b4fd441b90471384af288ea7e927897114871c668ad292f4e982e7cb9f0cbf7'
	# shellcheck disable=2034
	declare -r HADOOP_URL='https://archive.apache.org/dist/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz'
	# shellcheck disable=2034
	declare -r HADOOP_SHA256SUM='e311a78480414030f9ec63549a5d685e69e26f207103d9abf21a48b9dd03c86c'
else
	# shellcheck disable=2034
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/11.0.27.6.1/amazon-corretto-11.0.27.6.1-linux-${arch}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA256SUM='679ab9f1f614d3ed000b61ccb5e0c06041c9ee29fb9c0ca1b598a9f23975cf85'
	# shellcheck disable=2034
	declare -r HADOOP_URL="https://archive.apache.org/dist/hadoop/common/hadoop-3.4.0/hadoop-3.4.0-${arch}.tar.gz"
	# shellcheck disable=2034
	declare -r HADOOP_SHA256SUM='416c732ad372c3f03370732fd2fee48fdd69c351ceed500df4c1cef3871a164f'
fi

function download() {
	local package
	package="$(echo "${1}" | awk '{print toupper($0)}')"
	local url_variable="${package}_URL"
	local checksum_variable="${package}_SHA256SUM"

	local url="${!url_variable}"
	local checksum="${!checksum_variable}"
	local filename
	filename="$(basename "${url}")"

	local SHA256SUM
	SHA256SUM="$(command -v gsha256sum || true)"
	if [[ ! -f "${filename}" ]] || ! echo "${checksum} ${filename}" | "${SHA256SUM:-sha256sum}" --check &>/dev/null; then
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
