# This is the same Dockerfile as the one in the Dockerfiles folder. This is here for the automated workflow.
# Testing version control again again 
FROM nginx:1.10.1-alpine
COPY 4980_testsite /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chmod -R 750 /usr/share/nginx/html
EXPOSE 8080
# Just realized this below line was included in my first Dockerfile and was left out in this one.
# It appears to still work whether I have it or not, but the article I used recommended it so I am adding it in.
CMD ["nginx", "-g", "daemon off;"]
