#!/usr/bin/env bash
file -L ./result/lib/*.so | cut -d'5' -f1
