###################
2.8 Terminal Tuning
###################

###################
2.8 Terminal Tuning
###################

===================
Shell Customization
===================

**DevOps-Focused Aliases:**

.. code-block:: bash

    # Add to ~/.bashrc or ~/.zshrc
    
    # Enhanced file operations
    alias ll='ls -ltrha --color=auto'
    alias la='ls -la --color=auto'
    alias lt='ls -lat --color=auto'      # Sort by time
    alias lsize='ls -laSh --color=auto'  # Sort by size
    alias grep='grep --color=auto'
    alias tree='tree -C'
    
    # Modern alternatives
    alias cat='bat'                      # Syntax highlighting
    alias ls='exa'                       # Modern ls
    alias find='fd'                      # Faster find
    alias grep='rg'                      # Faster grep
    
    # Navigation shortcuts
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias ~='cd ~'
    alias -- -='cd -'
    
    # Git shortcuts for DevOps
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit -m'
    alias gp='git push'
    alias gl='git log --oneline --graph'
    alias gd='git diff'
    alias gb='git branch'
    alias gco='git checkout'
    
    # Docker shortcuts
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias dimg='docker images'
    alias dexec='docker exec -it'
    alias dlogs='docker logs -f'
    
    # Kubernetes shortcuts
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgd='kubectl get deployments'
    alias kdesc='kubectl describe'
    alias klogs='kubectl logs -f'
    
    # System monitoring
    alias top='htop'
    alias df='df -h'
    alias du='du -h --max-depth=1'
    alias free='free -h'
    alias ps='ps aux'
    alias ports='ss -tulpn'
    alias listen='ss -tulpn | grep LISTEN'

    
    # Infrastructure as Code
    alias tf='terraform'
    alias tfi='terraform init'
    alias tfp='terraform plan'
    alias tfa='terraform apply'
    alias ans='ansible'
    alias aplay='ansible-playbook'
    
    # Safety aliases
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
    alias chmod='chmod --preserve-root'
    alias chown='chown --preserve-root'

=====================
Environment Variables
=====================

**Essential Environment Variables:**

.. code-block:: bash

    # Add to ~/.bashrc or ~/.profile
    
    # Development paths
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/bin:$PATH"
    
    # Python
    export PYTHONPATH="$HOME/dev/python:$PYTHONPATH"
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    
    # Editor preferences
    export EDITOR=vim
    export VISUAL=vim
    
    # History settings
    export HISTSIZE=10000
    export HISTFILESIZE=20000
    export HISTCONTROL=ignoreboth
    
    # Colors
    export CLICOLOR=1
    export LSCOLORS=ExFxBxDxCxegedabagacad

.. note::

    **DevOps Tip**: Customize your terminal for efficiency. A well-configured shell can significantly speed up daily tasks and reduce errors.

``TheFuck`` is a magnificent app that corrects errors in previous console commands.

.. code-block:: bash

    # create Python environment
    python3 -m venv venv

    # source Python environment
    . venv/bin/activate

    # install thefuck python library
    pip install thefuck

Update user profile ``.bashrc``, ``bash_profile`` or ``.profile``

.. code-block:: bash

    eval $(thefuck --alias FUCK)

===========================
Run sudo without a password
===========================

Update the ``/etc/sudoers`` file:

.. code-block:: bash

    %sudo   ALL=(ALL:ALL) ALL

to

.. code-block:: bash

    %sudo   ALL=(ALL:ALL) NOPASSWD:ALL
