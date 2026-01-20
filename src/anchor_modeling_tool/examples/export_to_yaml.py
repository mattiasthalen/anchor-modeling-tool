import yaml
import json

def export_json_to_yaml(
    *,
    json_path: str,
    yaml_path: str
) -> None:

    with open(json_path, "r", encoding="utf-8") as f_json:
        data = json.load(f_json)

    with open(yaml_path, "w", encoding="utf-8") as f_yaml:
        yaml.dump(data, f_yaml, allow_unicode=True, sort_keys=False)

if __name__ == "__main__":
    export_json_to_yaml(
        json_path="src/anchor-modeling-tool/examples/example.json",
        yaml_path="src/anchor-modeling-tool/examples/example.yaml"
    )