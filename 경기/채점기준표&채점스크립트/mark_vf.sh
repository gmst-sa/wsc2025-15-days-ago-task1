#!/bin/bash
########## PARAM ##########
COLORA='\033[96m'
COLORRE="\e[0m"
COLORR="\033[0;31m"
COLORG="\033[0;32m"
COLORL="\e[92m"
###########################
echo -e "${COLORA}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo -e "@@@@@ 2025년 경기도 전국기능경기대회 [1과제] @@@@@"
echo -e "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${COLORRE}"
echo -e "${COLORL}----- 사전 준비 -----${COLORRE}"
rm -rf ~/.aws
mkdir -p ~/.aws
aws configure set region ap-northeast-2 --profile default
aws configure set output json
aws sts get-caller-identity >/dev/null 2>&1 && echo -e "${COLORG}[!] 자격 증명 확인 완료${COLORRE}" || { echo -e "${COLORR}[!] 채점에 필요한 자격 증명이 없어 채점을 진행할 수 없습니다.\n[!] 자격 증명 혹은 리전 설정을 다시 한번 확인해 주시기 바랍니다.${COLORRE}"; exit 1; }
echo -e "${COLORG}[!] 사전 준비가 완료되었습니다. 채점을 시작합니다.${COLORRE}"

echo -e "${COLORL}----- 1-1-A -----${COLORRE}"
aws ec2 describe-vpcs --filter Name=tag:Name,Values=ws25-hub-vpc --query "Vpcs[0].CidrBlock" \
; aws ec2 describe-vpcs --filter Name=tag:Name,Values=ws25-app-vpc --query "Vpcs[0].CidrBlock"

echo ""

echo -e "${COLORL}----- 1-2-A -----${COLORRE}"
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-hub-pub-a --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-hub-pub-c --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-app-pub-a --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-app-pub-b --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-app-pub-c --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-app-pri-a --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-app-pri-b --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-app-pri-c --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-app-db-a --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text ; 
aws ec2 describe-subnets --filter Name=tag:Name,Values=ws25-app-db-c --query "Subnets[0].[CidrBlock, AvailabilityZone]" --output text

echo ""
echo -e "${COLORL}----- 1-3-A -----${COLORRE}"
aws ec2 describe-vpc-peering-connections --filters Name=tag:Name,Values=ws25-peering --query "VpcPeeringConnections[0].{Requester:RequesterVpcInfo.VpcId, Accepter:AccepterVpcInfo.VpcId}" --output text

echo ""

echo -e "${COLORL}----- 1-4-A -----${COLORRE}"
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ws25-hub-pub-rt" --query "RouteTables[].{IGW: Routes[?GatewayId != null && starts_with(GatewayId, 'igw')].GatewayId, Subnets: Associations[?SubnetId != null].SubnetId, Peering: Routes[?VpcPeeringConnectionId != null].VpcPeeringConnectionId}" --output text
echo -e "\n"
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ws25-app-pub-rt" --query "RouteTables[].{IGW: Routes[?GatewayId != null && starts_with(GatewayId, 'igw')].GatewayId, Subnets: Associations[?SubnetId != null].SubnetId}" --output text
echo -e "\n"
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ws25-app-pri-rt-a" --query "RouteTables[].{NATGW: Routes[?NatGatewayId != null].NatGatewayId, Subnets: Associations[?SubnetId != null].SubnetId, Peering: Routes[?VpcPeeringConnectionId != null].VpcPeeringConnectionId}" --output text
echo -e "\n"
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ws25-app-pri-rt-b" --query "RouteTables[].{NATGW: Routes[?NatGatewayId != null].NatGatewayId, Subnets: Associations[?SubnetId != null].SubnetId, Peering: Routes[?VpcPeeringConnectionId != null].VpcPeeringConnectionId}" --output text
echo -e "\n"
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ws25-app-pri-rt-c" --query "RouteTables[].{NATGW: Routes[?NatGatewayId != null].NatGatewayId, Subnets: Associations[?SubnetId != null].SubnetId, Peering: Routes[?VpcPeeringConnectionId != null].VpcPeeringConnectionId}" --output text
echo -e "\n"
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ws25-app-db-rt-a" --query "RouteTables[].{Subnets: Associations[?SubnetId != null].SubnetId, Peering: Routes[?VpcPeeringConnectionId != null].VpcPeeringConnectionId}" --output text
echo -e "\n"
aws ec2 describe-route-tables --filters "Name=tag:Name,Values=ws25-app-db-rt-c" --query "RouteTables[].{Subnets: Associations[?SubnetId != null].SubnetId, Peering: Routes[?VpcPeeringConnectionId != null].VpcPeeringConnectionId}" --output text
echo -e "\n"

echo ""

echo -e "${COLORL}----- 1-5-A -----${COLORRE}"
VPCHUBID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=ws25-hub-vpc" --query "Vpcs[*].VpcId" --output text)
aws ec2 describe-flow-logs --filter "Name=resource-id,Values=$VPCHUBID" --query "FlowLogs[*].FlowLogId" --output text
VPCAPPID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=ws25-app-vpc" --query "Vpcs[*].VpcId" --output text)
aws ec2 describe-flow-logs --filter "Name=resource-id,Values=$VPCAPPID" --query "FlowLogs[*].FlowLogId" --output text

echo ""

echo -e "${COLORL}----- 1-5-B -----${COLORRE}"
for group in /ws25/flow/hub /ws25/flow/app; do count=$(aws logs describe-log-streams --log-group-name $group --query 'logStreams' --output json | jq length); echo "$group : $count"; done

echo ""

echo -e "${COLORL}----- 1-6-A -----${COLORRE}"
aws ec2 describe-vpc-endpoints --query "VpcEndpoints[].ServiceName"

echo ""

echo -e "${COLORL}----- 1-6-B -----${COLORRE}"
for service in com.amazonaws.$(aws configure get region).ecr.dkr com.amazonaws.$(aws configure get region).ecr.api; do eni=$(aws ec2 describe-vpc-endpoints --filters Name=service-name,Values=$service --query 'VpcEndpoints[0].NetworkInterfaceIds[0]' --output text); for sg in $(aws ec2 describe-network-interfaces --network-interface-ids $eni --query 'NetworkInterfaces[0].Groups[].GroupId' --output text); do echo "$service - $sg"; aws ec2 describe-security-groups --group-ids $sg --query 'SecurityGroups[0].IpPermissions[?FromPort==`443` && ToPort==`443`].IpRanges[].CidrIp' --output text; done; done

echo ""

echo -e "${COLORL}----- 2-1-A -----${COLORRE}"

aws ec2 describe-images --image-ids $(aws ec2 describe-instances --filters Name=tag:Name,Values=ws25-ec2-bastion Name=instance-state-name,Values=running --query "Reservations[].Instances[].ImageId" --output text) --query "Images[].Name" --output text; aws ec2 describe-instances --filters Name=tag:Name,Values=ws25-ec2-bastion Name=instance-state-name,Values=running --query "Reservations[].Instances[].InstanceType" --output text; aws ec2 describe-subnets --subnet-ids $(aws ec2 describe-instances --filters Name=tag:Name,Values=ws25-ec2-bastion Name=instance-state-name,Values=running --query "Reservations[].Instances[].SubnetId" --output text) --query "Subnets[].Tags[?Key=='Name'].Value | [0]" --output text; aws ec2 describe-addresses --filters Name=instance-id,Values=$(aws ec2 describe-instances --filters Name=tag:Name,Values=ws25-ec2-bastion Name=instance-state-name,Values=running --query "Reservations[].Instances[].InstanceId" --output text) --query "Addresses[].PublicIp"

echo ""

echo -e "${COLORL}----- 2-2-A -----${COLORRE}"

aws iam list-attached-role-policies --role-name $(aws ec2 describe-instances --filters Name=tag:Name,Values=ws25-ec2-bastion --query "Reservations[].Instances[].IamInstanceProfile.Arn" --output text | awk -F'instance-profile/' '{print $2}') --query "AttachedPolicies[?PolicyName=='AdministratorAccess'].PolicyName | [0]" --output text

echo ""

echo -e "${COLORL}----- 2-3-A -----${COLORRE}"

aws ec2 describe-security-groups --group-ids $(aws ec2 describe-instances --filters Name=tag:Name,Values=ws25-ec2-bastion --query "Reservations[].Instances[].SecurityGroups[].GroupId" --output text) --query "SecurityGroups[].IpPermissions" --output json | jq -c '.[][]'

echo ""
echo -e "${COLORL}----- 3-1-A -----${COLORRE}"
aws secretsmanager describe-secret --secret-id ws25/secret/key --query "Name" --output text; aws secretsmanager get-secret-value --secret-id ws25/secret/key --query "SecretString" --output text | jq -r 'keys[]'

echo ""
echo -e "${COLORL}----- 3-2-A -----${COLORRE}"

aws secretsmanager describe-secret --secret-id ws25/secret/key --query "KmsKeyId" --output text
echo ""

echo -e "${COLORL}----- 4-1-A -----${COLORRE}"

aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].Engine" --output text; aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].EngineVersion" --output text; aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "length(DBClusters[0].DBClusterMembers[?IsClusterWriter==\`false\`])" --output text; aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].Port" --output text; aws rds describe-db-instances --filters Name=db-cluster-id,Values=ws25-rdb-cluster --query "DBInstances[0].DBInstanceClass" --output text; aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].Status" --output text
echo ""

echo -e "${COLORL}----- 4-2-A -----${COLORRE}"

aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].PerformanceInsightsEnabled" --output text; aws rds describe-db-instances --filters Name=db-cluster-id,Values=ws25-rdb-cluster --query "DBInstances[0].EnabledCloudwatchLogsExports" --output json

echo ""

echo -e "${COLORL}----- 4-3-A -----${COLORRE}"
aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].DatabaseName" --output text; aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].BackupRetentionPeriod" --output text; aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].BacktrackWindow" --output text; aws rds describe-db-subnet-groups --db-subnet-group-name $(aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].DBSubnetGroup" --output text) --query "DBSubnetGroups[0].Subnets[].SubnetIdentifier" --output text

echo ""
echo -e "${COLORL}----- 4-4-A -----${COLORRE}"
aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].KmsKeyId" --output text; aws kms get-key-rotation-status --key-id $(aws rds describe-db-clusters --db-cluster-identifier ws25-rdb-cluster --query "DBClusters[0].KmsKeyId" --output text) --query "KeyRotationEnabled" --output text
echo ""

echo -e "${COLORL}----- 5-1-A -----${COLORRE}"

aws ecr describe-repositories --repository-names green --query "repositories[0].imageTagMutability" --output text; aws ecr describe-repositories --repository-names red --query "repositories[0].imageTagMutability" --output text

echo ""
echo -e "${COLORL}----- 5-2-A -----${COLORRE}"
aws ecr describe-repositories --repository-names red --query "repositories[0].encryptionConfiguration" --output json; aws ecr describe-repositories --repository-names green --query "repositories[0].encryptionConfiguration" --output json

echo ""
echo -e "${COLORL}----- 5-3-A -----${COLORRE}"
aws ecr list-images --repository-name green --query "imageIds[].imageTag" --output text

echo ""
echo -e "${COLORL}----- 5-3-B -----${COLORRE}"
aws ecr list-images --repository-name red --query "imageIds[].imageTag" --output text

echo ""
echo -e "${COLORL}----- 5-4-A -----${COLORRE}"
aws ecr describe-repositories --repository-names green --query "repositories[0].imageScanningConfiguration.scanOnPush" --output text; aws ecr describe-repositories --repository-names red --query "repositories[0].imageScanningConfiguration.scanOnPush" --output text; aws ecr describe-image-scan-findings --repository-name green --image-id imageTag=v1.0.0 --query "imageScanFindings.findingSeverityCounts" --output json; aws ecr describe-image-scan-findings --repository-name green --image-id imageTag=v1.0.1 --query "imageScanFindings.findingSeverityCounts" --output json; aws ecr describe-image-scan-findings --repository-name red --image-id imageTag=v1.0.0 --query "imageScanFindings.findingSeverityCounts" --output json; aws ecr describe-image-scan-findings --repository-name red --image-id imageTag=v1.0.1 --query "imageScanFindings.findingSeverityCounts" --output json
echo ""

echo -e "${COLORL}----- 6-1-A -----${COLORRE}"
aws ecs describe-clusters --clusters ws25-ecs-cluster --include CONFIGURATIONS --region ap-northeast-2 --output json | jq -r '.clusters[0].configuration.managedStorageConfiguration.kmsKeyId'

echo ""

echo -e "${COLORL}----- 6-2-A -----${COLORRE}"
bash -c 'for td in $(aws ecs list-task-definitions --family-prefix ws25-ecs-green-taskdef --region ap-northeast-2 --query "taskDefinitionArns[]" --output text); do aws ecs describe-task-definition --task-definition $td --region ap-northeast-2 --query "taskDefinition.containerDefinitions[].image" --output text | grep -qw green:v1.0.0 && { echo True; exit 0; }; done; echo False'

echo ""

echo -e "${COLORL}----- 6-2-B -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-green --region ap-northeast-2 --output text --query "services[0].taskDefinition" | xargs -I{} bash -c 'td="{}"; name=$(basename "${td%:*}"); echo "$name"; aws ecs describe-task-definition --task-definition "$td" --region ap-northeast-2 --output json | jq -r "(.taskDefinition.cpu|tonumber/1024|tostring) + \" vCPU, \" + (.taskDefinition.memory|tonumber/1024|tostring) + \"GB\""'
echo ""

echo -e "${COLORL}----- 6-2-C -----${COLORRE}"

aws ecs describe-task-definition --task-definition $(aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-green --query 'services[0].taskDefinition' --output text --region ap-northeast-2) --output json --region ap-northeast-2 | jq -r '"ENV", (.taskDefinition.containerDefinitions[] | select(.firelensConfiguration|not) | .environment[]?.name), "", "Secrets", (.taskDefinition.containerDefinitions[] | select(.firelensConfiguration|not) | .secrets[]?.name)'

echo ""

echo -e "${COLORL}----- 6-3-A -----${COLORRE}"
bash -c 'for td in $(aws ecs list-task-definitions --family-prefix ws25-ecs-red-taskdef --region ap-northeast-2 --query "taskDefinitionArns[]" --output text); do aws ecs describe-task-definition --task-definition $td --region ap-northeast-2 --query "taskDefinition.containerDefinitions[].image" --output text | grep -qw red:v1.0.0 && { echo True; exit 0; }; done; echo False'

echo ""

echo -e "${COLORL}----- 6-3-B -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-red --region ap-northeast-2 --output text --query "services[0].taskDefinition" | xargs -I{} bash -c 'td="{}"; name=$(basename "${td%:*}"); echo "$name"; aws ecs describe-task-definition --task-definition "$td" --region ap-northeast-2 --output json | jq -r "(.taskDefinition.cpu|tonumber/1024|tostring) + \" vCPU, \" + (.taskDefinition.memory|tonumber/1024|tostring) + \"GB\""'
echo ""

echo -e "${COLORL}----- 6-3-C -----${COLORRE}"
aws ecs describe-task-definition --task-definition $(aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-red --query 'services[0].taskDefinition' --output text --region ap-northeast-2) --output json --region ap-northeast-2 | jq -r '"ENV", (.taskDefinition.containerDefinitions[] | select(.firelensConfiguration|not) | .environment[]?.name), "", "Secrets", (.taskDefinition.containerDefinitions[] | select(.firelensConfiguration|not) | .secrets[]?.name)'
echo ""

echo -e "${COLORL}----- 6-4-A -----${COLORRE}"
ids=$(aws ec2 describe-instances --filters Name=tag:Name,Values=ws25-ecs-container-green --region ap-northeast-2 --query 'Reservations[].Instances[].SubnetId' --output text); echo $( [ $(echo $ids | wc -w) -eq 3 ] && echo True || echo False ); names=$(for id in $ids; do aws ec2 describe-subnets --subnet-ids $id --region ap-northeast-2 --query 'Subnets[0].Tags[?Key==`Name`].Value' --output text; done | sort | xargs); echo $( [ "$names" = "ws25-app-pri-a ws25-app-pri-b ws25-app-pri-c" ] && echo True || echo False ); types=$(aws ec2 describe-instances --filters Name=tag:Name,Values=ws25-ecs-container-green --region ap-northeast-2 --query 'Reservations[].Instances[].InstanceType' --output text); echo $( echo $types | xargs -n1 | grep -v t3.medium >/dev/null && echo False || echo True )
echo ""

echo -e "${COLORL}----- 6-4-B -----${COLORRE}"
aws ecs describe-tasks --cluster ws25-ecs-cluster --region ap-northeast-2 --tasks $(aws ecs list-tasks --cluster ws25-ecs-cluster --service-name ws25-ecs-green --desired-status RUNNING --region ap-northeast-2 --query 'taskArns[]' --output text) --query 'tasks[].containerInstanceArn' --output text | xargs -r aws ecs describe-container-instances --cluster ws25-ecs-cluster --region ap-northeast-2 --container-instances --query 'containerInstances[].ec2InstanceId' --output text | xargs -r aws ec2 describe-instances --region ap-northeast-2 --instance-ids --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text | sort -u | grep -qFx ws25-ecs-container-green && echo True || echo False
echo ""

echo -e "${COLORL}----- 6-4-C -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-green --region ap-northeast-2 --output json | jq -r '.services[0] | .runningCount, .availabilityZoneRebalancing, .deploymentController.type'
echo ""

echo -e "${COLORL}----- 6-4-D -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-green --region ap-northeast-2 --query 'services[0].loadBalancers[].targetGroupArn' --output text \
| xargs -I {} aws elbv2 describe-target-groups --target-group-arns {} --region ap-northeast-2 --query 'TargetGroups[].LoadBalancerArns[]' --output text \
| xargs -I {} aws elbv2 describe-load-balancers --load-balancer-arns {} --region ap-northeast-2 --query 'LoadBalancers[].LoadBalancerName' --output text
echo ""

echo -e "${COLORL}----- 6-4-E -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-green --region ap-northeast-2 --query 'services[0].status' --output text | grep -q '^ACTIVE$' && echo True || echo False; aws ecs list-tasks --cluster ws25-ecs-cluster --service-name ws25-ecs-green --desired-status RUNNING --region ap-northeast-2 --query 'taskArns[]' --output text | xargs -r aws ecs describe-tasks --cluster ws25-ecs-cluster --region ap-northeast-2 --tasks --query 'tasks[].lastStatus' --output text | xargs -n1 | grep -vx RUNNING >/dev/null && echo False || echo True
echo ""

echo -e "${COLORL}----- 6-5-A -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-red --region ap-northeast-2 --output json \
| jq -r '.services[0] | if .launchType != null and .launchType != "" then .launchType else (.capacityProviderStrategy[0].capacityProvider | if test("FARGATE") then "FARGATE" else "EC2" end) end'
echo ""

echo -e "${COLORL}----- 6-5-B -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-red --region ap-northeast-2 --output json | jq -r '.services[0] | .runningCount, .availabilityZoneRebalancing, .deploymentController.type'
echo ""

echo -e "${COLORL}----- 6-5-C -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-red --region ap-northeast-2 --query 'services[0].loadBalancers[].targetGroupArn' --output text \
| xargs -I {} aws elbv2 describe-target-groups --target-group-arns {} --region ap-northeast-2 --query 'TargetGroups[].LoadBalancerArns[]' --output text \
| xargs -I {} aws elbv2 describe-load-balancers --load-balancer-arns {} --region ap-northeast-2 --query 'LoadBalancers[].LoadBalancerName' --output text
echo ""

echo -e "${COLORL}----- 6-5-D -----${COLORRE}"
aws ecs describe-services --cluster ws25-ecs-cluster --services ws25-ecs-red --region ap-northeast-2 --query 'services[0].status' --output text | grep -q '^ACTIVE$' && echo True || echo False; aws ecs list-tasks --cluster ws25-ecs-cluster --service-name ws25-ecs-red --desired-status RUNNING --region ap-northeast-2 --query 'taskArns[]' --output text | xargs -r aws ecs describe-tasks --cluster ws25-ecs-cluster --region ap-northeast-2 --tasks --query 'tasks[].lastStatus' --output text | xargs -n1 | grep -vx RUNNING >/dev/null && echo False || echo True
echo ""

echo -e "${COLORL}----- 7-1-A -----${COLORRE}"
for service in ws25-ecs-green ws25-ecs-red; do task_def=$(aws ecs describe-services --cluster ws25-ecs-cluster --services $service --query 'services[0].taskDefinition' --output text); aws ecs describe-task-definition --task-definition $task_def --query 'taskDefinition.containerDefinitions[?firelensConfiguration].firelensConfiguration | length(@) > `0`' --output text && aws ecs describe-task-definition --task-definition $task_def --query 'taskDefinition.containerDefinitions[?firelensConfiguration].firelensConfiguration.type' --output text | grep -E 'fluentbit|fluentd' && echo True; done
echo ""

echo -e "${COLORL}----- 7-2-A -----${COLORRE}"
for log_group in /ws25/logs/green /ws25/logs/red; do aws logs describe-log-groups --log-group-name-prefix $log_group --query 'logGroups[0].logGroupName' --output text | grep -q $log_group && echo True || echo False; done

echo ""

echo -e "${COLORL}----- 7-2-B -----${COLORRE}"

for log_group in /ws25/logs/green /ws25/logs/red; do    echo -n "$log_group : ";    total=0;   log_streams=$(aws logs describe-log-streams --log-group-name "$log_group" --query 'logStreams[].logStreamName' --output text);   count=$(aws logs filter-log-events --log-group-name "$log_group" --log-stream-names $log_streams --filter-pattern "GET health" --query 'events | length(@)' --output text);   echo $count; done

echo -e "${COLORL}----- 8-1-A -----${COLORRE}"
aws elbv2 describe-load-balancers --names ws25-hub-nlb --query "LoadBalancers[0].[Type, Scheme]" --output text | tr '\t' '\n' && aws elbv2 describe-listeners --load-balancer-arn $(aws elbv2 describe-load-balancers --names ws25-hub-nlb --query "LoadBalancers[0].LoadBalancerArn" --output text) --query "Listeners[].Port" --output text && aws elbv2 describe-target-groups --load-balancer-arn $(aws elbv2 describe-load-balancers --names ws25-hub-nlb --query "LoadBalancers[0].LoadBalancerArn" --output text) --query "TargetGroups[].{TargetGroupName:TargetGroupName, Protocol:Protocol, TargetType:TargetType}" --output text | tr '\t' '\n'
echo ""

echo -e "${COLORL}----- 8-1-B -----${COLORRE}"
aws elbv2 describe-load-balancers --names ws25-app-nlb --query "LoadBalancers[0].AvailabilityZones[]" --output text | tr '\t' '\n' && for zone in $(aws elbv2 describe-load-balancers --names ws25-app-nlb --query "LoadBalancers[0].AvailabilityZones[].ZoneName" --output text); do ip_address=$(aws elbv2 describe-load-balancers --names ws25-app-nlb --query "LoadBalancers[0].AvailabilityZones[?ZoneName=='${zone}'].LoadBalancerAddresses[].IpAddress" --output text); echo "$zone $ip_address"; done && aws elbv2 describe-target-groups --load-balancer-arn $(aws elbv2 describe-load-balancers --names ws25-app-nlb --query "LoadBalancers[0].LoadBalancerArn" --output text) --query "TargetGroups[].{TargetGroupName:TargetGroupName, Protocol:Protocol, TargetType:TargetType}" --output text

echo ""

echo -e "${COLORL}----- 8-1-C -----${COLORRE}"
aws elbv2 describe-load-balancers --names ws25-app-alb --query "LoadBalancers[0].[Type,Scheme]" --output text | tr '\t' '\n'; aws elbv2 describe-listeners --load-balancer-arn $(aws elbv2 describe-load-balancers --names ws25-app-alb --query "LoadBalancers[0].LoadBalancerArn" --output text) --query "Listeners[0].Protocol" --output text

echo ""

echo -e "${COLORL}----- 8-2-A -----${COLORRE}"
aws elbv2 describe-target-health --target-group-arn $(aws elbv2 describe-target-groups --names ws25-hub-nlb-tg --query "TargetGroups[0].TargetGroupArn" --output text) --query "TargetHealthDescriptions[].Target.Id" --output text | tr '\t' '\n'; aws elbv2 describe-target-health --target-group-arn $(aws elbv2 describe-target-groups --names ws25-hub-nlb-tg --query "TargetGroups[0].TargetGroupArn" --output text) --query "TargetHealthDescriptions[].TargetHealth.State" --output text

echo ""
echo -e "${COLORL}----- 8-2-B -----${COLORRE}"
aws elbv2 describe-target-health --target-group-arn $(aws elbv2 describe-target-groups --names ws25-app-nlb-tg --query "TargetGroups[0].TargetGroupArn" --output text) --query "TargetHealthDescriptions[].TargetHealth.State" --output text | tr '\t' '\n'

echo ""
echo -e "${COLORL}----- 8-2-C -----${COLORRE}"
aws elbv2 describe-load-balancers --names ws25-app-alb --query "LoadBalancers[0].LoadBalancerArn" --output text | xargs -I {} aws elbv2 describe-target-groups --load-balancer-arn {} --query "TargetGroups[].TargetGroupArn" --output text | tr '\t' '\n' | xargs -I {} aws elbv2 describe-target-health --target-group-arn {} --query "TargetHealthDescriptions[?TargetHealth.State=='healthy'].Target.Id" --output text | wc -w

echo ""

echo -e "${COLORL}----- 8-3 -----${COLORRE}"
echo -e "${COLORG}[!] 수동 채점으로 진행됩니다. ${COLORRE}"

echo ""

echo -e "${COLORL}----- 9 -----${COLORRE}"
echo -e "${COLORG}[!] 수동 채점으로 진행됩니다. ${COLORRE}"

echo ""

echo -e "${COLORL}----- 10 -----${COLORRE}"
echo -e "${COLORG}[!] 수동 채점으로 진행됩니다. ${COLORRE}"
echo ""
echo -e "${COLORL}----- 11-1-A -----${COLORRE}"
for deployment_group in $(aws deploy list-deployment-groups --application-name ws25-cd-green-app --query 'deploymentGroups' --output text); do echo "Deployment Group: $deployment_group"; aws deploy get-deployment-group --application-name ws25-cd-green-app --deployment-group-name "$deployment_group" --query 'deploymentGroupInfo.ecsServices' --output json; done

echo ""
echo -e "${COLORL}----- 11-2-A -----${COLORRE}"
for deployment_group in $(aws deploy list-deployment-groups --application-name ws25-cd-red-app --query 'deploymentGroups' --output text); do echo "Deployment Group: $deployment_group"; aws deploy get-deployment-group --application-name ws25-cd-red-app --deployment-group-name "$deployment_group" --query 'deploymentGroupInfo.ecsServices' --output json; done

echo ""
echo -e "${COLORL}----- 11-3-A -----${COLORRE}"
S3_BUCKET=$(aws codepipeline get-pipeline --name ws25-cd-green-pipeline --query 'pipeline.stages[?name==`Source`].actions[0].configuration.S3Bucket' --output text); \
DEPLOY_GROUP=$(aws codepipeline get-pipeline --name ws25-cd-green-pipeline --query 'pipeline.stages[?name==`Deploy`].actions[0].configuration.DeploymentGroupName' --output text); \
echo "S3 Bucket: $S3_BUCKET"; echo "Deploy Group: $DEPLOY_GROUP"

echo ""

echo -e "${COLORL}----- 11-4-A -----${COLORRE}"
S3_BUCKET=$(aws codepipeline get-pipeline --name ws25-cd-red-pipeline --query 'pipeline.stages[?name==`Source`].actions[0].configuration.S3Bucket' --output text); \
DEPLOY_GROUP=$(aws codepipeline get-pipeline --name ws25-cd-red-pipeline --query 'pipeline.stages[?name==`Deploy`].actions[0].configuration.DeploymentGroupName' --output text); \
echo "S3 Bucket: $S3_BUCKET"; echo "Deploy Group: $DEPLOY_GROUP"

echo ""
echo -e "${COLORL}----- 11-5-A -----${COLORRE}"
echo -e "green.sh: $( [ -f /home/ec2-user/pipeline/green.sh ] && echo True || echo False )\nred.sh: $( [ -f /home/ec2-user/pipeline/red.sh ] && echo True || echo False )\nartifact dir: $( [ -d /home/ec2-user/pipeline/artifact ] && echo True || echo False )\ngreen dir: $( [ -d /home/ec2-user/pipeline/artifact/green ] && echo True || echo False )\nred dir: $( [ -d /home/ec2-user/pipeline/artifact/red ] && echo True || echo False )\ngreen files: $( [ $(ls /home/ec2-user/pipeline/artifact/green | wc -l) -ge 1 ] && echo True || echo False )\nred files: $( [ $(ls /home/ec2-user/pipeline/artifact/red | wc -l) -ge 1 ] && echo True || echo False )"
echo ""

echo -e "${COLORL}----- 11-6 -----${COLORRE}"
echo -e "${COLORG}[!] 수동 채점으로 진행됩니다. ${COLORRE}"
echo ""


echo -e "${COLORL}----- 11-7 -----${COLORRE}"
echo -e "${COLORG}[!] 수동 채점으로 진행됩니다. ${COLORRE}"
echo ""