
SCHEMA_NAME=schema.yaml
GD_PATH=../truth_lies_and_democracy/Util/
EXCEL_PATH=data_template.xlsx
JSON_PATH=../truth_lies_and_democracy/Assets/papers/data.json
GENERATED_SCRIPTS=scripts/

generate:
	python3 generate_from_schema_v2.py $(SCHEMA_NAME) $(GD_PATH) $(GENERATED_SCRIPTS)

convert:
	python3 $(GENERATED_SCRIPTS)/excel_to_json.py $(EXCEL_PATH) $(JSON_PATH)
	python3 $(GENERATED_SCRIPTS)/validate_data.py $(JSON_PATH)