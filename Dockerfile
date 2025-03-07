FROM emscripten/emsdk:2.0.32


ARG USER_ID
ARG GROUP_ID

RUN mkdir -p /install
RUN mkdir -p /install/lib


##################################################################
# git config
##################################################################
RUN git config --global advice.detachedHead false

##################################################################
# xtl
##################################################################
RUN mkdir -p /opt/xtl/build && \
    git clone --branch 0.7.2 --depth 1 https://github.com/xtensor-stack/xtl.git  /opt/xtl/src

RUN cd /opt/xtl/build && \
    emcmake cmake ../src/   -DCMAKE_INSTALL_PREFIX=/install

RUN cd /opt/xtl/build && \
    emmake make -j8 install


##################################################################
# nloman json
##################################################################
RUN mkdir -p /opt/nlohmannjson/build && \
    git clone --branch v3.9.1 --depth 1 https://github.com/nlohmann/json.git  /opt/nlohmannjson/src

RUN cd /opt/nlohmannjson/build && \
    emcmake cmake ../src/   -DCMAKE_INSTALL_PREFIX=/install -DJSON_BuildTests=OFF

RUN cd /opt/nlohmannjson/build && \
    emmake make -j8 install

##################################################################
# lua
##################################################################
RUN git clone --branch 0.1.0 --depth 1 https://github.com/DerThorsten/wasm_lua   /opt/wasm_lua
RUN cd /opt/wasm_lua && \
    emmake make -j8


##################################################################
# xpropery
##################################################################
RUN mkdir -p /opt/xproperty/build && \
    git clone --branch 0.11.0 --depth 1 https://github.com/jupyter-xeus/xproperty.git  /opt/xproperty/src

RUN cd /opt/xproperty/build && \
    emcmake cmake ../src/   \
    -Dxtl_DIR=/install/share/cmake/xtl \
    -DCMAKE_INSTALL_PREFIX=/install

RUN cd /opt/xproperty/build && \
    emmake make -j8 install


##################################################################
# xeus itself
##################################################################
# ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN mkdir -p /opt/xeus
RUN git clone --branch 2.4.1 --depth 1 https://github.com/jupyter-xeus/xeus.git /opt/xeus

# COPY xeus /opt/xeus

RUN mkdir -p /xeus-build && cd /xeus-build  && ls &&\
    emcmake cmake  /opt/xeus \
        -DCMAKE_INSTALL_PREFIX=/install \
        -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
        -Dxtl_DIR=/install/share/cmake/xtl \
        -DXEUS_EMSCRIPTEN_WASM_BUILD=ON
RUN cd /xeus-build && \
    emmake make -j8 install


##################################################################
# xwidgets
##################################################################
RUN mkdir -p /opt/xwidgets/build && \
    git clone --branch  0.26.1 --depth 1 https://github.com/jupyter-xeus/xwidgets.git  /opt/xwidgets/src

RUN cd /opt/xwidgets/build && \
    emcmake cmake ../src/  \
    -Dxtl_DIR=/install/share/cmake/xtl \
    -Dxproperty_DIR=/install/lib/cmake/xproperty \
    -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
    -Dxeus_DIR=/install/lib/cmake/xeus \
    -DXWIDGETS_BUILD_SHARED_LIBS=OFF \
    -DXWIDGETS_BUILD_STATIC_LIBS=ON  \
    -DCMAKE_INSTALL_PREFIX=/install \
    -DCMAKE_CXX_FLAGS="-Oz -flto"
RUN cd /opt/xwidgets/build && \
    emmake make -j8 install


##################################################################
# xcanvas
##################################################################

RUN mkdir -p /opt/xcanvas/
RUN git clone  --branch  0.2.3 --depth 1  https://github.com/martinRenou/xcanvas.git   /opt/xcanvas


RUN mkdir -p /xcanvas-build && cd /xcanvas-build  && ls && \
    emcmake cmake  /opt/xcanvas \
        -DCMAKE_INSTALL_PREFIX=/install \
        -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
        -Dxtl_DIR=/install/share/cmake/xtl \
        -Dxproperty_DIR=/install/lib/cmake/xproperty \
        -Dxwidgets_DIR=/install/lib/cmake/xwidgets \
        -DXCANVAS_BUILD_SHARED_LIBS=OFF \
        -DXCANVAS_BUILD_STATIC_LIBS=ON  \
        -Dxeus_DIR=/install/lib/cmake/xeus \
        -DCMAKE_CXX_FLAGS="-Oz -flto"

RUN cd /xcanvas-build && \
    emmake make -j8 install

##################################################################
# xeus-lua
##################################################################

RUN mkdir -p /opt/xeus-lua/
RUN git clone --branch 0.6.3 --depth 1 https://github.com/jupyter-xeus/xeus-lua.git /opt/xeus-lua

# COPY xeus-lua /opt/xeus-lua

RUN mkdir -p /xeus-lua-build && cd /xeus-lua-build  && ls && \
    emcmake cmake  /opt/xeus-lua \
        -DXEUS_LUA_EMSCRIPTEN_WASM_BUILD=ON \
        -DCMAKE_INSTALL_PREFIX=/install \
        -Dnlohmann_json_DIR=/install/lib/cmake/nlohmann_json \
        -Dxtl_DIR=/install/share/cmake/xtl \
        -Dxproperty_DIR=/install/lib/cmake/xproperty \
        -Dxwidgets_DIR=/install/lib/cmake/xwidgets \
        -Dxcanvas_DIR=/install/lib/cmake/xcanvas \
        -DXLUA_WITH_XWIDGETS=ON\
        -DXLUA_WITH_XCANVAS=ON\
        -DXLUA_USE_SHARED_XWIDGETS=OFF\
        -DXLUA_USE_SHARED_XCANVAS=OFF\
        -DLUA_INCLUDE_DIR=/opt/wasm_lua/lua-5.3.4/src \
        -DLUA_LIBRARY=/opt/wasm_lua/lua-5.3.4/src/liblua.a \
        -Dxeus_DIR=/install/lib/cmake/xeus \
        -DCMAKE_CXX_FLAGS="-Oz -flto"

RUN cd /xeus-lua-build && \
    emmake make -j8

