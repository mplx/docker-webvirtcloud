#!/bin/bash

# check_cla()
# https://jameshunt.us/writings/travis-cla.html
check_cla() {
  local passchar="\xe2\x9c\x94" # U+2714 - ballot check
  local failchar="\xe2\x9c\x98" # U+2718 - ballot x
  local rc=0
  local IFS=$'\n'

  echo "Checking CONTRIBUTOR status..."
  for x in $(git log --pretty=format:'%aE %h - %s (%aN <%aE>)' \
                 ${TRAVIS_COMMIT_RANGE}); do
    email=${x%% *}
    desc=${x#* }
    if grep -q '^[^#].*<'${email}'>' CONTRIBUTORS; then
      echo -e "\033[32m${passchar}\033[0m $desc"
    else
      echo -e "\033[31m${failchar}\033[0m $desc"
      echo -e "  \033[31m<${email}> not listed in CONTRIBUTORS file!\033[0m"
      rc=1
    fi
  done
  echo

  return $rc
}

check_cla
