include <BOSL2/std.scad>

$fs=$preview?1:0.4; 
$fa=$preview?15:5;
$fn=$preview?16:64;

/* [主要参数] */
//主板类型选择GUITION，HW458，或其他
esp32boardname="GUITION"; // [GUITION,HW458,other]
//是否打印底部盒子
isdrawbase=true;
//是否打印顶部盒子
isdrawtop=true;    
//是否将顶盖打开在旁边绘制
isdrawtopside=true;         
//是否打印speaker接口
isdrawspk=true;  
//是否打印MicroUSB接口
isdrawmicrousb=true;
//是否打印uart接口
isdrawuart=true; 
//是否打印MicroSD Card
isdrawsdcard=true; 
//是否打印温湿度传感器接口
isdrawtemphum=true;
//是否打印扩展IO接口
isdrawextio=true;   
//是否打印触摸笔隐藏孔
isdrawpenhole=true;
//是否为光线传感器开孔
isdrawldr=true;
//是否为ws2812 LED绘制遮蔽罩
isdrawled=true;
//是否打印logo
isdrawlogo=true;
//logo是否分体打印
islogo_isolate=true;
//是否打印logo支撑
isdrawlogosupport=true;
//logo font size
fontsize=6; //[4:1:10]
ft_adj_x=2.2; //[-10:0.1:10]
//仅当isdrawlogo为true时输入的字符才有效。
logotext="";
logo_text= (logotext!="") ? logotext : esp32boardname; // 如果 A 是 undef，B 就等于 42
//显示屏厚度（测量pcb和屏幕整体厚度然后减去pcb厚度)
set_screen_height=3.8;//[3:0.1:5]   
screen_height=(esp32boardname=="GUITION") ? 4   :
              (esp32boardname=="HW458")   ? 3.6 :
              set_screen_height;  //默认值
echo(screen_height=screen_height);
//pcb板厚度
set_pcb_thickness=1.0;//[0.8:0.1:3]
pcb_thickness=(esp32boardname=="GUITION") ? 1.6   :
              (esp32boardname=="HW458")   ? 1.2 :
              set_pcb_thickness;  //默认值 
echo(pcb_thickness=pcb_thickness);        
//屏幕左侧到板子边缘的距离，用于显示屏幕外漏部分的调整，默认8.6，测量LDR附件区域显示屏至板卡边缘的距离。
//显示屏左右距离调整
screen_adj_x=8.6;           //[6:0.1:10]
//遮蔽显示屏部分厚度
screen_mask_thickness=0.8;  //[0.2:0.1:1]

/* [其它参数] */
// 定义尺寸PCB长宽高
length=86;
width=50;
height=10;

//pcb和盒子壁之间的间隙
gapx=0.2;
gapy=0.8;
gapz=0.2;

//盒子壁厚
wallx=2.4;
wally=2.4;
wallz=1.2;
roundsize=5;                //圆角尺寸
chamfersize=0.8;            //外观底面和顶面倒脚尺寸

//屏幕嵌入的尺寸
screen_length_out=72;  
screen_wildth_out=51.6;
//有效显示尺寸
screen_length_in=60;   
screen_wildth_in=46;
//上盖打开后距离底盒距离
shift=20;                   
//装配视图距离
yshift=10;                  
//卡扣部分的高度
snip_height=2.4;            

/* [Hidden] */
ldr_l=4;
ldr_w=5.6;
ldr_p_x=-39.4;
ldr_p_y=14.2;
led_l=6;
led_w=6;
led_p_x=13.4;
led_p_y=12.8;
typec_l=5.6;
typec_r=1.6;
typec_p_y=-0.8;             //typec在y方向的坐标

support_pin_length=78;
support_pin_wildth=42;
support_pin_d1=5.6;
support_pin_d2=2.8;         //要能穿过pcb上的定位孔
support_pin_d3=3.2;         //上盖内孔

eps=0.001;

//pcb长+X方向两个墙壁+X方形两个间隙
L  = length + 2*gapx + 2*wallx;   //最大长度
L1 = length + 2*gapx + wallx;  //上下壳交错部分
L2 = length + 2*gapx;             //内部最大尺寸

W  = width + 2*gapy + 2*wally; 
W1 = width + 2*gapy + wally; 
W2 = width + 2*gapy; 

is_left_half=false;
is_right_half=false;
is_front_half=false;
is_back_half=false;
is_top_half=false;
is_bottom_half=false;

H_pcb_lo=screen_mask_thickness+screen_height;
H_pcb_hi=screen_mask_thickness+screen_height+pcb_thickness;

H  = height +2*gapz + 2*wallz;     //整体最大高度，上下壳子相加
H1 = H_pcb_hi + 2.8 + eps ;        //下壳的总高度
H11= H1-wallz-gapz-snip_height;    //下壳管状拉升高度


H2 = H-H1;                        //上壳总高度
H21= H2-wallz-gapz;               //上壳管状拉升高度

echo(L=L,L1=L1,L2=L2);
echo(W=W,W1=W1,W2=W2);
echo(H=H,H1=H1,H11=H11,H2=H2,H21=H21);

R=roundsize;
BR=chamfersize;
uart_p_y=(esp32boardname=="GUITION") ?  -11   : -9 ;
typc_p_y=(esp32boardname=="GUITION") ?  1.4   : 1.8 ;

module microtypec(typec_l=5.6,typec_r=1.8){
    hole_depth=wally+gapy;
    X=L2/2-eps;Y=typc_p_y;Z=H_pcb_hi;   
    move([X,Y,Z]) cuboid([hole_depth+2*eps, typec_l + 2*typec_r, 2*typec_r], rounding = typec_r, edges = "X",anchor = LEFT+BOT);        //typeC
    move([L/2+eps,Y,Z+typec_r])  cuboid([wally/2+2*eps,11, 6.2],rounding = 2, edges = "X",anchor = RIGHT);                    //typeC 扩展方便插入
    if (isdrawmicrousb) {
        move([X,12,Z]) cuboid([hole_depth+2*eps,8,3],anchor = LEFT+BOT);
        move([L/2+eps,12,Z+typec_r])  cuboid([wally/2+2*eps,11, 6.2],rounding = 2, edges = "X",anchor = RIGHT);                    //microUSB 扩展方便插入
        }                                                                                                                                        //microusb及扩展方便插入
    if (isdrawuart)     {move([X,uart_p_y,Z]) cuboid([hole_depth+2*eps,8,4],anchor = LEFT+BOT);}                                                       //uart
}

//touch pen
module touchpen(){   
    cuboid([12,8,5],anchor=LEFT+BOT) attach(RIGHT,LEFT,align=FWD) 
    xcyl(l=60,r=2.5) attach(RIGHT,LEFT) xcyl(h=15,r1=2.5,r2=1) ;
}

//画盒子同时做Z轴rouding和底面chamfer
module drawbox(L,W,H,R,BR){
    roundrect2d=rect([L,W],rounding=R);
    offset_sweep(roundrect2d, h=H, bottom=os_chamfer(BR),anchor=BOT);
}

module button2d(button_h){
    move([31.6,-19,button_h/2])
    linear_extrude(button_h+3,center=true)
    union(){
        rect([0.8,9.2])
        left(4.2) rect([0.8,9.2]);
        right(4.2) rect([0.8,9.2]);
        fwd(4.2) zrot(90) rect([0.8,9.2]);
    }
}

module button_text(){
    move([33.6,-17.6,0])zrot(180)mirror([1,0,0])text3d("R",font="Arial", h=0.2+eps,size=4,anchor=BOT);
    move([29.4,-17.6,0])zrot(180)mirror([1,0,0])text3d("B",font="Arial", h=0.2+eps,size=4,anchor=BOT); 
}

module logo_text(){
    color("red") move([32+ft_adj_x,0,0.2]) zrot(-90) mirror([1,0,0]) text3d(logo_text,direction="ltr",font="Arial:style=Bold", h=0.2+eps,size=fontsize,anchor=BOT);
    color("red") move([32+ft_adj_x,0,0.2]) zrot(-90) mirror([1,0,0]) text3d(logo_text,direction="ltr",font="Arial:style=Bold", h=0.2+eps,size=fontsize,anchor=TOP);

}

module mylogo(L=10,W=30,H=0.6,snip_l=3,snip_w=2,snip_h=0.2,fs=10,logo=false){
        cuboid([L,W,H],rounding=3,edges="Z",anchor=BOT);
        ycopies([-(W/2-snip_l),0,W/2-snip_l])translate([L/2,0,H-snip_h]) cuboid([snip_l,snip_w,snip_h],anchor=BOT);   
        mirror([1,0,0]) ycopies([-(W/2-snip_l),0,W/2-snip_l])translate([L/2,0,H-snip_h]) cuboid([snip_l,snip_w,snip_h],anchor=BOT);   
        translate([3,W/2,H-snip_h]) zrot(90) cuboid([snip_l,snip_w,snip_h],anchor=BOT);   
        mirror([0,1,0])translate([3,W/2,H-snip_h]) zrot(90) cuboid([snip_l,snip_w,snip_h],anchor=BOT);   
        if (logo) {recolor("red") move([-5+ft_adj_x,0,-0.1]) zrot(90) mirror([0,1,0]) text3d(logo_text,direction="ltr",font="Arial:style=Bold", h=snip_h,size=fs,anchor=BOT);}
}

module base_case(){
    //if (isdrawlogo) {mylogo();}
    recolor("gray") difference(){
        union(){
            drawbox(L,W,wallz,R,BR);  //basewall
            if (isdrawlogo && !islogo_isolate ) logo_text();    //logo text in front
            up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP)  
            union(){
                grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) cyl(h=H_pcb_lo-wallz-gapz,d=support_pin_d1,chamfer1=-1.6,anchor=BOT) position(TOP) 
                cyl(h=pcb_thickness+3,d=support_pin_d2, chamfer2=0.4,anchor=BOT);  //支撑柱及定位孔
                if (isdrawldr){ move([ldr_p_x,ldr_p_y,0]) cuboid([ldr_l+1.2,ldr_w+1.2,H_pcb_lo-wallz-gapz],chamfer=-1.6,edges=BOT,anchor=BOT);}  //LDR传感器屏蔽外壳 
                rect_tube(h=H11, size=[L-eps,W-eps],isize=[L2-eps,W2-eps],rounding=R,irounding=R-wallx,anchor=BOT)  position(TOP) 
                difference(){
                    down(0.1) rect_tube(h=snip_height+0.1, size1=[L1,W1],size2=[L1-0.8,W1-0.8],isize1=[L2,W2],isize2=[L2,W2],rounding1=R-wallx/2,rounding2=R-wallx/2-0.4,irounding=R-wallx,$fn=32,anchor=BOT);
                    mirror([0,1,0]) xcopies([-36,-20,20,35])    move([0,-W1/2,0.2])cuboid([5,0.8,1.8],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+BOT);  //卡扣Y方向
                                    xcopies([-30,-15,0,15,30])  move([0,-W1/2,0.2])cuboid([5,0.8,1.8],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+BOT);  //卡扣Y方向
                    ycopies([-20,20])                           move([L1/2,0,0.2]) cuboid([0.8,5,1.8],chamfer=0.8,edges=[LEFT+TOP,LEFT+BOT],anchor=RIGHT+BOT);    //卡扣X方向
                    mirror([1,0,0])ycopies([0,15,-20])          move([L1/2,0,0.2]) cuboid([0.8,5,1.8],chamfer=0.8,edges=[LEFT+TOP,LEFT+BOT],anchor=RIGHT+BOT);    //卡扣X方向
                }
            }
        }
        up(screen_mask_thickness) cuboid([screen_length_out,screen_wildth_out,screen_height],anchor=BOT);  //预留screen_mask_thickness厚度的屏幕遮罩,挖出屏幕嵌入空间
        move([-2.9-(8.4-screen_adj_x),0,-eps]) cuboid([screen_length_in,screen_wildth_in,screen_mask_thickness+2*eps],anchor=BOT);  //挖出屏幕外漏用于显示的部分
        if (isdrawldr){ move([ldr_p_x,ldr_p_y,-eps]) cuboid([ldr_l,ldr_w,H1+2*eps],chamfer=-chamfersize,anchor=BOT);} //LDR挖孔 
        microtypec();
        if (isdrawsdcard) {move([4.8,W2/2-eps,H_pcb_hi])cuboid([15.6,wally+2*eps,3.2],anchor=FWD+BOT); } //sdcard
        if (isdrawtemphum) {move([-12,W2/2-eps,H_pcb_hi])cuboid([8,wally+2*eps,4],anchor=FWD+BOT);  } //temp_hum_interface
        if (isdrawextio) {move([-28,W2/2-eps,H_pcb_hi])cuboid([8,wally+2*eps,4],anchor=FWD+BOT);  } //Ext IO
        if (isdrawpenhole) {move([-(L/2)-eps,-12,H_pcb_hi+0.6]) touchpen();}  //touch pen
        if (isdrawlogo && islogo_isolate ) {move([L2/2-7,0,-eps]) mylogo(12,35+eps,screen_height+screen_mask_thickness+0.4,3.2,2.4,screen_height+screen_mask_thickness+2*eps);} //else if (isdrawlogo) {logo_text();}  //logo pad
        }

}

module top_case(){
    //top_adj=wallz+gapz;
    top_adj=0.8;
    recolor("red") down(0.01) button_text();
    recolor("gray") difference(){
        union(){
             difference(){
                union(){
                    drawbox(L,W,wallz,R,BR);  //上盖底层带倒脚
                    up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT);// position(TOP) 
                }
                up(top_adj) cuboid([L2,W2,wallz+gapz],rounding=R-wallx,edges="Z",anchor=BOT);
            } 
            up(top_adj-0.1) union(){
                grid_copies([support_pin_length,support_pin_wildth], n=[2,2]) tube(h=H-H_pcb_hi-top_adj+0.1,od=support_pin_d1,id=support_pin_d3,ichamfer2=0.4,ochamfer1=-1.6,anchor=BOT);   //四个支撑柱
                if (isdrawled) move([led_p_x,led_p_y,0]) cuboid([led_l+1.2,led_w+1.2,H-H_pcb_hi-top_adj-1],chamfer=-1.6,edges=BOT,anchor=BOT);  //LED屏蔽外壳
                if (isdrawpenhole) {xcopies([-35,-20,0,20,38])move([0,-13.6,0]) cuboid([1.2,8,H-H_pcb_hi-top_adj-1],chamfer=-1.6,edges=BOT,anchor=LEFT+BOT);}         //touchpen 
                move([29.6,-20,0])cuboid([3.4,6,H-top_adj-screen_mask_thickness-height],anchor=BOT); //boot
                move([33.6,-20,0])cuboid([3.4,6,H-top_adj-screen_mask_thickness-height],anchor=BOT); //reset
            }
            up(wallz+gapz) rect_tube(h=H21, size=[L,W],isize=[L2,W2],rounding=R,irounding=R-wallx,$fn=32,anchor=BOT) position(TOP) 
                union(){ 
                    down(0.1) rect_tube(h=snip_height+0.1, size=[L,W],isize=[L1,W1],rounding=R,irounding=R-wallx/2,$fn=32,anchor=BOT) position(BOT) 
                    mirror([0,1,0]) xcopies([-35,-20,20,36])    move([0,-W1/2,snip_height-0.2]) cuboid([4.8,0.8,1.8],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+TOP);   //卡扣X方向
                                    xcopies([-30,-15,0,15,30])  move([0,-W1/2,snip_height-0.2]) cuboid([4.8,0.8,1.8],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+TOP);   //卡扣X方向
                                    ycopies([0,15,-20])         move([L1/2,0, snip_height-0.2]) cuboid([0.8,4.8,1.8],chamfer=0.8,edges=[LEFT+TOP,LEFT+BOT],anchor=RIGHT+TOP); 
                    mirror([1,0,0]) ycopies([-20,20])           move([L1/2,0, snip_height-0.2]) cuboid([0.8,4.8,1.8],chamfer=0.8,edges=[LEFT+TOP,LEFT+BOT],anchor=RIGHT+TOP);    //卡扣X方向
     //卡扣Y方向
                }
            } 
        if (isdrawled) {move([led_p_x,led_p_y,0.4]) cuboid([led_l,led_w,H-H_pcb_hi-top_adj+eps],anchor=BOT);}  //LED屏蔽外壳挖坑
        if (isdrawspk) {move([-15.6,-22.5,-0.001]) cuboid([8,4.5,top_adj+2*eps],anchor=BOT);}  //speaker
        move([25,-1,-0.001])   grid_copies([3,3], n=[5,5]) cube([2,2,top_adj+2*eps]);  //散热孔
        move([-6,18,-0.001])  grid_copies([3,3], n=[4,4]) cube([2,2,top_adj+2*eps]);  //sdcard 散热孔
        //move([-13,16,0])  grid_copies([3,3], n=[14,6]) cube(2);  //散热孔
        button2d(top_adj);
        up(H1+H2) yrot(180)
            union(){
                microtypec();
                if (isdrawpenhole) {move([-(L/2)-eps,-12,H_pcb_hi+0.6]) touchpen();}  //touch pen
                if (isdrawsdcard) {move([4.8,W2/2-eps,H_pcb_hi])cuboid([15.6,wally+2*eps,3.2],anchor=FWD+BOT); } //sdcard
                if (isdrawtemphum) {move([-12,W2/2-eps,H_pcb_hi])cuboid([8,wally+2*eps,4],anchor=FWD+BOT);  } //temp_hum_interface
                if (isdrawextio) {move([-28,W2/2-eps,H_pcb_hi])cuboid([8,wally+2*eps,4],anchor=FWD+BOT);  } //Ext IO
            }
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

//上盖
if (isdrawtop) {
    if (isdrawtopside)  back(shift+W) top_case();
    else up(H+yshift) yrot(180)  top_case();
}

//下盖
if (isdrawbase) { base_case(); }

//logo
if (isdrawlogo) {
    if (islogo_isolate) { 
        right(W) up(screen_mask_thickness) xrot(180) mylogo(12,35,screen_mask_thickness,3,2.2,screen_mask_thickness-0.4,fs=fontsize,logo=true);  //logo pad
        if (isdrawlogosupport) {
            right(W+15) up(screen_height-0.4) xrot(180) 
                difference(){
                    mylogo(12,35,screen_height-0.4,2.8,2.0,screen_height-0.4);
                    move([-6,0,-eps]) cuboid([12,35+eps,screen_height-0.4+2*eps],anchor=BOT);
           }
        }
    }
}
