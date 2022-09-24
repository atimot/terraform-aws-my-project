# artifact S3
resource "aws_s3_bucket" "artifact" {
  bucket = "artifact-pragmatic-terraform-on-aws-pf-tomita"
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "artifact" {
  bucket = aws_s3_bucket.artifact.id

  rule {
    id = "artifact"
    expiration {
      days = 180
    }

    status = "Enabled"
  }
}

# codestarconnections
resource "aws_codestarconnections_connection" "example" {
  name = "github-connection"
  provider_type = "GitHub"
}

# codepipeline
resource "aws_codepipeline" "example" {
  name = "example"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = aws_s3_bucket.artifact.id
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeStarSourceConnection"
      version = 1
      output_artifacts = ["Source"]

      configuration = {
        ConnectionArn = aws_codestarconnections_connection.example.arn
        FullRepositoryId = "atimot/terraform-aws-my-project"
        BranchName = "master"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = 1
      input_artifacts = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = var.codebuild_project_id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "ECS"
      version = 1
      input_artifacts = ["Build"]

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName = "imagedefinitions.json"
      }
    }
  }
}

# codepipeline webhook
resource "aws_codepipeline_webhook" "example" {
  name = "example"
  target_pipeline = aws_codepipeline.example.name
  target_action = "Source"
  authentication = "GITHUB_HMAC"

  authentication_configuration {
    secret_token = "VeryRandomStringMoreThan20Byte!"
  }

  filter {
    json_path = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

# github repository webhook
resource "github_repository_webhook" "example" {
  repository = "terraform"

  configuration {
    url = aws_codepipeline_webhook.example.url
    secret = "VeryRandomStringMoreThan20Byte!"
    content_type = "json"
    insecure_ssl = false
  }

  events = ["push"]
}