#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cd /etc/puppet/puppet-from-git/

/usr/bin/git pull

for br in `git branch -r | grep 'origin/feature' | cut -d/ -f2,3 `;
do
        working_tree=`echo ${br##*/}`
        echo $working_tree
        echo $br
        if [ ! -d /etc/puppet/environments/$working_tree ]; then
              mkdir /etc/puppet/environments/$working_tree
              cd /etc/puppet/environments/$working_tree
              git init
              git config --global user.email "release@puppet.office"
              git config --global user.name "Release Account"
              git remote add -t $br -f origin git@gitserver:puppet
              git checkout $br
	      ln -s /etc/puppet/environments/$working_tree/facts /var/lib/puppet/facts/$working_tree
	      ln -s /etc/puppet/environments/$working_tree/files /var/lib/puppet/files/$working_tree
        fi
        cd /etc/puppet/environments/$working_tree
        git pull origin $br
done

cd /etc/puppet/development
git pull origin develop
