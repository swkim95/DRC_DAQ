//
// File generated by rootcint at Thu Nov 11 17:42:15 2021

// Do NOT change. Changes will be lost next time file is generated
//

#define R__DICTIONARY_FILENAME NoticeIBS_SIPM_DAQROOTDict
#include "RConfig.h" //rootcint 4834
#if !defined(R__ACCESS_IN_SYMBOL)
//Break the privacy of classes -- Disabled for the moment
#define private public
#define protected public
#endif

// Since CINT ignores the std namespace, we need to do so in this file.
namespace std {} using namespace std;
#include "NoticeIBS_SIPM_DAQROOTDict.h"

#include "TClass.h"
#include "TBuffer.h"
#include "TMemberInspector.h"
#include "TError.h"

#ifndef G__ROOT
#define G__ROOT
#endif

#include "RtypesImp.h"
#include "TIsAProxy.h"
#include "TFileMergeInfo.h"

// START OF SHADOWS

namespace ROOT {
   namespace Shadow {
   } // of namespace Shadow
} // of namespace ROOT
// END OF SHADOWS

namespace ROOT {
   void NKIBS_SIPM_DAQ_ShowMembers(void *obj, TMemberInspector &R__insp);
   static void *new_NKIBS_SIPM_DAQ(void *p = 0);
   static void *newArray_NKIBS_SIPM_DAQ(Long_t size, void *p);
   static void delete_NKIBS_SIPM_DAQ(void *p);
   static void deleteArray_NKIBS_SIPM_DAQ(void *p);
   static void destruct_NKIBS_SIPM_DAQ(void *p);
   static void streamer_NKIBS_SIPM_DAQ(TBuffer &buf, void *obj);

   // Function generating the singleton type initializer
   static TGenericClassInfo *GenerateInitInstanceLocal(const ::NKIBS_SIPM_DAQ*)
   {
      ::NKIBS_SIPM_DAQ *ptr = 0;
      static ::TVirtualIsAProxy* isa_proxy = new ::TInstrumentedIsAProxy< ::NKIBS_SIPM_DAQ >(0);
      static ::ROOT::TGenericClassInfo 
         instance("NKIBS_SIPM_DAQ", ::NKIBS_SIPM_DAQ::Class_Version(), "./NoticeIBS_SIPM_DAQROOT.h", 8,
                  typeid(::NKIBS_SIPM_DAQ), DefineBehavior(ptr, ptr),
                  &::NKIBS_SIPM_DAQ::Dictionary, isa_proxy, 2,
                  sizeof(::NKIBS_SIPM_DAQ) );
      instance.SetNew(&new_NKIBS_SIPM_DAQ);
      instance.SetNewArray(&newArray_NKIBS_SIPM_DAQ);
      instance.SetDelete(&delete_NKIBS_SIPM_DAQ);
      instance.SetDeleteArray(&deleteArray_NKIBS_SIPM_DAQ);
      instance.SetDestructor(&destruct_NKIBS_SIPM_DAQ);
      instance.SetStreamerFunc(&streamer_NKIBS_SIPM_DAQ);
      return &instance;
   }
   TGenericClassInfo *GenerateInitInstance(const ::NKIBS_SIPM_DAQ*)
   {
      return GenerateInitInstanceLocal((::NKIBS_SIPM_DAQ*)0);
   }
   // Static variable to force the class initialization
   static ::ROOT::TGenericClassInfo *_R__UNIQUE_(Init) = GenerateInitInstanceLocal((const ::NKIBS_SIPM_DAQ*)0x0); R__UseDummy(_R__UNIQUE_(Init));
} // end of namespace ROOT

//______________________________________________________________________________
TClass *NKIBS_SIPM_DAQ::fgIsA = 0;  // static to hold class pointer

//______________________________________________________________________________
const char *NKIBS_SIPM_DAQ::Class_Name()
{
   return "NKIBS_SIPM_DAQ";
}

//______________________________________________________________________________
const char *NKIBS_SIPM_DAQ::ImplFileName()
{
   return ::ROOT::GenerateInitInstanceLocal((const ::NKIBS_SIPM_DAQ*)0x0)->GetImplFileName();
}

//______________________________________________________________________________
int NKIBS_SIPM_DAQ::ImplFileLine()
{
   return ::ROOT::GenerateInitInstanceLocal((const ::NKIBS_SIPM_DAQ*)0x0)->GetImplFileLine();
}

//______________________________________________________________________________
void NKIBS_SIPM_DAQ::Dictionary()
{
   fgIsA = ::ROOT::GenerateInitInstanceLocal((const ::NKIBS_SIPM_DAQ*)0x0)->GetClass();
}

//______________________________________________________________________________
TClass *NKIBS_SIPM_DAQ::Class()
{
   if (!fgIsA) fgIsA = ::ROOT::GenerateInitInstanceLocal((const ::NKIBS_SIPM_DAQ*)0x0)->GetClass();
   return fgIsA;
}

//______________________________________________________________________________
void NKIBS_SIPM_DAQ::Streamer(TBuffer &R__b)
{
   // Stream an object of class NKIBS_SIPM_DAQ.

   TObject::Streamer(R__b);
}

//______________________________________________________________________________
void NKIBS_SIPM_DAQ::ShowMembers(TMemberInspector &R__insp)
{
      // Inspect the data members of an object of class NKIBS_SIPM_DAQ.
      TClass *R__cl = ::NKIBS_SIPM_DAQ::IsA();
      if (R__cl || R__insp.IsA()) { }
      TObject::ShowMembers(R__insp);
}

namespace ROOT {
   // Wrappers around operator new
   static void *new_NKIBS_SIPM_DAQ(void *p) {
      return  p ? new(p) ::NKIBS_SIPM_DAQ : new ::NKIBS_SIPM_DAQ;
   }
   static void *newArray_NKIBS_SIPM_DAQ(Long_t nElements, void *p) {
      return p ? new(p) ::NKIBS_SIPM_DAQ[nElements] : new ::NKIBS_SIPM_DAQ[nElements];
   }
   // Wrapper around operator delete
   static void delete_NKIBS_SIPM_DAQ(void *p) {
      delete ((::NKIBS_SIPM_DAQ*)p);
   }
   static void deleteArray_NKIBS_SIPM_DAQ(void *p) {
      delete [] ((::NKIBS_SIPM_DAQ*)p);
   }
   static void destruct_NKIBS_SIPM_DAQ(void *p) {
      typedef ::NKIBS_SIPM_DAQ current_t;
      ((current_t*)p)->~current_t();
   }
   // Wrapper around a custom streamer member function.
   static void streamer_NKIBS_SIPM_DAQ(TBuffer &buf, void *obj) {
      ((::NKIBS_SIPM_DAQ*)obj)->::NKIBS_SIPM_DAQ::Streamer(buf);
   }
} // end of namespace ROOT for class ::NKIBS_SIPM_DAQ

/********************************************************
* NoticeIBS_SIPM_DAQROOTDict.cc
* CAUTION: DON'T CHANGE THIS FILE. THIS FILE IS AUTOMATICALLY GENERATED
*          FROM HEADER FILES LISTED IN G__setup_cpp_environmentXXX().
*          CHANGE THOSE HEADER FILES AND REGENERATE THIS FILE.
********************************************************/

#ifdef G__MEMTEST
#undef malloc
#undef free
#endif

#if defined(__GNUC__) && __GNUC__ >= 4 && ((__GNUC_MINOR__ == 2 && __GNUC_PATCHLEVEL__ >= 1) || (__GNUC_MINOR__ >= 3))
#pragma GCC diagnostic ignored "-Wstrict-aliasing"
#endif

extern "C" void G__cpp_reset_tagtableNoticeIBS_SIPM_DAQROOTDict();

extern "C" void G__set_cpp_environmentNoticeIBS_SIPM_DAQROOTDict() {
  G__add_compiledheader("TObject.h");
  G__add_compiledheader("TMemberInspector.h");
  G__add_compiledheader("NoticeIBS_SIPM_DAQROOT.h");
  G__cpp_reset_tagtableNoticeIBS_SIPM_DAQROOTDict();
}
#include <new>
extern "C" int G__cpp_dllrevNoticeIBS_SIPM_DAQROOTDict() { return(30051515); }

/*********************************************************
* Member function Interface Method
*********************************************************/

/* NKIBS_SIPM_DAQ */
static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_1(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
   NKIBS_SIPM_DAQ* p = NULL;
   char* gvp = (char*) G__getgvp();
   int n = G__getaryconstruct();
   if (n) {
     if ((gvp == (char*)G__PVOID) || (gvp == 0)) {
       p = new NKIBS_SIPM_DAQ[n];
     } else {
       p = new((void*) gvp) NKIBS_SIPM_DAQ[n];
     }
   } else {
     if ((gvp == (char*)G__PVOID) || (gvp == 0)) {
       p = new NKIBS_SIPM_DAQ;
     } else {
       p = new((void*) gvp) NKIBS_SIPM_DAQ;
     }
   }
   result7->obj.i = (long) p;
   result7->ref = (long) p;
   G__set_tagnum(result7,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_2(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQopen());
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_3(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQclose((int) G__int(libp->para[0]));
      G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_4(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQreset((int) G__int(libp->para[0]));
      G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_5(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQstart((int) G__int(libp->para[0]));
      G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_6(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQread_RUN((int) G__int(libp->para[0])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_7(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQread_DATA((int) G__int(libp->para[0]), (unsigned short*) G__int(libp->para[1])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_8(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQread_MON((int) G__int(libp->para[0]), (int) G__int(libp->para[1])
, (short*) G__int(libp->para[2]));
      G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_9(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQwrite_HV((int) G__int(libp->para[0]), (float) G__double(libp->para[1]));
      G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_10(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letdouble(result7, 102, (double) ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQread_HV((int) G__int(libp->para[0])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_11(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQwrite_THR((int) G__int(libp->para[0]), (int) G__int(libp->para[1]));
      G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_12(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQread_THR((int) G__int(libp->para[0])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_13(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letdouble(result7, 102, (double) ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQread_TEMP((int) G__int(libp->para[0])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_14(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) ((NKIBS_SIPM_DAQ*) G__getstructoffset())->IBS_SIPM_DAQread_PED((int) G__int(libp->para[0])));
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_15(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 85, (long) NKIBS_SIPM_DAQ::Class());
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_16(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 67, (long) NKIBS_SIPM_DAQ::Class_Name());
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_17(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 115, (long) NKIBS_SIPM_DAQ::Class_Version());
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_18(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      NKIBS_SIPM_DAQ::Dictionary();
      G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_22(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      ((NKIBS_SIPM_DAQ*) G__getstructoffset())->StreamerNVirtual(*(TBuffer*) libp->para[0].ref);
      G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_23(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 67, (long) NKIBS_SIPM_DAQ::DeclFileName());
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_24(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) NKIBS_SIPM_DAQ::ImplFileLine());
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_25(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 67, (long) NKIBS_SIPM_DAQ::ImplFileName());
   return(1 || funcname || hash || result7 || libp) ;
}

static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_26(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
      G__letint(result7, 105, (long) NKIBS_SIPM_DAQ::DeclFileLine());
   return(1 || funcname || hash || result7 || libp) ;
}

// automatic copy constructor
static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_27(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)

{
   NKIBS_SIPM_DAQ* p;
   void* tmp = (void*) G__int(libp->para[0]);
   p = new NKIBS_SIPM_DAQ(*(NKIBS_SIPM_DAQ*) tmp);
   result7->obj.i = (long) p;
   result7->ref = (long) p;
   G__set_tagnum(result7,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ));
   return(1 || funcname || hash || result7 || libp) ;
}

// automatic destructor
typedef NKIBS_SIPM_DAQ G__TNKIBS_SIPM_DAQ;
static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_28(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
   char* gvp = (char*) G__getgvp();
   long soff = G__getstructoffset();
   int n = G__getaryconstruct();
   //
   //has_a_delete: 1
   //has_own_delete1arg: 0
   //has_own_delete2arg: 0
   //
   if (!soff) {
     return(1);
   }
   if (n) {
     if (gvp == (char*)G__PVOID) {
       delete[] (NKIBS_SIPM_DAQ*) soff;
     } else {
       G__setgvp((long) G__PVOID);
       for (int i = n - 1; i >= 0; --i) {
         ((NKIBS_SIPM_DAQ*) (soff+(sizeof(NKIBS_SIPM_DAQ)*i)))->~G__TNKIBS_SIPM_DAQ();
       }
       G__setgvp((long)gvp);
     }
   } else {
     if (gvp == (char*)G__PVOID) {
       delete (NKIBS_SIPM_DAQ*) soff;
     } else {
       G__setgvp((long) G__PVOID);
       ((NKIBS_SIPM_DAQ*) (soff))->~G__TNKIBS_SIPM_DAQ();
       G__setgvp((long)gvp);
     }
   }
   G__setnull(result7);
   return(1 || funcname || hash || result7 || libp) ;
}

// automatic assignment operator
static int G__NoticeIBS_SIPM_DAQROOTDict_169_0_29(G__value* result7, G__CONST char* funcname, struct G__param* libp, int hash)
{
   NKIBS_SIPM_DAQ* dest = (NKIBS_SIPM_DAQ*) G__getstructoffset();
   *dest = *(NKIBS_SIPM_DAQ*) libp->para[0].ref;
   const NKIBS_SIPM_DAQ& obj = *dest;
   result7->ref = (long) (&obj);
   result7->obj.i = (long) (&obj);
   return(1 || funcname || hash || result7 || libp) ;
}


/* Setting up global function */

/*********************************************************
* Member function Stub
*********************************************************/

/* NKIBS_SIPM_DAQ */

/*********************************************************
* Global function Stub
*********************************************************/

/*********************************************************
* Get size of pointer to member function
*********************************************************/
class G__Sizep2memfuncNoticeIBS_SIPM_DAQROOTDict {
 public:
  G__Sizep2memfuncNoticeIBS_SIPM_DAQROOTDict(): p(&G__Sizep2memfuncNoticeIBS_SIPM_DAQROOTDict::sizep2memfunc) {}
    size_t sizep2memfunc() { return(sizeof(p)); }
  private:
    size_t (G__Sizep2memfuncNoticeIBS_SIPM_DAQROOTDict::*p)();
};

size_t G__get_sizep2memfuncNoticeIBS_SIPM_DAQROOTDict()
{
  G__Sizep2memfuncNoticeIBS_SIPM_DAQROOTDict a;
  G__setsizep2memfunc((int)a.sizep2memfunc());
  return((size_t)a.sizep2memfunc());
}


/*********************************************************
* virtual base class offset calculation interface
*********************************************************/

   /* Setting up class inheritance */

/*********************************************************
* Inheritance information setup/
*********************************************************/
extern "C" void G__cpp_setup_inheritanceNoticeIBS_SIPM_DAQROOTDict() {

   /* Setting up class inheritance */
   if(0==G__getnumbaseclass(G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ))) {
     NKIBS_SIPM_DAQ *G__Lderived;
     G__Lderived=(NKIBS_SIPM_DAQ*)0x1000;
     {
       TObject *G__Lpbase=(TObject*)G__Lderived;
       G__inheritance_setup(G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ),G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_TObject),(long)G__Lpbase-(long)G__Lderived,1,1);
     }
   }
}

/*********************************************************
* typedef information setup/
*********************************************************/
extern "C" void G__cpp_setup_typetableNoticeIBS_SIPM_DAQROOTDict() {

   /* Setting up typedef entry */
   G__search_typename2("Version_t",115,-1,0,-1);
   G__setnewtype(-1,"Class version identifier (short)",0);
   G__search_typename2("vector<ROOT::TSchemaHelper>",117,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR),0,-1);
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<const_iterator>",117,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<iterator>",117,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("vector<TVirtualArray*>",117,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR),0,-1);
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<const_iterator>",117,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR));
   G__setnewtype(-1,NULL,0);
   G__search_typename2("reverse_iterator<iterator>",117,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR),0,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR));
   G__setnewtype(-1,NULL,0);
}

/*********************************************************
* Data Member information setup/
*********************************************************/

   /* Setting up class,struct,union tag member variable */

   /* NKIBS_SIPM_DAQ */
static void G__setup_memvarNKIBS_SIPM_DAQ(void) {
   G__tag_memvar_setup(G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ));
   { NKIBS_SIPM_DAQ *p; p=(NKIBS_SIPM_DAQ*)0x1000; if (p) { }
   G__memvar_setup((void*)0,85,0,0,G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_TClass),-1,-2,4,"fgIsA=",0,(char*)NULL);
   }
   G__tag_memvar_reset();
}

extern "C" void G__cpp_setup_memvarNoticeIBS_SIPM_DAQROOTDict() {
}
/***********************************************************
************************************************************
************************************************************
************************************************************
************************************************************
************************************************************
************************************************************
***********************************************************/

/*********************************************************
* Member function information setup for each class
*********************************************************/
static void G__setup_memfuncNKIBS_SIPM_DAQ(void) {
   /* NKIBS_SIPM_DAQ */
   G__tag_memfunc_setup(G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ));
   G__memfunc_setup("NKIBS_SIPM_DAQ",1092,G__NoticeIBS_SIPM_DAQROOTDict_169_0_1, 105, G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ), -1, 0, 0, 1, 1, 0, "", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQopen",1373,G__NoticeIBS_SIPM_DAQROOTDict_169_0_2, 105, -1, -1, 0, 0, 1, 1, 0, "", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQclose",1473,G__NoticeIBS_SIPM_DAQROOTDict_169_0_3, 121, -1, -1, 0, 1, 1, 1, 0, "i - - 0 - tcp_Handle", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQreset",1486,G__NoticeIBS_SIPM_DAQROOTDict_169_0_4, 121, -1, -1, 0, 1, 1, 1, 0, "i - - 0 - tcp_Handle", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQstart",1497,G__NoticeIBS_SIPM_DAQROOTDict_169_0_5, 121, -1, -1, 0, 1, 1, 1, 0, "i - - 0 - tcp_Handle", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQread_RUN",1691,G__NoticeIBS_SIPM_DAQROOTDict_169_0_6, 105, -1, -1, 0, 1, 1, 1, 0, "i - - 0 - tcp_Handle", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQread_DATA",1728,G__NoticeIBS_SIPM_DAQROOTDict_169_0_7, 105, -1, -1, 0, 2, 1, 1, 0, 
"i - - 0 - tcp_Handle R - - 0 - data", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQread_MON",1680,G__NoticeIBS_SIPM_DAQROOTDict_169_0_8, 121, -1, -1, 0, 3, 1, 1, 0, 
"i - - 0 - tcp_Handle i - - 0 - trig_mode "
"S - - 0 - data", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQwrite_HV",1747,G__NoticeIBS_SIPM_DAQROOTDict_169_0_9, 121, -1, -1, 0, 2, 1, 1, 0, 
"i - - 0 - tcp_Handle f - - 0 - data", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQread_HV",1604,G__NoticeIBS_SIPM_DAQROOTDict_169_0_10, 102, -1, -1, 0, 1, 1, 1, 0, "i - - 0 - tcp_Handle", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQwrite_THR",1827,G__NoticeIBS_SIPM_DAQROOTDict_169_0_11, 121, -1, -1, 0, 2, 1, 1, 0, 
"i - - 0 - tcp_Handle i - - 0 - data", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQread_THR",1684,G__NoticeIBS_SIPM_DAQROOTDict_169_0_12, 105, -1, -1, 0, 1, 1, 1, 0, "i - - 0 - tcp_Handle", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQread_TEMP",1756,G__NoticeIBS_SIPM_DAQROOTDict_169_0_13, 102, -1, -1, 0, 1, 1, 1, 0, "i - - 0 - tcp_Handle", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("IBS_SIPM_DAQread_PED",1663,G__NoticeIBS_SIPM_DAQROOTDict_169_0_14, 105, -1, -1, 0, 1, 1, 1, 0, "i - - 0 - tcp_Handle", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("Class",502,G__NoticeIBS_SIPM_DAQROOTDict_169_0_15, 85, G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_TClass), -1, 0, 0, 3, 1, 0, "", (char*)NULL, (void*) G__func2void( (TClass* (*)())(&NKIBS_SIPM_DAQ::Class) ), 0);
   G__memfunc_setup("Class_Name",982,G__NoticeIBS_SIPM_DAQROOTDict_169_0_16, 67, -1, -1, 0, 0, 3, 1, 1, "", (char*)NULL, (void*) G__func2void( (const char* (*)())(&NKIBS_SIPM_DAQ::Class_Name) ), 0);
   G__memfunc_setup("Class_Version",1339,G__NoticeIBS_SIPM_DAQROOTDict_169_0_17, 115, -1, G__defined_typename("Version_t"), 0, 0, 3, 1, 0, "", (char*)NULL, (void*) G__func2void( (Version_t (*)())(&NKIBS_SIPM_DAQ::Class_Version) ), 0);
   G__memfunc_setup("Dictionary",1046,G__NoticeIBS_SIPM_DAQROOTDict_169_0_18, 121, -1, -1, 0, 0, 3, 1, 0, "", (char*)NULL, (void*) G__func2void( (void (*)())(&NKIBS_SIPM_DAQ::Dictionary) ), 0);
   G__memfunc_setup("IsA",253,(G__InterfaceMethod) NULL,85, G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_TClass), -1, 0, 0, 1, 1, 8, "", (char*)NULL, (void*) NULL, 1);
   G__memfunc_setup("ShowMembers",1132,(G__InterfaceMethod) NULL,121, -1, -1, 0, 1, 1, 1, 0, "u 'TMemberInspector' - 1 - -", (char*)NULL, (void*) NULL, 1);
   G__memfunc_setup("Streamer",835,(G__InterfaceMethod) NULL,121, -1, -1, 0, 1, 1, 1, 0, "u 'TBuffer' - 1 - -", (char*)NULL, (void*) NULL, 1);
   G__memfunc_setup("StreamerNVirtual",1656,G__NoticeIBS_SIPM_DAQROOTDict_169_0_22, 121, -1, -1, 0, 1, 1, 1, 0, "u 'TBuffer' - 1 - ClassDef_StreamerNVirtual_b", (char*)NULL, (void*) NULL, 0);
   G__memfunc_setup("DeclFileName",1145,G__NoticeIBS_SIPM_DAQROOTDict_169_0_23, 67, -1, -1, 0, 0, 3, 1, 1, "", (char*)NULL, (void*) G__func2void( (const char* (*)())(&NKIBS_SIPM_DAQ::DeclFileName) ), 0);
   G__memfunc_setup("ImplFileLine",1178,G__NoticeIBS_SIPM_DAQROOTDict_169_0_24, 105, -1, -1, 0, 0, 3, 1, 0, "", (char*)NULL, (void*) G__func2void( (int (*)())(&NKIBS_SIPM_DAQ::ImplFileLine) ), 0);
   G__memfunc_setup("ImplFileName",1171,G__NoticeIBS_SIPM_DAQROOTDict_169_0_25, 67, -1, -1, 0, 0, 3, 1, 1, "", (char*)NULL, (void*) G__func2void( (const char* (*)())(&NKIBS_SIPM_DAQ::ImplFileName) ), 0);
   G__memfunc_setup("DeclFileLine",1152,G__NoticeIBS_SIPM_DAQROOTDict_169_0_26, 105, -1, -1, 0, 0, 3, 1, 0, "", (char*)NULL, (void*) G__func2void( (int (*)())(&NKIBS_SIPM_DAQ::DeclFileLine) ), 0);
   // automatic copy constructor
   G__memfunc_setup("NKIBS_SIPM_DAQ", 1092, G__NoticeIBS_SIPM_DAQROOTDict_169_0_27, (int) ('i'), G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ), -1, 0, 1, 1, 1, 0, "u 'NKIBS_SIPM_DAQ' - 11 - -", (char*) NULL, (void*) NULL, 0);
   // automatic destructor
   G__memfunc_setup("~NKIBS_SIPM_DAQ", 1218, G__NoticeIBS_SIPM_DAQROOTDict_169_0_28, (int) ('y'), -1, -1, 0, 0, 1, 1, 0, "", (char*) NULL, (void*) NULL, 1);
   // automatic assignment operator
   G__memfunc_setup("operator=", 937, G__NoticeIBS_SIPM_DAQROOTDict_169_0_29, (int) ('u'), G__get_linked_tagnum(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ), -1, 1, 1, 1, 1, 0, "u 'NKIBS_SIPM_DAQ' - 11 - -", (char*) NULL, (void*) NULL, 0);
   G__tag_memfunc_reset();
}


/*********************************************************
* Member function information setup
*********************************************************/
extern "C" void G__cpp_setup_memfuncNoticeIBS_SIPM_DAQROOTDict() {
}

/*********************************************************
* Global variable information setup for each class
*********************************************************/
static void G__cpp_setup_global0() {

   /* Setting up global variables */
   G__resetplocal();

}

static void G__cpp_setup_global1() {

   G__resetglobalenv();
}
extern "C" void G__cpp_setup_globalNoticeIBS_SIPM_DAQROOTDict() {
  G__cpp_setup_global0();
  G__cpp_setup_global1();
}

/*********************************************************
* Global function information setup for each class
*********************************************************/
static void G__cpp_setup_func0() {
   G__lastifuncposition();

}

static void G__cpp_setup_func1() {
}

static void G__cpp_setup_func2() {
}

static void G__cpp_setup_func3() {
}

static void G__cpp_setup_func4() {
}

static void G__cpp_setup_func5() {
}

static void G__cpp_setup_func6() {
}

static void G__cpp_setup_func7() {
}

static void G__cpp_setup_func8() {
}

static void G__cpp_setup_func9() {
}

static void G__cpp_setup_func10() {
}

static void G__cpp_setup_func11() {
}

static void G__cpp_setup_func12() {

   G__resetifuncposition();
}

extern "C" void G__cpp_setup_funcNoticeIBS_SIPM_DAQROOTDict() {
  G__cpp_setup_func0();
  G__cpp_setup_func1();
  G__cpp_setup_func2();
  G__cpp_setup_func3();
  G__cpp_setup_func4();
  G__cpp_setup_func5();
  G__cpp_setup_func6();
  G__cpp_setup_func7();
  G__cpp_setup_func8();
  G__cpp_setup_func9();
  G__cpp_setup_func10();
  G__cpp_setup_func11();
  G__cpp_setup_func12();
}

/*********************************************************
* Class,struct,union,enum tag information setup
*********************************************************/
/* Setup class/struct taginfo */
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_TClass = { "TClass" , 99 , -1 };
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_TBuffer = { "TBuffer" , 99 , -1 };
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_TMemberInspector = { "TMemberInspector" , 99 , -1 };
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_TObject = { "TObject" , 99 , -1 };
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR = { "vector<ROOT::TSchemaHelper,allocator<ROOT::TSchemaHelper> >" , 99 , -1 };
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR = { "reverse_iterator<vector<ROOT::TSchemaHelper,allocator<ROOT::TSchemaHelper> >::iterator>" , 99 , -1 };
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR = { "vector<TVirtualArray*,allocator<TVirtualArray*> >" , 99 , -1 };
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR = { "reverse_iterator<vector<TVirtualArray*,allocator<TVirtualArray*> >::iterator>" , 99 , -1 };
G__linked_taginfo G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ = { "NKIBS_SIPM_DAQ" , 99 , -1 };

/* Reset class/struct taginfo */
extern "C" void G__cpp_reset_tagtableNoticeIBS_SIPM_DAQROOTDict() {
  G__NoticeIBS_SIPM_DAQROOTDictLN_TClass.tagnum = -1 ;
  G__NoticeIBS_SIPM_DAQROOTDictLN_TBuffer.tagnum = -1 ;
  G__NoticeIBS_SIPM_DAQROOTDictLN_TMemberInspector.tagnum = -1 ;
  G__NoticeIBS_SIPM_DAQROOTDictLN_TObject.tagnum = -1 ;
  G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR.tagnum = -1 ;
  G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR.tagnum = -1 ;
  G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR.tagnum = -1 ;
  G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR.tagnum = -1 ;
  G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ.tagnum = -1 ;
}


extern "C" void G__cpp_setup_tagtableNoticeIBS_SIPM_DAQROOTDict() {

   /* Setting up class,struct,union tag entry */
   G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_TClass);
   G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_TBuffer);
   G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_TMemberInspector);
   G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_TObject);
   G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgR);
   G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlEROOTcLcLTSchemaHelpercOallocatorlEROOTcLcLTSchemaHelpergRsPgRcLcLiteratorgR);
   G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_vectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgR);
   G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_reverse_iteratorlEvectorlETVirtualArraymUcOallocatorlETVirtualArraymUgRsPgRcLcLiteratorgR);
   G__tagtable_setup(G__get_linked_tagnum_fwd(&G__NoticeIBS_SIPM_DAQROOTDictLN_NKIBS_SIPM_DAQ),sizeof(NKIBS_SIPM_DAQ),-1,161024,"NKIBS_SIPM_DAQ wrapper class for root",G__setup_memvarNKIBS_SIPM_DAQ,G__setup_memfuncNKIBS_SIPM_DAQ);
}
extern "C" void G__cpp_setupNoticeIBS_SIPM_DAQROOTDict(void) {
  G__check_setup_version(30051515,"G__cpp_setupNoticeIBS_SIPM_DAQROOTDict()");
  G__set_cpp_environmentNoticeIBS_SIPM_DAQROOTDict();
  G__cpp_setup_tagtableNoticeIBS_SIPM_DAQROOTDict();

  G__cpp_setup_inheritanceNoticeIBS_SIPM_DAQROOTDict();

  G__cpp_setup_typetableNoticeIBS_SIPM_DAQROOTDict();

  G__cpp_setup_memvarNoticeIBS_SIPM_DAQROOTDict();

  G__cpp_setup_memfuncNoticeIBS_SIPM_DAQROOTDict();
  G__cpp_setup_globalNoticeIBS_SIPM_DAQROOTDict();
  G__cpp_setup_funcNoticeIBS_SIPM_DAQROOTDict();

   if(0==G__getsizep2memfunc()) G__get_sizep2memfuncNoticeIBS_SIPM_DAQROOTDict();
  return;
}
class G__cpp_setup_initNoticeIBS_SIPM_DAQROOTDict {
  public:
    G__cpp_setup_initNoticeIBS_SIPM_DAQROOTDict() { G__add_setup_func("NoticeIBS_SIPM_DAQROOTDict",(G__incsetup)(&G__cpp_setupNoticeIBS_SIPM_DAQROOTDict)); G__call_setup_funcs(); }
   ~G__cpp_setup_initNoticeIBS_SIPM_DAQROOTDict() { G__remove_setup_func("NoticeIBS_SIPM_DAQROOTDict"); }
};
G__cpp_setup_initNoticeIBS_SIPM_DAQROOTDict G__cpp_setup_initializerNoticeIBS_SIPM_DAQROOTDict;

