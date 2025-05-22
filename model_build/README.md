# SageMaker MLOps Pipeline with Glue Catalog Integration

This project implements an end-to-end MLOps pipeline for training, evaluating, and deploying an XGBoost model using AWS Glue Data Catalog as the data source. The pipeline automates the entire machine learning lifecycle from data preprocessing to model deployment using AWS SageMaker and GitHub Actions.

## Repository Structure

```
.
├── ml_pipelines/                  # Core SageMaker pipeline definition
│   ├── training/                  # Training pipeline implementation
│   │   └── pipeline.py            # Pipeline definition with Glue integration
│   └── data/                      # Data upload utilities
└── source_scripts/                # Individual pipeline step implementations
    ├── preprocessing/             # Data preprocessing scripts with AWS Data Wrangler
    ├── training/                  # Model training scripts  
    └── evaluate/                  # Model evaluation scripts
```

## Pipeline Steps

1. **Preprocessing**: Reads data from AWS Glue Data Catalog using AWS Data Wrangler
2. **Training**: Trains an XGBoost model on the preprocessed data
3. **Evaluation**: Evaluates model performance using MSE metric
4. **Registration**: Registers the model in SageMaker Model Registry if MSE ≤ 6.0