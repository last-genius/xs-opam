# Opam Repository for the xapi components of xenserver

[![Build Status](https://github.com/xapi-project/xs-opam/actions/workflows/main.yml/badge.svg)](https://github.com/xapi-project/xs-opam/actions/workflows/main.yml)
[![LCM Build Status](https://github.com/xapi-project/xs-opam/actions/workflows/lcm.yml/badge.svg)](https://github.com/xapi-project/xs-opam/actions/workflows/lcm.yml)
[![LCM Scheduled Build Status](https://github.com/xapi-project/xs-opam/actions/workflows/yangtze-lcm.yml/badge.svg)](https://github.com/xapi-project/xs-opam/actions/workflows/yangtze-lcm.yml)
[![Old LCM Scheduled Build Status](https://github.com/xapi-project/xs-opam/actions/workflows/stockholm-lcm.yml/badge.svg)](https://github.com/xapi-project/xs-opam/actions/workflows/stockholm-lcm.yml)

This [Opam] repository contains the [OCaml] components of the XenServer
toolstack and their upstream dependencies. This is just package metadata
(not the actual source code) that tells [Opam] how to download source
code, compile, and install packages.

## Using this OPAM Repository for Dev Work

You can add this Git repository as a remote [Opam] repository to your
local [Opam] setup in order to install XenServer packages. See
below for an alternative using Docker when you don't want to use [Opam]
natively. Please be aware that this is not giving you a working XenServer
installation because this depends on other components. It is
most useful for development outside a build system for the complete
XenServer distribution.

```bash
opam repo add xs-opam https://github.com/xapi-project/xs-opam.git
```

### Installing packages

To install all dependencies of xapi, use the xs-toolstack metapackage:

```bash
opam install -t xs-toolstack
```

Additionally, there are developer tools, like utop, merlin or the lsp server:

```bash
opam install dev-tools
```

## Continuous Integration

Github Actions builds the entire universe represented by this Opam repository.

[Opam]:    http://opam.ocaml.org
[OCaml]:   http:/ocaml.org
[Docker]:  https://www.docker.com/

### Using xs-opam on github actions builds

To use the repository in github actions 3 steps are needed to set up the opam environment:
- One to download the .env file
- One to load it into the environment
- One to initialize the opam environment

Here's an example template for the standard `.github/workflows/main.yml`, package should be change to include the opam packages available in the repository and the build and test steps adapted to the repository.

```yaml
name: Build and test

on:
  push:
  pull_request:

jobs:
  ocaml-test:
    name: Ocaml tests
    runs-on: ubuntu-20.04
    env:
      package: "EXAMPLE-BINARY EXAMPLE-LIBRARY"

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Pull configuration from xs-opam
        run: |
          curl --fail --silent https://raw.githubusercontent.com/xapi-project/xs-opam/master/tools/xs-opam-ci.env | cut -f2 -d " " > .env

      - name: Load environment file
        id: dotenv
        uses: falti/dotenv-action@v0.2.4

      - name: Use ocaml
        uses: avsm/setup-ocaml@v1
        with:
          ocaml-version: ${{ steps.dotenv.outputs.ocaml_version_full }}
          opam-repository: ${{ steps.dotenv.outputs.repository }}

      - name: Install dependencies
        run: |
          opam pin add . --no-action
          opam depext -u ${{ env.package }}
          opam install ${{ env.package }} --deps-only --with-test -v

      - name: Build
        run: |
          opam exec -- ./configure
          opam exec -- make

      - name: Run tests
        run: opam exec -- make test
```

## Development on xs-opam

xs-opam's purpose is to provide packages for the ocaml xapi-project packages.
It's used also as what would now would be called a 'lock file', so most of the time only one version of a package is present in the repository to minimize the size of the tarballs produced from it and easily tell which version is used.
The exception to this rule is to allow the project to work for different versions of the OCaml compiler at the same time.

### Setting up a working environment to develop on xs-opam

Clone this repository, then use the file location to use it as the repository for a new switch, and install all the packages, like so:
```bash
opam switch create 9.0-xcp --repos=xs-opam-local=git+file://${PWD} ocaml.4.14.2
opam install xs-toolstack dev-tools -y
```

This allows us to test upgrades and see that all packages are installable.

### Finding upgradable packages

This needs adding the default repository, but with lower priority that the local repository, as well as explicitly request to upgrade all packages, while locking some packages to a version.
Locking packages to a version is useful when newer versions of a package breaks its interface. Locking can be done by using the already-installed version, or using a specific version that's known to not contain breaking changes.

This can be done like so:
```bash
opam repo add default && opam repo priority default 2 && OPAMNO=true opam upgrade --all tar.2.6.0 cohttp.5.3.1
```

Output:
```
<><> Updating package repositories ><><><><><><><><><><><><><><><><><><><><><><>
[xs-opam-local] no changes from git+file:///home/pau/code/xcp/ocaml/xs-opam
[default] no changes from https://opam.ocaml.org
The following actions will be performed:
=== recompile 174 packages

[...]

=== upgrade 75 packages
  ↗ alcotest                   1.9.0 to 1.9.1       [uses dune]
  ↗ alcotest-lwt               1.9.0 to 1.9.1       [uses dune]
  ↗ ambient-context            0.1.0 to 0.2         [uses dune]
  ↗ base                       v0.16.3 to v0.16.5   [uses dune]
  ↗ base64                     3.5.1 to 3.5.2       [uses dune]
  ↗ bos                        0.2.1 to 0.3.0       [uses fmt]
  ↗ ca-certs                   1.0.1 to 1.0.3       [uses dune]
  ↗ checkseum                  0.5.2 to 0.5.3       [uses dune]
  ↗ chrome-trace               3.20.2 to 3.23.1     [uses dune]
  ↗ cohttp                     5.3.1 to 6.1.1       [uses dune]
  ↗ cohttp-lwt                 5.3.0 to 6.1.1       [uses dune]
  ↗ cohttp-lwt-unix            5.3.0 to 6.1.1       [uses dune]
  ↗ conf-gmp                   4 to 5               [required by conf-gmp-powm-sec]
  ↗ conf-gmp-powm-sec          3 to 4               [required by mirage-crypto-pk]
  ↗ conf-libev                 4-12 to 4-13         [required by lwt]
  ↗ conf-pkg-config            4 to 5               [required by dlm]
  ↗ crowbar                    0.2.1 to 0.2.2       [uses dune]
  ↗ crunch                     3.3.1 to 4.0.0       [uses dune]
  ↗ ctypes                     0.23.0 to 0.24.0     [uses dune]
  ↗ ctypes-foreign             0.23.0 to 0.24.0     [uses dune]
  ↗ domain-name                0.4.1 to 0.5.0       [uses dune]
  ↗ dune                       3.20.2 to 3.23.1     [required by tar]
  ↗ dune-build-info            3.20.2 to 3.23.1     [uses dune]
  ↗ dune-configurator          3.20.2 to 3.23.1     [uses dune]
  ↗ dune-private-libs          3.20.2 to 3.23.1     [uses dune]
  ↗ dune-rpc                   3.20.2 to 3.23.1     [uses dune]
  ↗ dune-site                  3.20.2 to 3.23.1     [uses dune]
  ↗ duration                   0.2.1 to 0.3.1       [uses dune]
  ↗ dyn                        3.20.2 to 3.23.1     [uses dune]
  ↗ eqaf                       0.9 to 0.10          [uses dune]
  ↗ ezcurl                     0.2.4 to 0.3         [uses dune]
  ↗ fix                        20230505 to 20250919 [uses dune]
  ↗ fmt                        0.10.0 to 0.11.0     [required by alcotest]
  ↗ integers                   0.7.0 to 0.8.0       [uses dune]
  ↗ ipaddr                     5.6.0 to 5.6.2       [uses dune]
  ↗ ipaddr-sexp                5.6.0 to 5.6.2       [uses dune]
  ↗ lambda-term                3.3.2 to 3.4.0       [uses dune]
  ↗ logs                       0.8.0 to 0.10.0      [uses fmt]
  ↗ lwt                        5.9.1 to 5.10.0      [uses dune]
  ↗ macaddr                    5.6.0 to 5.6.2       [uses dune]
  ↗ menhir                     20240715 to 20260209 [uses dune]
  ↗ menhirCST                  20240715 to 20260209 [uses dune]
  ↗ menhirLib                  20240715 to 20260209 [uses dune]
  ↗ menhirSdk                  20240715 to 20260209 [uses dune]
  ↗ mirage-crypto              2.0.1 to 2.1.0       [uses dune]
  ↗ mirage-crypto-ec           2.0.1 to 2.1.0       [uses dune]
  ↗ mirage-crypto-pk           2.0.1 to 2.1.0       [uses dune]
  ↗ mirage-crypto-rng          2.0.1 to 2.1.0       [uses dune]
  ↗ ocaml-version              4.0.0 to 4.1.2       [uses dune]
  ↗ ocamlc-loc                 3.20.2 to 3.23.1     [uses dune]
  ↗ ocamlformat                0.28.1 to 0.29.0     [uses dune]
  ↗ ocamlformat-lib            0.28.1 to 0.29.0     [uses dune]
  ↗ ocamlformat-rpc-lib        0.28.1 to 0.29.0     [uses dune]
  ↗ ocp-indent                 1.8.1 to 1.9.0       [uses dune]
  ↗ odoc                       3.1.0 to 3.2.1       [uses dune]
  ↗ odoc-parser                3.1.0 to 3.2.1       [uses dune]
  ↗ opentelemetry              0.10 to 0.90         [uses dune]
  ↗ opentelemetry-client-ocurl 0.10 to 0.90         [uses dune]
  ↗ ordering                   3.20.2 to 3.23.1     [uses dune]
  ↗ pbrt                       3.1.1 to 4.1         [uses dune]
  ↗ polly                      0.4.1 to 0.5.0       [uses dune]
  ↗ ppx_deriving_rpc           9.0.0+2 to 10.2.0    [uses dune]
  ↗ prometheus                 1.2 to 1.3           [uses dune]
  ↗ qcheck-alcotest            0.24 to 0.91         [uses dune]
  ↗ qcheck-core                0.24 to 0.91         [uses dune]
  ↗ re                         1.12.0 to 1.14.0     [uses dune]
  ↗ rpclib                     9.0.0+2 to 10.2.0    [uses dune]
  ↗ rpclib-lwt                 9.0.0+2 to 10.2.0    [uses dune]
  ↗ stdune                     3.20.2 to 3.23.1     [uses dune]
  ↗ topkg                      1.0.8 to 1.1.1       [required by fmt]
  ↗ tyre                       0.5 to 1.0           [uses dune]
  ↗ utop                       2.16.0 to 2.17.0     [uses dune]
  ↗ uucp                       16.0.0 to 17.0.0     [uses topkg]
  ↗ uuseg                      16.0.0 to 17.0.0     [uses topkg]
  ↗ xdg                        3.20.2 to 3.23.1     [uses dune]
=== install 7 packages
  ∗ fs-io                      3.23.1               [required by stdune]
  ∗ http                       6.1.1                [required by cohttp]
  ∗ menhirGLR                  20260209             [required by menhir]
  ∗ opentelemetry-client       0.90                 [required by opentelemetry-client-ocurl]
  ∗ pbrt_yojson                4.1                  [required by opentelemetry]
  ∗ thread-local-storage       0.2                  [required by ambient-context]
  ∗ top-closure                3.23.1               [required by stdune]

Proceed with ↻ 174 recompilations, ↗ 75 upgrades and ∗ 7 installations? [Y/n] n
```

### Upgrade a new package version

Now we're ready to start updating packages, giving special attention to the package that come from the same source repository which need to be updated at the same time.

To update the metadata, a helper is recommended, like this one:
```fish
function opam-update
  if test (count $argv) -ne 3
    echo "opam_update: expected 3 args"
    echo "Usage: oswitch <name> <old version> <new version>"
    return -1
  end
  set name "$argv[1]"
  set old "$argv[2]"
  set new "$argv[3]"
  git mv packages/$name/$name.$old packages/$name/$name.$new
  opam show --raw $name.$new > packages/$name/$name.$new/opam
end
```

This helper moves the opam metadata file for a package to the new version, and replace its contents with metadata from the default repository.

For example, to update all the dune packages at the same time, such a command can be used:
```fish
for pkg in chrome-trace dune dune-build-info dune-configurator dune-rpc dyn ocamlc-loc ordering stdune xdg; and opam-update $pkg 3.18.2 3.20.2; end
```

Now the change should be committed before testing it, or opam will ignore the changes.

When that is done, the change can be tested by removing the default repository and upgrading opam:
```bash
opam repo remove default && opam update -u
```

To repeat the step re-add the default repository so the metadata can be fetched by the helper again.


### Add a new package
Similar to upgrading a package, a helper is useful for this, which works when the switch has enabled the default repository:
```fish
function opam-new
  if test (count $argv) -lt 2
    echo "opam_new: expected a least 2 args"
    echo "Usage: oswitch <name> <version>"
    return -1
  end
  set name "$argv[1]"
  set ver "$argv[2]"
  set package "$name.$ver"
  mkdir -p "packages/$name/$package"
  opam show --raw "$package" > "packages/$name/$package/opam"
end 
```

One thing to note is that if it meant to be used, it needs to be added as a dependency to the metapackage of xs-toolstack or dev-tools, if it's meant to be packaged; or to the ignored packages, if it's only meant to be used for testing a feature that's not package yet.


### Updating stale metadata

To update the stale metadata a (surprise, surprise) helper can be used yet again.
It also needs to have the default repository in the loaded switch:

```fish
function opam-update-upstream
  opam repo add default
  opam repo priority default 1
  for dir in packages/*/*
    set -l versioned (path basename $dir)
    if string match --regex -v '.master' $versioned
      opam show --raw "$versioned" > "$dir/opam"
    end
  end
end 
```

The helper only works on the master branch and not LCM branch, but the versions in the LCM are already outdated with respect of the upstream versions available, so they usually don't require updating.
