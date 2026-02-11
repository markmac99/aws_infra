$instdetails=(aws ec2 describe-instances --filters Name="tag:Name",Values="testserver" --profile default)
$instanceid= (Write-Output $instdetails| convertfrom-json)[0].reservations.instances.instanceid
aws ec2 create-image --instance-id $instanceid --name "WMPL Testing" --description "Latest WMPL testing image" --profile default