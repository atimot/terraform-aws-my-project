resource "aws_codebuild_project" "example" {
  name = "example"
  service_role = var.service_role_arn

  source {
    type = "CODEPIPELINE"
  }
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/ubuntu-base:14.04"
    privileged_mode = true
  }
}