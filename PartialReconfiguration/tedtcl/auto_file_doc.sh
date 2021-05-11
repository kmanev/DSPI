#!/bin/sh
# Mark a file as documented so doxygen gives us undocumented member warnings
echo "## \\file $1 "
cat $1