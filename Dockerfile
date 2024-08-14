FROM python:3
ARG BASE \
    AWSCLI=https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip

RUN apt-get update
RUN apt-get -y install locales less && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG ja_JP.UTF-8 
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ JST-9
ENV TERM xterm

# TOFU
# https://opentofu.org/docs/intro/install/deb/
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg unzip
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://get.opentofu.org/opentofu.gpg | tee /etc/apt/keyrings/opentofu.gpg >/dev/null
RUN curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null
RUN chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main"  >  /etc/apt/sources.list.d/opentofu.list
RUN echo "deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main"   >>/etc/apt/sources.list.d/opentofu.list
RUN chmod a+r /etc/apt/sources.list.d/opentofu.list
RUN apt-get update &&apt-get install -y tofu


# aws-cli
RUN unzip \
    && curl "${AWSCLI}" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/bin

#
WORKDIR ${BASE} 
COPY pyproject.toml poetry.lock README.md ${BASE}/
COPY bedrag/ ${BASE}/bedrag/
#
RUN pip install --upgrade pip poetry
RUN poetry config virtualenvs.create false
# RUN poetry install --no-root --no-dev
RUN poetry install --no-dev

