# NODE CONFIG

## DISKS

xfs_admin -L /mongodb <mongo disk>
mkswap -L SWAP /dev/nvme1n1

[root@ip-10-53-0-46 ~]# cat /etc/fstab

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

## on PRIMARY, add SECONDARY

rs.add( { host: "ip-xxx-xx-xx-xx.aws.local:27017", priority: 0, votes: 0 } )
rs.status()


