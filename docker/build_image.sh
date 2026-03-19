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
	declare -r HADOOP_URL='https://archive.apache.org/dist/hadoop/common/hadoop-3.4.3/hadoop-3.4.3.tar.gz'
	# shellcheck disable=2034
	declare -r HADOOP_SHA256SUM='ca65b67a9cdad27b3aa1cb81496a3136de572bab3e8f2289c2aade965f687353'
else
	# shellcheck disable=2034
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/11.0.27.6.1/amazon-corretto-11.0.27.6.1-linux-${arch}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA256SUM='679ab9f1f614d3ed000b61ccb5e0c06041c9ee29fb9c0ca1b598a9f23975cf85'
	# shellcheck disable=2034
	declare -r HADOOP_URL="https://archive.apache.org/dist/hadoop/common/hadoop-3.4.3/hadoop-3.4.3-${arch}.tar.gz"
	# shellcheck disable=2034
	declare -r HADOOP_SHA256SUM='229016c37f7d1f2da43e9712e21236670c8cca3546df99e983e47d8a86860118'
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
