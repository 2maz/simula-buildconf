#! /bin/sh

CONF_URL=${CONF_URL:=https://github.com/2maz/simula-buildconf.git}
RUBY=ruby
AUTOPROJ_BOOTSTRAP_URL=https://raw.githubusercontent.com/2maz/autoproj/master/bin/autoproj_bootstrap
BOOTSTRAP_ARGS=

set -e

if ! which $RUBY > /dev/null 2>&1; then
    echo "cannot find the ruby executable. On Debian or Ubuntu you should run"
    echo "  sudo apt install ruby ruby-dev"
    exit 1
fi

RUBY_VERSION_VALID=`$RUBY -e 'STDOUT.puts RUBY_VERSION.to_f >= 2.0'`

if [ "x$RUBY_VERSION_VALID" != "xtrue" ]; then
    if test "$RUBY_USER_SELECTED" = "1"; then
        echo "You selected $RUBY as the ruby executable, and it is not providing Ruby >= 2.0"
    else
        cat <<EOMSG
ruby --version reports
  `$RUBY --version`
The supported version for Rock is ruby >= 2.0. I don't know if you have it
installed, and if you do what name it has. You will have to select a Ruby
executable by passing it on the command line, as e.g.
  sh bootstrap.sh ruby2.1
EOMSG
        exit 1
    fi
fi

if ! test -f $PWD/autoproj_bootstrap; then
    if which wget > /dev/null; then
        DOWNLOADER=wget
    elif which curl > /dev/null; then
        DOWNLOADER=curl
    else
        echo "I can find neither curl nor wget, either install one of these or"
        echo "download the following script yourself, and re-run this script"
        exit 1
    fi
    $DOWNLOADER $AUTOPROJ_BOOTSTRAP_URL
fi

CONF_URL=${CONF_URL#*//}
CONF_SITE=${CONF_URL%%/*}
CONF_REPO=${CONF_URL#*/}
GET_REPO=https://$CONF_SITE/$CONF_REPO
PUSH_TO=git@$CONF_SITE:$CONF_REPO

#until [ -n "$GET_REPO" ]
#do
#    echo -n "Which protocol do you want to use to access $CONF_REPO on $CONF_SITE? [git|ssh|http] (default: http) "
#    read ANSWER
#    ANSWER=`echo $ANSWER | tr "[:upper:]" "[:lower:]"`
#    case "$ANSWER" in
#        "ssh") GET_REPO=git@$CONF_SITE:$CONF_REPO ;;
#        "git") GET_REPO=git://$CONF_SITE/$CONF_REPO ;;
#    esac
#done

GEMFILE_DEV=Gemfile.autoproj-dev
echo "source 'https://rubygems.org'" > $GEMFILE_DEV
echo "gem 'autobuild', git: 'https://github.com/2maz/autobuild', branch: 'master'" >> $GEMFILE_DEV
echo "gem 'autoproj', git: 'https://github.com/rock-core/autoproj', branch: 'fix_bootstrap'" >> $GEMFILE_DEV


$RUBY autoproj_bootstrap --gemfile=$GEMFILE_DEV $@ git $GET_REPO push_to=$PUSH_TO $BOOTSTRAP_ARGS

if test "x$@" != "xlocaldev"; then
    $SHELL -c '. $PWD/env.sh; autoproj update; autoproj osdeps; autoproj build'
fi

