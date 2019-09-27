# Bash Init
Super-flexible, system-aware initialization scripts for bash environments

Most software folks these days find themselves working in multiple different computing environments simultaneously these days.  You may be developing code on an Ubuntu system running in AWS, be remoting to it from an OSX laptop, have a pet project on your personal CentOS box at home, and still be keeping that old DEC Alpha system from the mid-'90s alive for nostalgia.  But you find that you have different environment configuration needs for each of them.  Bash, Emacs, Vim, etc. -- all of them need to get tuned a bit for each environment.  Soon you find that your `.bashrc` is a maze of twisty conditional logic spaghetti.

This is my personal yak shaving solution to all that.  Inspired by the decomposition of the system-wide `init` mechanism that is widely used in moden *nix distros, this system decomposes your `.bashrc` into a set of independent, system-specific modules that are intelligently invoked depending on what system they're run on.

With this init system, you write configuration functionality in a set of independent files stored in the `.init/env` directory hierarchy.  Directory names in this hierarchy include tokens that describe facets of the target system -- OS, platform, hostname, etc.  At shell initialization time, `.init/sh/getenv` is run and it recurses this hierarchy, entering directories that match the current system and executing the scripts it finds there. It recognizes five kinds of scripts to run:

  - E*X*ecute: Run the contents of the script in a sub-shell.  (If you want only the side-effects of the script, such as creating a directory or cleaning up scratch files.)
  - *S*ource: Run the contents of the script in the current shell context via the Bash `source` builtin.  (If you want to modify the currently running shell, e.g., by setting environment variables.)
  - *F*ront: Prepend the contents of the file to a specific environment variable in the currently running shell context.  (E.g., for adding stuff to the front of a `PATH` variable.)
  - *B*ack: Append the contents of the file to a specific environment variable in the currently running shell context.  (E.g., for adding stuff to the back of a `PATH` variable.)
  - *R*eplace: Replace the content of an environment variable altogether with the contents of the file.
  
Filenames start with a 2-digit integer in the [00, 99] range, which is used for prioritization.  Within a single directory, files are executed in order from smallest to largest.
  
  Here's an example `env` hierarchy:
  
  - `env/`
    - `15.X.TEMPDIR`  # Run this always, regardless of system.  Execute contents of this file in a subshell.
    - `osx/`  # Enter this directory when running in an OSX environment.
      - `20.R.LESS`  # Replace the `LESS` environment variable with the contents of this file.
      - `30.S.SHELL_FUNCTIONS`  # Run this file in the current shell context.
    - `spark/solaris/ecn/`  # Spark architecture, running Solaris, on the ECN domain (Purdue's Engineering Computer Network).
      - `10.B.LD_LIBRARY_PATH`  # Append this to the `LD_LIBRARY_PATH` variable
      - `80.F.BIBINPUTS`  # Add this to the front of the `BIBINPUTS` variable
    - `linux/tdrl/`  # Any linux system, running as `USER` `tdrl`.
      - `20.X.XINPUT`  # Execute in a subshell.  (This one uses `xinput` to set up a track ball with scroll wheel.)
      
## Installation

1. Copy (or symlink) the contents of this directory to `${HOME}/.init`.
1. `cd ${HOME}/.init`
1. Run the `install.sh` script.

That will create a bunch of symlinks from `${HOME}` to the files in `.init/dotfiles`.  Any previous existing files will be moved to `${HOME}/.dotfiles_backups`.  The most important file created in this way is the `.bashrc`, which includes the logic to kick off the whole initialization.

Thereafter, it's all down to your personal tuning of the various dotfiles and the pile of stuff under `env`.  Have fun yak shaving!  :-)
