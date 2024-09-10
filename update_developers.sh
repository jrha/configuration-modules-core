#!/bin/bash

DEBUG=0

for d in ncm-*/; do (
    echo "Processing $d"
    cd "$d" || exit
    file_authors_raw="$(mktemp)"
    git log --no-merges --format="format:%an" | sort  > "$file_authors_raw"

    # Correct names and lookup aliases
    file_authors="$(mktemp)"
    file_unrecognised="$(mktemp)"
    while read -r author_raw; do
        author_name=$(grep -iF "$author_raw" /filestore/scratch/jrha/work.ral/src/jrha/release/src/scripts/update_contributors/names.csv | cut -d , -f 1)
        if [[ -n "$author_name" ]]; then
            echo "$author_name"
        else
            echo "$author_raw" >> "$file_unrecognised"
        fi
    done < "$file_authors_raw" | sort | uniq -c > "$file_authors"
    rm "$file_authors_raw"

    if [[ $DEBUG -gt 0 ]]; then
        echo Recognised Authors
        echo ==================
        cat "$file_authors"
    fi

    if [[ -s "$file_unrecognised" ]]; then
        echo "  Unrecognised Authors:"
        echo
        echo "   Commits | Name"
        echo "  ---------|------"
        sort "$file_unrecognised" | uniq -c | xargs -n 2 printf "%10s | %s\n"
        echo
    fi
    rm "$file_unrecognised"

    # Remove existing developer list with xmlstarlet
    xmlstarlet edit --pf --inplace \
        --delete "_:project/_:developers/_:developer" \
        pom.xml

    # Update developer list with xmlstarlet
    while read -r commit_count author_name; do
        if [[ commit_count -ge 10 ]]; then
            xmlstarlet ed --pf --inplace \
                --subnode _:project/_:developers --type elem --name "developer" \
                --subnode '$prev' --type elem --name "name" -v "$author_name" \
                pom.xml
        fi
    done < "$file_authors"
    rm "$file_authors"

    # Cleanup output with xmllint
    file_output="$(mktemp)"
    cp pom.xml "$file_output"
    xmllint --format "$file_output" > pom.xml

); done
