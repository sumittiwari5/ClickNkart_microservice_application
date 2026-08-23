# check if i already have a SSH key on the ansible ec2
ls -la ~/.ssh/

# if you don't have then,
ssh-keygen -t ed25519

# press enter and you will get two files 
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub

# our Ubuntu EC2 Jump Server was created from your AWS key pair: 
# AWS doesn't normally give the ubuntu user a password.
# So ssh-copy-id may not work with password authentication.
# Instead, use the existing EC2 private key to make the first SSH connection:
ssh -i /path/to/your-existing-key.pem ubuntu@10.0.1.123

# Then you can copy the Ansible public key:
cat ~/.ssh/id_ed25519.pub
# Copy that entire line.

# On the Jump Server:
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
# Paste the public key.

chmod 600 ~/.ssh/authorized_keys
# then exit

# Now test without the AWS .pem key:
ssh ubuntu@<jumpserver_private_ip>

# If that works, our Ansible SSH setup is ready.

# If your existing .pem private key is already accessible from the Ansible EC2, we can also use ssh-copy-id with an SSH connection that specifies that key. The key point is that ssh-copy-id itself needs an authenticated first connection.

=============================================

# after completing it and cofiguring the inventory.ini file. before moving on first test the connection:
ansible -i inventory.ini jumpserver -m ping

# expected 
jumpserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
# If this doesn't work, don't proceed to the playbook. We'll fix the SSH connection first.

