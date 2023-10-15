#!/bin/bash
# Сборка проекта

git submodule update --init
cmake -S . -B build
cmake --build build