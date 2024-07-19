FROM nginx:alpine

# Copy the build output to nginx's html directory
COPY  /build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]                                                                                                                                               