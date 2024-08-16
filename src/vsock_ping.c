#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/socket.h>
#include <linux/vm_sockets.h>
#include <time.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    struct timespec start, end;
    uint32_t cid;
    uint32_t port;
    uint32_t iterations = 0;
    uint32_t sleep_ms = 1000; // Default sleep time is 1000ms (1 second)
    int fd;

    if (argc < 3 || argc > 5) {
        printf("Usage: %s <CID> <port> [iterations] [sleep_ms]\n", argv[0]);
        return 1;
    }

    cid = strtoul(argv[1], NULL, 0);
    port = strtoul(argv[2], NULL, 0);

    if (argc >= 4) {
        iterations = strtoul(argv[3], NULL, 0);
    }

    if (argc == 5) {
        sleep_ms = strtoul(argv[4], NULL, 0);
    }

    struct sockaddr_vm sa = {
        .svm_family = AF_VSOCK,
        .svm_cid = cid,
        .svm_port = port,
    };

    do {
        uint64_t delta_us;
        int r;

        fd = socket(AF_VSOCK, SOCK_STREAM, 0);
        if (fd == -1) {
            perror("socket");
            return 1;
        }

        clock_gettime(CLOCK_MONOTONIC, &start);
        r = connect(fd, (struct sockaddr *)&sa, sizeof(sa));
        clock_gettime(CLOCK_MONOTONIC, &end);
        close(fd);

        delta_us = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_nsec - start.tv_nsec) / 1000;
        printf("Reply from cid=%d port=%d status=%s time=%lu µs\n", cid, port, r == -1 ? "refused" : "open", delta_us);

        usleep(sleep_ms * 1000); // Sleep for the specified time in microseconds
    } while (iterations-- != 1);

    return 0;
}
