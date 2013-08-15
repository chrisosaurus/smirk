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

templates/index.html is populated with one entry in the list per post, sorted in reverse chronological
order (newest first).

smirk will output an index.html to the current directory as well as a folder called 'posts' where the
converted posts are kept (and linked to from index.html), you can deploy these to your web server for
hosting.

Automating
-----------
I have smirk set up such that whenever I push an update via git smirk will regenerate my site,
details coming soon.

License
-------
Smirk is released under the MIT license, see LICENSE or https://github.com/mkfifo/smirk/blob/master/LICENSE for details.


Author
------
Smirk was thrown together by Chris Hall <followingthepath at gmail d0t com>

