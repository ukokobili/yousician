import os
import subprocess

# Define the directory to save the models
output_dir = 'models/staging/'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Define the models to generate
source_name = "go_coffee_shop"
tables = [
    "menu_items",
    "payment_methods",
    "stores",
    "transaction_items",
    "transactions",
    "users",
    "vouchers"
    ]

prefix = 'stg__'
materialized = 'view'

# Function to call dbt to generate the base model content
def generate_base_model(source_name, table_name, materialized):
    command = f'dbt run-operation codegen.generate_base_model --args "{{\\"source_name\\": \\"{source_name}\\", \\"table_name\\": \\"{table_name}\\", \\"materialized\\": \\"{materialized}\\"}}"'
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result.stdout

# Iterate over each table and create a file
for table in tables:
    model_name = f"{prefix}{table}"
    file_path = os.path.join(output_dir, f"{model_name}.sql")
    content = generate_base_model(source_name, table, materialized)

    # Write the content to the file
    with open(file_path, 'w') as f:
        f.write(content)

    print(f"Written {file_path}")