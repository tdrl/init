#!/bin/false
# DO NOT EXECUTE THIS FILE!  Only source it...

# this program should be invoked by a higher-level script in order to
# descend the env hierarchy (this really should be done by a subroutine,
# but csh doesn't support shell functions -- grrr...)  Invoke only via
# "source".  The descent is depth-first with nodes evaluated before
# children, so items deeper in the heirarchy override those higher in it.
#
# Preconditions:  The calling program must set up the following conditions
# and environment variables:
#
# - the current working directory must be the top of the env hierarchy
# - the variables ARCH, OS, DOMAIN, SHORT_DOMAIN, HOST, SHORT_HOST, and
#   USER must be defined and set to sane values.

set idir=${HOME}/.init
set bindir=${idir}/bin
set varprog=${bindir}/addpath.pl
set recprog=${idir}/csh/recurse.csh
set nonomatch

set dirlist=( $ARCH $OS $DOMAIN $SHORT_DOMAIN $HOST $SHORT_HOST $USER )

# Handle this node: extract the variables in the current directory

# Put these on the FRONT of the current variable
if ( "./F[0-9][0-9].*" != ./F[0-9][0-9].* ) then
  foreach vfile (./F[0-9][0-9].*)
    set vname=`echo ${vfile} | cut -f 3 -d .`
    eval "setenv ${vname} '`${varprog} -v ${vname} -F -i ${vfile} -x -f :`'"
  end
endif

# Put these on the BACK of the current variable
if ( "./B[0-9][0-9].*" != ./B[0-9][0-9].* ) then
  foreach vfile (./B[0-9][0-9].*)
    set vname=`echo ${vfile} | cut -f 3 -d .`
    eval "setenv ${vname} '`${varprog} -v ${vname} -B -i ${vfile} -x -f :`'"
  end
endif

# REPLACE the current variable with these
if ( "./R[0-9][0-9].*" != ./R[0-9][0-9].* ) then
  foreach vfile (./R[0-9][0-9].*)
    set vname=`echo ${vfile} | cut -f 3 -d .`
    eval "setenv ${vname} '`${varprog} -i ${vfile} -x -f :`'"
  end
endif

# This is a hack to get around some brokennesses in the tcsh alias
# mechanism.  It turns out that if a shell builtin is aliased to
# something else, but you want to get ahold of the underlying builtin
# command anyway, you can't just quote it the way you would an alias
# of a regular command name b/c tcsh won't look up the resulting
# command in its internal tables -- only in the PATH.  Ugh.  So
# instead, we set a variable to point to the builtin b/c _apparently_
# alias expansion is _not_ done on the result of variable expansions,
# but the internal command tables _are_ searched after variable
# expansion.  Ohhhh, the pain...

set pushd_cmd=pushd
set popd_cmd=popd

# Now recurse:
foreach d ( $dirlist )
  if ( -d $d ) then
    $pushd_cmd $d > /dev/null
    source ${recprog}
    $popd_cmd > /dev/null
  endif
end

# now clean up
#unset idir bindir varprog recprog nonomatch dirlist vname vfile
