#!/bin/bash
#----------------------------------------------------------------------
# Target Environment
#--------------------------------------------------------------------------------
clear
environments=( $(for i in $(ls -d */); do basename $(realpath $i); done) )

if [[ " ${environments[@]} " =~ " ${1} " ]]; then
    export ENVIRONMENT=${1} && cd ${ENVIRONMENT}
else
    echo "Which environment [${environments[@]}]?"
    select env in "${environments[@]}"
    do
        case ${env} in
            *)
                export ENVIRONMENT=${env} && cd ${ENVIRONMENT}
                break
                ;;
        esac
    done
fi
