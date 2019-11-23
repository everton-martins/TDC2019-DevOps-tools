# NODE CONFIG


## DISKS

  xfs_admin -L /mongodb <mongo disk>
  
  mkswap -L SWAP /dev/nvme1n1


  #cat /etc/fstab

  LABEL=/mongodb /mongodb    xfs     defaults        0   0

  LABEL=SWAP   none        swap    sw   0 0


## MONGODB PARAMETER

  mv /etc/mongod.conf /mongodb/mongod.conf

  ln -s /mongodb/mongod.conf /etc/mongod.conf

  chown mongod.mongod /mongodb/mongod.conf


## EBS TAGS

  nvme2n1 Function data

  nvme1n1 Function swap



# CLUSTER CONFIG

## primary

  rs.initiate()

  rs.conf()

  rs.status()

  rs.add( { host: "ip-xxx-xx-xx-xx.aws.local:27017", priority: 0, votes: 0 } )
  
  rs.status()


# CONFIG PROJECT

Este projeto é baseado na versão terraform v0.12.5
wget https://releases.hashicorp.com/terraform/0.12.5/terraform_0.12.5_linux_amd64.zip

Packer packer v1.4.1
wget https://releases.hashicorp.com/packer/1.4.1/packer_1.4.1_linux_arm64.zip
