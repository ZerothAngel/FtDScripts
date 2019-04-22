# ZerothAngel's From the Depths Scripts #

A collection of From the Depths Lua scripts and the libraries/modules used to build them.

## Scripts ##

**If you're just looking for scripts to use, don't download anything above.** You want to go to my [Public FtD Scripts page](https://zerothangel.com/public-ftd-scripts.html) instead.

## Building ##

Simply run build.py which is a Python 3 script. Assembled scripts will be written to the *out* directory.

### Build System ###

The build system simply concatenates files ("modules") in a specific way. Modules may have 0 or more dependencies designated by Lua comments that start with "--@" (which must appear before any code at the top of the module). Multiple dependent modules must be separated by whitespace.

Main scripts are designated with Lua comments that start with "--!" followed by the output filename.

So a module *foo* will have the main body in a file named *foo.lua*. It may optionally have "header" and/or "footer" segments (misnomers since they're only headers/footers to the main script's **header**, typically used for configurables). If present, they should be named *foo-header.lua* and *foo-footer.lua*.

Once the build script works out the total order of modules (via the dependency system), they are output like so:

1. Header files, in order
2. Footer files, in reverse order
3. Main body, in reverse order

## Contributing ##

 * Bug fixes, bug reports and small documentation updates always welcome
 
 * I reserve the right to turn away anything else, because:
 
    1. I want to keep this project limited to code and features that I actually use regularly. This ensures that it gets tested regularly as I play and that it gets supported in the future (as long as FtD holds my interest...)

    2. I'm not interested in any major refactoring of the code to clean things up or to conform more to Lua conventions. I've got my own plans for restructuring.

    3. Also not interested in maintaining a generalized library. But feel free to pick and choose modules to be included in one. See LICENSE.

 * Having said all that, feel free to fork. See LICENSE.
