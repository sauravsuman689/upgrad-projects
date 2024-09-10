FROM node:10.15.1
# Define a working directory /home
WORKDIR /home
# Copy package json files
COPY package*.json ./
# Copy rest all the code 
COPY . . 
# Install all dependencies
RUN npm install
# Export the port 3000 on which the application will run
EXPOSE 3000
# Start the server
CMD ["node", "index.js"]
