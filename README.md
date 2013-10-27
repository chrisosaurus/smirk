smirk - simple blog management

What
----
Smirk will take some markdown files and html templates and generate something resembling a blog.

Dependencies
------------
Smirk requires Perl and the Text::Markdown Perl module, on debian-derived systems this is called 'libtext-markdown-perl'.

How
---
Smirk is run from a directory containing 2 subdirectories

One called 'templates' which by default contains index.html and post.html

and another called 'content' where each markdown file is formatted as yyyy-mm-dd-some-title.md,
each of these represents a post. These are converted to html and inserted into templates/post.html

NB: if smirk encounters a file in `content/` where the date is `9999-99-99` smirk will still process
this file but will _not_ add it to the index; I use this to denote unfinished posts that I do not yet
want to publish, thus the post can only be seen if you open it manually or know the complete url.

templates/index.html is populated with one entry in the list per post, sorted in reverse chronological
order (newest first).

smirk will output an index.html to the current directory as well as a folder called 'posts' where the
converted posts are kept (and linked to from index.html), you can deploy these to your web server for
hosting.

Automating
-----------
I have smirk set up such that whenever I push an update via git smirk will regenerate my site.

I use gitolite for my git hosting (repos live in /home/git) 

The git user (owner of /home/git) is in the www-data group so he can write to /var/www, and www-data is in the git group so he can read the files copied.
NB: you can do this many different ways, as long as www-data (web server user/group) and git (gitolite user/group) can read/write to the same place.

    root@segfault# cat /etc/passwd | grep git
    git:x:1011:1011::/home/git:/bin/bash

    root@segfault# cat /etc/group | grep git
    www-data:x:33:git
    git:x:1011:www-data,gitdaemon

I the have a post-update hook setup for the git repo hosting my site

    root@segfault:/home/git/repositories/segfault.git/hooks# ls -la | grep post-update
    lrwxrwxrwx 1 git git   44 Aug 14 20:05 post-update -> /home/git/.gitolite/hooks/common/post-update

    # contents of /home/git/.gitolite/hooks/common/post-update
    if [ "$GL_REPO" = "segfault" ]; then
            DIR=/home/git/checkouts/segfault
            GIT_DIR=$DIR/.git git fetch
            GIT_DIR=$DIR/.git GIT_WORK_TREE=$DIR git merge origin/master
            cd $DIR
            ./smirk.pl

            rm -rf /var/www/posts
            rm /var/www/index.html
            rm /var/www/segfault.css

            if [ -e index.html ]; then
                cp index.html /var/www/
            fi
            if [ -e segfault.css ]; then
                cp segfault.css /var/www/
            fi
            if [ -d posts ]; then
                cp -r posts/ /var/www/
            fi
            if [ -d resources ]; then
                cp -r resources /var/www
            fi
    fi

I also have a git checkout at /home/git/checkouts/segfault which is merely a clone of my repo.

License
-------
Smirk is released under the MIT license, see LICENSE or https://github.com/mkfifo/smirk/blob/master/LICENSE for details.


Author
------
Smirk was thrown together by Chris Hall <followingthepath at gmail d0t com>

