# Dev Server Setup
For the C4Social fork of diaspora*

In this document we will setup a development environment for our fork of diaspora*. This is not the only way you can install the system for development and may not even be the best way, but it is one that was tested to work as of the last checked date.

## Prerequisites
As a prerequisite you should have a computer with 20gb of storage and 2gb of memory running Debian 11 (Bullseye). This could be a virtual machine running on your computer via VirtualBox or a VPS from your hosting provider.

## Prepare the system
***
#### Install packages

Run:

```
sudo apt-get update
sudo apt-get install build-essential git curl gsfonts imagemagick libmagickwand-dev nodejs redis-server libssl-dev libcurl4-openssl-dev libxml2-dev libxslt1-dev libidn11-dev libpq-dev cmake
```
If you receive errors about packages that could not be found, make sure that `universe` is enabled in `/etc/apt/sources.list` after the entry for `trusty-updates`


#### Install the database

Skip this step if you already have one.
See the [Ubuntu server guide](https://ubuntu.com/server/docs/databases-postgresql)


#### Removing packaged version of RVM

If you installed RVM via the package manager, we recommend to remove it. See [this StackOverflow answer](http://stackoverflow.com/questions/9056008/installed-ruby-1-9-3-with-rvm-but-command-line-doesnt-show-ruby-v/9056395#9056395) for some tips on how to do that and then continue with the installation instructions below.

#### Creating a user for DB

If you like a separate DB user for your diaspora* installation, log in to your PostgreSQL server as the main user 'postgres'. One way to do this is:
```
psql -U postgres
```

You need a user with the privilege to create databases.

```
CREATE USER diaspora WITH CREATEDB PASSWORD '<password>';
```

#### RVM
We recommend using [Ruby Version Manager](http://rvm.io/) it will ensure you're always on the currently recommended Ruby version and cleanly separate your diaspora* installation from all other Ruby applications on your machine. If you opt for not using it ensure your Ruby version is at least 2.3.0, prior versions are incompatible. We currently recommend using the latest release of the 2.6 series.

##### Install RVM
As the user you want to run diaspora* under, that is not as root, run:
```
curl -L https://s.diaspora.software/1t | bash
```

and follow the instructions. If you get GPG signature problems, follow the instructions printed by the command. Running the 'gpg --recv-keys' command with 'sudo' should not be necessary. If those commands give you permission denied errors, change them to 640 for all files and 750 for all folders in the .gnupg folder.

##### Set up RVM
Ensure the following line is in your `~/.bashrc`:
```
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
```

Now run `source ~/.bashrc` in the terminal(s) you are using for this guide.

If you **don't** have sudo installed or your current user doesn't have the privileges to execute it, run:
```
rvm autolibs read-fail
```

The next command will check if all dependencies to build Ruby are installed. If these are not met, you will see a list of packages preceded by "`Missing required packages:`". As root install all the packages listed there for your OS. Then rerun the install command.

Ensure the currently recommend version of Ruby is installed:
```
rvm install 2.6
```

## Get the source
***
It's time to download diaspora*! As your diaspora user run:
```
cd ~
git clone  https://github.com/diaspora/diaspora.git
cd diaspora
```

Don't miss the cd diaspora, all coming commands expect to be run from that directory!

### Copy files
```
cp config/database.yml.example config/database.yml
cp config/diaspora.toml.example config/diaspora.toml
```

## Bundle
***

It's time to install the Ruby libraries required by diaspora*:

```
gem install bundler
script/configure_bundler
bin/bundle install --full-index
```

This takes quite a while. When it's finished, you should see a message similar to: `Bundle complete! 137 Gemfile dependencies, 259 gems now installed.` If that's not the case, you should seek for help on the mailing list or the IRC channel.

Running the manual `gem install` command shown in the error message can sometimes show a clearer error message if the bundle command fails.

## Database setup
***
Double check your config/database.yml looks right and run:
```
bundle exec rake db:create db:migrate
```

## Start diaspora
***
It's time to start diaspora*:
```
./script/server
```

Your diaspora server is now running, either on a unix socket (current default) or on http port 3000. The listening method can be configured in diaspora.toml, search for '3000' or 'listen' to find the correct line.

You will likely need to install a reverse proxy ([example on github](https://gist.github.com/jhass/719014) for apache2) in order to get it to be served publicly. If you are new to running rails applications you may find the diaspora [components page](https://wiki.diasporafoundation.org/wiki/index.php?title=Diaspora_components&action=edit&redlink=1) helpful for orientation.