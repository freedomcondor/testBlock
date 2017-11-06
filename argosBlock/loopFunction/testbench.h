#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <string.h>

#include <opencv2/opencv.hpp>

#include <apriltag/apriltag.h>
#include <apriltag/tag36h11.h>


#include <lua5.2/lua.h>
#include <lua5.2/lauxlib.h>
#include <lua5.2/lualib.h>

/*
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
*/

using namespace std;
using namespace cv;

/*
///////////////////////////////////////////// VARS ////////////////////////////
extern lua_State *L;
extern apriltag_detector* m_psTagDetector;
extern apriltag_family* m_psTagFamily;       

////////// loop filename initail //////////////////////////////////////////////////
extern char fileName[30];
extern char fileNameBase[20];
//char fileNameBase[20] = "data/output_";
extern char fileExt[10];
extern char fileNumber[5];
extern string strFileName;
extern string strFileSuffix;
extern std::string strFileExtension;
extern int nTimestamp;

///////// opencv //////////////
extern Mat imageRGB, image;
*/

extern int tags_n;
extern double tags_pos[20][10];

//extern double rx,ry,rz,tx,ty,tz;    

///////////////////////////////////////////// init step and close //////////////
int testbench_init(int SystemWeight, int SystemHeight);
int testbench_step(char charFileName[]);
int testbench_close();

////////////////////////////////////////////// tool functions //////////////////
// conver n into something like "00001"
char *numberToString5(int n, char str[]);
 
// opencv draw
//int setColor(uchar pix[],int R,int G, int B);
int setColor(cv::Vec<unsigned char, 3> &pix,int R,int G, int B);
int drawCross(Mat img, int x, int y, const char color[]);

