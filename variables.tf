variable "vpc-cidr" {
    type = string
    default = "192.168.0.0/16"
  
}

variable "command_tags" {
    type = map(string)
    default = {
      "ENV" = "Dev"
      "Team" = "Terraform"
    }
  
}


variable "public_subnets" {
    type = list(string)
    default = [ "192.168.0.0/19","192.168.32.0/19" ]
}

variable "private_subnets" {
    type = list(string)
    default = [ "192.168.64.0/18","192.168.128.0/17" ]
}

variable "eks_node_policies" {
  type = set(string)
  default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}
