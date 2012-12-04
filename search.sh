#!/bin/bash

# Given a querey, looks for packages that match the query string
# Unnecessary shit is trimmed
yum search $1 | tail -n +4 | head -n -2
