#!/bin/sh

service_account=''
cicd_release_name=''
license_path=''
gcloud_file='google-cloud-sdk-226.0.0-linux-x86_64.tar.gz'

echo "Usage: jenkins-setup.sh -s service_account -c cicd_release_name -h license_path [-f gcloud_file]"

while getopts 's:c:h:f:' opt; do
  case "${opt}" in
    s ) service_account=${OPTARG} ;;
    c ) cicd_release_name=${OPTARG} ;;
    h ) license_path=${OPTARG} ;;
    f ) gcloud_file=${OPTARG} ;;
  esac
done

if test -z "${service_account}"
then
	echo "A service_account must be specified"
	exit 1
fi

if test -z "${cicd_release_name}"
then
	echo "A cicd_release_name must be specified"
	exit 1
fi

if test -z "${license_path}"
then
	echo "A license_path must be specified"
	exit 1
fi

pod="$(kubectl get pods | grep ${cicd_release_name}-jenkins | awk '{print $1}')"
project="$(kubectl config current-context | cut -d "_" -f 2)"
region="$(kubectl config current-context | cut -d "_" -f 3)"
cluster="$(kubectl config current-context | cut -d "_" -f 4)"

gcloud iam service-accounts keys create ./jenkins.json --iam-account $service_account --project $project
kubectl cp jenkins.json $pod:/jenkins.json
kubectl cp configure-jenkins-agent.sh $pod:/configure-jenkins-agent.sh
kubectl cp "$license_path" "$pod":/var/jenkins_home/license.xml
kubectl exec -it $pod  -- /bin/sh -c "chmod u+x configure-jenkins-agent.sh"
kubectl exec -it $pod "/configure-jenkins-agent.sh" jsonfilename="jenkins.json" service_account=$service_account project=$project region=$region cluster=$cluster gcloud_file=$gcloud_file cicd_release_name=$cicd_release_name
rm jenkins.json
echo "---FINISHED---"
