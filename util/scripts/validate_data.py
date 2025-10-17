#!/usr/bin/env python3
"""
Standalone JSON data validator
Validates data files against the schema without requiring Godot
"""
import json
import sys
from pathlib import Path
from typing import Dict, List, Any, Set, Tuple

class DataValidator:
    def __init__(self):
        self.errors: List[str] = []
        self.warnings: List[str] = []
        self.all_objects: Dict[str, Dict[Any, Any]] = {}

    def validate_files(self, file_paths: List[str]) -> bool:
        """Validate multiple JSON files and their cross-references"""
        print(f"Validating {len(file_paths)} file(s)...")

        for path in file_paths:
            self._load_and_validate_file(path)

        self._validate_cross_references()

        return self._print_results()

    def _load_and_validate_file(self, path: str) -> None:
        """Load and validate a single file"""
        print(f"\nValidating: {path}")

        try:
            with open(path, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except FileNotFoundError:
            self.errors.append(f"File not found: {path}")
            return
        except json.JSONDecodeError as e:
            self.errors.append(f"Invalid JSON in {path}: {e}")
            return

        if "StoryGroup" in data:
            self._validate_StoryGroup(data["StoryGroup"], path)
        if "Story" in data:
            self._validate_Story(data["Story"], path)
        if "MediaPostGroup" in data:
            self._validate_MediaPostGroup(data["MediaPostGroup"], path)
        if "StoryPosts" in data:
            self._validate_StoryPosts(data["StoryPosts"], path)
        if "SocialMediaPost" in data:
            self._validate_SocialMediaPost(data["SocialMediaPost"], path)

    def _validate_StoryGroup(self, entries: List[Dict], file_path: str) -> None:
        """Validate StoryGroup entries"""
        if not isinstance(entries, list):
            self.errors.append(f"StoryGroup must be a list in {file_path}")
            return

        type_objects = {}
        seen_ids = set()

        for idx, entry in enumerate(entries):
            if not isinstance(entry, dict):
                self.errors.append(f"StoryGroup[{idx}] must be a dictionary in {file_path}")
                continue


            # Validate group_id
            value = entry.get("group_id")

            if value is None:
                self.errors.append(f"StoryGroup[{idx}].group_id is required in {file_path}")

            if value is not None:
                try:
                    value = int(value)
                    entry["group_id"] = value
                except (ValueError, TypeError):
                    self.errors.append(f"StoryGroup[{idx}].group_id must be an integer in {file_path}")


            # Validate stories
            value = entry.get("stories")

            if value is None or (isinstance(value, list) and len(value) == 0):
                self.errors.append(f"StoryGroup[{idx}].stories is required in {file_path}")

            if value is not None and not isinstance(value, list):
                self.errors.append(f"StoryGroup[{idx}].stories must be an array in {file_path}")










            # Store for cross-reference validation
            id_field = entry.get("group_id")
            if id_field is not None:
                type_objects[id_field] = entry

        self.all_objects["StoryGroup"] = type_objects
        print(f"  Validated {len(entries)} StoryGroup entries")

    def _validate_Story(self, entries: List[Dict], file_path: str) -> None:
        """Validate Story entries"""
        if not isinstance(entries, list):
            self.errors.append(f"Story must be a list in {file_path}")
            return

        type_objects = {}
        seen_ids = set()

        for idx, entry in enumerate(entries):
            if not isinstance(entry, dict):
                self.errors.append(f"Story[{idx}] must be a dictionary in {file_path}")
                continue


            # Validate story_id
            value = entry.get("story_id")

            if value is None:
                self.errors.append(f"Story[{idx}].story_id is required in {file_path}")

            if value is not None:
                try:
                    value = int(value)
                    entry["story_id"] = value
                except (ValueError, TypeError):
                    self.errors.append(f"Story[{idx}].story_id must be an integer in {file_path}")


            # Validate news_headline
            value = entry.get("news_headline")

            if value is None or (isinstance(value, str) and not value.strip()):
                self.errors.append(f"Story[{idx}].news_headline is required in {file_path}")





            if value is not None and isinstance(value, str) and len(value) > 200:
                self.errors.append(f"Story[{idx}].news_headline exceeds max length 200 in {file_path}")


            # Validate news_content
            value = entry.get("news_content")

            if value is None or (isinstance(value, str) and not value.strip()):
                self.errors.append(f"Story[{idx}].news_content is required in {file_path}")





            if value is not None and isinstance(value, str) and len(value) > 1000:
                self.errors.append(f"Story[{idx}].news_content exceeds max length 1000 in {file_path}")


            # Validate news_fake
            value = entry.get("news_fake")

            if value is None:
                self.errors.append(f"Story[{idx}].news_fake is required in {file_path}")

            if value is not None and not isinstance(value, bool):
                if isinstance(value, str):
                    entry["news_fake"] = value.lower() in ['true', '1', 'yes', 'y']
                elif isinstance(value, int):
                    entry["news_fake"] = value != 0
                else:
                    self.errors.append(f"Story[{idx}].news_fake must be a boolean in {file_path}")


            # Store for cross-reference validation
            id_field = entry.get("story_id")
            if id_field is not None:
                type_objects[id_field] = entry

        self.all_objects["Story"] = type_objects
        print(f"  Validated {len(entries)} Story entries")

    def _validate_MediaPostGroup(self, entries: List[Dict], file_path: str) -> None:
        """Validate MediaPostGroup entries"""
        if not isinstance(entries, list):
            self.errors.append(f"MediaPostGroup must be a list in {file_path}")
            return

        type_objects = {}
        seen_ids = set()

        for idx, entry in enumerate(entries):
            if not isinstance(entry, dict):
                self.errors.append(f"MediaPostGroup[{idx}] must be a dictionary in {file_path}")
                continue


            # Validate group_id
            value = entry.get("group_id")

            if value is None:
                self.errors.append(f"MediaPostGroup[{idx}].group_id is required in {file_path}")

            if value is not None:
                try:
                    value = int(value)
                    entry["group_id"] = value
                except (ValueError, TypeError):
                    self.errors.append(f"MediaPostGroup[{idx}].group_id must be an integer in {file_path}")










            # Validate story_posts
            value = entry.get("story_posts")

            if value is None or (isinstance(value, list) and len(value) == 0):
                self.errors.append(f"MediaPostGroup[{idx}].story_posts is required in {file_path}")

            if value is not None and not isinstance(value, list):
                self.errors.append(f"MediaPostGroup[{idx}].story_posts must be an array in {file_path}")










            # Store for cross-reference validation
            id_field = entry.get("group_id")
            if id_field is not None:
                type_objects[id_field] = entry

        self.all_objects["MediaPostGroup"] = type_objects
        print(f"  Validated {len(entries)} MediaPostGroup entries")

    def _validate_StoryPosts(self, entries: List[Dict], file_path: str) -> None:
        """Validate StoryPosts entries"""
        if not isinstance(entries, list):
            self.errors.append(f"StoryPosts must be a list in {file_path}")
            return

        type_objects = {}
        seen_ids = set()

        for idx, entry in enumerate(entries):
            if not isinstance(entry, dict):
                self.errors.append(f"StoryPosts[{idx}] must be a dictionary in {file_path}")
                continue


            # Validate story_id
            value = entry.get("story_id")

            if value is None:
                self.errors.append(f"StoryPosts[{idx}].story_id is required in {file_path}")

            if value is not None:
                try:
                    value = int(value)
                    entry["story_id"] = value
                except (ValueError, TypeError):
                    self.errors.append(f"StoryPosts[{idx}].story_id must be an integer in {file_path}")










            # Validate posts
            value = entry.get("posts")

            if value is None or (isinstance(value, list) and len(value) == 0):
                self.errors.append(f"StoryPosts[{idx}].posts is required in {file_path}")

            if value is not None and not isinstance(value, list):
                self.errors.append(f"StoryPosts[{idx}].posts must be an array in {file_path}")










            # Store for cross-reference validation
            id_field = entry.get("story_id")
            if id_field is not None:
                type_objects[id_field] = entry

        self.all_objects["StoryPosts"] = type_objects
        print(f"  Validated {len(entries)} StoryPosts entries")

    def _validate_SocialMediaPost(self, entries: List[Dict], file_path: str) -> None:
        """Validate SocialMediaPost entries"""
        if not isinstance(entries, list):
            self.errors.append(f"SocialMediaPost must be a list in {file_path}")
            return

        type_objects = {}
        seen_ids = set()

        for idx, entry in enumerate(entries):
            if not isinstance(entry, dict):
                self.errors.append(f"SocialMediaPost[{idx}] must be a dictionary in {file_path}")
                continue


            # Validate post_id
            value = entry.get("post_id")

            if value is None:
                self.errors.append(f"SocialMediaPost[{idx}].post_id is required in {file_path}")

            if value is not None:
                try:
                    value = int(value)
                    entry["post_id"] = value
                except (ValueError, TypeError):
                    self.errors.append(f"SocialMediaPost[{idx}].post_id must be an integer in {file_path}")


            # Validate user_name
            value = entry.get("user_name")

            if value is None or (isinstance(value, str) and not value.strip()):
                self.errors.append(f"SocialMediaPost[{idx}].user_name is required in {file_path}")





            if value is not None and isinstance(value, str) and len(value) > 50:
                self.errors.append(f"SocialMediaPost[{idx}].user_name exceeds max length 50 in {file_path}")


            # Validate content_text
            value = entry.get("content_text")

            if value is None or (isinstance(value, str) and not value.strip()):
                self.errors.append(f"SocialMediaPost[{idx}].content_text is required in {file_path}")





            if value is not None and isinstance(value, str) and len(value) > 500:
                self.errors.append(f"SocialMediaPost[{idx}].content_text exceeds max length 500 in {file_path}")


            # Store for cross-reference validation
            id_field = entry.get("post_id")
            if id_field is not None:
                type_objects[id_field] = entry

        self.all_objects["SocialMediaPost"] = type_objects
        print(f"  Validated {len(entries)} SocialMediaPost entries")


    def _validate_cross_references(self) -> None:
        """Validate references between types"""
        print("\nValidating cross-references...")


        # StoryGroup external references
        if "StoryGroup" in self.all_objects:
            for obj_id, obj in self.all_objects["StoryGroup"].items():
                # stories -> Story.story_id (external)
                value = obj.get("stories")
                if value:
                    for ref_id in value:
                        if ref_id not in self.all_objects.get("Story", {}):
                            self.errors.append(f"StoryGroup.{obj_id}.stories references missing external Story.{ref_id}")
        # MediaPostGroup external references
        if "MediaPostGroup" in self.all_objects:
            for obj_id, obj in self.all_objects["MediaPostGroup"].items():
                # group_id -> StoryGroup.group_id (external)
                value = obj.get("group_id")
                if value is not None and value not in self.all_objects.get("StoryGroup", {}):
                    self.errors.append(f"MediaPostGroup.{obj_id}.group_id references missing external StoryGroup.{value}")
                # story_posts -> StoryPosts.story_id (external)
                value = obj.get("story_posts")
                if value:
                    for ref_id in value:
                        if ref_id not in self.all_objects.get("StoryPosts", {}):
                            self.errors.append(f"MediaPostGroup.{obj_id}.story_posts references missing external StoryPosts.{ref_id}")
        # StoryPosts external references
        if "StoryPosts" in self.all_objects:
            for obj_id, obj in self.all_objects["StoryPosts"].items():
                # story_id -> Story.story_id (external)
                value = obj.get("story_id")
                if value is not None and value not in self.all_objects.get("Story", {}):
                    self.errors.append(f"StoryPosts.{obj_id}.story_id references missing external Story.{value}")
                # posts -> SocialMediaPost.post_id (external)
                value = obj.get("posts")
                if value:
                    for ref_id in value:
                        if ref_id not in self.all_objects.get("SocialMediaPost", {}):
                            self.errors.append(f"StoryPosts.{obj_id}.posts references missing external SocialMediaPost.{ref_id}")

    def _print_results(self) -> bool:
        """Print validation results and return success status"""
        print("\n" + "=" * 60)

        if self.warnings:
            print(f"\n {len(self.warnings)} Warning(s):")
            for warning in self.warnings:
                print(f"  - {warning}")

        if self.errors:
            print(f"\n✗ {len(self.errors)} Error(s):")
            for error in self.errors:
                print(f"  • {error}")
            print("\n" + "=" * 60)
            print("VALIDATION FAILED")
            return False
        else:
            print("\n✓ VALIDATION PASSED")
            print(f"All data files are valid!")
            if self.warnings:
                print(f"({len(self.warnings)} warnings)")
            print("=" * 60)
            return True

def main():
    if len(sys.argv) < 2:
        print("Usage: python validate_data.py <file1.json> [file2.json] ...")
        print("\nExample:")
        print("  python validate_data.py papers.json media_posts.json")
        sys.exit(1)

    validator = DataValidator()
    file_paths = sys.argv[1:]

    success = validator.validate_files(file_paths)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()