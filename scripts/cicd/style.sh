#!/bin/bash
# Проверка стилей

find ${PWD}/src -iname *.hpp -o -iname *.cpp | xargs clang-format -style=file --Werror -n --verbose && \
find ${PWD}/proto -iname *.proto | xargs clang-format -style=file --Werror -n --verbose

find ${PWD}/src -iname *.hpp -o -iname *.cpp | xargs clang-format -style=file -i && \
find ${PWD}/proto -iname *.proto | xargs clang-format -style=file -i