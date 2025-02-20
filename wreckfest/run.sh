docker run -it --rm -v $PWD/volume:/data \
  -p 27015:27015 -p 27015:27015/udp -p 27016:27016/udp -p 33540:33540/udp \
  -e UPDATE_STEAM=0 -e UPDATE_SERVER=0 \
  mgomezzul/wreckfest:0.1.0
