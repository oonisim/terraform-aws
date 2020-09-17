#--------------------------------------------------------------------------------
# Setup AWS temporal credential for MFA enabled account.
# https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
#
# For an account enabled with MFA, a temporary AWS credential for CLI needs
# to be acquired from AWS STS to access AWS API.
#--------------------------------------------------------------------------------
export AWS_DEFAULT_REGION=''
export AWS_ACCESS_KEY_ID=''
export AWS_SECRET_ACCESS_KEY=''
export AWS_SECURITY_DEVICE_ARN=''

#--------------------------------------------------------------------------------
# AWS Credentials of the user account
#--------------------------------------------------------------------------------
echo "Source this file to set the AWS MFA temprary credentials"

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:?'Set AWS_DEFAULT_REGION'}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?'Set AWS_ACCESS_KEY_ID'}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?'Set AWS_SECRET_ACCESS_KEY'}"

#--------------------------------------------------------------------------------
# MFA
# Acquire temprarly credentials for MFA access.
#--------------------------------------------------------------------------------
echo "AWS MFA token?"
read AWS_MFA_TOKEN

if true
then
	export AWS_MFA_TOKEN=${AWS_MFA_TOKEN:?'Set AWS_MFA_TOKEN with the Authenticator token'}
	export AWS_SECURITY_DEVICE_ARN="${AWS_SECURITY_DEVICE_ARN:?'Set AWS_SECURITY_DEVICE_ARN'}"

	session="$(aws sts get-session-token --serial-number "${AWS_SECURITY_DEVICE_ARN}" --token-code ${AWS_MFA_TOKEN} --output json)"

	echo "session = [$session]"
	export AWS_SESSION_TOKEN="$(echo "$session" | jq -r .Credentials.SessionToken)"
	export AWS_ACCESS_KEY_ID=$(echo $session | jq  -r .Credentials.AccessKeyId)
	export AWS_SECRET_ACCESS_KEY=$(echo $session | jq  -r .Credentials.SecretAccessKey)

	export TF_VAR_aws_access_key_id="${AWS_ACCESS_KEY_ID}"
	export TF_VAR_aws_secret_access_key="${AWS_SECRET_ACCESS_KEY}"
	export TF_VAR_aws_region=${AWS_DEFAULT_REGION}

	echo "${AWS_SESSION_TOKEN}"
echo "-------------------------"
fi

#--------------------------------------------------------------------------------
# EC2
#--------------------------------------------------------------------------------
export EC2_KEYPAIR_NAME="test-test_us-east-1.pem"
export EC2_REMOTE_USER=ubuntu
eval $(ssh-agent)
ssh-add ~/.ssh/${EC2_KEYPAIR_NAME}