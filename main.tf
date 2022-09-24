# vpc 
module "vpc" {
  source = "./modules/vpc"
}

# alb security group 
module "http_sg" {
  source = "./modules/security_group"
  name = "http-sg"
  vpc_id = module.vpc.vpc_id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source = "./modules/security_group"
  name = "https-sg"
  vpc_id = module.vpc.vpc_id
  port = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source = "./modules/security_group"
  name = "http-redirect-sg"
  vpc_id = module.vpc.vpc_id
  port = 8080
  cidr_blocks = ["0.0.0.0/0"]
}

# alb
module "alb" {
  source = "./modules/alb"
  subnets = [
    module.vpc.public_subnet_0_id,
    module.vpc.public_subnet_1_id,
  ]
  security_groups = [
    module.http_sg.security_group_id, 
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
  certificate_arn = module.acm.certificate_arn
  vpc_id = module.vpc.vpc_id
}

# route53
module "route53" {
  source = "./modules/route53"
  domain_name = "practice-domain.link"
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
}

# acm
module "acm" {
  source = "./modules/acm"
  domain_name = module.route53.domain_name
  route53_zone_id = module.route53.zone_id
}

# ecs tasks security groups
module "nginx_sg" {
  source = "./modules/security_group"
  name = "nginx-sg"
  vpc_id = module.vpc.vpc_id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}

# ecs
module "ecs" {
  source = "./modules/ecs"
  service_security_groups = [
    module.nginx_sg.security_group_id,
  ]
  subnets = [
    module.vpc.public_subnet_0_id,
    module.vpc.public_subnet_1_id,
  ]
  target_group_arn = module.alb.target_group_arn
  task_execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

# ecs log group
resource "aws_cloudwatch_log_group" "for_ecs" {
  name = "/ecs/example"
  retention_in_days = 3
}

# ecs task execution role 
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy]

  statement {
    effect = "Allow"
    actions = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source = "./modules/iam_role"
  name = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy = data.aws_iam_policy_document.ecs_task_execution.json
}

# kms
module "kms" {
  source = "./modules/kms"
}

# ecr
module "ecr" {
  source = "./modules/ecr"
}

# codebuild iam role
data "aws_iam_policy_document" "codebuild" {
  statement {
    effect = "Allow"
    resources = ["*"]

    actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "codestar-connections:UseConnection",
    ]
  }
}

module "codebuild_role" {
  source = "./modules/iam_role"
  name = "codebuild"
  identifier = "codebuild.amazonaws.com"
  policy = data.aws_iam_policy_document.codebuild.json
}

# code build
module "codebuild" {
  source = "./modules/codebuild"
  service_role_arn = module.codebuild_role.iam_role_arn
}

# code pipeline iam role
data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect = "Allow"
    resources = ["*"]

    actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "ecs:DescribeServices",
        "ecs:DescribeTaskDefinition",
        "ecs:DescribeTasks",
        "ecs:ListTasks",
        "ecs:RegisterTaskDefinition",
        "ecs:UpdateService",
        "iam:PassRole",
        "codestar-connections:UseConnection"
    ]
  }
}

module "codepipeline_role" {
  source = "./modules/iam_role"
  name = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy = data.aws_iam_policy_document.codepipeline.json
}

module "codepipeline" {
  source = "./modules/codepipeline"
  codepipeline_role_arn = module.codepipeline_role.iam_role_arn
  codebuild_project_id = module.codebuild.codebuild_project_id
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
}
