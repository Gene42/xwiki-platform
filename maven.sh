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

action="${1}"

declare -A moduleMap

for module in $(echo $(./diff.sh))
do
    moduleMap["|${module}|"]="true"
done


output_temp="$(pwd)/out.tmp"
echo "" > ${output_temp}

traverse() (
   folder="${1}"

   cd "${folder}"
   pom_file="pom.xml"

   if [ -e "${pom_file}" ]; then
      artifact_id=$(cat pom.xml | grep artifactId | head -n 2 | tail -n 1 | sed -e 's|^.*<artifactId>||g' -e 's|</artifactId>.*$||g')

      current_folder="$(pwd)"

      modules=$(cat "${pom_file}" | grep \<module\>.*\</module\> | cat)
      commented_out_modules=$(cat "${pom_file}" | grep \<module\>.*\</module\> | grep  \<\!--.*--\> | cat)
      module_dir=$(pwd | sed -e 's|/|\n|g' | tail -n 1)

      if [ "${artifact_id}" ] && [ "${moduleMap["|${artifact_id}|"]}" = "true" ]; then
          echo "${current_folder}" >> ${output_temp}
          echo "${module_dir}"
      else
          #if [ "${modules}" ] && [ -z "${commented_out_modules}" ]; then
             #sed -e 's|<module>|<!--<module>|g' -e 's|</module>|</module>-->|g' -i "${pom_file}"
          #fi
          has_any_sub_module=
          for folder in $(ls)
          do
             if [ -d "${folder}" ] && [ "${folder}" != "target" ] && [ "${folder}" != "src" ]; then
                module=$(traverse "${current_folder}/${folder}")

                if [ "${module}" ]; then
                  #sed -e "s|<\!--<module>${module}</module>-->|<module>${module}</module>|g" -i "${pom_file}"

                  echo "${current_folder}" >> ${output_temp}
                  has_any_sub_module="${module}"
                fi
             fi
          done

          if [ "${has_any_sub_module}" ]; then
            echo "${module_dir}"
          fi
      fi
   fi
)

traverse "$(pwd)"
#echo "$(pwd)/${pom_file}" >> ${output_temp}

output="out.txt"

cat ${output_temp} | sort -u > ${output}

current_folder="$(pwd)"

while read -r line; do
  if [ "${line}" ]; then
     case "${action}" in
     ls|"")
        echo "${line}"
        ;;
     deploy|install)
        #echo "deploy"
        cd ${line}
        mvn --non-recursive "${action}" -DskipTests
        ;;
     *)
        echo "Unknown action, allowed [ls, deploy]"
        ;;
     esac
  fi
done < ${output}

rm ${output_temp}
rm ${output}
