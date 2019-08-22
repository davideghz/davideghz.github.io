---
title: Deploy a Django App with Pipenv
date: 2019-08-22
tags: deploy, python, django, pipenv
---

> **Warning**: setup your remote environment with **Pipenv**; if you don't know how to do that, you might want to
> check my [post](https://davideghezzi.com/posts/install-python-the-right-way/) about it.

Once saved in a **deploy.sh** file, the deploy script is thought to be launched from your local system, from the Django
project's root folder, with something like `./deploy.sh /path/to/your-key.pem`.

Note that, in order to ssh to the server, the script currently requires `/path/to/your-key.pem` string as first positional parameter.

**deploy.sh**

```bash
#!/bin/bash

# set handy variables
REMOTE=ubuntu@ec2-xx-xxx-xxx-x.eu-west-1.compute.amazonaws.com
REMOTE_FOLDER=/path/to/your/django-app/

# pull latest changes
ssh -i "$1" $REMOTE "cd $REMOTE_FOLDER; git pull";

# install dependencies defined in Pipenv file
ssh -i "$1" $REMOTE "cd $REMOTE_FOLDER; export LC_ALL=C.UTF-8; export LANG=C.UTF-8; /home/ubuntu/.local/bin/pipenv install";

# run scripts defined in Pipenv file (cannot call manage.py scripts directly due to wrong context and lack of real terminal issues)
ssh -i "$1" $REMOTE "cd $REMOTE_FOLDER; export LC_ALL=C.UTF-8; export LANG=C.UTF-8; /home/ubuntu/.local/bin/pipenv run migrate";
ssh -i "$1" $REMOTE "cd $REMOTE_FOLDER; export LC_ALL=C.UTF-8; export LANG=C.UTF-8; /home/ubuntu/.local/bin/pipenv run collectstatic";

# restart gunicorn and nginx
ssh -i "$1" $REMOTE "cd $REMOTE_FOLDER; sudo supervisorctl restart guni:gunicorn";
ssh -i "$1" $REMOTE "cd $REMOTE_FOLDER; sudo service nginx restart";

```

The scripts is commented and should be easy to understand.

In order to launch migrations and to collect static assets, it is important to call `manage.py` scripts from within the
virtual environment; for this reason I added a `[script]` block to my **Pipfile**, that I can run from the deploy script.

> You can then run `pipenv run <shortcut name>` in your terminal to run the command in the context of your pipenv virtual
> environment even if you have not activated the pipenv shell first.

Also, this will avoid the dreadful error "inappropriate ioctl for device", which typically means some code in your
project or its dependencies has replaced one of the process streams (`sys.stdin`, `sys.stdout` or `sys.stderr`)
with an object that isn’t actually hooked up to a terminal, but which pretends that it is. For example,
test runners or build systems often do this ([source](http://www.pyinvoke.org/faq.html#i-m-getting-ioerror-inappropriate-ioctl-for-device-when-i-run-commands)).

**Pipfile**

```bash
[[source]]
name = "pypi"
url = "https://pypi.org/simple"
verify_ssl = true

[scripts]
migrate = "python pariterequity/manage.py migrate --noinput"
collectstatic = "python pariterequity/manage.py collectstatic --noinput"

[dev-packages]

[packages]
django = "*"
django-storages = "*"
boto3 = "*"
django-compressor = "*"
django-sass-processor = "*"
libsass = "*"

[requires]
python_version = "3.6.8"
```

Happy deploying :)