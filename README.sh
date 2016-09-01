#!/bin/bash

set -e -x

ln -sf ~/.steam/steamapps/common/Terraria src/Terraria

bosh create-release

# etc
