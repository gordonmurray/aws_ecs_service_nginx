packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1.0.10"
    }
    amazon-ecr = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.2"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

source "docker" "nginx" {
  image  = "nginx:latest"
  commit = true # Commit the image to the local Docker daemon
}

build {
  name = "nginx"
  sources = [
    "source.docker.nginx" # Use the Docker source defined above
  ]

  provisioner "shell" {
    inline = [
     "echo 'Nginx image built using Packer'",
      "sed -i 's/access_log\\ \\/var\\/log\\/nginx\\/access.log;/access_log\\ \\/dev\\/stdout;/g' /etc/nginx/nginx.conf",
      "sed -i 's/error_log\\ \\/var\\/log\\/nginx\\/error.log;/error_log\\ \\/dev\\/stderr;/g' /etc/nginx/nginx.conf"
    ]
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "000000000.dkr.ecr.us-east-1.amazonaws.com/ecr-repository"
      tags       = ["nginx"]
    }

    post-processor "docker-push" {
      ecr_login    = true
      aws_profile  = "voyager"
      login_server = "https://000000000.dkr.ecr.us-east-1.amazonaws.com/"
    }
  }

}
