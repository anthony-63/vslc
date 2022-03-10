# Checking if required commands exist
if ! type luac >> info.vslci
then
    echo "'luac' not installed. Install the lua package for your distro please."
    exit
fi
if ! type gcc >> info.vslci
then
    echo "'gcc' not installed. Install the binutils or gcc package for your distro please."
    exit
fi

if ! type xxd >> info.vslci
then
    echo "'xxd' not installed. Install the xxd package for your distro please."
    exit
fi

if [ $# -ne 2 ]
then
    echo "usage: vslc <lua input> <binary output>"
    exit
fi
echo "Very Small Lua Compiler(vslc) jsef5 2022"
rm info.vslci

echo "cmd: luac -o \"$2.lbc\" $1"
luac -o "$2.lbc" $1
if [ $? -ne 0 ]
then
    rm $2
    exit
fi

echo "cmd: xxd -i $2.lbc > $2.h"
xxd -i $2.lbc > $2.h
cat <<EOF > $2.c
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <stdio.h>
#include <stdlib.h>
#include "$2.h"
int main() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    luaL_loadbuffer(L, $2_lbc, $2_lbc_len, "");
    lua_pcall(L, 0, 0, 0);
    lua_close(L);
    return 0;
}
EOF
echo "cmd: gcc $2.c -o $2 -llua -static -lm -ldl -g -lc"
gcc $2.c -o $2 -llua -static -lm -ldl -g -lc 2>> info.vlsci
echo "cmd: rm info.vslci $2.lbc $2.c $2.h"
rm info.vlsci $2.lbc $2.c $2.h
