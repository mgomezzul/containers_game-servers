docker run -it --rm -v $PWD/volume:/data \
  -p 27015:27015 -p 27015:27015/udp \
  -e UPDATE_STEAM=0 -e UPDATE_SERVER=0 \
  mgomezzul/insurgency:0.1.0
