FROM debian:12-slim

LABEL org.opencontainers.image.authors="mgomezzul@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/mgomezzul/containers_game-servers"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN rm -f /etc/apt/source.list
COPY debian.sources /etc/apt/sources.list.d/debian.sources

ENV SERVER_DIR=/data/server \
    STEAM=/steam \
    STEAM_APP_ID=237410 \
    UPDATE_OS=0 \
    UPDATE_STEAM=1 \
    UPDATE_SERVER=1 \
    PUID=1000 \
    PGID=1000 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

COPY source /docker

RUN export LANG=en_US.UTF-8 && \
    export LANGUAGE=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    export DEBIAN_FRONTEND=noninteractive && \
    export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true && \
    apt-get --quiet update && \
		# Set UTF-8 Locale and base packages.
		apt-get install --yes --install-recommends 2> /dev/null \
			apt-utils \
			ca-certificates \
			gnupg \
			lib32gcc-s1 \
			locales \
			nano \
			software-properties-common \
			supervisor \
			wget && \
		sed --in-place --expression='s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
		/usr/sbin/locale-gen 2> /dev/null && \
		dpkg-reconfigure --frontend=noninteractive locales && \
		# Auto-accept license and install steamcmd.
		echo steam steam/question select 'I AGREE' | debconf-set-selections && \
		echo steam steam/license note '' | debconf-set-selections && \
		dpkg --add-architecture i386 && \
		apt-get --quiet update && \
		apt-get --quiet --yes upgrade && \
		# Explicitly add SDL library: https://github.com/ValveSoftware/steam-for-linux/issues/7036
		apt-get install --yes --install-recommends \
			libsdl2-2.0-0:i386 \
			libsdl2-2.0-0 \
			gdb && \
		apt-get install --yes --install-recommends \
			steamcmd && \
		# Create steam user and setup permissions.
		useradd -c "Steam CMD" -d ${STEAM} -m steam && \
		su - steam -c " \
			cd ${STEAM} && \
			steamcmd +quit" && \
		mkdir -p ${STEAM}/.steam && \
		ln -s ${STEAM}/.local/share/Steam/steamcmd/linux32 ${STEAM}/.steam/sdk32 && \
		ln -s ${STEAM}/.local/share/Steam/steamcmd/linux64 ${STEAM}/.steam/sdk64 && \
		ln -s ${STEAM}/.steam/sdk32/steamclient.so ${STEAM}/.steam/sdk32/steamservice.so && \
		ln -s ${STEAM}/.steam/sdk64/steamclient.so ${STEAM}/.steam/sdk64/steamservice.so && \
		mkdir -p /data && \
		chown -R steam:steam ${STEAM} /data /docker && \
		chmod 0755 /docker/* && \
		# Setup supervisord process control system.
		cp /docker/supervisord.conf /etc/supervisor/supervisord.conf && \
		mkdir -p /data/supervisord && \
		# Clean up target host system caches.
		apt-get clean autoclean && \
		apt-get autoremove --yes && \
		rm -rfv /var/lib/{apt,dpkg} /var/lib/{cache,log} /tmp/* /var/tmp/* && \
		mkdir -p /var/lib/dpkg/{alternatives,info,parts,updates} && \
		touch /var/lib/dpkg/status && \
		echo -e 'amd64\ni386' > /var/lib/dpkg/arch

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

WORKDIR /data

VOLUME /data

ENTRYPOINT ["/docker/startup"]

# For ports required by steam servcies, see:
# https://support.steampowered.com/kb_article.php?ref=8571-GLVN-8711
# Be sure to include any server-specific ports.
EXPOSE 27015/tcp 27015/udp