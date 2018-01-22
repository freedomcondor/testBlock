#include<math.h>
#include"function_opengl.h"
#include"../testbench/testbench.h"

#define pi 3.1415926

#define Max_plot 10000

///////////////////  function definations /////////////////
//
//
double buffer_draw2 = 0;
double plot_y_max = 0;
double plot_x_max = 0;
double datalog[Max_plot];

char filenamebase[100] = "../../data/";
char filenameline[100];
FILE *namelist;
#define MAX_LINE 1024

///////////////////  functions  ///////////////////////////
int function_exit()
{
	testbench_close();
#ifdef windows
	exit(0);
#else
	exit(0);
#endif
}
int function_init(int SystemWeight, int SystemHeight)
{
	//namelist = fopen("loopFunction/data/exp-13-passed.txt","r");
	//namelist = fopen("../../data/exp-10-failed.txt","r");
	//namelist = fopen("../../data/exp-11-passed.txt","r");
	//namelist = fopen("../../data/exp-13-passed.txt","r");
	namelist = fopen("../../data/exp-16-passed.txt","r");
	if (namelist == NULL)
	{
		printf("open file namelist failed\n");
	}

	testbench_init( SystemWeight, SystemHeight);

	return 0;
}

int function_draw()
{
	double rx,ry,rz,tx,ty,tz,qx,qy,qz,qw;
	int i;

	double scale = 0.2;
	if (0 == 1)
	for (i = 0; i < tags_n; i++)
	{
		rx = tags_pos[i][0]/scale;
		ry = tags_pos[i][1]/scale;
		rz = tags_pos[i][2]/scale;
		tx = tags_pos[i][3]/scale;
		ty = tags_pos[i][4]/scale;
		tz = tags_pos[i][5]/scale;
		qx = tags_pos[i][6]/scale;
		qy = tags_pos[i][7]/scale;
		qz = tags_pos[i][8]/scale;
		qw = tags_pos[i][9];

		//drawSphere(rx,ry,rz,0.02);
		drawCylinder(	0.005, 0.005, 0.05,
						tx,	ty, tz,
						-rx,	-ry, -rz);
		drawSphere(tx,ty,tz,0.02);
		//drawSphere(tx+rx*0.05,ty+ry*0.05,tz+rz*0.05,0.02);
	}

	if (0 == 0)
	for (i = 0; i < boxes_n; i++)
	{
		rx = boxes_pos[i][0]/scale;
		ry = boxes_pos[i][1]/scale;
		rz = boxes_pos[i][2]/scale;
		tx = boxes_pos[i][3]/scale;
		ty = boxes_pos[i][4]/scale;
		tz = boxes_pos[i][5]/scale;
		qx = boxes_pos[i][6]/scale;
		qy = boxes_pos[i][7]/scale;
		qz = boxes_pos[i][8]/scale;
		qw = boxes_pos[i][9];

		///*

		//drawSphere(rx,ry,rz,0.02);

		/*
		drawCylinder(	0.005, 0.005, 0.05,
						tx,	ty, tz,
						-rx,	-ry, -rz);
		*/
		///*
		drawCylinder(	0.005, 0.005, 0.05,
						tx,	ty, tz,
						-rx,	-ry, -rz);
		//*/
		drawSphere(tx,ty,tz,0.02);

		//drawSphere(tx+rx*0.05,ty+ry*0.05,tz+rz*0.05,0.02);
	}

	return 0;
}

int function_draw2()
{
	/*
	for (int i = 1; i <= herd.time; i++)
	{
		if (herd.time < plot_x_max)
		{
		glBegin(GL_LINES);
			glVertex3f( (i-1)/plot_x_max,	datalog[i-1]/plot_y_max,0.0f);
			glVertex3f(  i/plot_x_max,		datalog[i] / plot_y_max,0.0f);
		glEnd();
		}
		else
		{
		glBegin(GL_LINES);
			glVertex3f( 1.0*(i-1)/herd.time,	datalog[i-1]/plot_y_max,0.0f);
			glVertex3f( 1.0* i/herd.time,		datalog[i] / plot_y_max,0.0f);
		glEnd();
		}
	}
	*/
		
	return 0;
}

int function_step()
{
	string name;
	int flag;
	
	char thename[100];
	if (!feof(namelist))
	{
		fgets(filenameline,MAX_LINE,namelist);
		//printf("%s : %d\n",filenameline,strlen(filenameline));
		filenameline[strlen(filenameline)-1] = '\0';

		strcpy(thename,filenamebase);
		strcat(thename,filenameline);

		//printf("%s\n", thename);
		//testbench_step("loopFunction/data/output_00021.png");
		//testbench_step("loopFunction/data/exp-13-passed/cap_0000091.png");
		flag = testbench_step(thename);
	}

	/*
	cin >> name;
	//return testbench_step(name.c_str());
	//printf("---------------------\n");
	//printf("before calling testbench\n");
	flag = testbench_step((char*)name.c_str());
	//printf("after calling testbench\n");
	//printf("---------------------\n");
	*/
	/*
	herd.run();
	datalog[herd.time] = herd.value[herd.queue[0]];
	*/
	return flag;
}



////////////////////////////// drawings  /////////////////////////
int drawSphere(double x, double y, double z, double r)
{
	glTranslatef(x,y,z);
	glutSolidSphere(r,10,10);
	glTranslatef(-x,-y,-z);

	return 0;
}

int drawCube(double x, double y, double z, double half)
{
	glTranslatef(x,y,z);
	glutSolidCube(half);
	glTranslatef(-x,-y,-z);

	return 0;
}

int drawCylinder(	double base, double top, double height,
				double lx,	double ly, double lz,
				double ex,	double ey, double ez
			)
{
	double xaxis,yaxis,zaxis,angleaxis;
	double xbase,ybase,zbase;
	double e;
	int rotateflag = 1;
	GLUquadricObj *quadratic;
	double error = 0.001;

	quadratic = gluNewQuadric();

	//printf("l: %lf %lf %lf\n",lx,ly,lz);
	//printf("e: %lf %lf %lf\n",ex,ey,ez);

	if (((ex-0)*(ex-0)<error) && ((ey-0)*(ey-0)<error) && ((ez-1)*(ez-1)<error))
		rotateflag = 0;

	if (rotateflag == 1)
	{
		e = sqrt(ex * ex + ey * ey + ez * ez);
		if (e == 0) return -1;

		xbase = 0; ybase = 0; zbase = 1;
		xaxis = ybase * ez - zbase * ey;
		yaxis = zbase * ex - xbase * ez;
		zaxis = xbase * ey - ybase * ex;
		//angleaxis = acos((xbase*ex+ybase*ey+zbase*ez)/e) + pi;
		angleaxis = acos((xbase*ex+ybase*ey+zbase*ez)/e);

		//printf("%lf %lf %lf %lf\n",angleaxis,xaxis,yaxis,zaxis);

	}

	glTranslatef(lx,ly,lz);

	if (rotateflag == 1)
		glRotatef(angleaxis*180/pi,xaxis,yaxis,zaxis);

	gluCylinder(quadratic,base,top,height,32,32);//»­Ô²Öù	base top height
	if (rotateflag == 1)
		glRotatef(-angleaxis*180/pi,xaxis,yaxis,zaxis);

	glTranslatef(-lx,-ly,-lz);
	return 0;
}
