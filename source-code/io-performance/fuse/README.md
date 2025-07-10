# FUSE

FUSE can be used to mount an image as a file system.  Since this is just a
single file, it doesn't contribute to the inode count of the file system quota.
Moreover, it can be mounted on any directory, so especially on a directory on a
local file system.

**Note:** This tool uses
[`argc`](https://github.com/sigoden/argc/blob/main/docs/specification.md#meta)
to parse command line arguments, define and run subcommands, and generate help
messages.  If you don't have `argc` installed, you can use the pure-Bash
version `confuse.sh` instead.

## What is it?

1. `confuse`: command line utility to create, mount and unmount file system images
   using FUSE.  This version has a dependency on `argc`.
1. `confuse.sh`: pure-Bash version of the scriot.
1. `Makefile`: build script to create the `confuse.sh` script.
