Build Instructions
==================

## Dependencies

### Cortex-M4 Toolchain

Download and unpack the [gcc-arm-embedded toolchain][1].

[1]:https://launchpad.net/gcc-arm-embedded

### FreeRTOS

[Download the latest FreeRTOS][2] release. We're using version 7.3.0.

Unpack the ZIP file in a directory near the smaccmpilot-stm32f4 tree: the same
parent directory is best. We will refer to the path of the unzipped source
tree during build configuration.

[2]: http://sourceforge.net/projects/freertos/files/

### ArduPilot

Many of the libraries in the SMACCMPilot software are from the ArduPilot
project.

Clone the [Galois fork of the ArduPilot repo][22], using the `master` branch.
Keep this clone in a directory near the smaccmpilot-stm32f4 tree, as you did
with the FreeRTOS sources.

[22]:https://github.com/GaloisInc/diydrones/ardupilot.git

## Configuration File

  1. Copy `Config.mk.example` to `Config.mk`.  Open this file in a text editor.
  2. Set `CONFIG_CORTEX_M4_PREFIX` to the location of the Cortex-M4 toolchain.
  3. Set `CONFIG_FREERTOS_PREFIX` to the location of the FreeRTOS source.
  3. Set `CONFIG_ARDUPILOT_PREFIX` to the location of the Ardupilot source.
  4. Set `CONFIG_BOARD` to `px4` for the PX4FMU, or `stm32f4-discovery`.

## Compiling

  1. Simply run `make` from the top-level directory.  You can also specify
     a specific target such as `libhwf4.a`.
  2. Build output is placed in the `build` directory.  The test program images
     are in the `build/$(CONFIG_ARCH)/$(CONFIG_BOARD)/img` directory.

## Flashing the PX4FMU Board

We use the [Black Sphere Technologies Black Magic Probe][3] as a
JTAG/SWD debugger to flash and debug on the PX4FMU hardware.

  1. Follow the [instructions on the PX4 wiki][4]
     for setting up your Black Magic Probe.
  2. Start GDB: `arm-none-eabi-gdb`
  3. Connect to the Black Magic Probe: `target extended-remote /dev/ttyACM0`
  4. Scan the single-wire debug adapters: `mon swdp_scan`
  5. This should display a single result, such as: `1 STM32F4xx`.
  6. Attach to this target: `attach 1`
  7. Load the image to flash: `file build/cortex-m4/px4/img/ledtest`
  8. Flash the image to the device: `load`
  9. Execute the firmware: `run`
  10. Interrupt the debugger with Control-C to reflash by running `load` and
    `run` again.

You may wish to place the commands in steps 3-6 in a .gdbinit file.

[3]: http://www.blacksphere.co.nz/main/blackmagic
[4]: https://pixhawk.ethz.ch/px4/dev/jtag/black_magic_probe

## Installing OpenOCD (required for STM32F4-Discovery board)

On the STM32F4-Discovery board, we find it easier to use the builtin STLink
debugger with OpenOCD.  (If you're only using the Black Magic Probe with the
PX4FMU, you can skip this section.)

 1. Download a recent release of [OpenOCD][5]
    We have tested with version 0.6.1.

[5]: http://sourceforge.net/projects/openocd/files/openocd/0.6.1/

 2. Configure and install OpenOCD with:

```
$ tar -zxvf openocd-0.6.1.tar.gz
$ cd openocd-0.6.1
# NOTE: you may not need all of these flags
$ ./configure --enable-ftdi --enable-ft2232_libftdi --enable-stlink \
  --enable-amtjtagaccel --enable-buspirate
$ make
$ sudo make install
```

