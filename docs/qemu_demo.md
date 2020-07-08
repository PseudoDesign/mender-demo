# Yocto BSP Firmware Updates Using Mender

## Setup

For this tutorial, we're going to use version 2.4 of [Mender](https://docs.mender.io/2.4).  When deploying this to a real product, you will need to select a version of Mender that's right for your project.  Generally speaking, this should be the latest version with support targeting your project's version of [Yocto](https://wiki.yoctoproject.org/wiki/Releases).

### Mender Server

### Mender Client

The full project is located on [Github](https://github.com/PseudoDesign/mender-demo).  The project is based on my go-to implementation of Dockerize OpenEmbedded builds

For the sake of this demo, we're going to run Mender in a [QEMU](https://www.qemu.org/) environment.  This will allow us to demonstrate the capabilities of Mender without having to deal with any physical hardware.  

This demo is targeting Yocto Warrior using a qemux86-64 machine.

Given the limited needs of this project, we won't need many OpenEmbedded meta layers.  They've been added as git submodules in the `.../sources` directory; you can find details on the layers in the links below.

* [Yocto Poky](https://www.yoctoproject.org/software-item/poky/)
* [meta-mender](https://github.com/mendersoftware/meta-mender/tree/warrior)

