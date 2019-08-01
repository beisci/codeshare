# Install R and compile packages from source on MacOS

Latest versions of MacOS have a lot of problems when it comes to installing R and making it compile packages from source smoothly. Here are the steps that led to successful installation of R on a new Mac lately, with no issues compiling from source. Please google for the latest download links the texts refer to.

## 1. Installing X Code from App Store
After installation, open it to accept terms; then need to install command line tools: go to terminal, type in `xcode-select --install`.

## 2. Install xQuaz/X11
Google the latest link for installation.

## 3. Install Java JDK
After insalling, go to Terminal, sign in as root user, type in `R CMD javareconf` so it's set up. This requires root user to be enabled so java can access and write. To enable root user, type in Terminal the following: `dsenableroot to enable root user`. Sometimes the latest Java JDK doesn’t work (e.g., current Java JDK 12 is not supported, while version 11 is), so install the appropriate version of Java JDK again, then go to `/Library/Java/JavaVirtualMachines` and remove the directory whose name matches the following format `/Library/Java/JavaVirtualMachines/jdkmajor.minor.macro[_update].jdk`. Do not attempt to uninstall Java by removing the Java tools from `/usr/bin`. Once only the appropriate Java version is present in above folder, re-run `R CMD javareconf`.

## 4. Install clang
Go to R homepage, and there is a list of R tools for Mac, pick correct version of clang for the current R version. During installation, there are instructions on creating paths, need to follow these instructions for clang to work.

## 5. Install gfortran
The version on R page rtools does not currently work, use [github fortran for Mojave](https://github.com/fxcoudert/gfortran-for-macOS/releases)
