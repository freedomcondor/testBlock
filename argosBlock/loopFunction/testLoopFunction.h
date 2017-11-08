#include <argos3/core/simulator/loop_functions.h>
#include <argos3/plugins/simulator/entities/cylinder_entity.h>
#include <argos3/plugins/simulator/entities/box_entity.h>

#include "../../testbench/testbench.h"

using namespace argos;

class testLoopFunction : public CLoopFunctions
{
public:
	//testLoopFunction();
	//~testLoopFunction();
	void test();
	void Init(TConfigurationNode& t_tree);
	void PreStep();
	void Destroy();
private:
	int flag;
	CCylinderEntity* pcCylinder;
	CBoxEntity* pcBox[100];
	CBoxEntity* pcTag[100];
};
