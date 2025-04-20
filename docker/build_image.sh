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
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/8.452.09.1/amazon-corretto-8.452.09.1-linux-${arch/86_/}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA256SUM='7478d4a218d03d68bde6aaba91ad1057d68037c1281b646d4394826cde91b9be'
	# shellcheck disable=2034
	declare -r HADOOP_URL='https://archive.apache.org/dist/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz'
	# shellcheck disable=2034
	declare -r HADOOP_SHA256SUM='e311a78480414030f9ec63549a5d685e69e26f207103d9abf21a48b9dd03c86c'
else
	# shellcheck disable=2034
	declare -r JAVA_URL="https://corretto.aws/downloads/resources/8.452.09.1/amazon-corretto-8.452.09.1-linux-${arch}.tar.gz"
	# shellcheck disable=2034
	declare -r JAVA_SHA256SUM='b3d959bd1b9e8c82e383a9ae32a7a1ebdfaae4ec99f005ed9cf94275ba46819c'
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
