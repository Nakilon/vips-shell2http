From the host machine you already can use any of [existing Dockerhub images that have vips prebuilt](https://hub.docker.com/search?q=vips&type=image).  
But if you want to call vips from another container you need the

# vips Docker image with HTTP interface

The [vips image](https://github.com/felixbuenemann/vips-alpine) is by @felixbuenemann  
The [webserver](https://github.com/msoap/shell2http) is by @msoap

Luckily the shell2http was built on the same OS so to integrate these two things I had to just copy the binary.

### Usage example

This container runs arbitrary chain of shell commands to process posted image that shell2http implicitly puts somewhere in `/tmp` folder:

```bash
docker run --rm --read-only --tmpfs /tmp -p 8080:8080 vips-shell2http -show-errors -form / "eval \$v_command"
```

This curl posts an image and asks it to crop and respond with RGB pixels printed as TSV for further processing:

```bash
curl -s -X POST -F file=@/home/ubuntu/Downloads/house.png \
                -F factor=3 -F left=10 -F top=30 -F width=4 -F height=6 \
                -F command="vips crop \$filepath_file /tmp/temp.v \$v_left \$v_top \$v_width \$v_height &&
                            vips bandunfold /tmp/temp.v /tmp/temp_.v --factor \$v_factor &&
                            vips csvsave /tmp/temp_.v /tmp/temp.csv &&
                            cat /tmp/temp.csv" http://localhost:8080/

```
```
39  26  21  34  21  17  29  19  18  27  18  18
40  26  22  34  22  18  30  19  18  27  18  17
35  22  18  34  21  17  33  22  21  30  21  20
34  21  16  33  21  16  33  23  22  32  23  22
33  20  16  33  20  16  34  24  23  35  26  24
33  20  16  33  20  16  35  25  23  35  26  25
```

To call it from another container specify the container hostname with `docker run --name ...` or using docker-compose.

**Caution:** if you run the container like in this example (evaling an arbitrary command) you provide the shell access that in case of port being opened to Internet (through `docker run -p` and host firewall) is kind of vulnerability. Be sure you don't give this container an access to valuable source code, images and that it is launched only in docker networks with containers that don't have ports opened.
