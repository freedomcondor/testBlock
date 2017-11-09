#include<GL/glut.h>

/////////////  function include  /////////////

///////////////////  drawings /////////////////
int drawSphere(double x, double y, double z, double r);
int drawCube(double x, double y, double z, double half);
int drawCylinder(	double base, double top, double height,
				double lx,	double ly, double lz,
				double ex,	double ey, double ez
			);

/////////////////// functions //////////////////
int function_init(int SystemWeight, int SystemHeight);
int function_draw();
int function_draw2();
int function_step();
int function_exit();
