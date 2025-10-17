I really miss shell scripts

python3 .\generate_from_schema_v2.py schema.yaml ..\truth_lies_and_democracy\Util\ scripts\
python3 .\scripts\excel_to_json.py .\data_template.xlsx ..\truth_lies_and_democracy\Assets\papers\data.json
python3 .\scripts\validate_data.py ..\truth_lies_and_democracy\Assets\papers\data.json