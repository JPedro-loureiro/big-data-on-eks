resource "aws_ecr_repository" "kafka_connect" {
  name                 = "big-data-on-eks/kafka-connect"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "airflow" {
  name                 = "big-data-on-eks/airflow"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# It should be excluded after CI/CD pipeline implementation
resource "null_resource" "build_airflow_image" {
  provisioner "local-exec" {
    command = "apps/airflow/images/docker_build.sh"
  }
  depends_on = [ aws_ecr_repository.airflow ]
}

# resource "aws_ecr_repository" "ranger_admin" {
#   name                 = "big-data-on-eks/ranger_admin"
#   image_tag_mutability = "MUTABLE"
#   force_delete         = true
# }

# # It should be excluded after CI/CD pipeline implementation
# resource "null_resource" "build_ranger_image" {
#   provisioner "local-exec" {
#     command = "apps/ranger/images/ranger_admin_docker_build.sh"
#   }
#   depends_on = [ aws_ecr_repository.ranger_admin ]
# }

# resource "aws_ecr_repository" "ranger_usersync" {
#   name                 = "big-data-on-eks/ranger_usersync"
#   image_tag_mutability = "MUTABLE"
#   force_delete         = true
# }

# # It should be excluded after CI/CD pipeline implementation
# resource "null_resource" "build_ranger_image" {
#   provisioner "local-exec" {
#     command = "apps/ranger/images/ranger_usersync_docker_build.sh"
#   }
#   depends_on = [ aws_ecr_repository.ranger_usersync ]
# }