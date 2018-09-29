SSH_ENV=$HOME/.ssh/environment
export GNUPGHOME=$HOME/AppData/Roaming/gnupg/

# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    ssh-add

    ssh-add ~/.ssh/id_github
}

if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
	 ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
	    start_agent;
	}
else
    start_agent;
fi

 # added for npm-completion https://github.com/Jephuff/npm-bash-completion
PATH_TO_NPM_COMPLETION=~/AppData/Roaming/npm/node_modules/npm-completion
source $PATH_TO_NPM_COMPLETION/npm-completion.sh
