resource "aws_ecs_cluster" "main" {
  name = "zaywal-ecs-cluster"
}

resource "aws_ecs_task_definition" "db" {
  network_mode              = "awsvpc"
  family                    = "zaywaldb"
  requires_compatibilities  = [ "FARGATE" ]
  cpu                       = "256"
  memory                    = "512"
  execution_role_arn        = "arn:aws:iam::180127513132:role/ecsTaskExecutionRole"
  container_definitions     =<<DEFINITION
[
  {
    "name": "mongodb-containerr",
    "image": "mongo:5.0.2",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 27017,
        "hostPort": 27017
      }
    ],
    "environment": [
     {
       "name": "MONGO_INIT_ROOT_USERNAME",
       "value": "${var.mongo_root_username}"
     },
     {
       "name": "MONGO_INIT_ROOT_PASSWORD",
       "value": "${var.mongo_root_password}"
     }
    ],
    "logConfiguration": {
     "logDriver": "awslogs",
     "options": {
      "awslogs-group": "/ecs/db",
      "awslogs-region": "ap-southeast-1",
      "awslogs-stream-prefix": "ecs"
      }
    }
 }
]
DEFINITION
}

resource "aws_ecs_task_definition" "api" {
  network_mode              = "awsvpc"
  family                    = "zaywal-api"
  requires_compatibilities  = [ "FARGATE" ]
  cpu                       = "256"
  memory                    = "512"
  execution_role_arn        = "arn:aws:iam::180127513132:role/ecsTaskExecutionRole"
  container_definitions     = <<DEFINITION
[
  {
    "name": "api-server-container",
    "image": "180127513132.dkr.ecr.ap-southeast-1.amazonaws.com/api-server:f5159522505d00d59bf5d8a463676b3614bda2e8",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 4000,
        "hostPort": 4000
      }
    ],
    "environment": [
      {
        "name": "DB_HOST",
        "value": "${var.db_host}"
      },
      {
        "name": "DB_NAME",
        "value": "${var.db_name}"
      },
      {
        "name": "DB_PASS",
        "value": "${var.db_pass}"
      },
      {
        "name": "DB_PORT",
        "value": "${var.db_port}"
      },
      {
        "name": "DB_USER",
        "value": "${var.db_user}"
      },
      {
        "name": "HOST_NAME",
        "value": "${var.api_server_hostname}"
      }
      
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/api",
        "awslogs-region": "ap-southeast-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "admin" {
  network_mode              = "awsvpc"
  family                    = "zaywal-admin-panel"
  requires_compatibilities  = [ "FARGATE" ]
  cpu                       = "256"
  memory                    = "512"
  execution_role_arn        = "arn:aws:iam::180127513132:role/ecsTaskExecutionRole"
  container_definitions     = <<DEFINITION
[
  {
    "name": "admin-panel-container",
    "image": "180127513132.dkr.ecr.ap-southeast-1.amazonaws.com/zaywal-admin-panel:f5159522505d00d59bf5d8a463676b3614bda2e8",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "logConfiguration": {
     "logDriver": "awslogs",
     "options": {
      "awslogs-group": "/ecs/admin",
      "awslogs-region": "ap-southeast-1",
      "awslogs-stream-prefix": "ecs"
      }
    }
 }
]
DEFINITION
}