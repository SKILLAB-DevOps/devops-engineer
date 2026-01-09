##################
6.2 What is Sphinx 
##################

======
Sphinx
======

It's a parser written in Python that allows us to write ``rst`` or ``md`` files that will be compiled into ``html``, ``ePub`` or ``LaTeX``.

.. image:: ../diagrams/sphinx.png

.. note::

    Sphinx makes it easy to create intelligent and beautiful documentation.

Here are some of Sphinx's major features:

    1. Output formats: HTML (including Windows HTML Help), LaTeX (for printable PDF versions), ePub, Texinfo, manual pages, and plain text.
    2. Extensive cross-references: semantic markup and automatic links for functions, classes, citations, glossary terms, and similar pieces of information
    3. Hierarchical structure: easy definition of a document tree, with automatic links to siblings, parents, and children
    4. Automatic indices: general index as well as language-specific module indices
    5. Code handling: automatic highlighting using the Pygments highlighter
    6. Extensions: automatic testing of code snippets, the inclusion of docstrings from Python modules (API docs) via built-in extensions, and much more functionality via third-party extensions.
    7. Themes: modify the look and feel of outputs by creating themes, and reusing many third-party themes.
    8. Contributed extensions: dozens of extensions contributed by users; most of them installable from PyPI.
    9. Sphinx uses the reStructuredText markup language by default and can read MyST markdown via third-party extensions. Both of these are powerful and straightforward to use and have functionality for complex documentation and publishing workflows. They both build upon Docutils to parse and write documents.