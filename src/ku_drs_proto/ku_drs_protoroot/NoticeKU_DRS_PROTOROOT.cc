#include "NoticeKU_DRS_PROTOROOT.h"
#include "NoticeKU_DRS_PROTO.h"

ClassImp(NKKU_DRS_PROTO)

NKKU_DRS_PROTO::NKKU_DRS_PROTO() {}

NKKU_DRS_PROTO::~NKKU_DRS_PROTO() {}

int NKKU_DRS_PROTO::KU_DRS_PROTOopen(int sid)
{return ::KU_DRS_PROTOopen(sid);}

void NKKU_DRS_PROTO::KU_DRS_PROTOclose(int sid)
{::KU_DRS_PROTOclose(sid);}

void NKKU_DRS_PROTO::KU_DRS_PROTOread_DATA(int sid, int buf_cnt, char *data)
{::KU_DRS_PROTOread_DATA(sid, buf_cnt, data);}

void NKKU_DRS_PROTO::KU_DRS_PROTOreset(int sid)
{::KU_DRS_PROTOreset(sid);}

void NKKU_DRS_PROTO::KU_DRS_PROTOstart(int sid)
{::KU_DRS_PROTOstart(sid);}

void NKKU_DRS_PROTO::KU_DRS_PROTOstop(int sid)
{::KU_DRS_PROTOstop(sid);}

int NKKU_DRS_PROTO::KU_DRS_PROTOread_RUN(int sid)
{return ::KU_DRS_PROTOread_RUN(sid);}

int NKKU_DRS_PROTO::KU_DRS_PROTOread_DATASIZE(int sid)
{return ::KU_DRS_PROTOread_DATASIZE(sid);}

void NKKU_DRS_PROTO::KU_DRS_PROTOwrite_TRIG_DLY(int sid, int data)
{::KU_DRS_PROTOwrite_TRIG_DLY(sid, data);}

int NKKU_DRS_PROTO::KU_DRS_PROTOread_TRIG_DLY(int sid)
{return ::KU_DRS_PROTOread_TRIG_DLY(sid);}

void NKKU_DRS_PROTO::KU_DRS_PROTOwrite_CALMODE(int sid, int data)
{::KU_DRS_PROTOwrite_CALMODE(sid, data);}

int NKKU_DRS_PROTO::KU_DRS_PROTOread_CALMODE(int sid)
{return ::KU_DRS_PROTOread_CALMODE(sid);}

void NKKU_DRS_PROTO::KU_DRS_PROTOsend_TRIG(int sid)
{::KU_DRS_PROTOsend_TRIG(sid);}


