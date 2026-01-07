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
// 定义尺寸
//PCB长
length=86;
//pcb宽
width=50;
//pcb高(整体部件从底部倒顶部最大高度），用于设定盒子尺寸
height=12;

//下部盒子高度
baseheight=10;
//盒子壁厚
wallx=2;
wally=2;
wallz=1;
//pcb和盒子壁之间的间隙
gapx=1;
gapy=1;
gapz=0.2;
//圆角尺寸
roundsize=5;
//底面和顶面倒脚尺寸
chamfersize=0.8;
//上下盒子交叉部分尺寸
intel_height_size=2;

//屏幕及pcb
//屏幕嵌入的尺寸
screen_length_out=72;  
screen_wildth_out=52.2;
//有效显示尺寸
screen_length_in=60;   
screen_wildth_in=46;
//有效显示的调整
screen_adj_x=-2.9;  //屏幕左侧遮蔽到中心的距离，减去(screen_length_in/2)为x汁,原因是部分cyd板子，屏幕有错位
//遮挡屏幕部分的厚度
screen_mask_thickness=0.6;  //屏幕遮蔽部分厚度
screen_height=3.8;   //屏幕厚度（测量pcb和屏幕整体厚度然后减去pcb_thickness)
pcb_thickness=1.2; //pcb板子厚度

isdrawbase=true;//是否画底部盒子
isdrawtop=true;//是否画顶部盒子
//是否将顶盖打开在旁边绘制
isdrawtopside=true;
//上盖打开后距离底盒
shift=20;
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
ledheight=4.2;
typec_l=5.6;
typec_r=1.6;
typec_p_y=-1;  //typec在y方向的坐标
support_pin_length=78;
support_pin_wildth=42;
support_pin_d1=5.6;
support_pin_d2=2.4;  //要能穿过pcb上的定位孔
support_pin_d3=3.2;  //上盖内孔

snip_depth=0.4;
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
H  = baseheight+wallz+gapz;  //frome base chamfer to basebox top
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
            translate([9,0,0]) square([8,3]);}
}

//画盒子同时做Z轴rouding和底面chamfer
module drawbox(L,W,H,R,BR){
    roundrect2d=rect([L,W],rounding=R);
    offset_sweep(roundrect2d, h=H, bottom=os_chamfer(BR),anchor=BOT);
}

module teardrop_round_rect(L,W,R,d_tube){
    path=rect([L, W], rounding=R);
    vnf=teardrop2d(r=d_tube,bot_corner=0.4);
    path_sweep(vnf, path, closed=true);
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
    color("gray")
    difference(){
        union(){
            drawbox(L,W,wallz,R,BR);  //上盖底层带倒脚
            up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP) //gap
            grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) tube(h=H3,od=support_pin_d1,id=support_pin_d3,ichamfer2=0.4,ochamfer1=-1.6,anchor=BOT);   //四个支撑柱
            if (isdrawled) move([led_p_x,led_p_y,0]) cuboid([led_l+1.2,led_w+1.2,ledheight],chamfer=-1.6,edges=BOT,anchor=BOT);  //LED屏蔽外壳
            union(){
            up(wallz+gapz) rect_tube(h=intel_height_size, size=[L,W],isize=[L1,W1],rounding=R,irounding=R,$fn=32,anchor=BOT);
            up(wallz+gapz+intel_height_size-snip_depth/2) teardrop_round_rect(L1+snip_depth/2,W1+snip_depth/2,R,snip_depth);
            }
                }
        if (isdrawled){ move([led_p_x,led_p_y,0.4]) cuboid([led_l,led_w,ledheight+wallz+gapz],anchor=BOT);}  //LED屏蔽外壳挖坑
        move([25,0,0]) grid_copies([3,3], n=[5,5]) cube(2);  //散热孔
        microtypec();
        button2d();
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
            grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) cyl(h=screen_height+gapz-screen_mask_thickness,d=support_pin_d1,chamfer1=-1.6,anchor=BOT) position(TOP) cyl(h=pcb_thickness+2,d=support_pin_d2,chamfer2=0.4,anchor=BOT);  //支撑柱及定位孔
            if (isdrawldr){ move([ldr_p_x,ldr_p_y,0]) cuboid([ldr_l+1.2,ldr_w+1.2,H1],chamfer=-1.6,edges=BOT,anchor=BOT);}  //LDR传感器屏蔽外壳    
        }; 
        up(screen_mask_thickness) cuboid([screen_length_out,screen_wildth_out,screen_height],anchor=BOT);  //预留screen_mask_thickness厚度的屏幕遮罩,挖出屏幕嵌入空间
        move([screen_adj_x,0,-eps]) cuboid([screen_length_in,screen_wildth_in,screen_mask_thickness+2*eps],anchor=BOT);  //挖出屏幕外漏用于显示的部分
        if (isdrawldr){ move([ldr_p_x,ldr_p_y,-eps]) cuboid([ldr_l,ldr_w,H1+2*eps],chamfer=-chamfersize,anchor=BOT);} //LDR挖孔    
    }
    difference(){
        rect_tube(h=H, size=[L,W], isize=[L2,W2],rounding=R, irounding=R,$fn=32);    //圆角矩形管状物
        up(H-intel_height_size) rect_tube(h=intel_height_size, size=[L,W],isize=[L1,W1],rounding=R,irounding=R,$fn=32,anchor=BOT); //圆角矩形圈切出交叉区
        up(H-intel_height_size) rect_tube(h=intel_height_size, size1=[L,W],size2=[L1+1,W1+1],rounding=R,irounding=R,wall=1,$fn=32,anchor=BOT); //交叉区铲出斜坡
        up(H-intel_height_size+snip_depth/2) teardrop_round_rect(L1+snip_depth/2,W1+snip_depth/2,R,snip_depth); //在交叉带上挖槽用于上盒嵌入
        microtypec();
    }
}

//上盖
if (isdrawtop) {
    if (isdrawtopside) back(shift+W) top_case();
    else up(2*wallz+2*gapz+baseheight+yshift) yrot(180)  top_case();
}
}
