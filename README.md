# SageMaker MLOps Pipeline for Abalone Age Prediction

This project implements an end-to-end MLOps pipeline for training, evaluating and deploying an XGBoost model to predict the age of abalone based on physical measurements. The pipeline automates the entire machine learning lifecycle from data preprocessing to model deployment using AWS SageMaker, Step Functions, and CDK infrastructure as code.

The solution provides two data ingestion patterns - direct S3 access and AWS Glue Data Catalog integration. It implements CI/CD using GitHub Actions for automated model training and deployment with proper security controls and monitoring. The pipeline includes data preprocessing, model training, evaluation, and conditional model registration based on quality metrics.

## Repository Structure
```
.
├── model_build/                    # Model training pipeline implementation
│   ├── ml_pipelines/              # Core SageMaker pipeline definition
│   │   ├── training/              # Training pipeline implementation
│   │   └── data/                  # Data upload utilities
│   └── source_scripts/            # Individual pipeline step implementations
│       ├── preprocessing/         # Data preprocessing scripts
│       ├── training/             # Model training scripts  
│       └── evaluate/             # Model evaluation scripts
├── model_deploy/                  # Model deployment infrastructure
│   ├── deploy_endpoint/          # Endpoint deployment CDK stack
│   ├── lambda/                   # Lambda functions for deployment workflow
│   └── config/                   # Environment configurations
```

## Usage Instructions
### Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Python 3.11+
- Node.js 14+ (for CDK)
- Docker
- AWS CDK CLI

### Installation

1. Clone the repository and install dependencies:
```bash
# Install Python dependencies for model building
cd model_build
pip install -r ml_pipelines/requirements.txt

# Install deployment dependencies
cd ../model_deploy
sh install-prerequisites-brew.sh
pip install -r requirements.txt
```

2. Configure AWS credentials and environment variables:
```bash
export AWS_REGION=<your-region>
export SAGEMAKER_PROJECT_NAME=<project-name>
export SAGEMAKER_PROJECT_ID=<project-id>
```

### Quick Start

1. Train a model using the SageMaker pipeline:
```bash
cd model_build
python ml_pipelines/run_pipeline.py \
  --module-name training.pipeline \
  --role-arn <role-arn> \
  --kwargs '{"region":"us-east-1"}'
```

2. Deploy the model endpoint:
```bash
cd model_deploy
cdk deploy
```

### More Detailed Examples

1. Using Glue Data Catalog for data ingestion:
```bash
cd model_build
python ml_pipelines/run_pipeline.py \
  --module-name training.pipeline_requirements \
  --kwargs '{
    "region": "us-east-1",
    "glue_database_name": "abalone_db",
    "glue_table_name": "abalone_table"
  }'
```

2. Customizing endpoint configuration:
```yaml
# model_deploy/config/dev/endpoint-config.yml
initial_instance_count: 1
initial_variant_weight: 1
instance_type: "ml.m5.large"
variant_name: "AllTraffic"
```

### Troubleshooting

Common issues:

1. Pipeline execution fails:
- Check CloudWatch logs for detailed error messages
- Verify IAM roles have required permissions
- Ensure S3 bucket exists and is accessible

2. Model deployment fails:
- Check Lambda function logs in CloudWatch
- Verify model package exists in Model Registry
- Ensure endpoint configuration is valid

Debug mode:
```bash
# Enable debug logging
export PYTHONUNBUFFERED=TRUE
python ml_pipelines/run_pipeline.py --log-level debug
```

## Data Flow
The pipeline processes abalone measurement data through preprocessing, training, and evaluation stages before conditional deployment.

```
[S3/Glue] -> [Preprocessing] -> [Training] -> [Evaluation] -> [Model Registry] -> [Endpoint Deployment]
```

Key interactions:
1. Data is loaded from S3 or Glue Catalog
2. Preprocessing normalizes features and splits data
3. XGBoost model trains on processed data
4. Evaluation computes MSE metrics
5. Model is registered if MSE <= 6.0
6. Approved models trigger automated deployment
7. Endpoint status is monitored via Lambda

## Infrastructure

![Infrastructure diagram](./docs/infra.svg)

AWS Resources created:

Lambda Functions:
- check_endpoint_status: Monitors endpoint deployment
- deploy_endpoint: Handles model deployment

Step Functions:
- Model deployment workflow orchestration

SageMaker:
- Training pipeline
- Model endpoints
- Model registry

IAM:
- Execution roles for Lambda and SageMaker
- KMS keys for encryption

CDK:
- Deployment stack for infrastructure as code
- Bootstrap stack for CDK resources

## Deployment

Prerequisites:
- CDK bootstrapped in target account
- Required IAM roles and permissions
- Environment variables configured

Deployment Steps:
1. Configure environment:
```bash
cd model_deploy
source .env
```

2. Deploy infrastructure:
```bash
cdk deploy --require-approval never
```

3. Monitor deployment:
```bash
aws cloudformation describe-stacks \
  --stack-name <stack-name>
```