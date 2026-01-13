include <BOSL2/std.scad>

$fs=$preview?1:0.4; 
$fa=$preview?15:5;
$fn=$preview?32:64;

pcbl=98;
pcbw=26;
pcbh=13;

ledbd_tks=1.5;
grid_tks=2.2;
pet_tks=0.1;
acl_tks=1.6;
mask_tks=0.4;

esp32_l=52;
esp32_w=28;
esp32_height=4.8;
esp32_tks=1.4;
esp32_lct_l=46.5;
esp32_lct_w=23;

wallx=2;
wally=2;
wallz=1;
gapx=0.2;
gapy=0.2;
gapz=0.2;

lidheight=2;
snip_depth=0.4;
R=2;                     // 圆角
C=0.8;                     // 倒角
L =pcbl+2*wallx+2*gapx;  //外壳总长
L1=pcbl+wallx+2*gapx;  //上下壳子交叉
L2=pcbl+2*gapx;          //放置灯板,预留gapx尺寸
L3=pcbl-2;               //灯板对外显示长度

W =pcbw+2*wally+2*gapy;  //外壳总宽
W1=pcbw+wally+2*gapy;  //上下壳子交叉
W2=pcbw+2*gapy;          //放置灯板,预留gapy尺寸
W3=pcbw-2;               //灯板对外显示宽度

boxheight=mask_tks+acl_tks+pet_tks+grid_tks+ledbd_tks+gapz+esp32_height;
echo(boxlength=boxheight);

H =pcbh;
H1=H-wallz;
H2=H-mask_tks;
H3=mask_tks;
H4=mask_tks+acl_tks+pet_tks+grid_tks+ledbd_tks+gapz;  //嵌入esp32板子的高度
H5=H-H4;
echo(mask_tks,acl_tks,pet_tks,ledbd_tks,gapz);  //嵌入esp32板子的高度

is_left_half=false;
is_right_half=false;
is_front_half=false;
is_back_half=false;
is_top_half=false;
is_bottom_half=false;

isdrawbase=true;
isdrawlid=true;
isdrawtopside=true;
//上盖打开后距离底盒
shift=20;
yshift=10;

eps=0.001;

echo(L=L,L1=L1,L2=L2,L3=L3);
echo(W=W,W1=W1,W2=W2,W3=W3);
echo(H=H,H1=H1,H2=H2,H3=H3,H4=H4,H5=H5);

//画盒子同时做Z轴rouding和底面chamfer
module drawbox(L,W,H,R,C){
    roundrect2d=rect([L,W],rounding=R);
    offset_sweep(roundrect2d, h=H, bottom=os_chamfer(C),anchor=BOT);
}


module mirror_copy(v = [0, 1, 0]) {
    children();
    mirror(v) children();
}

module ldr_hole(){
        cuboid([5.6,2.3,4.6],rounding=2.3,edges=[TOP+LEFT,BOT+LEFT,TOP+RIGHT,BOT+RIGHT],anchor=BOT+BACK);
}

module powerline_hole(){
    xcyl(l=2.3, d=3, chamfer=-0.6,anchor=BOT+RIGHT);
}

module top_case(){
    //color("gray")
    difference(){
        union(){
            drawbox(L,W,wallz,R,C);  //上盖底层带倒脚
            up(wallz) cuboid([L,W,gapz],rounding=R,edges="Z",anchor=BOT) position(TOP) //gap
            union(){
                grid_copies([esp32_lct_l,esp32_lct_w], n=[2,2]) cyl(h=H5,d=2.6,chamfer1=-0.8,chamfer2=0.4,anchor=BOT);   //四个支撑柱
                mirror_copy() xcopies(35,n=3) move([0,14,0])
                union(){
                    cuboid([10,4,4.6],anchor=BOT);
                    move([0,2,1])cuboid([10,0.8,3.6],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+BOT);
                }
            }
       }
        grid_copies([3,3], n=[30,6]) cuboid(2,anchor=BOT);  //散热孔
        move([-35,W2/2+2.3,H5-0.2-4.6+wallz+gapz]) ldr_hole();
        move([L2/2+2.3,0,wallz+gapz])powerline_hole();
    }
}

module base_case(){
//    color("red")
    difference(){
        union(){
            drawbox(L,W,wallz,R,C);  //上盖底层带倒脚
            //up(wallz) cuboid([L,W,H1],rounding=R,edges="Z",anchor=BOT);  //加底面总高为H
            up(wallz) rect_tube(h=H1, size=[L,W],isize=[L2,W2],rounding=R,$fn=16,anchor=BOT); //圆角矩形圈切出上下盖子交叉区
       }
        up(mask_tks) cuboid([L2,W2,H2+eps],anchor=BOT);  //挖出pcb放置尺寸
        down(eps) cuboid([L3,W3,H3+2*eps],rounding=R,edges="Z",anchor=BOT); //挖出像素屏外漏区域
        mirror_copy() move([0,W2/2,H4])cuboid([56,0.8,3.6],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+BOT); //esp32板子嵌入
        mirror_copy() xcopies(35, n=3)  move([0,W2/2,H4+2])cuboid([10,0.8,3.6],chamfer=0.8,edges=[BACK+TOP,BACK+BOT],anchor=FWD+BOT); //卡扣
//        up(H-lidheight) rect_tube(h=lidheight, size=[L,W],isize=[L1,W1],rounding=R,$fn=16,anchor=BOT); //圆角矩形圈切出上下盖子交叉区
//        up(H-lidheight) rect_tube(h=lidheight, size1=[L+1,W+1],size2=[L1+1.4,W1+1.4],rounding=R,wall=1,$fn=32,anchor=BOT); //交叉区铲出斜坡
//        up(H-lidheight+snip_depth/2) teardrop_round_rect(L1+snip_depth/2,W1+snip_depth/2,R,snip_depth); //在交叉带上挖槽用于上盒嵌入
        move([-35,-W2/2,H4+0.2]) ldr_hole();
        move([L/2,0,H-3]) powerline_hole();
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
if (isdrawlid) {
    if (isdrawtopside) back(shift+W) top_case();
    else up(wallz+gapz+pcbh+yshift) xrot(180)  top_case();
}
//if (isdrawbase) base_case();
}



