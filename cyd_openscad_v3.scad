include <BOSL2/std.scad>

$fs=$preview ? 1 : 0.1; 
$fa=$preview ? 15 : 5; 

// 定义尺寸
//PCB长
length=86;
//pcb宽
width=50;
//pcb高(整体部件从底部倒顶部最大高度），用于设定盒子尺寸
height=11;

//下部盒子高度
baseheight=12;
//pcb和盒子壁之间的间隙
gapx=1;
gapy=1;
gapz=1;
//盒子壁厚
wallx=2;
wally=2;
wallz=1;
//圆角尺寸
roundsize=5;
//前后面倒脚尺寸
chamfersize=1;
//上下盒子交叉部分尺寸
intel_height_size=3;

//屏幕及pcb
screen_length_out=72;
screen_wildth_out=52.2;
screen_length_in=60;
screen_wildth_in=46;
screen_adj_x=-2.9;  //屏幕左侧遮蔽到中心的距离，减去(screen_length_in/2)为x汁,原因是部分cyd板子，屏幕有错位
screen_mask_thickness=0.6;  //屏幕遮蔽部分厚度
screen_height=4;   //屏幕厚度（测量pcb和屏幕整体厚度然后减去pcb_thickness)
pcb_thickness=1.6;

shift=20;

isdrawbase=true;//是否画底部盒子
isdrawtop=true;//是否画顶部盒子
isdrawldr=true;
isdrawled=true;
ldr_l=4;
ldr_w=5.5;
ldr_p_x=-39.4;
ldr_p_y=14.2;
led_l=5;
led_w=5;
led_p_x=-13.4;
led_p_y=-12.8;

support_pin_length=78;
support_pin_wildth=42;
support_pin_d1=5.5;
support_pin_d2=2.6;  //要能穿过pcb上的定位孔
support_pin_d3=3.2;  //上盖内孔

snip_depth=0.8;

eps=0.001;

//画盒子同时做Z轴rouding和底面chamfer
module drawbox(L,W,H,R,BR){
    roundrect2d=rect([L,W],rounding=R);
    offset_sweep(roundrect2d, h=H, bottom=os_chamfer(BR),anchor=BOT);

}

//pcb长+X方向两个墙壁+X方形两个间隙
L=length+2*wallx+2*gapx; 
W=width+2*wally+2*gapy;
H=baseheight+wallz+gapz;
R=roundsize;
BR=chamfersize;

//底座由wallz+gapz高度构建一个台面
//在台面上的四个支撑柱高度由屏幕高度决定,支撑柱上的定位柱高度超过pcbthickness
//
//if (isdrawbase) { 
//    difference(){
//        union(){
//            drawbox(L,W,wallz,R,BR);  //basewall
//            up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP) //gap
//            grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) cylinder(h=screen_height-gapz-screen_mask_thickness,d=support_pin_d1,anchor=BOT) position(TOP) cylinder(h=pcb_thickness+2,d=support_pin_d2,anchor=BOT);  //支撑柱及定位孔
//            if (isdrawldr){ move([ldr_p_x,ldr_p_y,wallz+gapz]) cuboid([ldr_l+1,ldr_w+1,screen_height-gapz-screen_mask_thickness],anchor=BOT);}  //LDR传感器屏蔽外壳    
//        }; 
//            up(screen_mask_thickness) cuboid([screen_length_out,screen_wildth_out,screen_height],anchor=BOT);  //预留screen_mask_thickness厚度的屏幕遮罩,挖出屏幕嵌入空间
//            move([screen_adj_x,0,-eps]) cuboid([screen_length_in,screen_wildth_in,screen_mask_thickness+2*eps],anchor=BOT);  //挖出屏幕外漏用于显示的部分
//        if (isdrawldr){ move([ldr_p_x,ldr_p_y,-eps]) cuboid([ldr_l,ldr_w,wallz+gapz+screen_height-screen_mask_thickness+2*eps],anchor=BOT);} //LDR挖孔    
//    }
////底座
//    up(wallz+gapz) union(){
//        difference(){
//            cuboid([L,W,H],rounding=R,edges="Z",anchor=BOT);  //画外立面
//            up(H-intel_height_size) cuboid([L-wallx-gapx/2,W-wally-gapy/2,intel_height_size+eps],rounding=R,edges="Z",anchor=BOT);  //切出上下盒子交叉部分
//            up(H-intel_height_size+snip_depth) 
//                minkowski(){
//                    cuboid([L-wallx-gapx/2,W-wally-gapy/2,eps],rounding=R,edges="Z",anchor=BOT);
//                    sphere(snip_depth);} 
//        	down(eps) cuboid([L-2*wallx,W-2*wally,H+2*eps],rounding=R,edges="Z",anchor=BOT);  // 切出下部盒子内空
//		}
//	}
//}

//上盖
if (isdrawtop) {
    back(shift+W)
//    union(){
//        drawbox(L,W,wallz,R,BR);  //上盖底层带倒脚
//        //up(wallz)  minkowski(){ cuboid([L-wallx-gapx/2,W-wally-gapy/2,eps],rounding=R,edges="Z",anchor=BOT); sphere(.8);} 
//        up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP) //gap
//        grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) 
//        difference(){
//            cylinder(h=screen_height-gapz-screen_mask_thickness,d=support_pin_d1,anchor=BOT);
//            cylinder(h=pcb_thickness+2,d=support_pin_d3,anchor=BOT);  //支撑柱及定位孔
//        }
//        if (isdrawled){ move([led_p_x,led_p_y,wallz+gapz]) cuboid([led_l+1,led_w+1,screen_height-gapz-screen_mask_thickness],anchor=BOT);}  //LED屏蔽外壳
union(){   
		up(wallz+gapz-eps)
		difference(){
       		cuboid([L-wallx-gapx/2,W-wally-gapy/2,intel_height_size],rounding=R,edges="Z",anchor=BOT);  //切出上盒交叉部分
      		cuboid([L-2*wallx-gapx,  W-2*wally-gapy,  intel_height_size+2*eps],rounding=R,edges="Z",anchor=BOT);  //切出上盒交叉部分
		}
        up(wallz+gapz+intel_height_size-snip_depth) 
        minkowski(){
	        difference(){
		        cuboid([L-wallx-gapx/2,W-wally-gapy/2,eps],rounding=R,edges="Z",anchor=BOT);
       	        cuboid([L-2*wallx-gapx,W-2*wally-gapy,eps],rounding=R,edges="Z",anchor=BOT);  //切出上盒交叉部分
		    }
            sphere(snip_depth);
		} 
}
}

