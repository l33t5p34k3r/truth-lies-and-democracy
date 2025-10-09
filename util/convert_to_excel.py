import json
import pandas as pd

with open('papers.json', 'r', encoding='utf-8') as file:
    data = json.load(file)

rows = []
for paper in data:
    paper_id = paper['id']
    for story in paper['stories']:
        rows.append({
            'id': paper_id,
            'news_headline': story['news_headline'],
            'news_content': story['news_content'],
            'news_fake': story['news_fake']
        })

df = pd.DataFrame(rows)
df.to_excel('papers.xlsx', index=False)

print(f"Successfully converted {len(rows)} stories to papers.xlsx")