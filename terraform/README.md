
-Usage-

Update provider.tf with a valid s3 bucket for the statefile.
Follow the instructions here to create a default profile with your AWS credentials:
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html.
Run terraform init, plan, and apply.

Access through kubectl with the following command:
aws eks update-kubeconfig --name terraform-eks-demo