$instdetails=(aws ec2 describe-instances --filters Name="tag:Name",Values="testserver" --profile default)
$instanceid= (Write-Output $instdetails| convertfrom-json)[0].reservations.instances.instanceid
aws ec2 stop-instances --instance-id $instanceid --profile default