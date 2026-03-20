#!/usr/bin/env python3
"""
Luminous Cosmic Architecture™ — EPUB 3.0 Generator
Generates a beautifully styled eBook from chapters.json content.
Uses the Resonance UX design system (forest greens, gold accents, cream base).
"""

import json
import os
import uuid
import zipfile
from datetime import datetime
from pathlib import Path
from typing import Any


class LuminousEpubGenerator:
    """Generate EPUB 3.0 eBook from Luminous Cosmic Architecture content."""

    def __init__(self, content_path: str, output_path: str, styles_path: str):
        self.content_path = content_path
        self.output_path = output_path
        self.styles_path = styles_path
        self.book_uid = str(uuid.uuid4())
        self.content: dict[str, Any] = {}

    def load_content(self) -> None:
        """Load chapter content from JSON."""
        with open(self.content_path, "r", encoding="utf-8") as f:
            self.content = json.load(f)

    def generate(self) -> str:
        """Generate the complete EPUB file."""
        self.load_content()
        book = self.content["book"]

        with zipfile.ZipFile(self.output_path, "w", zipfile.ZIP_DEFLATED) as epub:
            # 1. mimetype (must be first, uncompressed)
            epub.writestr("mimetype", "application/epub+zip", compress_type=zipfile.ZIP_STORED)

            # 2. META-INF/container.xml
            epub.writestr("META-INF/container.xml", self._container_xml())

            # 3. content.opf (package document)
            epub.writestr("OEBPS/content.opf", self._content_opf(book))

            # 4. toc.ncx (NCX table of contents)
            epub.writestr("OEBPS/toc.ncx", self._toc_ncx(book))

            # 5. toc.xhtml (EPUB 3 navigation document)
            epub.writestr("OEBPS/toc.xhtml", self._toc_xhtml(book))

            # 6. Stylesheet
            if os.path.exists(self.styles_path):
                with open(self.styles_path, "r", encoding="utf-8") as f:
                    epub.writestr("OEBPS/styles.css", f.read())
            else:
                epub.writestr("OEBPS/styles.css", self._default_styles())

            # 7. Cover page
            epub.writestr("OEBPS/cover.xhtml", self._cover_page(book))

            # 8. Chapter pages
            for chapter in book["chapters"]:
                filename = f"chapter{chapter['id']:02d}.xhtml"
                epub.writestr(f"OEBPS/{filename}", self._chapter_page(chapter))

        return self.output_path

    # ─── XML Generators ──────────────────────────────────────────────

    def _container_xml(self) -> str:
        return """<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>"""

    def _content_opf(self, book: dict) -> str:
        chapters = book["chapters"]
        manifest_items = [
            '<item id="toc" href="toc.xhtml" media-type="application/xhtml+xml" properties="nav"/>',
            '<item id="style" href="styles.css" media-type="text/css"/>',
            '<item id="cover" href="cover.xhtml" media-type="application/xhtml+xml"/>',
        ]
        spine_refs = ['<itemref idref="cover"/>']

        for ch in chapters:
            ch_id = f"ch{ch['id']:02d}"
            manifest_items.append(
                f'<item id="{ch_id}" href="chapter{ch["id"]:02d}.xhtml" media-type="application/xhtml+xml"/>'
            )
            spine_refs.append(f'<itemref idref="{ch_id}"/>')

        return f"""<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="uid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="uid">urn:uuid:{self.book_uid}</dc:identifier>
    <dc:title>{self._escape(book['title'])}</dc:title>
    <dc:creator>{self._escape(book['author'])}</dc:creator>
    <dc:language>en</dc:language>
    <dc:publisher>Luminous Prosperity Publishing</dc:publisher>
    <dc:description>{self._escape(book.get('description', ''))}</dc:description>
    <dc:date>{datetime.now().strftime('%Y-%m-%d')}</dc:date>
    <meta property="dcterms:modified">{datetime.now().strftime('%Y-%m-%dT%H:%M:%SZ')}</meta>
  </metadata>
  <manifest>
    {chr(10).join(f'    {item}' for item in manifest_items)}
  </manifest>
  <spine>
    {chr(10).join(f'    {ref}' for ref in spine_refs)}
  </spine>
</package>"""

    def _toc_ncx(self, book: dict) -> str:
        nav_points = []
        for i, ch in enumerate(book["chapters"], 1):
            nav_points.append(f"""    <navPoint id="navpoint-{i}" playOrder="{i}">
      <navLabel><text>Chapter {ch['id']}: {self._escape(ch['title'])}</text></navLabel>
      <content src="chapter{ch['id']:02d}.xhtml"/>
    </navPoint>""")

        return f"""<?xml version="1.0" encoding="UTF-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
  <head>
    <meta name="dtb:uid" content="urn:uuid:{self.book_uid}"/>
    <meta name="dtb:depth" content="1"/>
    <meta name="dtb:totalPageCount" content="0"/>
    <meta name="dtb:maxPageNumber" content="0"/>
  </head>
  <docTitle><text>{self._escape(book['title'])}</text></docTitle>
  <navMap>
{chr(10).join(nav_points)}
  </navMap>
</ncx>"""

    def _toc_xhtml(self, book: dict) -> str:
        links = []
        for ch in book["chapters"]:
            links.append(
                f'      <li><a href="chapter{ch["id"]:02d}.xhtml">Chapter {ch["id"]}: {self._escape(ch["title"])}</a></li>'
            )

        return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head>
  <title>Table of Contents</title>
  <link rel="stylesheet" type="text/css" href="styles.css"/>
</head>
<body>
  <nav epub:type="toc" id="toc">
    <h1>Table of Contents</h1>
    <ol>
{chr(10).join(links)}
    </ol>
  </nav>
</body>
</html>"""

    def _cover_page(self, book: dict) -> str:
        return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>{self._escape(book['title'])}</title>
  <link rel="stylesheet" type="text/css" href="styles.css"/>
</head>
<body>
  <div class="cover-page">
    <div class="cover-ornament">&#10022;</div>
    <h1 class="book-title">{self._escape(book['title'])}</h1>
    <p class="book-subtitle">{self._escape(book.get('subtitle', ''))}</p>
    <div class="cover-ornament">&#10023; &#10023; &#10023;</div>
    <p class="book-author">{self._escape(book['author'])}</p>
  </div>
</body>
</html>"""

    def _chapter_page(self, chapter: dict) -> str:
        sections_html = []

        for section in chapter.get("sections", []):
            content = section.get("content", "")
            if content and content != "Coming in the full edition.":
                paragraphs = content.split("\n\n")
                section_body = "\n".join(f"    <p>{self._escape(p)}</p>" for p in paragraphs if p.strip())

                # Add shareable quotes as pull quotes
                quotes = section.get("shareableQuotes", [])
                quote_html = ""
                if quotes:
                    quote_html = f'\n    <blockquote class="pull-quote-large">{self._escape(quotes[0])}</blockquote>'

                sections_html.append(f"""
  <div class="section">
    <h2>{self._escape(section['title'])}</h2>
{section_body}{quote_html}
    <div class="section-divider">&#10022; &#10022; &#10022;</div>
  </div>""")
            else:
                sections_html.append(f"""
  <div class="section">
    <h2>{self._escape(section['title'])}</h2>
    <p class="text-muted"><em>Coming in the full edition.</em></p>
  </div>""")

        # Reflection questions
        reflection_html = ""
        questions = chapter.get("reflectionQuestions", [])
        if questions:
            q_items = "\n".join(f'    <div class="reflection-question">{self._escape(q)}</div>' for q in questions)
            reflection_html = f"""
  <div class="reflection-section">
    <h3>Reflection Questions</h3>
    <p><em>These questions are invitations, not tests. Sit with them the way you might sit with a night sky.</em></p>
{q_items}
  </div>"""

        # Practical exercise
        exercise_html = ""
        exercise = chapter.get("practicalExercise")
        if exercise:
            steps = exercise.get("steps", [])
            steps_items = "\n".join(
                f'    <div class="exercise-step"><span class="exercise-step-number">{i+1}.</span> {self._escape(s)}</div>'
                for i, s in enumerate(steps)
            )
            exercise_html = f"""
  <div class="exercise-section">
    <h3>Practical Exercise: {self._escape(exercise['title'])}</h3>
    <p class="text-muted">Time required: {exercise.get('duration', 1200) // 60} minutes</p>
{steps_items}
  </div>"""

        # Luminous invitation
        invitation_html = ""
        invitation = chapter.get("luminousInvitation", "")
        if invitation:
            invitation_html = f"""
  <div class="luminous-invitation">
    <h3>&#10022; Luminous Invitation &#10022;</h3>
    <p>{self._escape(invitation)}</p>
  </div>"""

        return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Chapter {chapter['id']}: {self._escape(chapter['title'])}</title>
  <link rel="stylesheet" type="text/css" href="styles.css"/>
</head>
<body>
  <div class="chapter-opener">
    <div class="chapter-number">Chapter {chapter['id']}</div>
    <h1 class="chapter-title">{self._escape(chapter['title'])}</h1>
    <p class="chapter-subtitle">{self._escape(chapter.get('subtitle', ''))}</p>
    <div class="chapter-divider">&#10022; &#10022; &#10022;</div>
  </div>

  <div class="epigraph">
    <p>{self._escape(chapter.get('epigraph', ''))}</p>
  </div>
{''.join(sections_html)}
{reflection_html}
{exercise_html}
{invitation_html}
</body>
</html>"""

    # ─── Utilities ───────────────────────────────────────────────────

    @staticmethod
    def _escape(text: str) -> str:
        """Escape HTML entities."""
        return (
            text.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace('"', "&quot;")
            .replace("'", "&#x27;")
            .replace("™", "&#x2122;")
        )

    def _default_styles(self) -> str:
        """Fallback minimal styles if external CSS not found."""
        return """
body { font-family: Georgia, serif; line-height: 1.7; color: #122E21; background: #FAFAF8; padding: 1.5em; }
h1 { font-size: 2em; font-weight: 300; text-align: center; border-bottom: 1px solid #C5A059; padding-bottom: 0.5em; }
h2 { font-size: 1.5em; color: #1B402E; }
blockquote { border-left: 3px solid #C5A059; padding: 0.5em 1em; font-style: italic; }
.chapter-opener { text-align: center; margin: 3em 0; }
.chapter-number { color: #C5A059; text-transform: uppercase; letter-spacing: 0.2em; }
"""


# ─── CLI Entry Point ─────────────────────────────────────────────────

def main():
    """Generate the Luminous Cosmic Architecture EPUB."""
    script_dir = Path(__file__).parent
    content_path = script_dir.parent / "content" / "chapters.json"
    styles_path = script_dir / "styles.css"
    output_path = script_dir / "LuminousCosmicArchitecture.epub"

    if not content_path.exists():
        print(f"Error: Content file not found at {content_path}")
        return

    generator = LuminousEpubGenerator(
        content_path=str(content_path),
        output_path=str(output_path),
        styles_path=str(styles_path),
    )

    output = generator.generate()
    print(f"EPUB generated successfully: {output}")
    print(f"File size: {os.path.getsize(output) / 1024:.1f} KB")


if __name__ == "__main__":
    main()
