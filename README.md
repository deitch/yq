# yq

This is our instantiation of yq, a [yml](yaml.org) file parser and querier. Unlike most of the other yq implementations out there (e.g. on github), this will run on any platform with basic Linux/Unix/macOS tools installed:

* `bash`
* `sed`
* `awk`

We also are working at implementing it directly in [go](golang.org).

## Installation
Clone this repo `git clone https://github.com/deitch/yq.git` and use the file in the directory `yq`.

If you prefer, just `curl` the file directly: `curl -o yq https://raw.githubusercontent.com/deitch/yq/master/yq`

We recommend putting it in your `PATH`, either by changing your `PATH` to point to the directory it is installed in, or installing it in a typical directory already in `PATH`, e.g. `/usr/local/bin/`.

## Usage
Like the amazing and much more powerful [jq](https://stedolan.github.io/jq), yq receives its input from STDIN:

````
cat somefile.yml | yq
````

What yq does with the input depends entirely on the first argument to it, the filter.

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
