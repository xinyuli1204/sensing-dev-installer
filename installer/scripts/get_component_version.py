import sys
import yaml
import os
import json

def extract_versions(file_path, dst_json):
    with open(file_path, 'r') as file:
        data = yaml.safe_load(file)
    with open(dst_json, 'r') as json_file:
        json_data = json.load(json_file)

    component_json_data = {}

    libraries = data.get('libraries', {})
    for lib_name, lib_info in libraries.items():
        name = lib_info.get('name', 'N/A')
        version = lib_info.get('version', 'N/A')
        if version.startswith('v'):
            version = version[1:]
        
        component_json_data[name] = version
        # print(f"{name} : {version}")

    json_data["SDK components"] = component_json_data

    with open(dst_json, 'w') as json_file:
        json.dump(json_data, json_file, indent=4)

if __name__ == "__main__":
    # python get_component_version.py <config.yml> <version_info.json>
    if len(sys.argv) != 3:
        raise Exception("this script requires the config file to parse")
    config_file = sys.argv[1]
    dst_json = sys.argv[2]
    if not os.path.isfile(config_file):
        raise Exception(config_file + " does not exist")
    if not os.path.isfile(dst_json):
        raise Exception(dst_json + " does not exist")
    
    extract_versions(config_file, dst_json)