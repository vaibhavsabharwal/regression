#!/bin/bash
# run_requirements_pipeline.sh

# Set variables - replace these with your actual values
ROLE_ARN="${SAGEMAKER_PIPELINE_ROLE_ARN:-arn:aws:iam::ACCOUNT_ID:role/YOUR_ROLE_NAME}"
PROJECT_NAME="${SAGEMAKER_PROJECT_NAME:-your-project-name}"
PROJECT_ID="${SAGEMAKER_PROJECT_ID:-your-project-id}"
DATAZONE_DOMAIN="${AMAZON_DATAZONE_DOMAIN:-your-datazone-domain}"
DATAZONE_SCOPE="${AMAZON_DATAZONE_SCOPENAME:-your-datazone-scope}"
DOMAIN_ARN="${SAGEMAKER_DOMAIN_ARN:-arn:aws:sagemaker:REGION:ACCOUNT_ID:domain/your-domain-id}"
SPACE_ARN="${SAGEMAKER_SPACE_ARN:-arn:aws:sagemaker:REGION:ACCOUNT_ID:space/your-domain-id/your-space-id}"
DATAZONE_PROJECT="${AMAZON_DATAZONE_PROJECT:-your-datazone-project}"
REGION="${REGION:-us-east-1}"
S3_BUCKET="${ARTIFACT_BUCKET:-your-s3-bucket}"
MODEL_PACKAGE_GROUP="${MODEL_PACKAGE_GROUP_NAME:-AbaloneModels}"
PIPELINE_NAME="githubactions-${PROJECT_ID:-project-id}-requirements"
GLUE_DATABASE="${GLUE_DATABASE:-your-glue-database}"
GLUE_TABLE="${GLUE_TABLE:-abalone}"

# Create requirements directory if it doesn't exist
mkdir -p source_scripts/preprocessing/prepare_abalone_data/requirements

# Create a requirements.txt file for AWS Data Wrangler
cat > source_scripts/preprocessing/prepare_abalone_data/requirements/requirements.txt << EOF
awswrangler==2.16.1
pymysql
pandas==1.1.3
EOF

# Copy the AWS Data Wrangler script to S3
echo "Copying AWS Data Wrangler script to S3..."
aws s3 cp source_scripts/preprocessing/prepare_abalone_data/data_wrangler_requirements.py s3://${S3_BUCKET}/SMUSMLOPS/requirements-preprocess/input/code/data_wrangler_requirements.py

# Copy the requirements directory to S3
echo "Copying requirements directory to S3..."
aws s3 cp --recursive source_scripts/preprocessing/prepare_abalone_data/requirements s3://${S3_BUCKET}/SMUSMLOPS/requirements-preprocess/input/dependencies/

# Add Glue permissions to the role if needed
echo "Adding Glue permissions to the role..."
ROLE_NAME=$(echo $ROLE_ARN | cut -d'/' -f2)
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess

# Run the pipeline
echo "Running the pipeline with requirements.txt approach..."
python3 ./ml_pipelines/run_pipeline.py \
  --module-name training.pipeline_requirements \
  --role-arn "${ROLE_ARN}" \
  --tags '[{"Key":"sagemaker:project-name", "Value":"'"${PROJECT_NAME}"'"}, {"Key":"sagemaker:project-id", "Value":"'"${PROJECT_ID}"'"}, {"Key":"AmazonDataZoneDomain", "Value":"'"${DATAZONE_DOMAIN}"'"}, {"Key":"AmazonDataZoneScopeName", "Value":"'"${DATAZONE_SCOPE}"'"}, {"Key":"sagemaker:domain-arn", "Value":"'"${DOMAIN_ARN}"'"}, {"Key":"sagemaker:space-arn", "Value":"'"${SPACE_ARN}"'"}, {"Key":"AmazonDataZoneProject", "Value":"'"${DATAZONE_PROJECT}"'"}]' \
  --kwargs '{"region":"'"${REGION}"'","role":"'"${ROLE_ARN}"'","default_bucket":"'"${S3_BUCKET}"'","pipeline_name":"'"${PIPELINE_NAME}"'","model_package_group_name":"'"${MODEL_PACKAGE_GROUP}"'","base_job_prefix":"SMUSMLOPS","glue_database_name":"'"${GLUE_DATABASE}"'","glue_table_name":"'"${GLUE_TABLE}"'"}'