From the host machine you already can use any of [existing Dockerhub images that have vips prebuilt](https://hub.docker.com/search?q=vips&type=image).  
But if you want to call vips from another container you need the

# vips Docker image with HTTP interface

The [vips image](https://github.com/felixbuenemann/vips-alpine) is by @felixbuenemann  
The [webserver](https://github.com/msoap/shell2http) is by @msoap

Luckily the shell2http was built on the same OS so to integrate these two things I had to just copy the binary.

### Usage example

This container runs arbitrary chain of shell commands to process posted images that shell2http implicitly puts somewhere in `/tmp` folder:

```bash
docker run --rm --read-only --tmpfs /tmp -p 8080:8080 vips-shell2http -show-errors -form / "eval \$v_command"
```

This curl asks it to crop the image and respond with RGB pixels printed as TSV for further processing:

```bash
curl -s -X POST -F file=@/home/ubuntu/Downloads/house.png \
                -F factor=3 -F left=10 -F top=3 -F width=6 -F height=15 \
                -F command="vips crop \$filepath_file /tmp/temp.v \$v_left \$v_top \$v_width \$v_height &&
                            vips bandunfold /tmp/temp.v /tmp/temp_.v --factor \$v_factor &&
                            vips csvsave /tmp/temp_.v /tmp/temp.csv &&
                            cat /tmp/temp.csv" http://localhost:8080/
```

To call it from another container specify the container hostname with `docker run --name ...` or using docker-compose.
