/* OpenHarmony musl omits pthread_cancel/pthread_testcancel exports.
 * No-op fallbacks linked into libmosquitto: client tools never rely on
 * asynchronous cancellation for correctness (they exit via loop end);
 * mosquitto_loop_start threads should be joined via mosquitto_loop_stop. */
#include <pthread.h>

int pthread_cancel(pthread_t t) { (void)t; return 0; }
void pthread_testcancel(void) { }
