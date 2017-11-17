FROM ubuntu:latest as ajanti_base

RUN apt-get update \
	&& apt-get install -y \
		curl wget unzip \
	&& wget https://raw.githubusercontent.com/ajenti/ajenti/master/scripts/install.sh -O- | bash - \
	&& rm -rf /var/lib/apt/lists/*


###########################################
# Install development environment

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -

RUN apt-get update \
	&& apt-get install -y \
		nodejs \
		gettext \
	&& rm -rf /var/lib/apt/lists/* \
	&& npm -v

RUN npm -g install \
	bower \
	babel-cli \
	babel-preset-es2015 \
	babel-plugin-external-helpers \
	less \
	coffee-script \
	angular-gettext-cli \
	angular-gettext-tools

RUN pip install \
	ajenti-dev-multitool

ARG USER_ID
RUN echo "User: $USER_ID" && mkdir /opt/ajenti && chown $USER_ID -R /opt/ajenti

WORKDIR /opt/ajenti

# Ajenti needs root
# USER $USER_ID

EXPOSE 8000

# We keep bash as default entrypoint
# ENTRYPOINT ["ajenti-dev-multitool"]
