regions=(us-east-1 us-east-2 us-west-1 us-west-2 ap-south-1 ap-northeast-3 ap-northeast-2 ap-southeast-1 ap-southeast-2 ap-northeast-1 ca-central-1 eu-west-1 eu-west-2 eu-west-3 eu-north-1 sa-east-1)
created=true

if [ $created != true ]
then
    for region in "${regions[@]}"
    do
        echo "copying in region $region"
        aws rds copy-db-snapshot --source-db-snapshot-identifier arn:aws:rds:eu-central-1:751149478800:snapshot:dng3decpd01 --target-db-snapshot-identifier dng3decpd01 --region $region
    done
fi
for region in "${regions[@]}"
do
    echo "waiting in region $region"
    aws rds wait db-snapshot-available --db-snapshot-identifier dng3decpd01 --region $region
    aws rds modify-db-snapshot-attribute --db-snapshot-identifier dng3decpd01 --attribute-name restore --values-to-add all --region $region
done