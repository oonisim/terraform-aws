#!/usr/bin/env bash
DIR=$(realpath $(dirname $0))
cd ${DIR}

export PYTHONPATH=${PYTHONPATH}:${DIR}:${DIR}/python

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:?'Set AWS_DEFAULT_REGION'}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?'Set AWS_ACCESS_KEY_ID'}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?'Set AWS_SECRET_ACCESS_KEY'}"
export TEMP_PASSWORD="${TEMP_PASSWORD:?'Set TEMP_PASSWORD'}"

clear

#--------------------------------------------------------------------------------
# Pylint
#--------------------------------------------------------------------------------
set -eu

rm -rf test/__pycache__/
rm -f test/*.pyc

echo "--------------------------------------------------------------------------------"
echo "Running pylint in lamda pythons (run pylint in the directory in case of xxx not found in module)..."
for test in $(ls python/*.py)
do
    if [[ "${test}" != "python/six.py" ]]
     then
        pylint -E ${test}
    fi
done

echo "--------------------------------------------------------------------------------"
echo "Running pylint in lamda pythons"
for test in $(ls test/test_*.py)
do
    pylint -E ${test}
done

python -m pytest --verbose -x ${DIR}/test/
