# refactordoc

The _refactordoc_ script refactors assemblies and modules in AsciiDoc.
It follows conventions of
[Red Hat modular documentation](https://redhat-documentation.github.io/modular-docs/)
and the [newdoc](https://github.com/redhat-documentation/newdoc) tool.

Refactoring a module or assembly means that the script:

* renames the file according to the given title and prefix,
* replaces the AsciiDoc ID on the first line of the file if ID is present,
* replaces the old title with the new title on the second line of the file if a title is present,
* finds and replaces all references of the changed filename, title, and ID in other `.adoc` files.

## Limitations

* The given title must match the filename. The script converts the title to lower case and replaces spaces with hyphens to get the filename.
* The script does not work with attributes in the titles. Attributes will make it fail. It does work with trailing `_{context}` in the ID, but the suffix is removed upon refactoring.
* The script can only rename a file in the same directory.
* The script cannot change the module type given by a prefix.

## Installation

For example:

```
cd ~
git clone git@github.com:Lennonka/refactordoc.git
cd ~/bin
ln -s ~/refactordoc/refactordoc.sh refactordoc
```

## Usage

For example:

```
$ cd guides/
$ refactordoc -p "Registering a host" "Registering a host by using global registration" \
-T common/modules

File renamed successfully from 'common/modules/proc_registering-a-host.adoc'
 to 'common/modules/proc_registering-a-host-by-using-global-registration.adoc'.
Module ID refactored successfully on the first line
 of 'common/modules/proc_registering-a-host-by-using-global-registration.adoc'.
Module title refactored successfully on the second line
 of 'common/modules/proc_registering-a-host-by-using-global-registration.adoc'.
Attempting to refactor references in '.adoc' files starting from the current dir...
Module references refactored successfully in all '.adoc' files.
```

See `refactordoc --help`.
