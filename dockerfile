FROM nginx:alpine

# Copy the build output to nginx's html directory
COPY  /build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]


#docker build -t rr_tlt .
#docker tag rr_tlt 192.168.13.72:5000/rr_tlt
#docker push 192.168.13.72:5000/rr_tlt     