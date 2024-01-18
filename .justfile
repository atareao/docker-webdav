user    := "atareao"
name    := `basename ${PWD}`
version := `git tag -l  | tail -n1`

build:
    echo {{version}}
    echo {{name}}
    docker build -t {{user}}/{{name}}:{{version}} .

run:
    docker run --rm \
               --init \
               --name webdav \
               --detach \
               -p 8080:8080 \
               -v ${PWD}/share:/share \
               -e USERNAME=user \
               -e PASSWORD=passwd \
               {{user}}/{{name}}:{{version}}

sh:
    docker run --rm \
               --init \
               --name webdav \
               -it \
               -p 8080:8080 \
               -v ${PWD}/share:/share \
               -e USERNAME=user \
               -e PASSWORD=passwd \
               {{user}}/{{name}}:{{version}} \
               sh

tag:
    docker tag {{user}}/{{name}}:{{version}} {{user}}/{{name}}:latest

push:
    docker push {{user}}/{{name}}:{{version}}
    docker push {{user}}/{{name}}:latest
