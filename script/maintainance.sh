#!/usr/bin/env bash
#--------------------------------------------------------------------------------
# Set the exec permission to scripts in the git repository.
#--------------------------------------------------------------------------------
cd $(dirname $0)
find . -name '*.sh' | xargs -I % /bin/bash -c "git add %; "
find . -name '*.sh' | xargs -I % /bin/bash -c "chmod u+x %; "
find . -name '*.sh' | xargs -I % /bin/bash -c "git update-index --chmod=+x % "

#--------------------------------------------------------------------------------
# Remove terraform artefacts
#--------------------------------------------------------------------------------
find . -type d -name '.terraform' | xargs rm -rf
#find . -type f -name '*.zip' | xargs rm -rf
find . \( -name 'tfplan' -o -name '*.log' -o -name '*~' \) | xargs rm -f
find -type d -path '*/lambda/python/*' -prune -exec rm -r {} \;

#--------------------------------------------------------------------------------
# Remove ansible artefacts
#--------------------------------------------------------------------------------
find . -type f \( -name 'site.retry' -o -name 'ansible.log' -o -name '*~' \) | xargs rm -f
