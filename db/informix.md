To install Informix DB in Ubuntu using Docker, follow these steps: Install Docker on Ubuntu.
Ensure Docker is installed on your Ubuntu system. If not, you can install it by following the official Docker documentation or using commands like:
Code

    sudo apt update
    sudo apt install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    newgrp docker
Pull the Informix Developer Database Docker Image:
IBM provides official Docker images for Informix. You can pull the latest developer edition image using the following command:
Code

    docker pull ibmcom/informix-developer-database:latest
Run the Informix Docker Container.
After pulling the image, run a container from it. This command sets up the container, maps necessary ports, and accepts the Informix license:
Code

    docker run -it --name ifx -h ifx \
      -p 9088:9088 \
      -p 9089:9089 \
      -p 27017:27017 \
      -p 27018:27018 \
      -p 27883:27883 \
      -e LICENSE=accept \
      ibmcom/informix-developer-database:latest
--name ifx: Assigns the name "ifx" to your container.
-h ifx: Sets the hostname inside the container to "ifx".
-p <host_port>:<container_port>: Maps ports for various Informix services.
-e LICENSE=accept: Accepts the Informix license, which is mandatory for the server to function.
Verify Informix Server Status (Optional).
Open a new terminal and access the bash shell within your running Informix container:
Code

    docker exec -it ifx bash
Once inside the container, you can check the Informix server status using onstat:
Code

    onstat -
You can also use dbaccess to connect to a database, for example:
Code

    dbaccess - -
    database SysMaster;
    INFO TABLES;
