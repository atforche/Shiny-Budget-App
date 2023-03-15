# Initial Setup
### Shiny Server Setup
This project is configured to run on a Raspberry Pi using Shiny Server. Since Shiny Server doesn't ship binaries for ARM, you'll need to compile from source to get it to work. Luckily, the process is fairly straight forward using a Docker container. Fortunately, there's a very helpful repo from Hvalev that has a ready to go Docker container and setup guide to get Shiny Server working on a Raspberry Pi [(link here)](https://github.com/hvalev/shiny-server-arm-docker). For this project, I've forked that repo to make some small modifications to the Dockerfile and added a custom startup script. The link to my custom repo is [here](https://github.com/atforche/shiny-server-arm-docker). The initial setup is similar to the steps described in Hvalev's startup guide, with a few small changes.

First, you'll need to build my modified Docker image from scratch since it's not hosted anywhere. To do this, follow Hvalev's guide until you get to the step to clone the repository. Here, you'll want to clone my repository instead of theirs. Next, navigate to the cloned repository and run the command `docker build -t <your-image-name-here> .` with whatever name you want to give the image. For example, I named my image atforche/shiny-server-arm. This may take an hour or two to complete.

Once the Docker build has completed, you can continue following the guide for a bit. Once you reach the step to run the docker container, you'll need to make a second adjustment. You'll want to replace the `hvalev/shiny-server-arm:latest` with `<your-image-name-here>:latest` so your freshly built image is used.

Once you run that command, you should have a working Docker container running Shiny Server. Now, you can clone this repository into your ~/shiny-server/apps directory to install this app on your server. 

### My Configuration
On my local network, I'm using an Excel workbook stored on my Windows PC as the data entry point, and the Shiny application is running on my Raspberry Pi. To allow the application to access the Excel workbook, I've set up a Windows network share on the directory where the workbook is stored. Then, I mount that network share onto the Raspberry Pi's file system using CIFS so the Pi can access that file with real-time updates. If you'd like to use a different scheme, just modify the master_workbook_location and local_workbook_location variables in global.R to point to the file paths where you want your main workbook copy and local working workbook copy to be stored. 

To facilitate my unique configuration that crosses operating systems, I've added a startup.sh script to my fork of the shiny-server-arm repo. This startup script handles mounting the Windows network share into the /res/shared application directory and then it starts up the Docker container that runs Shiny Server. You may not need this script at all, or you may want to modify it to suite your unique network environment.

### Linux System Service
Lastly, to ensure that my startup script always runs when the Pi is rebooted, I've configured a Linux system service that will run my startup script. There are many guides online to creating a custom service. In short, you'll want to create a file in `/lib/systemd/system` named `shiny-startup.service`. In that file, you'll want to copy the following contents:
```
 [Unit]
 Description=Shiny Server Startup
 After=network-online.target multi-user.target

 [Service]
 Type=oneshot
 ExecStart=<your-local-path-to-the-startup-script>

 [Install]
 WantedBy=network-online.target multi-user.target
```
Once you've saved that file, you'll next need to run `sudo systemctl daemon-reload`, then you can enable your custom service using `sudo systemctl enable shiny-startup`, and lastly your changes will take affect once you reboot. Now, you should have a working Shiny app to track your budgets.
