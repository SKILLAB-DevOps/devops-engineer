# Run a webserver and a custom image

# Use the 'nginx' official image, with the latest version for alpine
FROM nginx:stable-alpine

# Change our working directory to the root of nginx webhost
WORKDIR /usr/share/nginx/html

# Copy in the the index.html
COPY index.html /usr/share/nginx/html/

# No need to specify EXPOSE or CMD because they're include in the base (FROM)