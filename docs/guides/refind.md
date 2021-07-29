# Introduction

This guide shall help you install the rEFInd Boot Manager in your T2 Mac in the safest possible way. Though there are various options to get rEFInd in your Mac, it is recommended to follow the instructions given below unless you know what you are doing.

# Installation

All steps given here have to be performed on **macOS**. You will also need to have [secure boot disabled](https://support.apple.com/en-us/HT208198).

1. With the help of disk utility, create a 100-200MB `MS-DOS FAT` partition and label it as `REFIND`.
2. Get a **binary zip file** of rEFInd from [here](https://www.rodsbooks.com/refind/getting.html).
3. The binary zip file of rEFInd shall be available in the downloads folder by the name of `refind-bin-<VERSION>.zip`, where `<VERSION>` represents the version of refind you have downloaded. For eg:- If you have downloaded `0.13.2` version, it will be available as `refind-bin-0.13.2.zip`.
4. Extract the zip file (can be done by double clicking on it). The contents shall be extracted in a folder named `refind-bin-<VERSION>`. Here `<VERSION>` means the same as described in step 3.
5. Open the terminal and run `diskutil list` to get the disk identifier of the `REFIND` volume created in step 1. A sample output is given below:-

   ```sh
   /dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *500.3 GB   disk0
   1:                        EFI ⁨EFI⁩                     314.6 MB   disk0s1
   2:                 Apple_APFS ⁨Container disk1⁩         284.0 GB   disk0s2
   3:       Microsoft Basic Data ⁨Windows⁩                 215.9 GB   disk0s3
   4:       Microsoft Basic Data ⁨REFIND⁩                  103.8 MB   disk0s4

   /dev/disk1 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +284.0 GB   disk1
                                 Physical Store disk0s2
   1:                APFS Volume ⁨macOS⁩                   15.3 GB    disk1s1
   2:              APFS Snapshot ⁨com.apple.os.update-...⁩ 15.3 GB    disk1s1s1
   3:                APFS Volume ⁨macOS - Data⁩            33.9 GB    disk1s2
   4:                APFS Volume ⁨Preboot⁩                 567.1 MB   disk1s3
   5:                APFS Volume ⁨Recovery⁩                626.1 MB   disk1s4
   6:                APFS Volume ⁨VM⁩                      20.5 KB    disk1s5
   ```
  
   Here, the disk indentifier of `REFIND` volume is `disk0s4`.
6. Now run the following in the terminal. Make sure you replace `disk0s4` (found in 4th, 5th, 6th and 7th line of below command) with the disk identifier you got in the output as described in step 5 and `refind-bin-0.13.2` (found in 1st line of below command) with the name of folder which was created in step 4.

   ```sh
   cd ~/Downloads/refind-bin-0.13.2
   xattr -rd com.apple.quarantine .
   sed -i '' "s/sed -i 's/sed -i '' 's/g" refind-install
   diskutil unmount disk0s4
   sudo ./refind-install --usedefault /dev/disk0s4
   diskutil unmount disk0s4
   diskutil mount disk0s4
   sudo rmdir /tmp/refind_install
