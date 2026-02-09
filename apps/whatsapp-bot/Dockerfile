# Use a lightweight Node.js image
FROM node:20-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of your bot code
COPY --chown=node:node . .

# Run as non-root user
USER node

# Start the bot
CMD ["node", "index.js"]