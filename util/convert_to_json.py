import pandas as pd
import json
import os


list_of_files_to_convert = {
    os.path.join("truth_lies_and_democracy", "Assets", "papers", "papers.xlsx"): os.path.join("truth_lies_and_democracy", "Assets", "papers", "papers.json")
}


for excel_source, target_path in list_of_files_to_convert.items():

    df = pd.read_excel(excel_source)

    grouped = df.groupby('id')

    papers = []
    for paper_id, group in grouped:
        stories = []
        for _, row in group.iterrows():
            if not row['news_fake'] in [False, True]:
                print(f"Unexpected value of news_fake: {row['news_fake']} ({type(row['news_fake'])})")
                exit(-1)
            if type(row['news_headline']) == float or row['news_headline'] == "" or not row['news_headline']:
                print(f"Unexpected value of news_headline: {row['news_headline']}")
                exit(-1)
            if row['news_content'] == "" or not row['news_content']:
                print(f"Unexpected value of news_content: {row['news_content']}")
                exit(-1)
            stories.append({
                'news_headline': row['news_headline'],
                'news_content': row['news_content'],
                'news_fake': bool(row['news_fake'])
            })
        
        if type(paper_id) == str and not paper_id.isdigit():
            print(f"Unexpected paper id: {paper_id}")
            exit(-1)

        papers.append({
            'id': str(paper_id),
            'stories': stories
        })

    with open(target_path, 'w', encoding='utf-8') as file:
        json.dump(papers, file, indent=2, ensure_ascii=False)

    print(f"Successfully converted {len(papers)} paper groups with {len(df)} total stories to papers_updated.json")