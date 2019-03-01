FROM felixbuenemann/vips-alpine
COPY --from=msoap/shell2http /app/shell2http /usr/local/bin/shell2http
ENTRYPOINT ["shell2http"]
EXPOSE 8080
CMD ["-help"]
