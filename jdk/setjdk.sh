#!/bin/bash
 
if [[ -n ${ZSH_VERSION-} ]]; then
    autoload -U +X bashcompinit && bashcompinit
fi

function setjdk {
    local ver=${1?Usage: setjdk <version>}
 
    echo -n "Setting this terminal's JDK to $ver ... "

    export JAVA_HOME=`/usr/libexec/java_home -v$ver`
    
    java -version
}

function _setjdk_completion() {
    COMPREPLY=()
 
    local options=$(/usr/libexec/java_home | grep $/w*1./d./d | tr '\n' ' ')
 
    COMPREPLY=($(compgen -W "${options}" ${cur}))
}
 
complete -F _setjdk_completion -o filenames setjdk
