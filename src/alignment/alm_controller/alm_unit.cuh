#ifndef ALM_UNIT_H
#define ALM_UNIT_H
#include "comm.cuh"

enum pointer:byte{
    tom,tox,toy,none    
};
class trace_unit{
public:
    byte storage;
    //pointer m,x,y;
    __all__ trace_unit(){}
    pointer next(pointer from){
        switch(from){
        case pointer::tom:return get_m();
        case pointer::tox:return get_x();
        case pointer::toy:return get_y();
        }
        return pointer::none;
    }
    __all__ void set_m(pointer p){
        storage&=0b11001111;
        storage|=p<<4;
    }
    __all__ void set_x(pointer p){
        storage&=0b11110011;
        storage|=p<<2;
    }
    __all__ void set_y(pointer p){
        storage&=0b11111100;
        storage|=p;
    }
    __all__ pointer get_m(){
        byte tmp=storage>>4;
        return (pointer)(tmp&0b00000011);
    }
    __all__ pointer get_x(){
        byte tmp=storage>>2;
        return (pointer)(tmp&0b00000011);
    }
    __all__ pointer get_y(){
        byte tmp=storage>>0;
        return (pointer)(tmp&0b00000011);
    }
};
class alm_unit{
public:
    datatype m,x,y;
    alm_unit(){
        m=NEG_INF;
        x=NEG_INF;
        y=NEG_INF;
    }
    __device__ datatype to_m(byte _x,byte _y,trace_unit *from){
        datatype ret;
        if(m>x&&m>y){
            from->set_m(pointer::tom);
            ret= m;
        }else if(x>y){
            from->set_m(pointer::tox);
            ret= x;
        }else{
            from->set_m(pointer::toy);
            ret=y;
        }
        return ret+score::match(_x,_y);
    }
    __device__ datatype to_x(trace_unit *from){
        datatype _m=m+score::g_device;
        datatype _x=x+score::e_device;
        datatype _y=y+score::g_device;
        if(_m>_x&&_m>_y){
            from->set_x(pointer::tom);
            return _m;
        }
        if(_x>_y){
            from->set_x(pointer::tox);
            return _x;
        }
        from->set_x(pointer::toy);
        return _y;
    }
    __device__ datatype to_y(trace_unit *from){
        datatype _m=m+score::g_device;
        datatype _x=x+score::g_device;
        datatype _y=y+score::e_device;
        if(_m>_x&&_m>_y){
            from->set_y(pointer::tom);
            return _m;
        }
        if(_x>_y){
            from->set_y(pointer::tox);
            return _x;
        }
        from->set_y(pointer::toy);
        return _y;
    }
    __all__ datatype result(){
        return max3(m,x,y);
    }
    __all__ datatype result(pointer* from){
        if(m>x&&m>y){
            *from=pointer::tom;
            return m;
        }
        if(x>y){
            *from=pointer::tox;
            return x;
        }
        *from=pointer::toy;
        return y;
    }
};

#endif