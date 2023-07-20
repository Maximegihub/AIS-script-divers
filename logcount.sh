#!/bin/bash
d1=$(date --date='5 min ago' "+%FT%R")
awk "/^$d1/{p++} p" /var/log/messages | wc -l
