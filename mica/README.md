Main constraints for profiling a container:

  * container instantiation shouldn't take arguments after image name 
    (`repo/image` is the last string)
      * this is mainly a restriction of how [`./profile`](profile) 
        works
  * entrypoint of image shouldn't `cd` out of `WORKDIR`
      * if it does so, the output of mica can't be found
  * `gcc, g++, make` are available inside the container
