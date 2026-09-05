# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code and build
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy package files and install production dependencies only
COPY package*.json ./
RUN npm ci --omit=dev

# Copy compiled code from builder
COPY --from=builder /app/dist ./dist

# Create directories required by the app (like for uploads) and set permissions
RUN mkdir -p uploads temp outputs && chown -R node:node uploads temp outputs /app

# Switch to non-root user
USER node

# Expose port (adjust if your app uses a different default port)
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
