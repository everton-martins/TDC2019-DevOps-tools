#!/bin/sh
export TF_VAR_name=$1


export VAR_region="us-east-1"
export VAR_SUBNET_ID="subnet-0dXXXXXXXXXXXXXXX"
export VAR_VPC_ID="vpc-04XXXXXXXXXXX"

  
echo "Building image on PRD environment"
./packer build  ${TF_VAR_name}.json
#[ $? -gt 0 ] && exit 1 

echo "Pipeline finished"
echo "Image $1 available"

