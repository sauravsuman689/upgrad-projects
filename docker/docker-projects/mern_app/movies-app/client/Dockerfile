FROM node:10.15.1
# Define the working directory
WORKDIR /home
# Copy package files to /home directory
COPY package*.json ./
# Copy rest all the file to /home directory
COPY . .
# Installs all node packages
RUN npm install
# Expose the application port
EXPOSE 8000
# Start the client application
CMD [ "npm", "start" ]

