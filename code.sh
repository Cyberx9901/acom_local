#!/bin/bash
read -p "Code" code
echo V2"$(echo $code | sed s/"r:"/"\nr:"/g | cut -d ' ' -f1 | grep r\: | sed s/"r:"/'-'/g | tr -d '\n' )"
