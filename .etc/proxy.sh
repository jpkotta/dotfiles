# /etc/profile.d/proxy.sh

export http_proxy="http://proxyv.jdnet.deere.com:81"
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,.deere.com"

function set_proxy_vars() {
    for i in https rsync ftp all ; do
	    export ${i}_proxy=$http_proxy
    done

    export NO_PROXY=$no_proxy
    export ALL_PROXY=$all_proxy

    if type oe-git-proxy >&/dev/null ; then
        export GIT_PROXY_COMMAND=oe-git-proxy
    fi
}

function make_wgetrc() {
    cat <<EOF
http_proxy = $http_proxy
https_proxy = $https_proxy
ftp_proxy = $ftp_proxy
no_proxy = $no_proxy
use_proxy = on
EOF
    }

function proxy_with_auth () {
    local user="jk72405"
    local host_and_port=${http_proxy#http*://}
    local passwd

    if [ -z "$*" ] ; then
        echo -e "Usage: ${FUNCNAME[0]} command [arg1] [arg2] ..." 1>&2
        echo -e "\tRuns COMMAND in a subshell with proxy variables set to " 1>&2
        echo -e "\t'http://$user:\$passwd@${host_and_port}'" 1>&2
        return -1
    fi

    read -s -p "RACF password for $user: " passwd
    echo
    if [ -z "$passwd" ] ; then
        echo "Error: empty password." 1>&2
        return -1
    fi

    local tmp="http://${user}:${passwd}@${host_and_port}"

    (
        export http_proxy="$tmp"
        set_proxy_vars
        "$@"
    )
}

set_proxy_vars
