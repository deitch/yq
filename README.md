# yq

This is our instantiation of yq, a [yml](yaml.org) file parser and querier. Unlike most of the other yq implementations out there (e.g. on github). As it is go-based and compiled, it will run on any platform.

It can be run as a standalone script or as a Docker container.

## Installation

#### Build from source

1. Run `go get github.com/deitch/yq`
2. `go install github.com/deitch/yq`
3. Run `yq`

#### Download the binary

Get the release for your platform from https://github.com/deitch/yq/releases

#### Container
Just run it:

````
cat somefile.yml | docker run -i --rm deitch/yq <filter>
````

Don't forget the `-i` so that docker will pass standard-in to the process.

The container image is **smaller than 5 MB!**. It uses the plain vanilla Alpine image with the script installed. That is it.


## Usage
Like the amazing (and much more powerful) [jq](https://stedolan.github.io/jq), yq receives its input from STDIN:

````
cat somefile.yml | yq
````

What yq does with the input depends entirely on the first argument to it, the filter.

In the case of using it as a Docker container, just replace `yq` with `docker run -i --rm deitch/yq <filter>`

### Filters
As of this writing, yq only supports basic simple filters. Here are some examples. The inputs are from the attached sample `docker-compose.yml`, so feel free to try these out.

````yml
version: "2"
services:
  web:
    image: nginx
    environment:
      - MYENV=abcd
      - OTHERENV=check
    command: run this command
    container_name: containerabc
````

#### No filter
No filter just spits out the original file.

````
$ cat docker-compose.yml | yq
version: "2"
services:
  web:
    image: nginx
    environment:
      - MYENV=abcd
      - OTHERENV=check
    command: run this command
    container_name: containerabc
$
````

#### Single .
A single `.` is like no filter, it just spits out the original file.

````
$ cat docker-compose.yml | yq .
version: "2"
services:
  web:
    image: nginx
    environment:
      - MYENV=abcd
      - OTHERENV=check
    command: run this command
    container_name: containerabc
$
````


#### Matched key
If the filter is a matched key, `.`-separated, then it will return the value of that key if it exists.

````
$ cat docker-compose.yml | yq .version
"2"
$
````

#### Deep key
If the filter is a matched deep key, `.`-separated, then it will return the value of that key if it exists.

````
$ cat docker-compose.yml | yq .services.web.image
nginx
$
````

#### Unmatched key
If the filter is a key that does not exist, it returns empty.

````
$ cat docker-compose.yml | yq .version222
$
````

#### List key
If the key points to a list, it returns the list on multiple rows.

````
$ cat docker-compose.yml | yq .services.web.environment
- MYENV=abcd
- OTHERENV=check
$
````


#### Children
If the key points to a parent node of multiple children, it will return all of the children in yml

````
$ cat docker-compose.yml | yq .services.web
    image: nginx
    environment:
      - MYENV=abcd
      - OTHERENV=check
    command: run this command
    container_name: containerabc
$
````
