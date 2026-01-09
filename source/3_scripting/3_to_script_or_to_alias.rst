#########################
3.3 Working with aliases
#########################

We can automate a lot of our work, by running multiple commands at the same time. Aliases are another way to make your life easier.

In Linux, an alias is a shortcut that references a command. An ``alias`` replaces a string that invokes a command in the Linux shell with another user-defined string.

.. code-block:: bash

	# same file we modified it for paths
	vim ~/.bashrc

	alias bang='git status && git add --all && git commit -m '
	alias bing='git push'
	. ~/.bashrc

	# when we run the command will be
	bang "Commit message"; bing

=============================================================
Create a script that runs the same functionalities as aliases
=============================================================

Create a script, add executable permission edit content

.. code-block:: bash
	
	touch gitPush && chmod +x gitPush && vim gitPush

.. code-block:: bash

	# !/usr/bin/env bash

	######################################
	# Automates the git push process.
	# Usage: ./scriptName
	# Author: Skillab Team
	# Copyright: Bla Bla Bla
	######################################

	######################################
	# Description
	# checks the status of the repository
	# adds all the updated files
	# adds a message commit
	# pushes the code to the
	# Globals:
	#	 None
	# Arguments:
	# 	 ${1} - Commit Message
	######################################

	function pushCode() {
	git status
	git add --all
	git commit -m "${1}"
	git push
	}

	if [[ $# -eq 1 ]]; then
		pushCode()
		echo "[INFO]: Code pushed."
	else
		echo "[ERROR]: No arguments supplied."
	fi
