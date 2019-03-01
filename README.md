From the host machine you already can use any of [existing Dockerhub images that have vips prebuilt](https://hub.docker.com/search?q=vips&type=image).
But if you want to call vips from another container you need the

# vips Docker image with HTTP interface

The [vips image](https://github.com/felixbuenemann/vips-alpine) is by @felixbuenemann
The [webserver](https://github.com/msoap/shell2http) is by @msoap

Luckily the shell2http was built on the same OS so to integrate these two things I had to just copy the binary.

## Usage example

This launches the container that crops the image and responds with RGB pixels printed as TSV for further processing:

```bash
docker run --rm --name=vips -p 8080:8080 nakilonishe/vips-shell2http -show-errors -form / "vips crop \$filepath_file temp.v \$v_left \$v_top \$v_width \$v_height && vips bandunfold temp.v temp_.v --factor \$v_factor && vips csvsave temp_.v temp.csv && cat temp.csv"
```

This is how I call it with cURL from host machine:

```bash
curl -s -X POST -F file=@/home/ubuntu/temp.png -F factor=4 -F left=10 -F top=3 -F width=3 -F height=5 http://localhost:8080/
```

For usage from a container you use ports bindings and container hostnames.
