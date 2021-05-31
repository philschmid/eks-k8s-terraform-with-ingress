# Create a AWS EKS Cluster with ALB Ingress using Terraform

## Resources

* [outdated blog post with example](https://learnk8s.io/terraform-eks)
* [Github Terraform Module for eks](https://github.com/terraform-aws-modules/terraform-aws-eks)
* [AWS Documentation for ALB Ingress](https://docs.aws.amazon.com/de_de/eks/latest/userguide/alb-ingress.html)
* [Helm Chart for ALB Ingress](https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller)
* [AWS ALB Ingress Service - Enable SSL](https://www.stacksimplify.com/aws-eks/aws-alb-ingress/learn-to-enable-ssl-on-alb-ingress-service-in-kubernetes-on-aws-eks/)
* [AWS ALB Documentation](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
* [AWS Managed node groups + auto-scaling](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)
* [Cetrificate Discovery for SSL](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/ingress/cert_discovery/)
* [AWS ALB Ingress annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/ingress/annotations/)
* [CLI: Transformers default Kuberentes yaml to terraform](https://github.com/sl1pm4t/k2tf)
* [CLI: Transformers K8s CRD to Terraform -> kuberetnes > 2.0](https://github.com/jrhouston/tfk8s)
* [Pre-build aws eks module](https://github.com/Young-ook/terraform-aws-eks/tree/1.4.9/modules)

## Create infrastucture

0. installs

* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Helm](https://helm.sh/docs/intro/install/)

1. create service
```bash
terraform apply -var-file="var.tfvars"
```

3. display nodes
```bash
KUBECONFIG=./kubeconfig_{cluser_name} kubectl get nodes --all-namespaces
```
should display
```
NAME                                         STATUS   ROLES    AGE   VERSION
ip-172-16-2-206.eu-west-1.compute.internal   Ready    <none>   10m   v1.20.4-eks-6b7464
```

To not prefix the `KUBECONFIG` environment variable to every command, you can export it with:
```bash
export KUBECONFIG="${PWD}/kubeconfig_infinity-k8s"
```

4. deploy application
```bash
kubectl apply -f app/deployment.yaml
```


5. deploy ALB ingress
```bash
kubectl apply -f app/ingress.yaml
```


6. Get DNS of ALB
```bash
kubectl describe ingress hello-kubernetes 
```

7. Request

