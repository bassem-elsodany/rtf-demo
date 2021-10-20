##[1] execute to prepare the env
export CLUSTER_NAME=rtf-cluster-demo
export AWS_DEFAULT_REGION=eu-west-2
export AWS_DEFAULT_PROFILE=development

rm ~/.kube/config
---------------------------------------------------------------------------------------------------------
##[2] execute to create the cluster
terraform init
terraform plan
terraform apply

##[to generate cluster config]
aws eks update-kubeconfig --name $CLUSTER_NAME
---------------------------------------------------------------------------------------------------------
##[3] install metrics server for HPA cabability

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install metrics-server metrics-server/metrics-server
---------------------------------------------------------------------------------------------------------
##[4] install fluentd log forwarder

envsubst < raw-manifests/fluentd.yml | kubectl apply -f -
---------------------------------------------------------------------------------------------------------
##[5] install nginx ingress controller

##NGINX Controller documentation
https://kubernetes.github.io/ingress-nginx/deploy/#aws

##INSTALL 
kubectl apply -f raw-manifests/deploy-tls-termination.yml 
---------------------------------------------------------------------------------------------------------
##[6] install rtf
##Create runtime fabric from anypoint and get the activiation code 
 
##execute to validate
./rtfctl validate YW55cG9pbnQubXVsZXNvZnQuY29tOjYyY2IyMjg1LTU2ZmQtNDdjOS05ZmE3LWJiM2IyOTVhMzBkMA==

##execute to install
./rtfctl install YW55cG9pbnQubXVsZXNvZnQuY29tOjYyY2IyMjg1LTU2ZmQtNDdjOS05ZmE3LWJiM2IyOTVhMzBkMA== --force-reinstall
---------------------------------------------------------------------------------------------------------
##[7] install mule license
./rtfctl apply mule-license 2+W35iUhD9msCdlzEtfyT/TPizhZF+QuSjv5DwIgxWwv+WX58k2jllOVjTfbInthDyjZ+jnMgLzFViyXoUuY+JSuD8KDYPSN3mRxw5/JZqtP8nxguK5YnSCAgwbWIcPAITNrec9DOA36g+dtvVZdMiP0TYB25kOI3yQNqE7KH76oFWSoqIkblqoATLiCKDZlJiF/IsJJqOvP0CbIQD9LdpM/hEboJVqgEF79DM7f52FYBytBBxsQjFkbWnYE3+Edkh5mtwJBQ+9vyK81eQBwkwgtf5OxYXfF8GLNp+xVoqp0y9z11k7kZcd4DPFS1XIpYn4G9/s9nMtn9mk5O/8FDdBG2Gw0MlrJwAjowAWab4oftCYLZe2bXC98DcQvugQ8zOzKQQjAMEN7LlUyLhZ2berRJ6uHVvT8TcYphryId31NJi6r9bh7uoKAKJupaw35FWcflCrpsj7/LgnUS73iN3zjSYLQAZJphrJqytPp1qyc1tBhIprEuq0r7Vph8g+iMcYcJF3IeYcBEUCuOal4joQPBqNtEc3JiI0OcOKCRw63hYRHeybqJr1/xjZB0peGH2mpcHSE5vMCaUDgnwisE1Z9eB7w6GK7Kg6tpqZN2SswdYQz2+i2HtO+grVCa8T01w1QU57sYEWTWsSjBgukeGd5l8Ihwq4T1T3ggTAsAfWLi5UVTN1lsITPNR8/vgewFjqKhiFdrWwY015JbXUcxpLTIC2aYfshR8DQ0BkwG1pWTnOdorWhp7sh1d4KWjCdoQbmb8vSiSFfF66J7HwWBn+3I7PIQ7kSkcQt93fOCvNDHQjBXHhkbifAxzWBdSDH09TUM7mp52Q4J1cqSzuoDg==
---------------------------------------------------------------------------------------------------------
deploy APP
set the followings as app env

##anypoint.platform.api_id 
##anypoint.platform.client_id 
##anypoint.platform.client_secret 
---------------------------------------------------------------------------------------------------------
##[8] Ingress resource
kubectl apply -f raw-manifests/rtf-nginx/nginx-ingress.yml 

set default ns
export RTF_DEFAULT_NS=a7c90494-197b-4ff9-8e55-5ebc136acd35
kubectl config set-context --current --namespace=$RTF_DEFAULT_NS

to batch ingress
kubectl patch ingress hello-rtf-rtf-ingress  -p '{"metadata":{"annotations":{"nginx.ingress.kubernetes.io/limit-rpm":"1000"}}}'

kubectl get ing -n rtf -oyaml
kubectl get ing -oyaml
---------------------------------------------------------------------------------------------------------
##[9] Usesful commands

check rs 
kubectl get rs

cehck all
kubectl get all

---------------------------------------------------------------------------------------------------------
##[10] HPA

export RTF_APP_NAME=hello-rtf

##deploy HPA
envsubst < raw-manifests/hpa.yml | kubectl apply -f -


##scaledown
kubectl scale --replicas=1 deployment hello-rtf

kubectl describe hpa
kubectl get hpa
kubectl top pods --containers

kubectl top pod hello-rtf-c6f4fb77-qlb5q --containers

kubectl get pods -l app=hello-rtf -o wide --watch

kubectl autoscale deployment hello-rtf --cpu-percent=70 --min=1 --max=5

---------------------------------------------------------------------------------------------------------
Uninstall

##RTF
./rtfctl uninstall --confirm

##ingress controller
kubectl delete namespace ingress-nginx

terraform destroy

