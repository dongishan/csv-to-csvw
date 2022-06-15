#!/usr/bin/env bash

for file in "${$1[@]}"; do
    echo "${file}"
    file_path="${file%.*}"
    file_name="${file_path##*/}"
    file_extension="${file##*.}"
    out_path="out/${file_path#csv/}/"

    if [[ "$file_extension" == "csv" ]]; then
        echo $'\n'
        echo "Processing file ${file}"
        echo "Output path is ${out_path}"

        csv_file=${file}
        for file_secondary in "${added_modified_files[@]}"; do
        file_secondary_name="${file_secondary%.*}"
        file_secondary_extension="${file_secondary##*.}"
        if [[ "${file_secondary_name}.${file_secondary_extension}" == "${file_path}.csv.json" ]]; then
            config_file="${file}.json"
        fi
        done
        
        if [[ -z $config_file ]]; then
        echo "Config for ${csv_file} is not available"
        echo "Building CSV-W"
        csvcubed build ${csv_file} --out $out_path
        else
        echo "Config for ${csv_file} is available: ${config_file}"
        echo "Building CSV-W"
        csvcubed build ${csv_file} -c $config_file --out $out_path
        fi
        
        echo "Inspecting CSV-W"
        csvcubed inspect "${GITHUB_WORKSPACE}/${out_path}${file_name//[ ,_]/-}.${file_extension}-metadata.json" >> "${out_path}inspect_output.txt"
        
        unset config_file
        echo "Finished processing file ${file}"
        echo "::set-output name=has_outputs::${{ toJSON(true) }}"
    fi
    done