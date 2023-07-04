#!/bin/sh

in=$1
staging=$2
out=$3

echo 'Copying traefik-certs-dumper certificates ('$in') to '$out' via '$staging

cp -ar $in/. $staging/.

chown -R 997:1002 $staging

rm -rf $out/*

mv $staging/* $out/.
