#!/usr/bin/env python3
"""One-time source migration helper; generated Nix never reads source YAML."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

import yaml


def nix_string(value: str) -> str:
    # Double-quoted Nix strings escape interpolation as \${. JSON escaping is
    # otherwise compatible with Nix for the source material used here.
    return json.dumps(value, ensure_ascii=False).replace("${", "\\${")


def key(value: object) -> str:
    text = str(value)
    return text if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_'-]*", text) else nix_string(text)


def render(value: object, indent: int = 0) -> str:
    pad = "  " * indent
    child = "  " * (indent + 1)
    if value is None:
        return "null"
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, str):
        return nix_string(value)
    if isinstance(value, list):
        if not value:
            return "[ ]"
        return "[\n" + "\n".join(f"{child}{render(item, indent + 1)}" for item in value) + f"\n{pad}]"
    if isinstance(value, dict):
        if not value:
            return "{ }"
        body = []
        for name, item in value.items():
            body.append(f"{child}{key(name)} = {render(item, indent + 1)};")
        return "{\n" + "\n".join(body) + f"\n{pad}}}"
    raise TypeError(type(value))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    docs = [doc for doc in yaml.safe_load_all(args.source.read_text()) if doc]
    args.destination.parent.mkdir(parents=True, exist_ok=True)
    args.destination.write_text("# Generated once from " + str(args.source) + "\n" + render(docs) + "\n")


if __name__ == "__main__":
    main()
