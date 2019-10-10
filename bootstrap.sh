#!/usr/bin/env bash
if [ -f /Workspace/bashrc ]; then
    source /Workspace/bashrc
fi
if [ -f /Workspace/bootstrap.sh ]; then
    bash /Workspace/bootstrap.sh
fi
tail -f /dev/null
