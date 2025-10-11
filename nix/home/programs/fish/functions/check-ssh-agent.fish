#echo "Checking ssh identity: $SSH_AGENT_PID $SSH_ENV"
ssh-add -l | grep "The agent has no identities" > /dev/null
if [ $status -eq 0 ]
    ssh-add
else
    ssh-add -l 2>&1 | grep "Connection refused" > /dev/null
    if [ $status -eq 0 ]
        reset-ssh-agent
    end
end