# Use a lightweight Node.js image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of your bot code
COPY . .

# Start the bot
CMD ["node", "index.js"]