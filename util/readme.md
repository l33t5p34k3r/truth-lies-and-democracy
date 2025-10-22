I really miss shell scripts

python3 .\generate_from_schema.py schema.yaml ..\truth_lies_and_democracy\Util\ scripts\
python3 .\scripts\json_to_excel.py ..\truth_lies_and_democracy\Assets\papers\data.json .\scripts\data_template.xlsx .\data.xlsx
python3 .\scripts\excel_to_json.py .\data.xlsx ..\truth_lies_and_democracy\Assets\papers\data.json
python3 .\scripts\validate_data.py ..\truth_lies_and_democracy\Assets\papers\data.json
TODO: validation should check for uniqueness...