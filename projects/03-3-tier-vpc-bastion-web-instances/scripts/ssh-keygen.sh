#! /bin/bash
cd ..
mkdir ssh-keys
ssh-keygen \
 -m PEM \
 -t rsa \
 -b 4069 \
 -C "ec2-user@myserver" \
 -f $(pwd)/ssh-keys/terraform-aws.pem

mv ./ssh-keys/terraform-aws.pem.pub ./ssh-keys/terraform-aws.pub