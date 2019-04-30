---
title: EBS extensions, from WTF?! to OMGILUVIT<3
date: 2019-04-17
tags: aws, code, config
---

AWS ElasticBeanstalk is an awesome tool to automate deploy operations.

Install the cli, checkout the code, and `eb deploy` will do the rest; it will setup a nice looking stack including cool stuff like load balancing, auto scaling, containerized virtual instances for your application and DB, security groups, health monitors, notifications, etc…

Easy? YES. Until you need to tune the underlying deploy pipeline or resources. Let’s say you need a different node version to run in your env because one of your app’s dependencies decided it no longer likes node 6.4, which is currently the default on the `Puma with Ruby 2.6 running on 64bit Amazon Linux/2.9.2` MRI; You’ll be in big trouble.

I spent many hours last night on this, and I feel like sharing my experience might save other people’s precious sleeping hours.

>You can add AWS Elastic Beanstalk configuration files (.ebextensions) to your web application’s source code to configure your environment and customize the AWS resources that it contains. Configuration files are YAML- or JSON-formatted documents with a .config file extension that you place in a folder named .ebextensions and deploy in your application source bundle.

> <cite>AWS EBS docs</cite>

Note that .ebextensions files are executed in alphabetical order. I was not able to find a complete list of such files, but errors from `eb deploy` command contained the files’ name containing the failing commands, so I was able to name them coherently.

To update or install a specific Node version in an EBS environment, just create a file and put in a `.ebextensions` folder in your root.

**e.g, my-app/.ebextensions/app.config**

```bash
files:
  "/opt/elasticbeanstalk/hooks/appdeploy/pre/10_nodejs.sh":
    mode: "000777"
    owner: 'root'
    group: 'root'
    content: |
        #!/usr/bin/env bash

        . /opt/elasticbeanstalk/hooks/common.sh

        set -xe
        EB_NODE_VERSION="v8.9.4"

        file="/etc/elasticbeanstalk/baking_manifest/node_installed_$EB_NODE_VERSION"
        if [ -e $file ]; then
            echo Node.js has already been installed. Skipping installation.
        else
            EB_TARBALL_URL=$(/opt/elasticbeanstalk/bin/get-config container -k tarball_url)
            EB_NODE_INSTALL_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k node_install_dir)

            MACHINE_TYPE=`uname -m`
            if [ "$MACHINE_TYPE" = "x86_64" ]; then
                ARCH=x64
            elif [ "$MACHINE_TYPE" = "i686" ]; then
                ARCH=x86
            else
                echo "Unknown architecture."
                exit 1
            fi

            mkdir -p $EB_NODE_INSTALL_DIR
            curl -L https://nodejs.org/dist/$EB_NODE_VERSION/node-$EB_NODE_VERSION-linux-$ARCH.tar.gz | tar zxf - -C $EB_NODE_INSTALL_DIR
            ln -sf $EB_NODE_INSTALL_DIR/node-$EB_NODE_VERSION-linux-$ARCH/bin/node /usr/bin/
            ln -sf $EB_NODE_INSTALL_DIR/node-$EB_NODE_VERSION-linux-$ARCH/bin/node-waf /usr/bin/
            ln -sf $EB_NODE_INSTALL_DIR/node-$EB_NODE_VERSION-linux-$ARCH/bin/npm /usr/bin/
            echo $(date) >> "/etc/elasticbeanstalk/baking_manifest/node_installed_$EB_NODE_VERSION"

            rm -rf /home/webapp/.npm/
            rm -rf /var/app/ondeck/node_modules/
            npm cache clean --force
            rm -rf /opt/elasticbeanstalk/support/node-install/node-v6*
            rm -rf /opt/elasticbeanstalk/support/node-install/node-v4*
        fi

        mkdir -p /home/webapp
        chown -R webapp:webapp /home/webapp
        mkdir -p /var/app/support/.npm_global
        npm config set prefix /var/app/support/.npm_global
```

Also the following note, straight from the docs, would have saved me a big headache, if I only would have read it before starting my journey down the ebextensions hole.

> TIP: When you are developing or testing new configuration files, launch a clean environment running the default application and deploy to that. Poorly formatted configuration files will cause a new environment launch to fail unrecoverably.

> <cite>AWS EBS docs</cite>

The same way it is possible to update Bundler to v2 (in case you are trying to deploy a Ruby 2.6 and Rails 5 app to EBS and getting error with Bundler).

```bash
files:
  # Runs before `./10_bundle_install.sh`:
  "/opt/elasticbeanstalk/hooks/appdeploy/pre/09_gem_install_bundler.sh" :
    mode: "000775"
    owner: root
    group: users
    content: |
      #!/usr/bin/env bash

      EB_APP_STAGING_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k app_staging_dir)
      EB_SCRIPT_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k script_dir)
      # Source the application's ruby, i.e. 2.6. Otherwise it will be 2.3, which will
      # give this error: `bundler requires Ruby version >= 2.3.0`
      . $EB_SCRIPT_DIR/use-app-ruby.sh

      cd $EB_APP_STAGING_DIR
      echo "Installing compatible bundler"
      gem install bundler -v 2.0.1
```