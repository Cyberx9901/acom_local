#!/bin/bash

set -euo pipefail

DIR_ASCII="ascii"
DIR_SAVES="saves"

usage() {
	echo "Usage: $0"
	exit 1
}

check_deps() {
	local deps=("fzf")
	for dep in "${deps[@]}"; do
		if ! command -v "$dep" &>/dev/null; then
			echo "Error: $dep not found" >&2
			exit 1
		fi
	done
}

check_dirs() {
	if [[ ! -d "$DIR_ASCII" ]]; then
		echo "Error: directory '$DIR_ASCII' not found" >&2
		exit 1
	fi
	if [[ ! -d "$DIR_SAVES" ]]; then
		mkdir -p "$DIR_SAVES"
	fi
}

get_digimon_name() {
	local name
	name=$(cat dmx.txt | fzf --prompt="Digimon Name: ")
	if [[ -z "$name" ]]; then
		echo "Error: name cannot be empty" >&2
		exit 1
	fi
	echo "$name"
}

get_code() {
	local code
	read -p "Code: " code
	if [[ -z "$code" ]]; then
		echo "Error: code cannot be empty" >&2
		exit 1
	fi
	echo "$code"
}

get_ascii_file() {
	local ascii
	ascii=$(ls "$DIR_ASCII/" | cut -d '.' -f1 | fzf --prompt="Icon: ")
	if [[ -z "$ascii" ]]; then
		echo "Error: no ASCII file selected" >&2
		exit 1
	fi
	echo "${ascii}.txt"
}

format_code() {
	local code="$1"
	echo "$code" | sed 's/r:/\nr:/g' | cut -d ' ' -f1 | grep 'r:' | sed 's/r:/-/g' | tr -d '\n'
}

check_overwrite() {
	local file="$1"
	if [[ -f "$DIR_SAVES/$file" ]]; then
		read -p "File exists. Overwrite? (y/n) " answer
		if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
			echo "Operation cancelled"
			exit 0
		fi
	fi
}

main() {
	check_deps
	check_dirs

	local name code ascii file usable_code
	name=$(get_digimon_name)
	cat readme.txt 
	code=$(get_code)
	ascii=$(get_ascii_file)

	file="$ascii"

	check_overwrite "$file"

	usable_code="V2$(format_code "$code")"

	{
		echo "$name"
		cat "$DIR_ASCII/$ascii"
		echo -e "\nCode: $usable_code"
	} >"$DIR_SAVES/$file"

	echo "Saved successfully to: saves/$file"
}

main "$@"
