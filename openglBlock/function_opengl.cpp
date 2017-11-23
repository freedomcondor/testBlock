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
	camera_flag = 1;
	testbench_init( SystemWeight, SystemHeight);
	/*
	herd.msg_ControltoHerd.n_dime = 2;
	herd.msg_ControltoHerd.n_indi = 100;			// has to be an even number
	herd.msg_ControltoHerd.flag_minmax = 0;
	herd.init(&herd.msg_ControltoHerd);	

	datalog[herd.time] = herd.value[herd.queue[0]];
	plot_y_max = herd.value[herd.queue[0]];
	plot_x_max = 10; 
	*/

	return 0;
}

int function_draw()
{
	double rx,ry,rz,tx,ty,tz,qx,qy,qz,qw;
	int i;
	/*
	for (int i = 0; i < herd.n_indi; i++)
	{
		double x,y;
		x = herd.indi[i].vector[0];
		y = herd.indi[i].vector[1];
		drawSphere(x,y,0,0.02);
	}
	*/
	double scale = 0.2;
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
	
	cin >> name;
	//return testbench_step(name.c_str());
	return testbench_step((char*)name.c_str());
	/*
	herd.run();
	datalog[herd.time] = herd.value[herd.queue[0]];
	*/
	//return 0;
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
