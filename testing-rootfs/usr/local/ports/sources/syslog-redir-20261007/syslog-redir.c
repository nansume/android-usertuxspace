#define _GNU_SOURCE

#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <stddef.h>

static int (*real_connect)(int, const struct sockaddr *, socklen_t);
static int (*real_open)(const char *, int, ...);

__attribute__((constructor))
static void init(void)
{
    real_connect = dlsym(RTLD_NEXT, "connect");
    real_open = dlsym(RTLD_NEXT, "open");
}

/*
 * Redirect:
 *
 *     connect(AF_UNIX, "/dev/log")
 *
 * to:
 *
 *     connect(AF_UNIX, "/tmp/log")
 */
int connect(int fd, const struct sockaddr *addr, socklen_t len)
{
    struct sockaddr_un sa;

    if (addr &&
        addr->sa_family == AF_UNIX &&
        len >= offsetof(struct sockaddr_un, sun_path) &&
        strcmp(((const struct sockaddr_un *)addr)->sun_path,
               "/dev/log") == 0) {

        memset(&sa, 0, sizeof(sa));
        sa.sun_family = AF_UNIX;
        strncpy(sa.sun_path, "/tmp/log", sizeof(sa.sun_path) - 1);

        return real_connect(fd,
                            (const struct sockaddr *)&sa,
                            sizeof(sa));
    }

    return real_connect(fd, addr, len);
}

/*
 * Redirect:
 *
 *     open("/dev/console", ...)
 *
 * to:
 *
 *     open("/dev/null", ...)
 */
int open(const char *path, int flags, ...)
{
    mode_t mode;

    if (strcmp(path, "/dev/log") == 0)
        path = "/tmp/log";
    else if (strcmp(path, "/dev/console") == 0)
        path = "/dev/null";
    else if (strcmp(path, "/dev/klog") == 0)
        path = "/dev/null";
    else if (strcmp(path, "/proc/kmsg") == 0)
        path = "/dev/null";

    if (flags & O_CREAT) {
        va_list ap;
        va_start(ap, flags);
        mode = va_arg(ap, mode_t);
        va_end(ap);

        return real_open(path, flags, mode);
    }

    return real_open(path, flags);
}
