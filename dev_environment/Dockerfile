FROM ubuntu:latest as ajanti_base


RUN apt-get update \
	&& apt-get install -y \
		curl wget \
		build-essential \
		python-pip \
		python-dev \
		python-lxml \
		libffi-dev \
		libssl-dev \
		libjpeg-dev \
		libpng-dev \
		uuid-dev \
		python-dbus \
	 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/ajenti

RUN pip install --upgrade pip \
	&& pip install \
		ajenti-panel \
		ajenti.plugin.dashboard \
		ajenti.plugin.settings \
		ajenti.plugin.plugins

RUN pip install \
	ajenti.plugin.filemanager \
	ajenti.plugin.notepad \
	ajenti.plugin.packages \
	ajenti.plugin.services \
	ajenti.plugin.terminal

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -

RUN apt-get update \
	&& apt-get install -y \
		nodejs \
		gettext \
		unzip \
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
RUN echo "User: $USER_ID" && chown $USER_ID -R /opt/ajenti

# Ajenti needs root
# USER $USER_ID

EXPOSE 8000

# We keep bash as default entrypoint
# ENTRYPOINT ["ajenti-dev-multitool"]
