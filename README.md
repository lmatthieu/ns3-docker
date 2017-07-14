# ns3-docker
A simple NS3 Docker image used for distributed algorithm experimentations

## Using NetAnim on MacOSX

This docker image install the NetAnim application to explore NS3 simulations. 
You can start it in MacOSX using the following commands:

```
# Start socat for opening ports X11
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"

# Extract the current IP
ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $ip

# Start Docker image
docker run -e DISPLAY=$ip:0 -v /tmp/.X11-unix:/tmp/.X11-unix -it ns3-docker:latest /usr/bin/NetAnim
```
