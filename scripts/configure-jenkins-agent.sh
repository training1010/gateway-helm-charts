#!/bin/sh

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)   

    case "$KEY" in
            jsonfilename)        jsonfilename=${VALUE} ;;
            project)             project=${VALUE} ;;
            cluster)             cluster=${VALUE} ;;
            region)              region=${VALUE} ;;
            service_account)     service_account=${VALUE} ;;
            gcloud_file)         gcloud_file=${VALUE} ;;
            cicd_release_name)   cicd_release_name=${VALUE} ;;
            *)   
    esac    
done
echo https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$gcloud_file
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$gcloud_file

tar zxvf $gcloud_file google-cloud-sdk
./google-cloud-sdk/install.sh --usage-reporting false --path-update true --command-completion true --rc-path /root/.bashrc --additional-components kubectl beta
PATH=$PATH:/google-cloud-sdk/bin
gcloud auth activate-service-account $service_account --key-file=$jsonfilename --project=$project
gcloud beta container clusters get-credentials $cluster --region $region --project $project
mv ./google-cloud-sdk/bin/kubectl /usr/local/bin/kubectl