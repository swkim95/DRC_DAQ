#define MAX_TCP_CONNECT         5       /* time in secs to get a connection */
#define MAX_TCP_READ            3       /* time in secs to wait for the DSO
                                           to respond to a read request */
#define BOOL                    int
#define TRUE                    1
#define FALSE                   0

// function prototypes
int CLIENT_Open(char *host);
int CLIENT_Close(int tcp_Handle);
int CLIENT_Transmit(int tcp_Handle, char *buf,int len);
int CLIENT_Receive(int tcp_Handle, char *buf, int len);

