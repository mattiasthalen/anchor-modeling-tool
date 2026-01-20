import yaml
import json
from anchor_modeling_tool.examples.export_to_yaml import export_json_to_yaml

def test_export_json_to_yaml(tmp_path):
    # Prepare a sample JSON file
    sample_data = {"foo": "bar", "baz": [1, 2, 3]}
    json_path = tmp_path / "sample.json"
    yaml_path = tmp_path / "sample.yaml"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(sample_data, f)

    # Run the export function
    export_json_to_yaml(json_path=str(json_path), yaml_path=str(yaml_path))

    # Check YAML output
    with open(yaml_path, "r", encoding="utf-8") as f:
        yaml_data = yaml.safe_load(f)
    assert yaml_data == sample_data
