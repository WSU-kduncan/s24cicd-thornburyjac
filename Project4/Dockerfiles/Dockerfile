# First Dockerfile I got to work for this project.

FROM nginx:1.10.1-alpine
COPY 4980_testsite /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chmod -R 750 /usr/share/nginx/html
EXPOSE 8080
# Just realized this below line was included in my first Dockerfile and was left out in this one.
# It appears to still work whether I have it or not, but the article I used recommended it so I am adding it in.
CMD ["nginx", "-g", "daemon off;"]
