FROM smartassert/runner:0.4

RUN echo 'deb http://deb.debian.org/debian/ unstable main contrib non-free' >> /etc/apt/sources.list
RUN echo 'Package: *' >> /etc/apt/preferences.d/99pin-unstable
RUN echo 'Pin: release a=stable' >> /etc/apt/preferences.d/99pin-unstable
RUN echo 'Pin-Priority: 900' >> /etc/apt/preferences.d/99pin-unstable
RUN echo 'Package: *' >> /etc/apt/preferences.d/99pin-unstable
RUN echo 'Pin release a=unstable' >> /etc/apt/preferences.d/99pin-unstable
RUN echo 'Pin-Priority: 10' >> /etc/apt/preferences.d/99pin-unstable
RUN apt-get update
RUN apt-get install -y -t unstable firefox libgcc-8-dev gcc-8-base libmpx2 jq

RUN cd vendor/symfony/panther/geckodriver-bin \
    && ./update.sh \
    && cd ../../../..

RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PANTHER_NO_SANDBOX=1
