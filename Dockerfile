FROM --platform=$BUILDPLATFORM golang AS build

ARG GIT_DESC=undefined

WORKDIR /go/src/github.com/Snawoot/dumbproxy
COPY . .
ARG TARGETOS TARGETARCH
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -a -tags netgo -ldflags '-s -w -extldflags "-static" -X main.version='"$GIT_DESC"
ADD https://curl.haxx.se/ca/cacert.pem /certs.crt
RUN chmod 0644 /certs.crt
RUN mkdir /.dumbproxy

FROM scratch AS scratch
COPY --from=build /go/src/github.com/Snawoot/dumbproxy/dumbproxy /
COPY --from=build /certs.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build --chown=9999:9999 /.dumbproxy /.dumbproxy
USER 9999:9999
EXPOSE 8080/tcp
ENTRYPOINT ["/dumbproxy", "-bind-address", ":8080"]

FROM alpine AS alpine
COPY --from=build /go/src/github.com/Snawoot/dumbproxy/dumbproxy /
COPY --from=build /certs.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build --chown=9999:9999 /.dumbproxy /.dumbproxy
USER 9999:9999
EXPOSE 8080/tcp
ENTRYPOINT ["/dumbproxy", "-bind-address", ":8080"]
