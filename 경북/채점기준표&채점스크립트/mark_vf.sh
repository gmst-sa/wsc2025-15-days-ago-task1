#!/bin/bash

BUCKET_NAME=skills-chart-bucket-<영문 4자리>
GITHUB_USER=$(gh api user --jq .login)

aws configure set default.region ap-northeast-2

echo =====1-1=====
aws ec2 describe-vpcs --filter Name=tag:Name,Values=skills-hub-vpc --query "Vpcs[].CidrBlock" \
; aws ec2 describe-vpcs --filter Name=tag:Name,Values=skills-app-vpc --query "Vpcs[].CidrBlock"
echo

echo =====1-2=====
aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-hub-subnet-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-hub-subnet-b --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-inspect-subnet-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-inspect-subnet-b --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-app-subnet-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-app-subnet-b --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-workload-subnet-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-workload-subnet-b --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-db-subnet-a --query "Subnets[0].CidrBlock" \
; aws ec2 describe-subnets --filter Name=tag:Name,Values=skills-db-subnet-b --query "Subnets[0].CidrBlock"
echo

echo =====1-3=====
aws ec2 describe-vpc-endpoints --query "VpcEndpoints[].ServiceName" 
echo

echo =====2-1=====
aws ec2 describe-vpc-peering-connections \
  --filters "Name=tag:Name,Values=skills-peering" \
  --query "VpcPeeringConnections[?Status.Code=='active'].{PeeringId:VpcPeeringConnectionId,Requester:RequesterVpcInfo.VpcId,Accepter:AccepterVpcInfo.VpcId,Status:Status.Code}" \
  --output json
echo

echo =====3-1=====
FIREWALL_NAME=$(aws network-firewall describe-firewall --firewall-name skills-firewall \
  --query 'Firewall.FirewallName' --output text)
FIREWALL_POLICY_NAME=$(aws network-firewall describe-firewall --firewall-name skills-firewall \
  --query 'Firewall.FirewallPolicyArn' --output text | awk -F'/' '{print $NF}')
SUBNET_NAMES=$(for subnet_id in $(aws network-firewall describe-firewall --firewall-name skills-firewall \
  --query 'Firewall.SubnetMappings[].SubnetId' --output text); do
  aws ec2 describe-subnets --subnet-ids $subnet_id \
    --query 'Subnets[].Tags[?Key==`Name`].Value' --output text
done | paste -sd "," -)

echo "$FIREWALL_NAME"
echo "$FIREWALL_POLICY_NAME"
echo "$SUBNET_NAMES"
echo

echo =====3-2=====
curl --max-time 10 ifconfig.me
echo

echo =====3-3=====
aws ec2 describe-security-groups \
  --filters Name=group-name,Values=skills-bastion-sg \
  --query "length(SecurityGroups[0].IpPermissionsEgress)" \
  --output text
echo

echo =====3-4=====
curl --max-time 10 ifconfig.io
echo

echo =====4-1=====
aws ec2 describe-instances --filter Name=tag:Name,Values=skills-bastion --query "Reservations[].Instances[].InstanceType"
echo

echo =====4-2=====
aws ec2 describe-instances --filter Name=tag:Name,Values=skills-bastion --query "Reservations[].Instances[].PublicIpAddress"
aws ec2 describe-addresses --query "Addresses[].PublicIp"
echo

echo =====4-3=====
INSTANCE_NAME_TAG="skills-bastion"
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME_TAG" --query "Reservations[0].Instances[0].InstanceId" --output text)
AMI_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].ImageId" --output text)
AMI_DESCRIPTION=$(aws ec2 describe-images --image-ids "$AMI_ID" --query "Images[0].Description" --output text)
INSTANCE_SG_NAME=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].SecurityGroups[0].GroupName" --output text)

echo "$AMI_DESCRIPTION"
echo "$INSTANCE_SG_NAME"
echo

echo =====4-4=====
POLICY_ARNS=$(aws iam list-attached-role-policies --role-name skills-bastion-role --query "AttachedPolicies[].PolicyArn" --output text)
for POLICY_ARN in $POLICY_ARNS; do
POLICY_VERSION=$(aws iam get-policy --policy-arn $POLICY_ARN --query "Policy.DefaultVersionId" --output text)
POLICY_DOCUMENT=$(aws iam get-policy-version --policy-arn $POLICY_ARN --version-id $POLICY_VERSION --query "PolicyVersion.Document" --output json)
echo "$POLICY_DOCUMENT"
done
echo

echo =====5-1=====
aws secretsmanager describe-secret --secret-id skills-secrets --query '{Name:Name, KmsKeyId:KmsKeyId}' --output json
echo

echo =====5-2=====
kubectl exec -n skills $(kubectl get pods -n skills -l app=green -o name | head -n1 | cut -d'/' -f2) -- env | grep DB
echo

echo =====6-1=====
aws rds describe-db-clusters --db-cluster-identifier skills-db-cluster --query 'DBClusters[0].EngineVersion' --output text \
; aws rds describe-db-clusters --db-cluster-identifier skills-db-cluster --query 'DBClusters[0].MasterUsername' --output text \
; aws rds describe-db-instances  --query "DBInstances[?DBClusterIdentifier=='skills-db-cluster'].DBInstanceClass" --output text
echo

echo =====6-2=====
aws rds describe-db-clusters --db-cluster-identifier skills-db-cluster --query "DBClusters[0].BacktrackWindow" --output text
echo

echo =====7-1=====
aws s3api list-buckets --query "Buckets[].Name" --output text
echo

echo =====7-2=====
aws s3 ls s3://$BUCKET_NAME/app/ --recursive | grep '.tgz'
echo

echo =====7-3=====
argocd app get green -o json | jq '.spec.sources[0].repoURL // null'
argocd app get red -o json | jq '.spec.sources[0].repoURL // null'
echo

echo =====8-1=====
aws ecr describe-repositories --repository-names "skills-green-repo" "skills-red-repo" --query "repositories[].{imageTagMutability:imageTagMutability,scanOnPush:imageScanningConfiguration.scanOnPush,encryptionConfiguration:encryptionConfiguration.encryptionType}"
echo

echo =====8-2=====
aws ecr describe-images --repository-name skills-green-repo --query "imageDetails[].imageTags[]"
aws ecr describe-images --repository-name skills-red-repo --query "imageDetails[].imageTags[]"
echo

echo =====9-1=====
aws eks describe-cluster --name skills-eks-cluster --query 'cluster.version' --output text \
; aws eks describe-cluster --name skills-eks-cluster --query 'cluster.logging.clusterLogging[].types' | jq . \
; aws eks describe-cluster --name skills-eks-cluster --query "cluster.resourcesVpcConfig.[endpointPublicAccess, endpointPrivateAccess]"
echo

echo =====9-2=====
aws eks describe-cluster --name skills-eks-cluster --query "cluster.encryptionConfig[].provider.keyArn" --output text
echo 

echo =====9-3=====
kubectl get node -l skills=app -o json | jq -r '.items[].metadata.labels."eks.amazonaws.com/nodegroup"'
kubectl get nodes -l skills=app -o json | jq -r '.items[].metadata.name'
kubectl get nodes -l skills=app -o json | jq -r '.items[] | .metadata.labels["beta.kubernetes.io/instance-type"]'
echo

echo =====9-4=====
kubectl get node -l skills=addon -o json | jq -r '.items[].metadata.labels."eks.amazonaws.com/nodegroup"'
kubectl get nodes -l skills=addon -o json | jq -r '.items[].metadata.name'
kubectl get nodes -l skills=addon -o json | jq -r '.items[] | .metadata.labels["beta.kubernetes.io/instance-type"]'
echo

echo =====9-5=====
aws eks describe-fargate-profile --cluster-name skills-eks-cluster --fargate-profile-name skills-fargate-profile --query "fargateProfile.fargateProfileName"
echo

echo =====9-6=====
kubectl get deploy -n skills
echo

echo =====10-1=====
aws elbv2 describe-load-balancers --query "LoadBalancers[].{Name:LoadBalancerName,Type:Scheme,Zones:AvailabilityZones[].ZoneName}" --output json
echo

echo =====10-2=====
EXTERNAL_NLB_DNS=$(aws elbv2 describe-load-balancers --names skills-nlb --query "LoadBalancers[].DNSName" --output text)
curl http://$EXTERNAL_NLB_DNS/green -X POST -H 'Content-Type: application/json' -d '{"x": "alice", "y": 21}'
echo

echo =====10-3=====
EXTERNAL_NLB_DNS=$(aws elbv2 describe-load-balancers --names skills-nlb --query "LoadBalancers[].DNSName" --output text)
curl http://$EXTERNAL_NLB_DNS/red -X POST -H 'Content-Type: application/json' -d '{"name": "bob"}'
echo

echo =====11-1=====
aws opensearch list-domain-names | grep skills-opensearch
echo

echo =====11-2=====
aws opensearch describe-domain --domain-name skills-opensearch --query "DomainStatus.ClusterConfig.[InstanceCount, DedicatedMasterCount]"
aws opensearch describe-domain --domain-name skills-opensearch --query "DomainStatus.EngineVersion"
echo

echo =====11-3=====
OPENSEARCH_ENDPOINT=$(aws opensearch describe-domain --domain-name skills-opensearch | jq -r '.DomainStatus.Endpoint')
curl -s -u admin:Skill53## "https://$OPENSEARCH_ENDPOINT/_cat/indices?v" | grep "app-log"
echo

echo =====11-4=====
curl --silent \
  -u "admin:Skill53##" \
  "https://${OPENSEARCH_ENDPOINT}/app-log/_search?size=1" \
  | jq -r '.hits.hits[0]._source'
echo

echo =====11-5=====
curl --silent \
  -u "admin:Skill53##" \
  "https://${OPENSEARCH_ENDPOINT}/app-log/_search?q=path:%22/health%22&size=1" \
  | jq -r '.hits.hits[0]._source'
echo

echo =====12-1=====
echo "CloudWatch 콘솔에서 채점"
echo

echo =====13-1=====
EXTERNAL_NLB_DNS=$(aws elbv2 describe-load-balancers --names skills-nlb --query "LoadBalancers[].DNSName" --output text)
export ID_GREEN=$(curl -s -X POST -H 'Content-Type: application/json' -d '{"x": "charlie", "y": 21}' http://$EXTERNAL_NLB_DNS/green | jq -r '.id')
export ID_RED=$(curl -s -X POST -H 'Content-Type: application/json' -d '{"name": "dave"}' http://$EXTERNAL_NLB_DNS/red | jq -r '.id')
curl http://$EXTERNAL_NLB_DNS/green?id=$ID_GREEN
curl http://$EXTERNAL_NLB_DNS/red?id=$ID_RED
echo
echo ==============

cd /home/ec2-user/images
AWS_REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
docker rmi -f $(docker images)
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com" > /dev/null 

cd green
aws s3 cp s3://$BUCKET_NAME/images/green_1.0.1 .
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker build -t $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/skills-green-repo:v1.0.1 .
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/skills-green-repo:v1.0.1

cd ..

cd red
aws s3 cp s3://$BUCKET_NAME/images/red_1.0.1 .
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker build -t $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/skills-red-repo:v1.0.1 .
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/skills-red-repo:v1.0.1

cd ~

gh repo clone "$GITHUB_USER/day1-values" "day1-values-mark"
cd /home/ec2-user/day1-values-mark
for file in green.values.yaml red.values.yaml; do
  sed -i 's/tag: .*/tag: v1.0.1/g' "$file"
done
git add green.values.yaml red.values.yaml
git commit -m "chore: bump tag to v1.0.1 in values files"
git push -u origin main

echo ==============

argocd app sync green
argocd app sync red

echo wait 1 minutes
sleep 1m
echo ==============
echo

EXTERNAL_NLB_DNS=$(aws elbv2 describe-load-balancers --names skills-nlb --query "LoadBalancers[].DNSName" --output text)
curl -s http://$EXTERNAL_NLB_DNS/green?id=$ID_GREEN
curl -s http://$EXTERNAL_NLB_DNS/red?id=$ID_RED
echo
