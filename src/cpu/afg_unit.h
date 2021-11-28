#define max2(a,b) ((a>b)?a:b)
#define max3(a,b,c) max2(a,max2(b,c))
#define NEG_INF -10000000

class afg_unit{
public:
    int m,x,y;
    static int g,e,mis,hit;
    static void set_score(int _g,int _e,int _mis,int _hit){
        g=_g;
        e=_e;
        mis=_mis;
        hit=_hit;
    }
    afg_unit(){
        m=x=y=NEG_INF;// -inf
    }
    afg_unit(int _m,int _x,int _y){
        m=_m;
        x=_x;
        y=_y;
    }
    ~afg_unit(){

    }
    void operator=(afg_unit b){
        m=b.m;
        x=b.x;
        y=b.y;
    }
    int to_m(bool equ){
        return max3(m,x,y)+(equ?hit:mis);
    }
    int to_x(){// y have gap, mean x move
        return max3(m+g,x+e,y+g);
    }
    int to_y(){// x have gap, mean y move
        return max3(m+g,x+g,y+e);
    }
    int result(){
        return max3(m,x,y);
    }
    static int equal(bool equ){
        return equ?hit:mis;
    }
private:
    
};

int afg_unit::e=-1;
int afg_unit::g=-2;
int afg_unit::mis=-1;
int afg_unit::hit=1;