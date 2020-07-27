FROM smartassert/runner:0.3

RUN curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb --output chrome.deb \
    && apt-get install -y ./chrome.deb \
    && rm ./chrome.deb

RUN cd vendor/symfony/panther/chromedriver-bin \
    && ./update.sh \
    && cd ../../../..

RUN apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PANTHER_NO_SANDBOX=1

# docker build -f docker/Chrome.Dockerfile -t smartassert/chrome-runner:master .
