Main constraints for profiling a container:

  * entrypoint of image shouldn't `cd` out of `WORKDIR`
      * if it does so, the output of mica can't be found
  * `gcc, g++, make` are available inside the container
