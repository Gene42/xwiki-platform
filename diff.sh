#!/bin/bash
# ---------------------------------------------------------------------------
# See the NOTICE file distributed with this work for additional
# information regarding copyright ownership.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.
# ---------------------------------------------------------------------------

#output=$(git diff --name-only origin/stable-7.1.x xwiki-7.1.4-gene42 | grep -v ".pom.xml" | cut -d"/"  -f -3 | sort -u)
output=$(git diff --name-only origin/stable-7.1.x xwiki-7.1.4-gene42 | grep -v "pom.xml" | sed -e "s|/src/.*||g" | awk -F "/" '{print $NF}' | sort -u)

#git diff --name-only origin/stable-7.1.x xwiki-7.1.4-gene42 | grep -v "pom.xml"

all_files=$(git diff --name-only origin/stable-7.1.x xwiki-7.1.4-gene42)
all_files_no_poms=$(git diff --name-only origin/stable-7.1.x xwiki-7.1.4-gene42 | grep -v "pom.xml")
all_files=${all_files_no_poms}

declare -A map

for module in $(echo ${output})
do
   #echo "${module}"
   current=""
   for file_path in $(echo "${all_files}")
   do
      if [ "$(echo ${file_path} | grep "${module}" | cat)" ]; then
        current="${current},${file_path}"
      fi
   done
   map["${module}"]="${current}"
done

for module in $(echo ${output})
do
    echo "${module}"
    #for file_path in $(echo ${map["${module}"]} | sed -e "s|,|\n|g")
    #do
       ##final_file=$(echo ${file_path} | awk -F"/" '{print $NF}')
       #final_file=${file_path}
       #echo "---- ${final_file}"
       #git checkout stable-7.1.x ${final_file}
    #done

done
