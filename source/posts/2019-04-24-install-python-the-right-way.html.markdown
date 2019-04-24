---
title: Install Python the right way
date: 2019-04-24
tags: code, python, environment, config
---

Does this sound familiar?

![Messy Python](https://imgs.xkcd.com/comics/python_environment_2x.png)

Installing Python for me has always been a pain. There are way too many "suggested" way to install it, too many strategies to handle different versions and projects' dependencies... virtualenv, pip, pip3, pyenv, pipenv, brew. It's a mess. And if you want your favorite IDE to automatically play along with your installations, well, things get more and more confused.

Until today!

I spent a night and a morning fooling around with python versions and virtual encironments, until I arrived to the perfect working solution. It's actually a cocktail of well balanced and tasty ingredients:

- pyenv: to efficiently install and handle different versions of Python
- pipenv: to isolate projects' dependencies
- PyCharm: the definitive IDE for python developers, it will fit perfectly this setup
- some smart tweaks to your `~/.profile`

> disclaimer: the following setup works on my macbook pro with macOS Mojave 10.14.4 - it has not been tested on different systems or different varsions of the same system.

# pyenv

First things first: install your next favorite toy

```bash
$ brew install pyenv
```

Then add `pyenv init` to your shell to enable shims and autocompletion

```bash
$ echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.profile
```

That's it. You can now install different Pythons compiling them directly from source

```bash
$ pyenv install 2.7.8
$ pyenv install 3.6.8
$ pyenv versions
  system
  2.7.8
* 3.6.8 (set by /Users/davide/.pyenv/version)
```

Now you'll be able to setup a global version or specific version for specific folders

```bash
pyenv global 3.6.8
pyenv local 2.7.6
# the last cmd creates a .python-version file in the current directory.
# The local version overrides the global one.
```

At [this link](https://github.com/pyenv/pyenv/blob/master/COMMANDS.md) you can find a comprehensive pyenv command reference.

# pipenv

The official guides instructs to install pipenv through HomeBrew: `brew install pipenv`.

What worked for me was instead the old fashioned `sudo -H pip install -U pipenv`.

I won't list pipenv commands and description, you can find them [here](https://github.com/pypa/pipenv).

# PyCharm

PyCharm will automatically try to install the dependencies listed in the Pipfile; but almost surely it will fail.

Here below some tweaks to make the magic happen:

First of all add the following to your `~/.profile`

```bash
# Run the following command to find the user base's binary directory:
$ python -m site --user-base

# A sample output can be
/Users/davide/.local

# Add bin to this path to receive a string for adding to the ~/.profile file, for example:
$ export PATH="$PATH:Users/jetbrains/.local/bin"
$ source ~/.profile
```

Now you can get back to PyCharm:

- look for **Project Interpreter** in the **Preferences** Panel.
- click on the small gear icon on the right / click on ADD

Now here there is a small gotcha that made me crazy spending a ton of time, so pay attention:

- I jknow you want to setup a **Pipenv Environment**, but STFU, trust me and click on **Virtualenv Environment** on the left menu.
- Check **Existing Enviroment** and select the correct pyenv's python installation / click ok
- Now click again on the small gear icon, and this time click on **Pipenv Environment** on the left menu
- The base interpreter will be available; select it! (at current time, if you don't follow what I wrote here above you won't find it)

PyCharm will create the environment using the global (or local) python version set with pyenv.

Happy coding!
