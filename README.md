
# wpkg

This fork of WPKG adds features needed by the Xcraft toolchain.

- Build with LLVM
- Restore original mtime when installing files
- x86-64 build for Windows
- Increase package size to 8 GB
- Fix TAR header computing of win32 filename with accents
- Restore optimizations with Darwin build
- Ignore dependencies that are not matching the core architecture
- Improve the create_index speed with a md5sum cache
- Optimize speed for --show and --field commands
- Add new option --accept-special-windows-filename
- Add support for cross-compiling WPKG
- Add support for AACRH64 and ARM32
- Fix bug with URI with spaces in sources.list
- Just warn (instead of error) in case of unsupported .lnk files
- Add support for Zstandard for the data payload of the packages
- Fixes for very large files (32 to 64 bits)
- Improve of graphs design
- Accept filenames with spaces at beginning or end
- Add case sensitive support for UNIX-like packages
- Improve delete on Windows with a retry strategy
- Fix HTTP queries with spaces in package names
- Enable update + upgrade after each build
- Add --depth option to --create-index --recursive
- Output diagrams when two trees are considered similar
- Fix debian comparer for tilde cases
- Add new command --list-index-packages-json to list extra metadata from an index
- Delete empty directories after remove
- Drop auto_ptr
- Add build support for old compilers
- Accept filenames with tilde at the beginning
- Add support for WSL2
- Add a file that list all symlinks in control.tar
- Support --exception option with sub-packages (control.info)
- Add new option --keep-original-symlink-target
- Continue backup with symbolic links on directories (must be improved)
- Add new option --skip-hooks in order to be able to install without postinst run
- Support for HTTPS via OpenSSL 3
