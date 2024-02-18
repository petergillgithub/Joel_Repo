resource "aws_eks_cluster" "main" {
    name = "Peter_Cluster"
    role_arn = aws_iam_role.cluster_role.arn

    vpc_config {
      subnet_ids = flatten([aws_subnet.publicsubnets[*].id , aws_subnet.privatesubnets[*].id])
      endpoint_private_access = true 
      endpoint_public_access = true
      public_access_cidrs = ["0.0.0.0/0"]
    }
    tags = merge(var.command_tags,{
        "Name" = "Peter_Cluster"
    }    )

    depends_on = [ aws_iam_role_policy_attachment.cluster_role_attachment ]
  
}

resource "aws_iam_role" "cluster_role" {
    name = "cluster_role"
    assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
    tags = merge(var.command_tags,{
        "Name" = "ClusterRole"
    })
  
}

resource "aws_iam_role_policy_attachment" "cluster_role_attachment" {
    role = aws_iam_role.cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" 
}

resource "aws_eks_node_group" "eks_worker_nodegroup" {
    cluster_name = aws_eks_cluster.main.name
    node_group_name = "WorkerNode"
    node_role_arn = aws_iam_role.worker_role.arn
    subnet_ids = aws_subnet.privatesubnets[*].id

    scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  update_config {
    max_unavailable = 1
  }
   ami_type       = "AL2_x86_64"
  disk_size      = 20
  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.medium"]

  depends_on = [ aws_iam_role_policy_attachment.worker_role_attachment ]
  
}

resource "aws_iam_role" "worker_role" {
    name = "workernodegroup"
    assume_role_policy = data.aws_iam_policy_document.worker_assume_role.json
  
}

resource "aws_iam_role_policy_attachment" "worker_role_attachment" {
    role = aws_iam_role.worker_role.name
    for_each = var.eks_node_policies
    policy_arn = each.value


  
}
