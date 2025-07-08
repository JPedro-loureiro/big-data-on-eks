aws ecr get-login-password --region us-east-1 --profile iamadmin-general | docker login --username AWS --password-stdin 590183863248.dkr.ecr.us-east-1.amazonaws.com
docker build -t big-data-on-eks/airflow ./apps/airflow/images
docker tag big-data-on-eks/airflow:latest 590183863248.dkr.ecr.us-east-1.amazonaws.com/big-data-on-eks/airflow:latest
docker push 590183863248.dkr.ecr.us-east-1.amazonaws.com/big-data-on-eks/airflow:latest