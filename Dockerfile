# This image includes Node.js and npm. Each Dockerfile must begin with a FROM instruction.
FROM node:10-alpine

# By default, the Docker Node image includes a non-root node user that you can use to avoid 
# running your application container as root. It is a recommended security practice to avoid
# running containers as root and to restrict capabilities within the container to only those
# required to run its processes. We will therefore use the node user’s home directory as the
# working directory for our application and set them as our user inside the container. 

# To fine-tune the permissions on your application code in the container, create the 
# node_modules subdirectory in /home/node along with the app directory. Creating these 
# directories will ensure that they have the correct permissions, which will be important
# when you create local node modules in the container with npm install. In addition to creating 
# these directories, set ownership on them to your node user:
RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

# Next, set the working directory of the application to /home/node/app. 
# If a WORKDIR isn’t set, Docker will create one by default, so it’s a good idea to set it explicitly.
WORKDIR /home/node/app

# Next, copy the package.json and package-lock.json (for npm 5+) files:
COPY package*.json ./
# Adding this COPY instruction before running npm install or copying the application code allows
# you to take advantage of Docker’s caching mechanism. At each stage in the build, Docker will 
# check to see if it has a layer cached for that particular instruction. If you change the 
# package.json, this layer will be rebuilt, but if you don’t, this instruction will allow 
# Docker to use the existing image layer and skip reinstalling your node modules.

# To ensure that all of the application files are owned by the non-root node user, 
# including the contents of the node_modules directory, switch the user to node before running npm install
USER node 

# After copying the project dependencies and switching the user, run npm install:
RUN npm install

# Next, copy your application code with the appropriate permissions to the application directory on the container:
COPY --chown=node:node . .


# EXPOSE does not publish the port, but instead functions as a way of documenting which ports on the container will be published at runtime.
EXPOSE 8080

# CMD runs the command to start the application — in this case, node app.js.
CMD [ "node", "app.js" ]

# Note: There should only be one CMD instruction in each Dockerfile. If you include more than one, only the last will take effect.

# Command to build an image
# docker build -t <your_dockerhub_username>/<image_name> . 
#       OR
# docker build -t <your_dockerhub_username>/<repo_name>:<tag_name> .
# use 2nd command if you want to store more than one image in a repo 

# Command to build the container
# docker run --name nodejs-image-demo -p 80:8080 -d your_dockerhub_username/nodejs-image-demo

# after running the container you can access your node application at localhost:80.