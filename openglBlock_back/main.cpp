#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <string.h>

#include <opencv2/opencv.hpp>

#include <apriltag/apriltag.h>
#include <apriltag/tag36h11.h>

///*
#include <lua5.2/lua.h>
#include <lua5.2/lauxlib.h>
#include <lua5.2/lualib.h>
//*/
/*
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
*/

using namespace std;
using namespace cv;

// conver n into something like "00001"
char *numberToString5(int n, char str[]);

// opencv draw
//int setColor(uchar pix[],int R,int G, int B);
int setColor(cv::Vec<unsigned char, 3> &pix,int R,int G, int B);
int drawCross(Mat img, int x, int y, const char color[]);

// find ../data/*.png | ./luaBlock -

int main(int n_arg_count, char* ppch_args[])
{
	int i,j,k;
	int x_temp,y_temp;
	char c;

	////////// Lua initial  ////////////////////////////////////////////////////////
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	//if ((luaL_loadfile(L,"../func.lua")) || (lua_pcall(L,0,0,0)))
	if ((luaL_loadfile(L,"../func.lua")) || (lua_pcall(L,0,0,0)))
		{printf("open lua file fail : %s\n",lua_tostring(L,-1));return -1;}

	////////// apriltag initial ////////////////////////////////////////////////////
				// these might be needed
				//		m_cCameraMatrix(c_camera_matrix),
				//		m_cDistortionParameters(c_distortion_parameters) {
	apriltag_detector* m_psTagDetector;
	apriltag_family* m_psTagFamily;
	m_psTagDetector = apriltag_detector_create();
		// not sure what does these means yet, just copied from Michael
	m_psTagDetector->quad_decimate = 1.0f;
	m_psTagDetector->quad_sigma = 0.0f;
	m_psTagDetector->nthreads = 1;
	m_psTagDetector->debug = 0;
	m_psTagDetector->refine_edges = 1;
	m_psTagDetector->refine_decode = 0;
	m_psTagDetector->refine_pose = 0;
		/* create the tag family */
	m_psTagFamily = tag36h11_create();
	m_psTagFamily->black_border = 1;
	apriltag_detector_add_family(m_psTagDetector, m_psTagFamily);


	////////// loop filename initail //////////////////////////////////////////////////
	char fileName[30];
	char fileNameBase[20] = "../data/output_";
	//char fileNameBase[20] = "data/output_";
	char fileExt[10] = ".png";
	char fileNumber[5];
	string strFileName;
	string strFileSuffix("output_");
	std::string strFileExtension(".png");
	int nTimestamp;


	///////// image and window initial ////////////////
	Mat imageRGB,image;
	namedWindow("output",WINDOW_NORMAL);
	moveWindow("output",100,100);
	resizeWindow("output",1000,700);

	/////////// main loop //////////////////////////////////////////////////////////
	/*
	for (i = 0; i < 197; i++)
	{
		///////// Open Image  //////////////////////////
		// conver i into "00001"
		numberToString5(i,fileNumber);
		// making filename
		strcpy(fileName,fileNameBase);
		strcat(fileName,fileNumber);
		strcat(fileName,fileExt);
		
						printf("%d, %s : \n",i, fileName);

		// open image
		imageRGB = imread( fileName, 1 );
	*/
	if(n_arg_count > 1 && ppch_args[1][0] == '-')
	for (;;)
	{
		////////////  to have the timestamp  ////////////////////////////////
		cin >> strFileName;
		if(std::cin.good())
			imageRGB = cv::imread(strFileName.c_str(), 1);
		else
			break;

		string::size_type unPosStart = strFileName.find(strFileSuffix) + strFileSuffix.size();
		string::size_type unPosEnd = strFileName.find(strFileExtension);
		if(unPosStart == std::string::npos || unPosEnd == std::string::npos) {
			std::cerr << "could not find suffix/extension in file name: "<< strFileName << std::endl;
			continue;
		}
		string strTimestamp = strFileName.substr(unPosStart, unPosEnd - unPosStart);
		//nTimestamp = std::stoi(strTimestamp);
		//printf("%d\n",nTimestamp);

		//printf("channels,%d ",image.channels());

						//printf("row and col,%d %d ",imageRGB.rows,imageRGB.cols);

		if ( !imageRGB.data ) { printf("Can't open image %s \n",fileName); return -1; }
		cvtColor(imageRGB,image,CV_BGR2GRAY);

		/* convert image to apriltags format */
		image_u8_t* ptImageY = image_u8_create(image.cols, image.rows);
		// remember to destroy it
		for (unsigned int un_row = 0; un_row < ptImageY->height; un_row++) 
		{
			memcpy(&ptImageY->buf[un_row * ptImageY->stride],
						image.row(un_row).data,
						ptImageY->width);
		}
		//now ptImageY is the image_u8_t type image

		zarray_t* psDetections = apriltag_detector_detect(m_psTagDetector, ptImageY);
		image_u8_destroy(ptImageY);
		//now psDetections is an array of detected tags

		/////////  Trick Start  ///////////////////////

		/////////  Lua ///////////////////
			/*
			   		for every frame, build a taglist, which is a table, to lua
			   			taglist
						{
							timestamp = xxx
							n = <a number> the number of tags
							1 = <a table> which is a tag
								{
									center = {x = **, y = **}
									corner = <a table>
									{
										1 = {x = **, y = **}
										2
										3
										4
									}
								}
							2
							3
							4
							...
						}
			 */
		lua_settop(L,0);
		lua_getglobal(L,"func"); // stack 1 is the function
		lua_newtable(L);		 // stack 2 is the table (without a name)
		lua_pushstring(L,"timestamp");	// stack 3 is the index of timestamp
		lua_pushstring(L,"tobefilled");	// stack 4 is the value of timestamp
		lua_settable(L,2);
		lua_pushstring(L,"n");	// stack 3 is the index of n
		lua_pushnumber(L,zarray_size(psDetections));
		lua_settable(L,2);

		// go through all the tags

							//printf("tags: %d\n: ",zarray_size(psDetections));

		for (j = 0; j < zarray_size(psDetections); j++)
		{
			apriltag_detection_t *psDetection;
			zarray_get(psDetections, j, &psDetection);

									//								 x
															////////////////////
															//				  //
															//				  //
									//					y	//				  //
															//				  //
															//				  //
															////////////////////

			////  output and draw
			////////// draw center /////////
			x_temp = psDetection->c[1];
			y_temp = psDetection->c[0];
			//printf("%d %d\n",x_temp, y_temp);
			//drawCross(imageRGB,x_temp,y_temp,"green");
			drawCross(imageRGB,x_temp,y_temp,"red");

			////////// draw corners /////////
			for (k = 0; k < 4; k++)
			{
				x_temp = psDetection->p[k][1];
				y_temp = psDetection->p[k][0];
				//drawCross(imageRGB,x_temp,y_temp,"blue");
				drawCross(imageRGB,x_temp,y_temp,"red");
			}

			/////////// Lua build table into stack ////////////////////////////
			lua_pushnumber(L,j+1);		//Stack 3 is the index of this tag
			lua_newtable(L);		 	// stack 4 is the table of this tag
				lua_pushstring(L,"id");		// stack 5 is the index of n
				lua_pushnumber(L,psDetection->id);		 	// stack 6 is the table of this center
			  lua_settable(L,4);
				lua_pushstring(L,"center");	// stack 5 is the index of n
				lua_newtable(L);		 	// stack 6 is the table of this center
					lua_pushstring(L,"x");	// stack 7 is the index of x
					lua_pushnumber(L,psDetection->c[1]);//Stack 8 is the value of x
				  lua_settable(L,6);

					lua_pushstring(L,"y");	// stack 7 is the index of y
					lua_pushnumber(L,psDetection->c[0]);//Stack 8 is the index of y
				  lua_settable(L,6);
			  lua_settable(L,4);

				lua_pushstring(L,"corners");	// stack 5 is index of corners
				lua_newtable(L);				// stack 6 is the table of the corners
					for (k = 0; k < 4; k++)
					{
						lua_pushnumber(L,k+1);	// stack 7 is the index of corner 1234
						lua_newtable(L);		// stack 8 is the table of corner 1234
							lua_pushstring(L,"x");	// stack 9 is the index of x
							lua_pushnumber(L,psDetection->p[k][1]);//Stack 10 is the value of x
				  		  lua_settable(L,8);
							lua_pushstring(L,"y");	// stack 9 is the index of x
							lua_pushnumber(L,psDetection->p[k][0]);//Stack 10 is the value of x
				  		  lua_settable(L,8);
				  	  lua_settable(L,6);
					}
			  lua_settable(L,4);	// add corners to table tag
			lua_settable(L,2);	// add tag to root table
		}

		//////////////// call lua function  /////////////////////////////////
		if (lua_pcall(L,1,1,0) != 0)	// one para, one return
			{printf("call func fail %s\n",lua_tostring(L,-1)); return -1;}

		/////////////// lua take lua function result ///////////////////////
			// the result should be the structure of the blocks
		int n;
		double rx,ry,rz,tx,ty,tz;
		printf("in C\n");
		if (lua_istable(L,1))
		{
			//printf("back is table\n");	// stack 1
			lua_pushstring(L,"n");		//stack 2
			lua_gettable(L,1);			//stack 2 now is the number n
			n = (int)luaL_checknumber(L,2);
			printf("number: %d\n",n);	//stack 2 now is the number n
			lua_pop(L,1);				// here goes stack 2
			// get every tags pos
			for (int i = 0; i < n; i++)
			{
				lua_pushnumber(L,i+1);		//stack 2
				lua_gettable(L,1);			//stack 2 now is the table of {rota, tran}
					lua_pushstring(L,"rotation");		//stack 3
					lua_gettable(L,2);			//stack 3 now is the table{x,y,z}
						lua_pushstring(L,"x");		//stack 4
						lua_gettable(L,3);			//stack 4 now is the value
						rx = lua_tonumber(L,4);
						lua_pop(L,1);			// here goes stack 4
						lua_pushstring(L,"y");		//stack 4
						lua_gettable(L,3);			//stack 4 now is the value
						ry = lua_tonumber(L,4);
						lua_pop(L,1);			// here goes stack 4
						lua_pushstring(L,"z");		//stack 4
						lua_gettable(L,3);			//stack 4 now is the value
						rz = lua_tonumber(L,4);
						lua_pop(L,1);			// here goes stack 4
					lua_pop(L,1);			// here goes stack 3

					lua_pushstring(L,"translation");		//stack 3
					lua_gettable(L,2);			//stack 3 now is the table{x,y,z}
						lua_pushstring(L,"x");		//stack 4
						lua_gettable(L,3);			//stack 4 now is the value
						tx = lua_tonumber(L,4);
						lua_pop(L,1);			// here goes stack 4
						lua_pushstring(L,"y");		//stack 4
						lua_gettable(L,3);			//stack 4 now is the value
						ty = lua_tonumber(L,4);
						lua_pop(L,1);			// here goes stack 4
						lua_pushstring(L,"z");		//stack 4
						lua_gettable(L,3);			//stack 4 now is the value
						tz = lua_tonumber(L,4);
						lua_pop(L,1);			// here goes stack 4
					lua_pop(L,1);			// here goes stack 3
				lua_pop(L,1);				// goes stack 2
				printf("ros x:%lf\n",rx);
				printf("ros y:%lf\n",ry);
				printf("ros z:%lf\n",rz);
				printf("tra x:%lf\n",tx);
				printf("tra y:%lf\n",ty);
				printf("tra z:%lf\n",tz);
			}
		}

		////////////// show image and next frame //////////////////
		imshow("output", imageRGB);
		//c = waitKey(30);
		c = waitKey(0);
	}	// end for

	lua_close(L);

	return 0;
}

///////  OpenCV draw  ////////////////////////////////////////////////

int drawCross(Mat img, int x, int y, const char color[])
{
	int R,G,B;
	if (strcmp(color,"blue") == 0)
	{ R = 0; G = 0; B = 255; }
	else if (strcmp(color,"green") == 0)
	{ R = 0; G = 255; B = 0; }
	else if (strcmp(color,"red") == 0)
	{ R = 255; G = 0; B = 0; }
	Mat_<Vec3b> _image = img;
	setColor(_image(x,y),R,G,B);
	if (x != 0) 			setColor(_image(x-1,y),R,G,B);
	if (x != img.cols-1) 	setColor(_image(x+1,y),R,G,B);
	if (y != 0) 			setColor(_image(x,y-1),R,G,B);
	if (y != img.rows-1) 	setColor(_image(x,y+1),R,G,B);
	img = _image;
	return 0;
}

int setColor(cv::Vec<unsigned char, 3> &pix,int R,int G, int B)
{
	pix[0] = B;
	pix[1] = G;
	pix[2] = R;
	return 0;
}

////////  Number to String  /////////////////////////////////////////////////////////
char* numberToString(int n, int k, char str[])
{
	int i;
	int tens;
												// take 5 as an example
	tens = 1;
	for (i = 0; i < k; i++)
		tens *= 10;
												// tens = 100000
	n = n % tens;
	tens /= 10;

	for (i = 0; i < k; i++)						//5 times
	{
		str[i] = n / tens + '0' - 0;
		n = n % tens;
		tens /= 10;
	}

	str[k] = '\0';

	return str;
}

char* numberToString5(int n, char str[])
{
	numberToString(n,5,str);
	return 0;
}
