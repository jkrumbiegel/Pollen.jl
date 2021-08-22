

## Semantic tags

`:reference` is an inline reference to a symbol defined in a Julia module. Can occur inside regular body text and code blocks. On hover, it should show a medium-large tooltip containing some information about the symbol, like: its type (function, constant, abstract type, struct), the module it is defined in, its name, and a preview of its documentation. Clicking the tooltip should open the dedicated documentation page for the symbol.
    - attributes: module, name

`:documentation` renders detailed documentation for a symbol reference. It shows the symbol's type, module and name. The detailed information depends on the type of symbol.
- all
    - type, name, module
    - references to the symbol in documents, examples and source code
- function
    - docstrings 
    - all methods including their definitions, with links to source file pages and to open on GitHub 

## Resources

- `/documents/[...name]`Page for every document
- `/symbols/`Page for every defined symbol that is referenced anywhere.
- Page for every source file that is referenced.
