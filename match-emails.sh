#!/bin/bash
#
# List *exact* locations of email adresses in biodiversity archive using
# Preston "match" and a regular expression.
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
#   $ preston cat hash://sha256/184886cc6ae4490a49a70b6fd9a3e1dfafce433fc8e3d022c89e0b75ea3cda0b | cut -b2782-2799
#   gsautter@gmail.com
#
# Date: 2020-10-20
#
# Requirements:
#   - Preston >v0.2.0
#   - Internet connection
set -xe

preston ls --remote https://deeplinker.bio | preston match -l tsv "[a-zA-Z0-9_.+-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}" | cut -f1,3 | grep -E "[a-zA-Z0-9_.+-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}" 

# expected output:
# $ preston ls | pv -l | preston match -l tsv "[a-zA-Z0-9_.+-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}" | cut -f1,3 | grep -E "[a-zA-Z0-9_.+-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}" | head
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
