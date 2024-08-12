#!/bin/bash

swap_filename() {
	local file="$1"
	local base="${file%.pdb_intercaat.txt}"
	local ext="pdb_intercaat.txt"
	local first_part="${base%%__*}"
	local second_part="${base#*__*}"
	local new_base="$second_part"__"$first_part"
	local new_name="$new_base.$ext"
	mv "$file" "$new_name"
}
	
for file in * ; do
	if [[ -f "$file" ]]; then
	swap_filename "$file"
	fi
done
	
