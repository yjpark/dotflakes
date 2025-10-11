echo "Reset ssh-agent"
pkill -9 ssh-agent
rm $SSH_ENV
set -x SSH_AGENT_PID
setup-ssh-agent