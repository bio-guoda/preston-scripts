#!/bin/bash
# Date: 2020-10-20
#
# ./match-emails.sh [optional regex]
#
# Streams *exact* content-based locations of email adresses mentioned in biodiversity archives
# registered in GBIF, iDigBio, BioCASe over period 2018-2020 in chronological order.
#
# This script streams a seemingly endless list of email addresses from >500GB biodiversity dataset 
# data using linked Preston tracking logs and versioned content stored across Zenodo, Internet Archive 
# and a hosted server at https://deeplinker.bio .
#
# You can provide any other regex to override the simple default regular expression matching email addresses.
#
# Output: 
#    A two column table with a location and and associated email address:
#       [location]\t[matched content]
#
# location syntax:
#   cut:([optional archive prefix]:)hash://sha256/[content id](!/[optional archive path])!/b[start byte]-[end byte]
#
# examples:
#   cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b2782-2799
# 
#   cut:zip:hash://sha256/cabb30246017945f852a149492bd0b1311a79cfde7cfcea45d15755901dec540!/eml.xml!/b1368-1387
# 
# compatible with universally available POSIX "cut" command https://www.man7.org/linux/man-pages/man1/cut.1p.html :
#
#   $ preston cat hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b | cut -z -b2782-2799
#   gsautter@gmail.com
#
#
# Requirements:
#   - Preston >=v0.2.2
#   - Internet connection
#
# For more information, see https://preston.guoda.bio .
#
# Note: 
# This script does not retain the streamed biodiversity data content to prevent flooding your harddisk. 
# If you'd like to keep a local copy to make the subsequent runs faster, remove the --no-cache options.
#
#set -xe

REGEX_EMAIL="[a-zA-Z0-9_.+-]+@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}"
REGEX_ARCTOS='http://arctos.database.museum/guid/[a-zA-Z]+:[a-zA-Z]+:[^ \t\n,?;]+'
REGEX_ARCTOS_LINKED='(?<subject>$REGEX_ARCTOS).*\((?<verb>[a-zA-Z ]+)\)\s(?<collection>[a-zA-Z]+:[^\s,]+)\s(?<object>$REGEX_ARCTOS)'
REGEX=${1:-$REGEX_EMAIL}

preston ls --no-cache --remote https://zenodo.org/record/3852671/files/,https://deeplinker.bio \
| preston match --no-cache --remote https://archive.org/download/biodiversity-dataset-archives/data.zip/data/,https://deeplinker.bio -l tsv "$REGEX" \
| cut -f1,3 \
| grep -E "$REGEX"

# expected output:
# $ preston ls --no-cache --remote https://deeplinker.bio | pv -l | preston match -l --remote  tsv "$MATCH_REGEX" | cut -f1,3 | grep -E "$MATCH_REGEX" | head
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b2782-2799  gsautter@gmail.com                       ]
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b3092-3107	info@pensoft.net
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b3528-3541	info@plazi.org
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b7108-7123	kenya@arocha.org
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b7590-7615	judithadhiambo85@gmail.com
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b8026-8044	surnbirds@gmail.com
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b8525-8546	rene.navarro@uct.ac.za
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b9045-9067	erustus.kanga@gmail.com
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b9465-9488	colin.jackson@arocha.org
# cut:hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b!/b9961-9986	judithadhiambo85@gmail.com

#
