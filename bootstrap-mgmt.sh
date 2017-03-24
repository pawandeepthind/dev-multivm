#!/usr/bin/env bash
su vagrant <<'EOF'
yes | ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
ssh-keyscan oracle activemq  >> ~/.ssh/known_hosts
EOF
