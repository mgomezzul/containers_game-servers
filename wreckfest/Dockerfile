FROM debian:12-slim

LABEL org.opencontainers.image.authors="mgomezzul@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/mgomezzul/containers_game-servers"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN rm -f /etc/apt/source.list
COPY debian.sources /etc/apt/sources.list.d/debian.sources

ENV SERVER_DIR=/data/server \
    STEAM=/steam \
    PLATFORM=windows \
    STEAM_APP_ID=361580 \
    STEAM_APP_EXTRAS='' \
    UPDATE_OS=0 \
    UPDATE_STEAM=1 \
    UPDATE_SERVER=1 \
    PUID=1000 \
    PGID=1000 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# ENV DATA_DIR="/serverdata" #?
# ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd" #?
# ENV SERVER_DIR="${DATA_DIR}/serverfiles" #?
# ENV GAME_ID="template" #?
# ENV GAME_NAME="template" #?
# ENV GAME_PARAMS="template" #?
# ENV GAME_PORT=27015 #?
# ENV VALIDATE="" #?
# ENV UMASK=000 #?
# ENV UID=99 #?
# ENV GID=100 #?
# ENV USERNAME="" #?
# ENV PASSWRD="" #?
# ENV USER="steam" #?
# ENV DATA_PERM=770 #?

COPY source /docker

RUN export LANG=en_US.UTF-8 && \
    export LANGUAGE=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    export DEBIAN_FRONTEND=noninteractive && \
    export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true && \
    apt-get --quiet update && \
		# Set UTF-8 Locale and base packages.
		# Note: more pkgs?
		apt-get install --yes --install-recommends 2> /dev/null \
			apt-utils \
			ca-certificates \
			gnupg \
			locales \
			nano \
			software-properties-common \
			supervisor \
			wget && \
		sed --in-place --expression='s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
		/usr/sbin/locale-gen 2> /dev/null && \
		dpkg-reconfigure --frontend=noninteractive locales && \
		# Add wine
		dpkg --add-architecture i386 && \
		wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
		wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && \
		apt-get --quiet update && \
		apt-get install --yes --install-recommends \
			libsdl2-2.0-0 \
			libsdl2-2.0-0:i386 \
			libc6 \
			libc6:i386 && \
		apt-get --quiet --yes upgrade && \
		apt-get install --yes --install-recommends \
			lib32gcc-s1 \
			winehq-stable \
			winbind \
			supervisor \
			xvfb && \
			apt-get install --yes --install-recommends \
			cabextract \
			unzip \
			p7zip && \
		# Add winetricks as an additional resource if needed for servers.
		wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/bin/winetricks && \
		chmod a+x /usr/bin/winetricks && \
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
		# winehq may potentially take ~5 minutes on first boot to launch, due to
		# blocking on boot events:
		#
		#  _"0014:err:ole:get_local_server_stream Failed: 80004002"_
		#  _"__wine_kernel_init boot event wait timed out"_
		#
		# Subsequent boots will not see the delay. We can mitigate this by updating wine
		# before our first use.
		#
		# wineboot --update
		# xvfb-run --autoservernum wineboot --update
		#
		# This is a suspected issue with the GCC build toolchain, but has not been
		# resolved yet. See:
		#    https://ubuntuforums.org/archive/index.php/t-1499348.html
		#    https://bugs.winehq.org/show_bug.cgi?id=38653
		echo 'Updating wine, ignore any errors ...' && \
		su - steam -c 'wineboot --update' /dev/null 2>&1 && \
		echo 'Wine update completed.' && \
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
EXPOSE 27015/tcp 27015/udp 27016/udp 33540/udp
