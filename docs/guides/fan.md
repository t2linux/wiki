# Introduction

This page is a step by step guide to get fan control working on t2 Macs.

In some Macs, the fan has been found to work out of the box. In such a case the driver is not required until you want to force a certain speed or do some other configuration which can be done by the help of this driver.

## Steps

1. Clone the repository into a directory of your choice

    ```sh
    git clone https://github.com/networkException/mbpfan
    cd mbpfan
    ```

2. Compile the daemon using `make`

    !!! note
        This will run a patch script that finds a fan device on your system.
        You can use its output for debug purposes

3. Copy mbpfan.conf to /etc with `sudo cp mbpfan.conf /etc`
4. Edit the config if needed
5. Confirm that everything is working by running `sudo make tests`
6. If the tests ran successfully, install using `sudo make install`
7. Now enable starting at boot

    ```sh
    sudo cp mbpfan.service /etc/systemd/system/
    sudo systemctl enable mbpfan.service
    sudo systemctl daemon-reload
    sudo systemctl start mbpfan.service
    ```

## Configuration

The daemons config file can be found at `/etc/mbpfan.conf`. Uncommenting and setting `min_fan1_speed` for example will let you
force a certain speed. Note that for laptops with a second fan, you need to add `min_fan2_speed` and `max_fan2_speed`.
