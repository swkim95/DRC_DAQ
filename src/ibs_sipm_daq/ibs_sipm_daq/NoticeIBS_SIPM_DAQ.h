#ifndef MINITCB_V2_H
#define MINITCB_V2_H

#define MAX_TCP_CONNECT         5       /* time in secs to get a connection */
#define MAX_TCP_READ            3       /* time in secs to wait for the DSO
                                           to respond to a read request */
#define BOOL                    int
#define TRUE                    1
#define FALSE                   0

#ifdef __cplusplus
extern  "C" {
#endif

extern int IBS_SIPM_DAQopen(void);
extern void IBS_SIPM_DAQclose(int tcp_Handle);
extern void IBS_SIPM_DAQunprotect(int tcp_Handle);
extern void IBS_SIPM_DAQprotect(int tcp_Handle);
extern void IBS_SIPM_DAQerase(int tcp_Handle, int sector);
extern void IBS_SIPM_DAQprogram(int tcp_Handle, int sector, int page, char *data);
extern void IBS_SIPM_DAQverify(int tcp_Handle, int sector, int page, char *data);
extern void IBS_SIPM_DAQreset(int tcp_Handle);
extern void IBS_SIPM_DAQstart(int tcp_Handle);
extern int IBS_SIPM_DAQread_RUN(int tcp_Handle);
extern int IBS_SIPM_DAQread_DATA(int tcp_Handle, unsigned short *data);
extern void IBS_SIPM_DAQread_MON(int tcp_Handle, int trig_mode, short *data);
extern void IBS_SIPM_DAQwrite_HV(int tcp_Handle, float data);
extern float IBS_SIPM_DAQread_HV(int tcp_Handle);
extern void IBS_SIPM_DAQwrite_THR(int tcp_Handle, int data);
extern int IBS_SIPM_DAQread_THR(int tcp_Handle);
extern float IBS_SIPM_DAQread_TEMP(int tcp_Handle);
extern int IBS_SIPM_DAQread_PED(int tcp_Handle);
extern void IBS_SIPM_DAQwrite_DBG(int tcp_Handle, int data);
extern int IBS_SIPM_DAQread_DBG(int tcp_Handle);

#ifdef __cplusplus
}
#endif

#endif
