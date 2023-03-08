# Bootstrapping a simula-buildconf based autoproj workspace

Select or create your workspace. Typically that will be initially empty.

```
    mkdir workspace
    cd workspace
```

To retrieve an run the bootstrap script, your system has to meet some minimal requirements for running Ruby
and downloading (via wget or curl, here we use wget):

```
    sudo apt install wget ruby ruby-dev
```

Download the bootstrap script and a minimal start configuration. That way you do not have to interactively
answer questions during the bootstrap.

```
    wget https://raw.githubusercontent.com/2maz/simula-buildconf/main/bootstrap.sh
    wget https://raw.githubusercontent.com/2maz/simula-buildconf/main/.ci/autoproj-config.yml

    ./bootstrap.sh --seed-config=autoproj-config.yml
```

The bootstrap will ask you one question at the end that you can safely confirm.

```
    ... 
    Using autobuild 1.24.0 from https://github.com/2maz/autobuild (at master@e50ea4c)
    Using rb-inotify 0.10.1
    Installing backports 3.24.0
    Using autoproj 2.16.0 from https://github.com/rock-core/autoproj (at fix_bootstrap@b31b30c)
    Bundle complete! 2 Gemfile dependencies, 27 gems now installed.
    Bundled gems are installed into `/home/roehr/.local/share/autoproj/gems`
    starting the newly installed autoproj for stage2 install
    saving temporary env.sh and .autoproj/env.sh
    running 'autoproj envsh' to generate a proper env.sh
      updated environment
    running 'autoproj osdeps' to re-install missing gems
      updated environment
    Command finished successfully at 2023-03-08 09:07:38 +0100
    The current directory is not empty, continue bootstrapping anyway ? [yes] 
```

The installation will proceed.

```
    autoproj bootstrap successfully finished

    To further use autoproj and the installed software, you
    must add the following line at the bottom of your .bashrc:
    source /home/simula/workspace/env.sh

    WARNING: autoproj will not work until your restart all
    your consoles, or run the following in them:
    $ source /home/simula/workspace/env.sh

    To import and build the packages, you can now run
    aup
    amake

    The resulting software is installed in
    /home/simula/workspace/install

      operating system: ubuntu,debian - 22.04,22.04.2,lts,jammy,jellyfish
      updating bundler
      updating autoproj
      bundler: connected to https://rubygems.org/
      already up-to-date autoproj main configuration
      checked out git:https://github.com/2maz/simula-package_set.git interactive=false push_to=https://github.com/2maz/simula-package_set.git repository_id=github:/2maz/simula-package_set.git retry_count=10
      checked out git:https://github.com/2maz/fenics-package_set.git interactive=false push_to=https://github.com/2maz/fenics-package_set.git repository_id=github:/2maz/fenics-package_set.git retry_count=10
      checked out simula-comphy/cardiac_geometries
      WARN: simula-comphy/cardiac_geometries from simula-computational-physiology does not have a manifest
      checked out simula-comphy/ap_features
      WARN: simula-comphy/ap_features from simula-computational-physiology does not have a manifest
      checked out graph/kahip
      WARN: graph/kahip from fenics does not have a manifest
      checked out simula-comphy/drug-database
```

You will be asked to confirm the location of the python binary. This binary will be used in order to create an isolated python environment for your workspace, i.e., 
shims for 'python' and 'pip' will be created in /home/simula/workspace/install/bin

```
    Select the path to the python executable [/usr/bin/python3] 
```

Finally, to work with this environment, i.e., to activate it - start by sourcing the env.sh:

```
    source /home/simula/workspace/env.sh
```


## Usage examples

### Update and build a package

```
    autoproj update simula-comphy/goss
    autoproj build simula-comphy/goss
```

In order to rebuild:

```
    autoproj clean simula-comphy/goss
    autoproj build simula-comphy/goss
```


### Ensure that all osdeps are installed for a package

When you update the os dependencies or the initial bootstrap failed for some reason intermittedly, make sure that all
os dependencies are installed.

For an individual package:

```
    autoproj osdeps simula-comphy/goss
```

For all packages in the workspace:

```
    autoproj osdeps simula-comphy/goss
```



### Show the contents of the package set fenics

```
    autoproj show fencis
```

```
    package set fenics
      overrides key: pkg_set:github:/2maz/fenics-package_set.git
      checkout dir: /opt/workspace/presentations/simula-test-env/.autoproj/remotes/github__2maz_fenics_package_set_git
      symlinked to: /opt/workspace/presentations/simula-test-env/autoproj/remotes/fenics
      version control information:
        type: git
        url: git@github.com:/2maz/fenics-package_set.git
        interactive: false
        push_to: git@github.com:/2maz/fenics-package_set.git
        repository_id: github:/2maz/fenics-package_set.git
        retry_count: 10
        first match: in main configuration (/opt/workspace/presentations/simula-test-env/autoproj/overrides.yml)
          github: 2maz/fenics-package_set
      refers to 13 packages
        communication/adios2, fenics/basix/cpp, fenics/basix/python, fenics/docs, fenics/dolfinx/cpp, fenics/dolfinx/python, fenics/ffcx, fenics/spack,
        fenics/ufl, fenics/web, graph/kahip, scientific_computing/petsc, scientific_computing/petsc4py
```


### Autodetection of packages and build types

If you create a new CMake package in your workspace, e.g., 
simula-comphy/my-new-package you can also run amake on this package.

Autoproj will try to guess the build system, e.g., when a CMakeLists.txt is available it will
assume it is a CMake package and build it accordingly.


```
    amake simula-comphy/my-new-package
```



## Directory structure of autoproj/

The *autoproj/* directory (this directory) contains the files and configuration
that define the whole build.:

- manifest:
  Simple key-value pair file in the YAML format. It lists sources for "package
  sets", other autoproj configuration directories in which packages have been
  declared for you to reuse (package_sets section). It also lists the packages
  that you actually want to build (layout section)


### Package sets

Package sets can either be stored as a direct subfolder in autoproj/ or can be cloned from 
a specified location as so-called remote package set.
Remotes will be bootstrapped into autoproj/remotes/.

remotes/:
  contains a checkout of the package sets listed in the manifest. You should not
  have to go in there unless you are yourself developing a package set.

#### Package Set Structure

- config.yml:
  Autoproj can be parametrized by build options. This file is where your
  previous choices for these options are saved. You should not change it manually.
  If you need tou change an option, run
    autoproj reconfigure |

- overrides.yml:
  Simple key-value pair file in the YAML format.  It allows to override branch
  information for specific packages.  Most people leave this to the default,
  unless they want to use a feature from an experimental branch. See the following
  page for a description of its contents.
    http://www.rock-robotics.org/stable/documentation/autoproj/advanced/importers.html

- init.rb:
  Ruby script that contains customization code that will get executed before
  autoproj is loaded.

- overrides.rb: 
  Ruby script that contains customization code that will get executed after
  autoproj is loaded, but before the build starts.


## Package Types

### CMake

Environment variables such as
'CMAKE_PREFIX_PATH' are always picked up. You can set them
in init.rb too, which will copy them to your env.sh script.

Because of cmake's aggressive caching behaviour, manual options
given to cmake will be overriden by autoproj later on. To make
such options permanent, add

``` 
  package('package_name').define "OPTION", "VALUE"
``` 


in overrides.rb. For instance, to set CMAKE_BUILD_TYPE for the rtt
package, do

``` 
  package('rtt').define "CMAKE_BUILD_TYPE", "Debug"
``` 


