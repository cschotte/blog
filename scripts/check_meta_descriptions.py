#!/usr/bin/env python3
"""Check rendered HTML for missing, duplicate, or short meta descriptions."""

import argparse
from html.parser import HTMLParser
from pathlib import Path


class Metadata(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.descriptions = []
        self.social = {}
        self.skip = False

    def handle_starttag(self, tag, attrs):
        if tag != "meta":
            return
        attrs = dict(attrs)
        name = attrs.get("name", "").lower()
        content = attrs.get("content", "")
        if attrs.get("http-equiv", "").lower() == "refresh":
            self.skip = True
        if name in ("robots", "bingbot") and "noindex" in content.lower():
            self.skip = True
        if name == "description":
            self.descriptions.append(content.strip())
        key = attrs.get("property", name)
        if key in ("og:description", "twitter:description"):
            self.social[key] = content.strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path, help="Hugo HTML output directory")
    parser.add_argument("--min-length", type=int, default=150)
    args = parser.parse_args()
    checked = skipped = failures = longer = 0
    for path in sorted(args.directory.rglob("*.html")):
        metadata = Metadata()
        metadata.feed(path.read_text(encoding="utf-8"))
        if metadata.skip:
            skipped += 1
            continue
        checked += 1
        problems = []
        if len(metadata.descriptions) != 1:
            problems.append(f"expected one description, found {len(metadata.descriptions)}")
        else:
            description = metadata.descriptions[0]
            if len(description) < args.min_length:
                problems.append(f"short description: {len(description)} characters")
            if len(description) > 160:
                longer += 1
            for key in ("og:description", "twitter:description"):
                if metadata.social.get(key) != description:
                    problems.append(f"{key} is missing or differs from the description")
        if problems:
            failures += 1
            print(f"{path.relative_to(args.directory)}: {'; '.join(problems)}")
    print(f"Checked {checked} indexable HTML pages; skipped {skipped} redirects/noindex pages.")
    print(f"{failures} pages failed; {longer} descriptions exceed the 160-character target (informational).")
    if not checked:
        parser.error("no indexable HTML pages found; build the site first")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
