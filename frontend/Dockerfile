# Build Stage 
FROM node:20-alpine as builder 

# setting up working directory.
WORKDIR /app

# copying both ".json" files so Docker can cache the "npm install" layer.
# if only react code changes, dependencies don't need to be downloaded again.
COPY package*.json ./

# installing all the frontend dependencies.
RUN npm install 

# copying remaining frontend source code files to the container.
COPY . . 

# building the react frontend.
RUN npm run build 

# Nginx Stage 
FROM nginx:alpine

# copying the custome nginx configuration file to the container.
COPY  nginx.conf /etc/nginx/conf.d/default.conf

# copying the built React files from the builder stage into the nginx's default web directory.
COPY --from=builder /app/build /usr/share/nginx/html

# nginx listens on port 80 by default.
EXPOSE 80

# inside the Docker container, after running the nginx, the nginx goes to the background which marks that main process had finished.
# after the main process has finished, the docker thinks that work is done and stops the container.
# so to overcome this situation we are starting nginx in the foreground.
CMD ["nginx", "-g", "daemon off;"]