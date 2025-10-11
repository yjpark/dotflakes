if [ -f $SSH_ENV ]
    source $SSH_ENV > /dev/null
end
if [ -n "$SSH_AGENT_PID" ]
    ps -ef | grep $SSH_AGENT_PID | grep ssh-agent > /dev/null
    if [ $status -eq 0 ]
        check-ssh-agent
    else
        reset-ssh-agent
    end
else
    ps -ef | grep "ssh-agent -c" | grep -v grep | grep "ssh-agent -c" > /dev/null
    if [ $status -eq 0 ]
        check-ssh-agent
    else
        echo "Initializing new ssh-agent ..."
        ssh-agent -c | sed 's/^echo/#echo/' > $SSH_ENV
        echo "succeeded"
        chmod 600 $SSH_ENV 
        source $SSH_ENV > /dev/null
        ssh-add
    end
end