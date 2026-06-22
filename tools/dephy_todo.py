#!/usr/bin/env python3
import argparse
import sys
from pathlib import Path

import yaml


VALID_STATUS = {"todo", "in_progress", "done", "blocked"}


def load(path: Path) -> dict:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def save(path: Path, data: dict) -> None:
    path.write_text(yaml.safe_dump(data, sort_keys=False), encoding="utf-8")


def validate_data(data: dict, path: Path) -> list[str]:
    errors: list[str] = []
    seen: set[str] = set()

    if not isinstance(data, dict):
        return [f"{path}: root must be a mapping"]
    if data.get("version") != 1:
        errors.append(f"{path}: missing version: 1")
    if not isinstance(data.get("policy"), dict):
        errors.append(f"{path}: missing policy mapping")

    items = data.get("items")
    if not isinstance(items, list):
        errors.append(f"{path}: items must be a list")
        return errors

    for index, item in enumerate(items, 1):
        if not isinstance(item, dict):
            errors.append(f"{path}: item {index} must be a mapping")
            continue
        item_id = item.get("id")
        status = item.get("status")
        title = item.get("title")
        area = item.get("area")
        if not item_id or not isinstance(item_id, str):
            errors.append(f"{path}: item {index} missing string id")
        elif item_id in seen:
            errors.append(f"{path}: duplicate id {item_id}")
        else:
            seen.add(item_id)
        if not area or not isinstance(area, str):
            errors.append(f"{path}: {item_id or index} missing string area")
        if not title or not isinstance(title, str):
            errors.append(f"{path}: {item_id or index} missing string title")
        if status not in VALID_STATUS:
            errors.append(f"{path}: {item_id or index} invalid status {status}")

    return errors


def command_validate(args: argparse.Namespace) -> int:
    path = Path(args.todo)
    errors = validate_data(load(path), path)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print(f"{path}: OK")
    return 0


def grouped_items(data: dict) -> dict[str, list[dict]]:
    groups: dict[str, list[dict]] = {}
    for item in data.get("items", []):
        groups.setdefault(item["area"], []).append(item)
    return groups


def render_markdown(data: dict) -> str:
    lines = [
        "# TODO",
        "",
        "Source of truth: `docs/todo.yaml`. Update YAML before starting or completing work.",
        "",
    ]
    for area, items in grouped_items(data).items():
        lines.append(f"## {area}")
        lines.append("")
        for item in items:
            checked = "x" if item["status"] == "done" else " "
            suffix = "" if item["status"] in {"todo", "done"} else f" (`{item['status']}`)"
            lines.append(f"- [{checked}] {item['title']}{suffix}")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def command_render_md(args: argparse.Namespace) -> int:
    todo_path = Path(args.todo)
    out_path = Path(args.output)
    data = load(todo_path)
    errors = validate_data(data, todo_path)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    out_path.write_text(render_markdown(data), encoding="utf-8")
    print(f"rendered {out_path}")
    return 0


def command_list(args: argparse.Namespace) -> int:
    path = Path(args.todo)
    data = load(path)
    errors = validate_data(data, path)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    for item in data["items"]:
        print(f"{item['status']:11} {item['id']:28} {item['title']}")
    return 0


def find_item(data: dict, item_id: str) -> dict | None:
    for item in data.get("items", []):
        if item.get("id") == item_id:
            return item
    return None


def command_set_status(args: argparse.Namespace) -> int:
    path = Path(args.todo)
    data = load(path)
    item = find_item(data, args.item_id)
    if not item:
        print(f"{path}: unknown TODO id {args.item_id}", file=sys.stderr)
        return 1
    if args.status not in VALID_STATUS:
        print(f"invalid status {args.status}", file=sys.stderr)
        return 1
    item["status"] = args.status
    if args.note:
        item["notes"] = args.note
    errors = validate_data(data, path)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    save(path, data)
    return 0


def command_add(args: argparse.Namespace) -> int:
    path = Path(args.todo)
    data = load(path)
    if find_item(data, args.item_id):
        print(f"{path}: duplicate TODO id {args.item_id}", file=sys.stderr)
        return 1
    data.setdefault("items", []).append({
        "id": args.item_id,
        "area": args.area,
        "title": args.title,
        "status": args.status,
    })
    errors = validate_data(data, path)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    save(path, data)
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("validate")
    p.add_argument("todo")
    p.set_defaults(func=command_validate)

    p = sub.add_parser("render-md")
    p.add_argument("todo")
    p.add_argument("output")
    p.set_defaults(func=command_render_md)

    p = sub.add_parser("list")
    p.add_argument("todo")
    p.set_defaults(func=command_list)

    p = sub.add_parser("set-status")
    p.add_argument("todo")
    p.add_argument("item_id")
    p.add_argument("status")
    p.add_argument("--note")
    p.set_defaults(func=command_set_status)

    p = sub.add_parser("add")
    p.add_argument("todo")
    p.add_argument("item_id")
    p.add_argument("area")
    p.add_argument("title")
    p.add_argument("--status", default="todo")
    p.set_defaults(func=command_add)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())

