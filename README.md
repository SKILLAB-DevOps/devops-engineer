# Introduction to DevOps documentation

Documentation is made using ``Sphinx``, to build it:

## Building documentation

1. Create and init a virtual environment

    ```bash
    pip install uv
    uv venv .venv
    source .venv/bin/activate
    ```

2. Install Python dependencies

    ```bash
    uv pip install .
    ```

3. Build documentation

    ```bash
    make clean html
    ```
    
    To build the documentation for ``pdf`` or ``epub``, run:

    ```bash
    make pdf 
    # or
    make epub
    ```

4. To read the documentation - open explorer.exe, change the directory to ``build``, then ``index.html``.

    ```bash
    explorer.exe .
    ```

## Publishing documentation

To have documentation available on GitHub pages you need to copy the files from ``build/html`` to docs (limitation from gh-pages) then will pick the ``index.html``

```bash
make clean html && rm -rf docs/* && cp -R build/html/* docs/ && touch docs/.nojekyll
```
