# Introduction

This guide shall help you install the rEFInd Boot Manager in your T2 Mac in the safest possible way. Though there are various options to get rEFInd in your Mac, it is recommended to follow the instructions given below unless you know what you are doing.

# Installation

All steps given here have to be performed on **macOS**. You will also need to have [secure boot disabled](https://support.apple.com/en-us/HT208198).

1. With the help of disk utility, create a 100-200MB `MS-DOS FAT` partition and label it as `REFIND`.
2. Get a **binary zip file** of rEFInd from [here](https://www.rodsbooks.com/refind/getting.html).
3. The binary zip file of rEFInd shall be available in the downloads folder by the name of `refind-bin-<VERSION>.zip`, where `<VERSION>` represents the version of refind you have downloaded. For eg:- If you have downloaded `0.13.2` version, it will be available as `refind-bin-0.13.2.zip`.
4. Extract the zip file (can be done by double clicking on it). The contents shall be extracted in a folder named `refind-bin-<VERSION>`. Here `<VERSION>` means the same as described in step 3.
5. Rename the `refind-bin-<VERSION>` folder to `refind`.
6. Open the terminal and run `diskutil list` to get the disk identifier of the `REFIND` volume created in step 1.
