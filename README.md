~/.vimrc && ~/.vim
------------------

My second variant of vim configuration.


Goal
----

 * KISS
 * Only: C, Python, JS, HTML/CSS


Installation
------------

Use last Vim with +conceal. (Default Mac VIm don't supported)

    brew install --with-cscope --with-lua --with-python3 vim
    mv ~/.vim{,_old}; mv ~/.vimrc{,_old}
    git clone <> ~/.vim
    ln -s ~/.vim/.vimrc ~/.vimrc


Information
-----------

Plugins installed throu Pathogen, so use git submodules to restore.

Directories:

 - `~/.vim/bundle/` - Installed plugins (git modules)
 - `~/.vim/sessions/` - files sessions and viminfo

