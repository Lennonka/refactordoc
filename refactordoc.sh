#!/bin/bash

# Function to display usage help
usage() {
    echo "Usage: $0 <prefix> <old_module_title> <new_module_title> [-T target_path]"
    echo
    echo "Refactors a module or assembly by doing the following:"
    echo
    echo "* renames the file according to the given title and prefix"
    echo "* replaces the AsciiDoc ID on the first line of the file"
    echo "* replaces the old title with the new title on the second line of the file"
    echo "* finds and replaces all occurences of titles and IDs in other .adoc files"
    echo
    echo "Prefixes:"
    echo "  -c    Use 'con_' prefix for concept module"
    echo "  -p    Use 'proc_' prefix for procedure module"
    echo "  -r    Use 'ref_' prefix for reference module"
    echo "  -a    Use 'assembly_' prefix for assembly"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message and exit"
    echo "  -T target_path  Specify the target path for the renamed file (also used as the source path)"
    echo "                  If no path is given, looks for the file in the current directory."
    echo "  -R              Inhibit replacement in all '.adoc' files"
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi

# Check if at least three arguments are provided
if [[ $# -lt 3 ]]; then
    echo "Error: At least three arguments are required."
    usage
    exit 1
fi

prefix_arg="$1"
old_module_title="$2"
new_module_title="$3"
target_path=""
inhibit_replacement=false

# Check for additional arguments
shift 3
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -T)
            target_path="$2"
            shift 2
            ;;
        -R)
            inhibit_replacement=true
            shift
            ;;
        *)
            echo "Error: Invalid argument '$1'"
            usage
            exit 2
            ;;
    esac
done

# Determine prefix based on argument
case "$prefix_arg" in
    -c) prefix="con_" ;;
    -p) prefix="proc_" ;;
    -r) prefix="ref_" ;;
    -a) prefix="assembly_" ;;
    *)
        echo "Error: Invalid prefix argument."
        usage
        exit 3
        ;;
esac

# Convert module titles to filenames with prefix and .adoc suffix
old_filename="${prefix}$(echo "$old_module_title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed -E 's/[\{\}]//g').adoc"
new_filename="${prefix}$(echo "$new_module_title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed -E 's/[\{\}]//g').adoc"

# Prepend target path if provided
if [[ -n "$target_path" ]]; then
    old_filepath="$target_path/$old_filename"
    new_filepath="$target_path/$new_filename"
else
    old_filepath="$old_filename"
    new_filepath="$new_filename"
fi

# Check if the old file exists
if [[ ! -f "$old_filepath" ]]; then
    echo "Error: File '$old_filepath' does not exist."
    exit 4
fi

# Rename the file
mv "$old_filepath" "$new_filepath"

# Check if the rename operation was successful
if [[ $? -eq 0 ]]; then
    echo "File renamed successfully from '$old_filepath' to '$new_filepath'."
else
    echo "Error: Failed to rename file."
    exit 5
fi

# Refactor the AsciiDoc identifier on the first line
old_id=`head -1 "$new_filepath" | sed -E 's/\[id=\"([^"]+)\"\]/\1/' | sed -E 's/(\{)/\\\{/g' | sed -E 's/(\})/\\\}/g'`
#echo "Old ID: '$old_id'"
new_id=$(echo "$new_module_title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
sed -i -E "1s/$old_id/$new_id/" "$new_filepath"

# Check if the AsciiDoc identifier replacement was successful
if [[ $? -eq 0 ]]; then
    echo "Module ID refactored successfully on the first line of '$new_filepath'."
else
    echo "Error: Failed to refactor module ID on the first line."
    exit 6
fi

# Refactor the module title inside the file
sed -i -E "2s/^= $old_module_title$/= $new_module_title/" "$new_filepath"

# Check if the sed operation was successful
if [[ $? -eq 0 ]]; then
    echo "Module title refactored successfully on the second line of '$new_filepath'."
else
    echo "Error: Failed to refactor module title on the second line."
    exit 7
fi

# Replace module titles and IDs in all '.adoc' files if not inhibited
if [[ "$inhibit_replacement" == false ]]; then
    echo "Attempting to refactor references in '.adoc' files starting from the current dir..."
    find . -type f -name '*.adoc' | while read -r file; do
        sed -i -E "s/xref:$old_id\[/xref:$new_id\[/g" "$file" # xrefs
	[ $? -eq 0 ] || ( echo "E: Trouble refactoring xrefs" && exit 81 )
        sed -i -E "s/DocURL\}$old_id\[/DocURL\}$new_id\[/g" "$file" # external links
	[ $? -eq 0 ] || ( echo "E: Trouble refactoring external links" && exit 82 )
        sed -i -E "s/\[$old_module_title\]/\[$new_module_title\]/g" "$file" # link titles
	[ $? -eq 0 ] || ( echo "E: Trouble refactoring ext. link titles" && exit 83 )
	sed -i -E "s/$old_filename/$new_filename/g" "$file" # inclusions
	[ $? -eq 0 ] || ( echo "E: Trouble refactoring inclusions" && exit 84 )
    done

    if [[ $? -eq 0 ]]; then
        echo "Module references refactored successfully in all '.adoc' files."
    fi
else
    echo "Inhibition of replacement in all '.adoc' files is active. Skipping file updates."
fi

