# Apache Tomcat on AWS EKS with Jenkins CI/CD

A Tomcat app packaged with Docker, built and deployed by a Jenkins pipeline to Amazon EKS,
with infrastructure created by Terraform and public access through an Application Load Balancer (ALB)
and a Route 53 DNS record.

## Architecture

    GitHub push -> Jenkins -> Docker build -> Docker Hub -> kubectl -> EKS (rolling update)
                                                                         |
    Browser -> Route 53 (your domain) -> ALB (from Ingress) -> Service -> Tomcat pods

## What you will learn
- Terraform: VPC + EKS from modules
- Docker: packaging a Java web app
- Kubernetes: Deployment, Service, Ingress, rolling updates, readiness probes
- Jenkins: a declarative pipeline with credentials
- AWS: ALB via the Load Balancer Controller, DNS with Route 53

## Prerequisites
AWS account and CLI configured, Terraform, kubectl, Helm, Docker, a Docker Hub account,
a Jenkins server with Docker, AWS CLI and kubectl installed.

## Steps

### 1. Test the image locally
    docker build -t tomcat-app .
    docker run -p 8080:8080 tomcat-app
Open http://localhost:8080

### 2. Create the cluster (costs money, see below)
    cd terraform
    terraform init
    terraform plan
    terraform apply
    aws eks update-kubeconfig --region ap-south-1 --name tomcat-eks
    kubectl get nodes

### 3. Install the AWS Load Balancer Controller
Follow the current official AWS guide ("Route internet traffic with AWS Load Balancer Controller" in the EKS docs).
In short: create the IAM policy, create an IAM role for the controller's service account, then
`helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=tomcat-eks ...`

### 4. Deploy by hand once (to understand what Jenkins automates)
Edit the image name in `k8s/deployment.yaml`, then:
    kubectl apply -f k8s/
    kubectl get pods
    kubectl get ingress        # wait for an ADDRESS (the ALB DNS name)

### 5. Point your domain at the ALB (Route 53)
Create a hosted zone for your domain, then add an **A record (Alias)** pointing to the ALB.
Open your domain in a browser to confirm.

### 6. Automate with Jenkins
1. Add credentials: `dockerhub-creds` (username + password/token).
2. New Item -> Pipeline -> "Pipeline script from SCM" -> your repo URL.
3. In GitHub: Settings -> Webhooks -> payload URL `http://<jenkins-ip>:8080/github-webhook/`.
4. Push a change to `app/ROOT/index.jsp` and watch the pipeline roll out the new version.

## Cost warning and cleanup
EKS control plane, worker nodes and the NAT gateway all bill by the hour (roughly a few dollars per day).
Do this in one sitting, then clean up:
    kubectl delete -f k8s/          # removes the ALB first
    cd terraform && terraform destroy
Also delete the Route 53 hosted zone/records if you no longer need them.

## Security notes
Never commit AWS keys, `*.tfstate` or `*.tfvars` (they are in `.gitignore`).
