# Go Web Application

This is a simple website written in Golang. It uses the `net/http` package to serve HTTP requests.

## Running the server

To run the server, execute the following command:

```bash
go run main.go
```

The server will start on port 8080. You can access it by navigating to `http://localhost:8080/courses` in your web browser.

## Looks like this

![Website](static/images/golang-website.png)



git add .
git commit -m "added docker"
git push origin main



# Images
docker images
docker pull nginx
docker build -t myapp:v1 .
docker rmi myapp:v1

# Containers
docker run -d --name app -p 8080:8080 myapp:v1
docker ps
docker ps -a
docker stop app
docker start app
docker restart app
docker rm app

# Debugging
docker logs app
docker logs -f app
docker exec -it app /bin/sh
docker inspect app
docker stats

# Docker Hub
docker login
docker tag myapp:v1 username/myapp:v1
docker push username/myapp:v1

# Cleanup
docker container prune
docker image prune -a
docker system prune -a