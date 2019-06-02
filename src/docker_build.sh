#!/bin/bash

for dir in ui post-py comment
do
if [ -d "$dir" ]
then
cd $dir/;
bash docker_build.sh;
cd -;
fi
done
