#--------------------------------------------------------------------------------
# [Terraform]
# Global variables throughout the execution.
#--------------------------------------------------------------------------------
export TF_VAR_REGION=${AWS_DEFAULT_REGION}
export TF_VAR_PROJECT="${PROJECT:?'Set PROJECT'}"
export TF_VAR_ENV="${ENVIRONMENT:?'Set ENVIRONMENT'}"
PLUGIN_DIR=${DIR}/plugins

#--------------------------------------------------------------------------------
# S3 Backend
#--------------------------------------------------------------------------------
BACKEND_DIR="backend"
export TF_VAR_BACKEND_BUCKET=$(cd "${BACKEND_DIR}" && terraform output | sed -n 's/^s3_bucket_id = \(.*\)$/\1/p')
#if [ "${TF_VAR_BACKEND_BUCKET}x" == "x" ] ; then
#    echo "What is the terraform backend S3 bucket name?"
#    read TF_VAR_BACKEND_BUCKET
#    export TF_VAR_BACKEND_BUCKET
#fi

if [[ "${TF_VAR_BACKEND_BUCKET}x" == "x" ]] ; then
  echo "Setting up Terraform backend in S3..."
  (cd ${BACKEND_DIR} && terraform init -get-plugins=false -plugin-dir=${PLUGIN_DIR} && terraform apply -auto-approve)
  export TF_VAR_BACKEND_BUCKET=$(cd "${BACKEND_DIR}" && terraform output | sed -n 's/^s3_bucket_id = \(.*\)$/\1/p')
fi

echo ""
echo "Terraform remote state to use is ${TF_VAR_BACKEND_BUCKET}"
echo "Proceeding..."
#read ANSWER

#--------------------------------------------------------------------------------
# Run terraform on a module at a time
# See https://learn.hashicorp.com/terraform/development/running-terraform-in-automation
#--------------------------------------------------------------------------------
init() {
    local target_component=$1
    (
        export TF_VAR_BACKEND_KEY="${target_component%%.*}.tfstate"
        cd ${target_component}
        terraform init \
            -get-plugins=false \
            -plugin-dir=${PLUGIN_DIR} \
            -input=false \
            -backend-config="region=${AWS_DEFAULT_REGION}" \
            -backend-config="bucket=${TF_VAR_BACKEND_BUCKET}" \
            -backend-config="key=${TF_VAR_BACKEND_KEY}" \
            -backend-config="encrypt=true"
        return $?
    )
}
pull() {
    local target_component=$1
    init "${target_component}"
    (
        export TF_VAR_BACKEND_KEY="${target_component%%.*}.tfstate"
        cd ${target_component} &&
        terraform state pull | tee pull.log
    )
}
plan() {
    local target_component=$1
    #init "${target_component}"
    (
        export TF_VAR_BACKEND_KEY="${target_component%%.*}.tfstate"
        cd ${target_component} &&
        terraform plan \
            -lock=true \
            -out=tfplan
    )
}
apply() {
    local target_component=$1
    #init "${target_component}"
    (
        export TF_VAR_BACKEND_KEY="${target_component%%.*}.tfstate"
        cd ${target_component}
        terraform apply \
            -input=false \
            -auto-approve \
            -lock=true | tee apply.log
        return ${PIPESTATUS[0]}
    )
}
destroy() {
    local target_component=$1
    #init "${target_component}"
    (
        export TF_VAR_BACKEND_KEY="${target_component%%.*}.tfstate"
        cd ${target_component}
        terraform destroy \
            -input=false \
            -force \
            -lock=true | tee destroy.log
    )
}
update() {
    local target_component=$1
    (
        cd ${target_component}
        terraform get -update
        return $?
    )
}
show() {
    local target_component=$1
    (
        cd ${target_component}
        terraform show -no-color -json 2>&1 | jq '.' | tee show.log.json
        return ${PIPESTATUS[0]}
    )
}
other() {
    local target_component=$1
    local command=$2
    (
        export TF_VAR_BACKEND_KEY="${target_component%%.*}.tfstate"
        cd ${target_component}
        terraform ${command}
        return $?
    )
}

tf() {
    local target_component=$1
    local command=$2
    case ${command} in
        plan)
            plan   ${target_component}
            ;;
        apply)
            apply   ${target_component}
            ;;
        destroy)
            destroy ${target_component}
            ;;
        init)
            init   ${target_component}
            ;;
        pull)
            pull   ${target_component}
            ;;
        update)
            update ${target_component}
           ;;
        show)
            show ${target_component}
            ;;
        *)
            other ${target_component} ${command}
            ;;
    esac
    return $?
}

