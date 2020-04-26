#!/bin/sh
# dwl.sh
# Copyright (c) 2020 Nils Stratmann <dev@uniporn.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# according to https://insanity.industries/post/safeshell/
set -e
set -u
set -o pipefail
set -E
export SHELLOPTS

# maybe reuse this script some other time?

URL1='https://link.springer.com/search/page/'
URL2='?facet-content-type=%22Book%22&package=mat-covid19_textbooks&facet-language=%22En%22&sortOrder=newestFirst&showAll=true'
URL_BASE='https://link.springer.com'

DEST="$(pwd)/springer-books"

# make working dir
mkdir -p "$DEST"
cd "$DEST"

# download list of links to book-pages
for i in {1..21}; do
    curl "${URL1}${i}${URL2}" | grep 'class="title"' | awk -F'href="' '{print $2}' | awk -F'" title="' '{print $1}' >> books.txt
done

# get list of download locations
while IFS= read -r line
do
    curl "${URL_BASE}${line}" | grep 'class="c-button' | awk -F'href="' '{print $2}' | awk -F'" title=' '{print $1}' | awk -F'" target="' '{print $1}' | sort | uniq >> dwl.txt
done < books.txt

# actual download
while IFS= read -r line
do
    filename=$(basename $line)
    curl -o "$filename" "${URL_BASE}${line}"

done < dwl.txt

rm books.txt dwl.txt
