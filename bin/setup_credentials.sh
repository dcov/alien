#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ "$SCRIPT_DIR" != "$PWD/bin" ]]; then
  echo "setup_credentials needs to be called from the root of the repo"
  exit 0
fi

if [[ ! -f "$PWD/reddit_credentials.dart" ]]; then
  echo "reddit_credentials.dart should be created before running this script"
  exit 0
fi

ln -s $PWD/reddit_credentials.dart $PWD/app/lib/
echo "Linked reddit_credentials.dart to app/lib"

ln -s $PWD/reddit_credentials.dart $PWD/reddit/bin/
echo "Linked reddit_credentials.dart to reddit/bin"
