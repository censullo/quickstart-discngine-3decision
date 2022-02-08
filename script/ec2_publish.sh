regions=(us-east-1 us-east-2 us-west-1 us-west-2 ap-south-1 ap-northeast-3 ap-northeast-2 ap-southeast-1 ap-southeast-2 ap-northeast-1 ca-central-1 eu-west-1 eu-west-2 eu-west-3 eu-north-1 sa-east-1)
volumes=(collection,snap-064065f29ff3d074a choral,snap-089f9b15de542ee74 data3dec,snap-0864d7a064ccaff25)
control='create'
IFS=","

if [ $control = 'create' ]
then
    for region in "${regions[@]}"
    do
        for volume in "${volumes[@]}"
        do
            set -- $volume
            echo "copying volume $1 with id $2 in region $region"
            id=`aws ec2 copy-snapshot --description "$1 snap" --source-region eu-central-1 --source-snapshot-id $2 --region $region | grep SnapshotId | cut -c20-41`
            echo $id
            aws ec2 modify-snapshot-attribute --snapshot-id $id --attribute createVolumePermission --operation-type add --group-names all --region $region
        done
    done
elif [ $control = 'delete' ]
then
    for region in "${regions[@]}"
    do
        for volume in "${volumes[@]}"
        do
            if [ $region = 'eu-central-1' ]
            then
                echo "DO NOT DELETE IN EU-CENTRAL-1"
            else
                set -- $volume
                echo "deleting in region $region"
                id=`aws ec2 describe-snapshots --filters "Name=description,Values=$1 snap" --region $region | grep SnapshotId | cut -c28-49`
                aws ec2 delete-snapshot --snapshot-id $id --region $region
            fi
        done
    done
else
    echo "control is neither create nor delete"
fi