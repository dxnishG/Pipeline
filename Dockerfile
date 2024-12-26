# Use the official Nginx image from Docker Hub
FROM nginx:latest

# Copy custom HTML content into the Nginx HTML directory
COPY ./index.html /usr/share/nginx/html/index.html

# Expose port 80 for the web server
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
