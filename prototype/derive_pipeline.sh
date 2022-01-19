#!/usr/bin/env bash
butane --pretty --strict input_butane.bu -d . -o test.ign 
./coreos-derive.sh
