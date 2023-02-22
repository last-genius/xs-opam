#! /bin/bash
# Require all upstream packages to be licensed

set -euo pipefail

errors=false

for file in packages/{upstream,xs}/*/opam;
do
  name=$(basename ${file%%.*})
  if ! license=$(grep 'license: ' $file); then 
    echo "ERROR: Package $name does not have a license"
    errors=true
  fi
  license=$(grep -Po 'license: \K.*' $file| tr -d '"')
  if echo $license | grep -vqEx 'Apache-1.0|Apache-2.0|BSD-2-Clause|BSD-3-Clause|GPL-1.0-or-later|GPL-3.0-only|ISC|MIT|MPL-2.0|LGPL-2.0-or-later|LGPL-2.1-only|LGPL-2.0-only WITH OCaml-LGPL-linking-exception|LGPL-2.0-or-later WITH OCaml-LGPL-linking-exception|LGPL-2.1-only WITH OCaml-LGPL-linking-exception|LGPL-2.1-or-later WITH OCaml-LGPL-linking-exception|LGPL-3.0-only WITH OCaml-LGPL-linking-exception|LGPL with OpenSSL linking exception|MIT AND LGPL-2.1-only WITH OCaml-LGPL-linking-exception'; then 
    echo "Unrecognised license used for $name: $license. Is it a valid a SPDX identifier?"
    errors=true
  fi
done

if $errors; then
  exit 1
else
  echo OK
fi
