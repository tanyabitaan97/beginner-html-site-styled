# Containerizes the beginner-html-site-styled static site with nginx
FROM nginx:alpine

# Remove the default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy the site content (index.html, images/, styles/) into nginx's webroot
COPY index.html /usr/share/nginx/html/
COPY images/ /usr/share/nginx/html/images/
COPY styles/ /usr/share/nginx/html/styles/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
