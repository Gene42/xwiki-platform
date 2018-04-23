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

set -e

declare -A moduleMap

for module in $(echo $(./diff.sh))
do
    moduleMap["${module}"]="true"
done


output="$(pwd)/out.tmp"
echo "" > ${output}

traverse() (
   folder="${1}"

   cd "${folder}"
   pom_file="pom.xml"

   if [ -e "${pom_file}" ]; then
      artifact_id=$(cat pom.xml | grep artifactId | head -n 2 | tail -n 1 | sed -e 's|^.*<artifactId>||g' -e 's|</artifactId>.*$||g')

      current_folder="$(pwd)"

      if [ "${artifact_id}" ] && [ "${moduleMap["${artifact_id}"]}" = "true" ]; then
          #mvn --non-recursive -U install

          echo "${current_folder}/${pom_file}" >> ${output}
          echo "yes"
      else
          for folder in $(ls)
          do
             if [ -d "${folder}" ] && [ "${folder}" != "target" ] && [ "${folder}" != "src" ]; then
                response=$(traverse "${current_folder}/${folder}")

                if [ "${response}" = "yes" ]; then
                  echo "${current_folder}/${pom_file}" >> ${output}
                fi
             fi
          done
      fi
   fi
)

traverse "$(pwd)"

cat ${output} | sort -u > "out.txt"

