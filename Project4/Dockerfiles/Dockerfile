# First Dockerfile I got to work for this project.

FROM nginx:1.10.1-alpine
COPY 4980_testsite /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chmod -R 750 /usr/share/nginx/html
EXPOSE 8080
