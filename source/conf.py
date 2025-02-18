import os
import sys
sys.path.insert(0, os.path.abspath('..'))

# Configuration file for the Sphinx documentation builder.
project = 'DevOps'
copyright = '2025, skillab'
author = 'skillab'
release = '3'
version = '0.0.3'

extensions = [
    'sphinx_rtd_theme',
    'sphinx_copybutton',
    'sphinx.ext.duration', #  will see a short durations report at the end of the console output
    'sphinx.ext.todo',
    # 'rst2pdf.pdfbuilder',
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    ]

# Grouping the document tree into PDF files. List of tuples
# (source start file, target name, title, author, options).
pdf_documents = [
    ('index', 'Introduction_to_DevOps', 'Introduction to DevOps', 'Claudiu Colesnicencu'),
]

pdf_stylesheets = ['sphinx', 'kerning', 'a4']
pdf_use_coverpage = False
pdf_use_toc = False
pdf_use_modindex = False
pdf_use_index = False
pdf_invariant = True
pdf_real_footnotes = False
pdf_break_level = 1

pygments_style = 'sphinx'

todo_include_todos = True

templates_path = ['_templates']
exclude_patterns = ['venv']

html_theme = "sphinx_rtd_theme"
html_static_path = ['_static']

html_theme_options = {
    "navigation_depth": -1
}

html_logo = "_static/Logo.jpg"

html_css_files = ['max_width.css']
