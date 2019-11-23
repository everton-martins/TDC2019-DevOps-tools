#set -x
export TF_VAR_instid=$2
export TF_VAR_envtype=$1


export AWS_DEFAULT_PROFILE=$TF_VAR_envtype

rm -f terraform.tfstate*
./terraform import aws_instance.mongodb $TF_VAR_instid
./terraform apply -auto-approve 

