aws cloudformation create-stack \
  --stack-name ec2-vpc-stack \
  --template-body file://ec2-vpc.yml \
  --parameters ParameterKey=KeyName,ParameterValue=my-ec2-key \
  --capabilities CAPABILITY_NAMED_IAM
