include <BOSL2/std.scad>

$fs=$preview ? 1 : 0.1;  // Don't generate smaller facets than 0.1 mm
$fa=$preview ? 15 : 5;    // Don't generate larger angles than 5 degrees

// 定义尺寸
//PCB长
length=86;
//pcb宽
width=50;
//pcb高
height=10;

//下部盒子高度
baseheight=8;
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
//倒脚尺寸
chamfersize=1;
//上下盒子交叉部分尺寸
intel_height_size=3;

//屏幕及pcb
screen_length_out=69.4;
screen_wildth_out=50;
screen_length_in=59.45;
screen_wildth_in=45.2;
screen_height=4;
screen_ajt=0;
pcb_thickness=1.6;



shift=20;

//是否画底部盒子
isdrawbase=true;
//是否画顶部盒子
isdrawtop=true;

//画盒子同时做Z皱rouding和底面chamfer
module drawbox(L,W,H,R,BR){
    roundrect2d=rect([L,W],rounding=R);
    offset_sweep(roundrect2d, h=H, bottom=os_chamfer(BR),anchor=BOT);

}


//module outline(wall = 1) {
//  difference() {
//    offset(wall / 2) children();
//    offset(-wall / 2) children();
//  }
//}
//
//
//
//translate([0, 0, 0]) {
//  linear_extrude(height = 20) {
//    outline(wall = 2) rect([L,W],rounding=R);
//  }
//}

//pcb长+X方向两个墙壁+X方形两个间隙
L=length+2*wallx+2*gapx; 
W=width+2*wally+2*gapy;
H=baseheight+wallz+gapz;

//translate([L/2,W/2,H/2]){
if (isdrawbase) { 

    R=roundsize;
    BR=chamfersize;
    difference(){
        echo (L=L,W=W,H=H,R=R,BR=BR);
        echo (up=wallz,L=L-2*wallx,W=W-2*wally,H=H-wallz,rounding=R);
        echo (up=(H-intel_height_size)/2,L=L-wallx,W=W-wally,H=intel_height_size);
        //画出整体
        drawbox(L,W,H,R,BR);
        //掏出边缘交错部分
        up(baseheight+wallz+gapz-intel_height_size+0.001) cuboid([L-wallx,W-wally,intel_height_size],rounding=R,edges="Z",anchor=BOT);
        //掏出pcb+gap
        up(wallz+gapz) cuboid([L-2*wallx,W-2*wally,H],rounding=R,edges="Z",anchor=BOT);
        //屏幕嵌入的尺寸
        up(0.4) cuboid([69.4,50.2,1],anchor=BOT);
        //屏幕外漏的尺寸
        cuboid([59.45,45.2,12],anchor=CENTER);
       
    } 
    grid_copies([78,42], n=[2,2]) up(1) 
       cylinder(h=3,d=5.5,anchor=BOT) position(TOP) cylinder(h=3,d=3,anchor=BOT);
}

if (isdrawtop) {
    H=height-baseheight+wallz+gapz;
    R=roundsize;
    BR=1;
    back(shift+W)
    union(){
        echo (L=L,W=W,H=H,R=R,BR=BR);
        echo (up=(H-intel_height_size)/2+0.001,L=L-wallx,W=W-wally,H=H);
        drawbox(L,W,H,R,BR); 
        up((H-intel_height_size)/2+0.001)
        #cuboid([L-wallx,W-wally,2],rounding=R,edges="Z",anchor=CENTER);
    }
}
