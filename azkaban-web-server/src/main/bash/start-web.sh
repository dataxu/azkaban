#!/bin/bash

script_dir=$(dirname $0)

${script_dir}/internal/internal-start-web.sh  2>&1 | tee webServerLog_`date +%F+%T`.out
