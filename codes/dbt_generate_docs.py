#!/usr/bin/env python3
import subprocess
import json
import sys

def get_model_names(select_path):
    """
    Get model names from dbt ls command
    
    Args:
        select_path: The path to select models from
    
    Returns:
        List of model names
    """
    try:
        # Run dbt ls command to get model names
        result = subprocess.run(
            ["dbt", "ls", "--select", f"{select_path}", "--output", "name"],
            capture_output=True,
            text=True,
            check=True
        )
        
        # Split output by lines and filter out empty lines and dbt log messages
        model_names = []
        for line in result.stdout.split('\n'):
            line = line.strip()
            # Skip empty lines and dbt log messages
            if line and not any([
                line.startswith('Running with dbt='),
                line.startswith('Registered adapter:'),
                line.startswith('Found'),
                'Running with dbt=' in line,
                'Registered adapter:' in line,
                'Found' in line and ('models' in line or 'tests' in line or 'sources' in line),
                line.startswith('\x1b[0m'),  # ANSI color codes
            ]):
                # Remove ANSI color codes if present
                clean_line = line.replace('\x1b[0m', '').strip()
                if clean_line:
                    model_names.append(clean_line)
        
        return model_names
    
    except subprocess.CalledProcessError as e:
        print(f"Error running dbt ls: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print("Error: dbt command not found. Make sure dbt is installed and in your PATH.", file=sys.stderr)
        sys.exit(1)

def generate_model_yaml(model_names):
    """
    Run dbt run-operation to generate model YAML documentation
    
    Args:
        model_names: List of model names
    """
    if not model_names:
        print("No models found to generate documentation for.")
        return
    
    # Build the args JSON
    args_json = json.dumps({"model_names": model_names})
    
    try:
        # Run dbt run-operation command
        print(f"Generating documentation for {len(model_names)} models...")
        print(f"Models: {', '.join(model_names)}\n")
        
        result = subprocess.run(
            ["dbt", "run-operation", "generate_model_yaml", "--args", args_json],
            check=True
        )
        
        print("\nDocumentation generated successfully!")
        
    except subprocess.CalledProcessError as e:
        print(f"Error running dbt run-operation: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    # Allow custom path from command line argument
    default_layer = "marts"  # Can be changed to staging, intermediate, etc.
    select_path = sys.argv[1] if len(sys.argv) > 1 else f"models/{default_layer}"
    
    print(f"Fetching models from: {select_path}")
    
    # Get model names
    model_names = get_model_names(select_path)
    
    if not model_names:
        print(f"No models found in {select_path}")
        sys.exit(0)
    
    # Generate documentation
    generate_model_yaml(model_names)

if __name__ == "__main__":
    main()