include <BOSL2/std.scad>

$fs=$preview?1:0.4; 
$fa=$preview?15:5;
$fn=$preview?32:64;

is_left_half=false;
is_right_half=false;
is_front_half=false;
is_back_half=false;
is_top_half=false;
is_bottom_half=false;

// 定义尺寸PCB长宽高
length=86;
width=50;
height=10;
//pcb和盒子壁之间的间隙
gapx=1;
gapy=1;
gapz=0.2;
//盒子壁厚
wallx=2;
wally=2;
wallz=1;
//圆角尺寸
roundsize=5;
//底面和顶面倒脚尺寸
chamfersize=0.8;

//屏幕及pcb
//屏幕嵌入的尺寸
screen_length_out=72;  
screen_wildth_out=52.2;
//有效显示尺寸
screen_length_in=60;   
screen_wildth_in=46;
//有效显示的调整
screen_adj_x=9;  //屏幕左侧到板子边缘的距离
//遮挡屏幕部分的厚度
screen_mask_thickness=0.6;  //屏幕遮蔽部分厚度
screen_height=4.2;   //屏幕厚度（测量pcb和屏幕整体厚度然后减去pcb_thickness)
pcb_thickness=1.5; //pcb板子厚度

isdrawbase=true;//是否画底部盒子
isdrawtop=true;//是否画顶部盒子
isdrawtopside=true; //是否将顶盖打开在旁边绘制

shift=20;//上盖打开后距离底盒

isdrawldr=true;
ldr_l=4;
ldr_w=5.6;
ldr_p_x=-39.4;
ldr_p_y=14.2;
isdrawled=true;
led_l=6;
led_w=6;
led_p_x=13.4;
led_p_y=12.8;
typec_l=5.6;
typec_r=1.6;
typec_p_y=-1;  //typec在y方向的坐标
support_pin_length=78;
support_pin_wildth=42;
support_pin_d1=5.6;
support_pin_d2=2.8;  //要能穿过pcb上的定位孔
support_pin_d3=3.2;  //上盖内孔

isdrawspk=true;
isdrawmicrousb=true;
isdrawuart=true;
isdrawsdcard=true;
isdrawtemphum=true;
isdrawextio=true;

eps=0.001;

yshift=10;

//pcb长+X方向两个墙壁+X方形两个间隙
L  = length + 2*gapx + 2*wallx;   //最大长度
L1 = length + 2*wallx + wallx/5;  //上下壳交错部分
L2 = length + 2*gapx;             //内部最大尺寸

W  = width + 2*gapy + 2*wally; 
W1 = width + 2*wally + wally/5; 
W2 = width + 2*gapy; 

snip_height=2.6;

H  = height +2*gapz + 2*wallz;                                      //整体最大高度，上下壳子相加
H1 = screen_mask_thickness+screen_height+pcb_thickness+gapz;        //下壳的总高度
H11= H1-wallz-gapz-snip_height;                                     //下壳管状拉升高度

H_pcb_lo=screen_mask_thickness+screen_height;
H_pcb_hi=screen_mask_thickness+screen_height+pcb_thickness;
H2 = H-H1-snip_height;                                                          //上壳总高度
H21= H2-wallz-gapz;                                     //上壳管状拉升高度

echo(L=L,L1=L1,L2=L2);
echo(W=W,W1=W1,W2=W2);
echo(H=H,H1=H1,H11=H11,H2=H2,H21=H21,H_pcb_lo=H_pcb_lo,H_pcb_hi=H_pcb_hi);

R=roundsize;
BR=chamfersize;

//画盒子同时做Z轴rouding和底面chamfer
module drawbox(L,W,H,R,BR){
    roundrect2d=rect([L,W],rounding=R);
    offset_sweep(roundrect2d, h=H, bottom=os_chamfer(BR),anchor=BOT);
}

module mirror_copy(v = [0, 1, 0]) {
    children();
    mirror(v) children();
}

module microtypec(typec_l=5.6,typec_r=1.6,typec_p_y=-1){
    hole_depth=wally+gapy;
    X=L1/2;Y=typec_p_y;Z=H_pcb_hi;
    move([X,Y,Z]) rotate([90,0,90]) linear_extrude(height=hole_depth, center=true) {
        translate ([0,typec_r,0]) hull() {circle(r=typec_r); translate([typec_l, 0, 0]) circle(r=typec_r);}
        if (isdrawmicrousb) {translate([9,0,0]) square([8,3]);} //microusb
        if (isdrawuart) {translate([-12,0,0]) square([8,4]);}   //uart
        }
}

//画盒子同时做Z轴rouding和底面chamfer
module drawbox(L,W,H,R,BR){
    roundrect2d=rect([L,W],rounding=R);
    offset_sweep(roundrect2d, h=H, bottom=os_chamfer(BR),anchor=BOT);
}

module button2d(){
    move([31.6,-19,(wallz+gapz)/2])
    linear_extrude(wallz+gapz+3,center=true)
    union(){
        rect([0.8,9.2])
        left(4.2) rect([0.8,9.2]);
        right(4.2) rect([0.8,9.2]);
        fwd(4.2) zrot(90) rect([0.8,9.2]);
    }
}

module top_case(){
difference(){
    union(){
        drawbox(L,W,wallz,R,BR);  //上盖底层带倒脚
        up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP) 
        union(){
            grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) tube(h=H_pcb_lo-wallz-gapz,od=support_pin_d1,id=support_pin_d3,ichamfer2=0.4,ochamfer1=-1.6,anchor=BOT);   //四个支撑柱
            if (isdrawled) move([led_p_x,led_p_y,0]) cuboid([led_l+1.2,led_w+1.2,H-H1],chamfer=-1.6,edges=BOT,anchor=BOT);  //LED屏蔽外壳
            move([29.6,-20,0])cuboid([3.4,6,H-11]); //boot
            move([33.6,-20,0])cuboid([3.4,6,H-11]); //reset
        }
        up(wallz+gapz) rect_tube(h=H21, size=[L,W],isize=[L2,W2],rounding=R,irounding=R-wallx,$fn=32,anchor=BOT) position(TOP) 
            union(){ 
                rect_tube(h=snip_height, size=[L,W],isize=[L1,W1],rounding=R,irounding=R-wallx/2,$fn=32,anchor=BOT) position(BOT) 
                mirror_copy() xcopies([-30,-15,0,15,30])  move([0,-W1/2,snip_height]) cuboid([5,0.8,2],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+TOP);   //卡扣X方向
                mirror_copy([1,0,0]) ycopies([-15,0,15]) move([L1/2,0,snip_height])  cuboid([0.8,5,2],chamfer=0.8,edges=[LEFT+TOP,LEFT+BOT],anchor=RIGHT+TOP);  //卡扣Y方向
            }
        } 
    #if (isdrawled) {move([led_p_x,led_p_y,0.4]) cuboid([led_l,led_w,H1],anchor=BOT);}  //LED屏蔽外壳挖坑
    if (isdrawspk) {move([-15.6,-22.5]) cuboid([8,4.5,wallz+gapz],anchor=BOT);}  //speaker
    move([25,0,0]) grid_copies([3,3], n=[5,5]) cube(2);  //散热孔
    button2d();
    up(H+wallz+gapz)yrot(180) microtypec();
    if (isdrawsdcard) {up(H+wallz+gapz) yrot(180) move([4.8,W2/2-eps,H2])cuboid([15.6,3+2*eps,3.2],anchor=FWD+BOT); } //sdcard
    if (isdrawtemphum) { up(H+wallz+gapz) yrot(180) move([-12,W2/2-eps,H2])cuboid([8,3+2*eps,4],anchor=FWD+BOT);  } //temp_hum_interface
    if (isdrawextio) {up(H+wallz+gapz) yrot(180) move([-28,W2/2-eps,H2])cuboid([8,3+2*eps,4],anchor=FWD+BOT);  } //Ext IO
    }
}

module base_case(){
    difference(){
        union(){
            drawbox(L,W,wallz,R,BR);  //basewall
            up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP) 
            grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) cyl(h=H_pcb_lo-wallz-gapz,d=support_pin_d1,chamfer1=-1.6,anchor=BOT) position(TOP) 
            cyl(h=pcb_thickness+3,d=support_pin_d2,chamfer1=-0.4,chamfer2=0.4,anchor=BOT);  //支撑柱及定位孔
            if (isdrawldr){ move([ldr_p_x,ldr_p_y,0]) cuboid([ldr_l+1.2,ldr_w+1.2,H_pcb_lo],chamfer=-1.6,edges=BOT,anchor=BOT);}  //LDR传感器屏蔽外壳    
            up(wallz+gapz) union(){
                rect_tube(h=H11, size=[L,W],isize=[L2,W2],rounding=R,irounding=R-wallx,$fn=32,anchor=BOT) position(TOP) 
                difference(){
                    rect_tube(h=snip_height, size=[L1,W1],isize=[L2,W2],rounding=R,irounding=R-wallx/2,$fn=32,anchor=BOT);
                    mirror_copy() xcopies([-30,-15,0,15,30])  move([0,-W1/2,0])cuboid([5,0.8,2],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+BOT);  //卡扣Y方向
                    mirror_copy([1,0,0]) ycopies([-15,0,15]) move([L1/2,0,0]) cuboid([0.8,5,2],chamfer=0.8,edges=[LEFT+TOP,LEFT+BOT],anchor=RIGHT+BOT);    //卡扣X方向
                }
            }
        }
         up(screen_mask_thickness) cuboid([screen_length_out,screen_wildth_out,screen_height],anchor=BOT);  //预留screen_mask_thickness厚度的屏幕遮罩,挖出屏幕嵌入空间
         move([-2.9-(8.4-screen_adj_x),0,-eps]) cuboid([screen_length_in,screen_wildth_in,screen_mask_thickness+2*eps],anchor=BOT);  //挖出屏幕外漏用于显示的部分
         if (isdrawldr){ move([ldr_p_x,ldr_p_y,-eps]) cuboid([ldr_l,ldr_w,H1+2*eps],chamfer=-chamfersize,anchor=BOT);} //LDR挖孔 
        microtypec();
        if (isdrawsdcard) {move([4.8,W2/2-eps,H2])cuboid([15.6,2+2*eps,3.2],anchor=FWD+BOT); } //sdcard
        if (isdrawtemphum) {move([-12,W2/2-eps,H2])cuboid([8,2+2*eps,4],anchor=FWD+BOT);  } //temp_hum_interface
        if (isdrawextio) {move([-28,W2/2-eps,H2])cuboid([8,2+2*eps,4],anchor=FWD+BOT);  } //Ext IO
    }
}

module conditional_half(cond, plane, children) {
    if (cond && $preview) { // 只有在预览模式且开关打开时才切开
        half_of(plane) children();
    } else {children();}
}
conditional_half(is_left_half  , LEFT)
conditional_half(is_right_half , RIGHT)
conditional_half(is_front_half , FWD)
conditional_half(is_back_half  , BACK)
conditional_half(is_top_half   , UP)
conditional_half(is_bottom_half, DOWN)

union(){
//上盖
if (isdrawtop) {
    if (isdrawtopside) back(shift+W) top_case();
    else up(H+yshift) yrot(180)  top_case();
}

//下盖
if (isdrawbase) { base_case(); }

}
