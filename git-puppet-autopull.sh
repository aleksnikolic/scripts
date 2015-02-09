#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd /etc/puppet/puppet.git/

/usr/bin/git fetch

for br in `git branch -a | grep 'remotes/origin/feature' | cut -d "/" -f 2,3,4`;
do
	cd /etc/puppet/puppet.git/
	working_tree=`echo ${br##*/}`
	echo $working_tree
	if [ ! -d /etc/puppet/environments/$working_tree ]; then
 	      mkdir /etc/puppet/environments/$working_tree
	fi
	GIT_WORK_TREE=/etc/puppet/environments/$working_tree GIT_DIR=. git checkout -f $br
	cd /etc/puppet/environments/$working_tree
        GIT_WORK_TREE=. GIT_DIR=/etc/puppet/puppet.git git clean -dfx
done

cd /etc/puppet/puppet.git
GIT_WORK_TREE=/etc/puppet/development GIT_DIR=. git checkout -f origin/develop
cd /etc/puppet/development
GIT_WORK_TREE=. GIT_DIR=/etc/puppet/puppet.git git clean -dfx
