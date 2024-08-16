# vsock-ping
Ping that uses connect() calls to measure vsock latency

When working with vsock, you want to know whether a specific port is reachable and how long it takes to reach that port. This is a tiny helper tool that measures periodic connect() calls to a target CID:port combination so you can see whether vsock latencies are acceptable.

You can also use it to generate regular vsock traffic.

## Building

You can build it directly using make which creates a `vsock_ping` binary in the current directory:

```sh
$ make
```

or alternatively create a reproducible musl based build using nix which will
put the resulting artifact will in `result/vsock_ping`:

```sh
$ nix build
```

## Usage

The `vsock_ping` tool takes up to 4 arguments

```sh
$ ./vsock_ping
Usage: ./vsock_ping <CID> <port> [iterations] [sleep_ms]
```

**CID** - The vsock target CID (IP address in vsock speech)  
**port** - The vsock port to connect to  
**iterations** - Number of pings to execute. 0 means infinite. Defaults to 0  
**sleep_ms** - Time to sleep between pings in milliseconds. Defaults to 1000.  

To run the tool locally and ping CID 3 (the parent for Nitro Enclaves) on port 8000 every 10ms, run

```sh
$ ./vsock_ping 3 8000 0 100
Reply from cid=3 port=8000 status=refused time=7 µs
Reply from cid=3 port=8000 status=refused time=7 µs
Reply from cid=3 port=8000 status=refused time=7 µs
[...]
```

## Nitro Enclaves

As example, `nix build` will also output a Nitro Enclave Image (EIF) file that you can use to create
background pings inside an enclave. The EIF executes

```sh
$ /bin/vsock_ping 3 8000 0 10 >/dev/null
```

inside the Enclave which will create a connect() request to its parent instance every 1ms. To execute that EIF file, run

```sh
nitro-cli run-enclave --eif-path result/image.eif --cpu-count 2 --memory 512 --debug-mode --attach-console
```

By default, it won't output anything on the console. To check whether it does ping the parent, you can
check whether vsock messages arrive on the parent:

```sh
$ sudo su -
# cd /sys/kernel/debug/tracing/
# echo 1 > events/vsock/enable
# cat trace_pipe
```
