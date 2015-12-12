FROM debian:jessie

RUN apt-get update && apt-get install -y build-essential wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    wget --no-check-certificate http://software.intel.com/sites/landingpage/pintool/downloads/pin-2.10-45467-gcc.3.4.6-ia32_intel64-linux.tar.gz -q -O - | tar xz && \
    mkdir -p /pin && \
    mv pin-*-linux/* /pin && \
    wget --no-check-certificate http://kejo.be/ELIS/mica/mica_v0.40.tar.gz -q -O - | tar xz && \
    mv mica_v0.40 /pin/source/tools/mica
RUN sed -i 's/PAGE_SIZE/PAGE_SIZES/' /pin/source/tools/mica/mica_init.cpp && \
    sed -i 's/"mica.conf"/"\/pin\/source\/tools\/mica\/mica.conf"/' /pin/source/tools/mica/mica_init.cpp && \
    sed -i 's/.*include <sstream>/#include <sstream>\n#include <unistd.h>/' /pin/source/tools/mica/mica.cpp && \
    sed -i '/^.*machine == "ia64"/,$d' /pin/pin && \
    echo 'exec "$origin"/intel64/bin/pinbin -p32 "$origin"/ia32/bin/pinbin "${@}"' >> /pin/pin
RUN make -C /pin/source/tools/mica

ENTRYPOINT ["mv", "/pin", "/mnt"]
