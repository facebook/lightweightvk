# LightweightVK
#
# Copyright (c) 2023-2026 Sergey Kosarevsky and contributors.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

if(NOT MANIFEST_DIR OR NOT LIBRARY_DIRS)
  message(FATAL_ERROR "MANIFEST_DIR and LIBRARY_DIRS are required")
endif()

string(REPLACE "|" ";" LIBRARY_DIRS "${LIBRARY_DIRS}")

file(GLOB manifests "${MANIFEST_DIR}/VkLayer_*.json")

if(NOT manifests)
  message(FATAL_ERROR "No layer manifests found in ${MANIFEST_DIR}")
endif()

foreach(manifest ${manifests})
  file(READ "${manifest}" content)
  string(REGEX MATCH "\"library_path\"[ \t]*:[ \t]*\"([^\"]*)\"" match "${content}")
  if(NOT match)
    message(WARNING "No library_path in ${manifest}")
    continue()
  endif()
  get_filename_component(library_name "${CMAKE_MATCH_1}" NAME)
  set(library_path "")
  foreach(dir ${LIBRARY_DIRS})
    if(EXISTS "${dir}/${library_name}")
      set(library_path "${dir}/${library_name}")
      break()
    endif()
  endforeach()
  if(NOT library_path)
    message(FATAL_ERROR "Cannot find ${library_name} in ${LIBRARY_DIRS}")
  endif()
  string(REPLACE "${match}" "\"library_path\": \"${library_path}\"" content "${content}")
  file(WRITE "${manifest}" "${content}")
  message(STATUS "${manifest}: library_path = ${library_path}")
endforeach()
