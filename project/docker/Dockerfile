FROM nginx:1.27

COPY index.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"] 
# CMD ["nginx", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf"]


