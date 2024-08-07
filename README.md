# refactordoc

The refactordoc tool refactors assemblies and modules in AsciiDoc.
It follows conventions of
[Red Hat modular documentation](https://redhat-documentation.github.io/modular-docs/)
and the [newdoc](https://github.com/redhat-documentation/newdoc) tool.

## Limitations

* The script will only work when the title heading and the filename match precisely, excluding brackets `{}`. It will work when the ID does not match.
* The script cannot detect any context variables. The `project-` and `smart-proxy-` contexts will make it fail because the naming isn't compatible. It does work with trailing `_{context}`, but the suffix is removed upon refactoring.
* The script can only rename a file in the same directory.
* The script cannot change the module type.

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
$ refactordoc -p "Registering a host" "Registering a host by using global registration" \
-T guides/common/modules

File renamed successfully from 'guides/common/modules/proc_registering-a-host.adoc' 
to 'guides/common/modules/proc_registering-a-host-by-using-global-registration.adoc'.
AsciiDoc identifier refactored successfully on the first line 
of 'guides/common/modules/proc_registering-a-host-by-using-global-registration.adoc'.
Module title refactored successfully 
inside 'guides/common/modules/proc_registering-a-host-by-using-global-registration.adoc'.
Module titles and IDs refactored successfully in all '.adoc' files starting from the current directory.
```

See `refactordoc --help`.
