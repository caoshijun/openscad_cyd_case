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
height=12;
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
//上下盒子交叉部分尺寸
intel_height_size=3;

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
L  = length+2*wallx+2*gapx; 
L1 = length+2*wallx; 
L2 = length+wallx; 
L3 = length+gapx; 
W  = width+2*wally+2*gapy;
W1 = width+2*wally;
W2 = width+wally;
W3 = width+gapy;
H  = height+wallz+gapz;  //frome base chamfer to basebox top
H1 = screen_mask_thickness+screen_height; //from base chamfer to bottom of pcb
H2 = screen_mask_thickness+screen_height+pcb_thickness;   //from base chamfer to pcbboard top
H3 = H-H2;

echo(L=L,L1=L1,L2=L2,L3=L3);
echo(W=W,W1=W1,W2=W2,W3=W3);
echo(H=H,H1=H1,H2=H2,H3=H3);

R=roundsize;
BR=chamfersize;

module microtypec(typec_l=5.6,typec_r=1.6,typec_p_y=-1){
    hole_depth=wally+gapy;
    X=L1/2;Y=typec_p_y;Z=H2;
    move([X,Y,Z]) rotate([90,0,90]) linear_extrude(height=hole_depth, center=true) {
        translate ([0,typec_r,0]) hull() {circle(r=typec_r); translate([typec_l, 0, 0]) circle(r=typec_r);}
        if (isdrawmicrousb) {translate([9,0,0]) square([8,3]);}
        if (isdrawuart) {translate([-12,0,0]) square([8,4]);}
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
module mirror_copy(v = [0, 1, 0]) {
    children();
    mirror(v) children();
}

module mirror_copyx(v = [1, 0, 0]) {
    children();
    mirror(v) children();
}

module top_case(){
    color("gray")
    difference(){
        union(){
            drawbox(L,W,wallz,R,BR);  //上盖底层带倒脚
            up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP) //gap
            grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) tube(h=H3,od=support_pin_d1,id=support_pin_d3,ichamfer2=0.4,ochamfer1=-1.6,anchor=BOT);   //四个支撑柱
            if (isdrawled) move([led_p_x,led_p_y,0]) cuboid([led_l+1.2,led_w+1.2,H3],chamfer=-1.6,edges=BOT,anchor=BOT);  //LED屏蔽外壳
//            union(){
            up(wallz+gapz) rect_tube(h=intel_height_size, size=[L,W],isize=[L1,W1],rounding=R,irounding=R-wallx/2,$fn=32,anchor=BOT);
            mirror_copy() xcopies([-30,-15,0,15,30])  move([0,-W1/2,wallz+gapz+1])cuboid([5,0.8,2],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+BOT);   //卡扣X方向
            mirror_copyx() ycopies([-15,0,15])        move([L1/2,0,wallz+gapz+1]) cuboid([0.8,5,2],chamfer=0.8,edges=[LEFT+TOP,LEFT+BOT],anchor=RIGHT+BOT);  //卡扣Y方向
            
            up(wallz+gapz)move([29.6,-20,0])cuboid([3.4,6,H-10]); //boot
            up(wallz+gapz)move([33.6,-20,0])cuboid([3.4,6,H-10]); //reset
//            }
        }
        if (isdrawled) {move([led_p_x,led_p_y,0.4]) cuboid([led_l,led_w,H3],anchor=BOT);}  //LED屏蔽外壳挖坑
        if (isdrawspk) {move([-15.6,-22.5]) cuboid([8,4.5,H3],anchor=BOT);}  //speaker
        move([25,0,0]) grid_copies([3,3], n=[5,5]) cube(2);  //散热孔
        button2d();

        up(H+wallz+gapz)yrot(180) microtypec();
        if (isdrawsdcard) {up(H+wallz+gapz) yrot(180) move([4.8,W2/2-eps,H2])cuboid([15.6,3+2*eps,3.2],anchor=FWD+BOT); } //sdcard
        if (isdrawtemphum) { up(H+wallz+gapz) yrot(180) move([-12,W2/2-eps,H2])cuboid([8,3+2*eps,4],anchor=FWD+BOT);  } //temp_hum_interface
        if (isdrawextio) {up(H+wallz+gapz) yrot(180) move([-28,W2/2-eps,H2])cuboid([8,3+2*eps,4],anchor=FWD+BOT);  } //Ext IO
        
        }
}

module conditional_half(cond, plane, children) {
    if (cond && $preview) { // 只有在预览模式且开关打开时才切开
        half_of(plane) children();
    } else {
        children();
    }
}

conditional_half(is_left_half  , LEFT)
conditional_half(is_right_half , RIGHT)
conditional_half(is_front_half , FWD)
conditional_half(is_back_half  , BACK)
conditional_half(is_top_half   , UP)
conditional_half(is_bottom_half, DOWN)

union(){
//盒子底座底座由wallz+gapz高度构建一个台面,在之上放置四个定位孔，然后是LDR
if (isdrawbase) { 
    difference(){
        union(){
            drawbox(L,W,wallz,R,BR);  //basewall
            up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP) //gap
            grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) cyl(h=H1-gapz-wallz,d=support_pin_d1,chamfer1=-1.6,anchor=BOT) position(TOP) 
             cyl(h=pcb_thickness+intel_height_size,d=support_pin_d2,chamfer1=-0.4,chamfer2=0.4,anchor=BOT);  //支撑柱及定位孔
            if (isdrawldr){ move([ldr_p_x,ldr_p_y,0]) cuboid([ldr_l+1.2,ldr_w+1.2,H1],chamfer=-1.6,edges=BOT,anchor=BOT);}  //LDR传感器屏蔽外壳    
        }; 
        up(screen_mask_thickness) cuboid([screen_length_out,screen_wildth_out,screen_height],anchor=BOT);  //预留screen_mask_thickness厚度的屏幕遮罩,挖出屏幕嵌入空间
        move([-2.9-(8.4-screen_adj_x),0,-eps]) cuboid([screen_length_in,screen_wildth_in,screen_mask_thickness+2*eps],anchor=BOT);  //挖出屏幕外漏用于显示的部分
        if (isdrawldr){ move([ldr_p_x,ldr_p_y,-eps]) cuboid([ldr_l,ldr_w,H1+2*eps],chamfer=-chamfersize,anchor=BOT);} //LDR挖孔    
    }
    up(wallz+gapz) difference(){
        rect_tube(h=H-wallz-gapz, size=[L,W], isize=[L2,W2],rounding=R, irounding=R-wallx,$fn=32);    //圆角矩形管状物
        up(H-wallz-gapz-intel_height_size) rect_tube(h=intel_height_size, size=[L,W],isize=[L1,W1],rounding=R,irounding=R-wallx/2,$fn=32,anchor=BOT); //圆角矩形圈切出交叉区
        mirror_copy() xcopies([-30,-15,0,15,30])  move([0,-W1/2,H-wallz-gapz-intel_height_size])cuboid([5,0.8,2],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+BOT);  //卡扣Y方向
        mirror_copyx() ycopies([-15,0,15]) move([L1/2,0,H-wallz-gapz-intel_height_size]) cuboid([0.8,5,2],chamfer=0.8,edges=[LEFT+TOP,LEFT+BOT],anchor=RIGHT+BOT);    //卡扣X方向
        down(wallz+gapz) microtypec();
        if (isdrawsdcard) {move([4.8,W2/2-eps,H2-wallz-gapz])cuboid([15.6,2+2*eps,3.2],anchor=FWD+BOT); } //sdcard
        if (isdrawtemphum) {move([-12,W2/2-eps,H2-wallz-gapz])cuboid([8,2+2*eps,4],anchor=FWD+BOT);  } //temp_hum_interface
        if (isdrawextio) {move([-28,W2/2-eps,H2-wallz-gapz])cuboid([8,2+2*eps,4],anchor=FWD+BOT);  } //Ext IO

    }
}

//上盖
if (isdrawtop) {
    if (isdrawtopside) back(shift+W) top_case();
    else up(2*wallz+2*gapz+height+yshift) yrot(180)  top_case();
}
}
