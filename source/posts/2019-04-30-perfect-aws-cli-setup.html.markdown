---
title: The Perfect aws-cli setup
date: 2019-04-30
tags: code, python, aws, config
---

> **Shameless acknowledgment**: All the following has been copied and pasted from https://duseev.com/articles/perfect-aws-cli-setup.
> I found that article so useful that I wanted to dump it here in case that blog will stop working.

[...] keep the installation of AWS CLI isolated from everything else.

- create `/aws` directory if it does not exist.
- create `~/.aws/.python-version` and fiull it with your favorite Python version
- cd into `/aws` and `pipenv install awscli`

This will create a dedicated virtual environment and install AWS CLI there so that it’s exclusively available only from that place.
Pipenv will know which virtual environment to use in this directory thanks to the `Pipfile.lock` file.

[...] make a symlink that will redirect any requests to aws command into our dedicated virtual environment.

- create `~/.aws/bin/ directory`
- create `~/.aws/bin/aws` file there with the following script inside

```bash
#!/usr/bin/env bash
# The line above ensures cross compatibility in MacOS

# Set ENV variable for PyEnv to know which interpreter to use
# This will not work if you no longer have 3.6.5 version in Pyenv!
export PYENV_VERSION=3.6.5

# Set PIPENV location ENV variable to tell Pipenv where to look for virtual environment.
export PIPENV_PIPFILE=~/.aws/Pipfile

# When this command is executed following happens:
# 1. Pyenv starts and uses shims to look for the pipenv module in the
#    3.6.5 installation of Python. Then it starts pipenv
# 2. Pipenv reads Pipfile location from environment variable of the
#    shell that we just set and finds the aws executable
#    in the dedicated virtual evnironment.
# 3. We pass all the arguments in our script to aws executable using
#    "$@" bash directive.
pipenv run aws "$@"
```

- make the script executable: `chmod a+x ~/.aws/bin/aws`
- create a symlink to this executable script `sudo ln -s ~/.aws/bin/aws /usr/local/bin`

That's it! The aws executable is now available from any directory.

```bash
~$ pwd
/Users/davide

~$ aws --version
aws-cli/1.16.148 Python/3.6.8 Darwin/18.5.0 botocore/1.12.138
```