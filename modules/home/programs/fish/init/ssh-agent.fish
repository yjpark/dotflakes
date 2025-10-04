setenv SSH_ENV $HOME/.ssh/environment

if test -e ~/.ssh/id_ecdsa
    setup-ssh-agent
else if test -e ~/.ssh/id_dsa
    setup-ssh-agent
else if test -e ~/.ssh/id_rsa
    setup-ssh-agent
end
