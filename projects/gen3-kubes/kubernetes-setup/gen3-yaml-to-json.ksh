#!/usr/bin/env bash
#set -x

usage () {
  echo "
  Program to generate a single json file from a directory of yaml files.  Useful for data dictionaries

  usage: gen3-yaml-to-json.ksh <input_dir>  <output_file>

  "
}

input_dir=$1
output_file=$2


if test -z "${input_dir}" -o -z "${output_file}"  ;
  then
    usage
    exit;
fi

  echo "{" > /tmp/schema.generated.json ; #initial open paren
  for i  in ${input_dir}/*.yaml;
    do yml=`cat ${i} | python3 -c 'import sys, yaml, json; y=yaml.safe_load(sys.stdin.read()); print(json.dumps(y))'`;
    echo "\"$i\":$yml," >>/tmp/schema.generated.json;
  done;
  cat /tmp/schema.generated.json |  sed '$s/,$//' > ${output_file}; #delete trailing comma on last line
  echo "}" >> ${output_file};   # final close paren
  rm  /tmp/schema.generated.json;
