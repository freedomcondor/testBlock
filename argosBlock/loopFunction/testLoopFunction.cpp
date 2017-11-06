#include <stdio.h>

#include "testLoopFunction.h"
//#include "testbench.h"

char filenamebase[100] = "../data/";
char filenameline[100];
FILE *namelist;

char boxnamebase[100] = "testbox";
char boxnameline[100];
char boxnamenumber[10];
int lastn = 0;
#define MAX_LINE 1024

//CBoxEntity* pcBox[20];
//CBoxEntity* pcBox;

CVector3 cv3 = CVector3(0.4,0.4,0);
CVector3 size3 = CVector3(0.05,0.05,0.005);
CQuaternion cq = CQuaternion(1,0,0,0);

void testLoopFunction::PreStep()
{
	int i;

	//// clear Entity
	printf("here is the start of frame");
	printf("clock : %d\n",GetSpace().GetSimulationClock());
	//if (tags_n != 0)
	//for (i = 0; i < tags_n; i++)
	for (i = 0; i < lastn; i++)
	//if (GetSpace().GetSimulationClock() != 1)
	{
		/*
		printf("here is remove\n");

		CEntity::TVector entities;
		GetSpace().GetEntitiesMatching(entities,"testbox");
		printf("%ld\n",entities.size());
		for (int i = 0; i < entities.size(); i++)
	   	{
	   		printf("%s\n",entities[i]->GetId().c_str());
		}

		pcBox = dynamic_cast<CBoxEntity*>(entities[0]);
		*/

		//RemoveEntity(*pcBox);
		strcpy(boxnameline,boxnamebase);
		boxnamenumber[0] = i+'0';
		boxnamenumber[1] = '\0';
		strcat(boxnameline,boxnamenumber);

		printf("removing %s\n",boxnameline);
		RemoveEntity(boxnameline);
		//pcBox->Destroy();
	}

	//// detect new frame
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
		testbench_step(thename);
	}   


	//// add new entity
	//if (tags_n != 0)
	for (i = 0; i < tags_n; i++)
	{
			/*
			CVector3 cv3 = CVector3(0.4,0.4,0);
			CVector3 size3 = CVector3(0.05,0.05,0.05);
			CQuaternion cq = CQuaternion(1,0,0,0);
			*/
		// left and right hand should convert x axis
		cv3.SetX(tags_pos[i][3]/500);
		cv3.SetY(tags_pos[i][4]/500);
		cv3.SetZ(tags_pos[i][5]/500);

		///*
		cq = CQuaternion(	tags_pos[i][9],
							tags_pos[i][6],
							tags_pos[i][7],
							tags_pos[i][8]);
		//*/


		strcpy(boxnameline,boxnamebase);
		boxnamenumber[0] = i+'0';
		boxnamenumber[1] = '\0';
		strcat(boxnameline,boxnamenumber);
		printf("%s\n",boxnameline);

		pcBox[i] = new CBoxEntity(boxnameline,cv3,cq,false,size3,1);
		AddEntity(*pcBox[i]);
		printf("%lf, %lf, %lf\n",cv3.GetX(),cv3.GetY(),cv3.GetZ());
	}
	lastn = tags_n;
	printf("here is the end of step\n\n");
}

void testLoopFunction::Init(TConfigurationNode& t_tree)
{
	//namelist = fopen("loopFunction/data/exp-13-passed.txt","r");
	//namelist = fopen("../data/exp-13-passed.txt","r");
	//namelist = fopen("../data/exp-11-passed.txt","r");
	//namelist = fopen("../data/exp-16-passed.txt","r");
	namelist = fopen("../data/exp-10-failed.txt","r");
	if (namelist == NULL)
	{
		printf("open file namelist failed\n");
	}
	testbench_init(1920,1200);
	/*
	flag = 0;
	printf("test: I am init\n");
	printf("getting config tree\n");
	TConfigurationNodeIterator itEntity("entity");
	for(itEntity = itEntity.begin(&t_tree);
			itEntity != itEntity.end();
			++itEntity) 
	{
		std::string strBaseId;
		GetNodeAttribute(*itEntity, "id", strBaseId);
		//m_mapEntityDefinitions.emplace(strBaseId, *itEntity);
		printf("%s\n",strBaseId.c_str());
	}
	*/

	/////////////////////////////////////////////////////////////////
	/*
	printf("read entity\n");
	CEntity::TVector entities;
	GetSpace().GetEntitiesMatching(entities,"obstacle");
	*/

	/*
	printf("%ld\n",entities.size());
	for (int i = 0; i < entities.size(); i++)
	{
		printf("%s\n",entities[i]->GetId().c_str());
	}
	*/

	/*
	pcCylinder = dynamic_cast<CCylinderEntity*>(entities[0]);

	*/
	/////////////////////////////////////////////////////////////////

	/*
	printf("create entity\n");
	const CVector3 cv3 = CVector3(0.4,0.4,0);
	const CVector3 size3 = CVector3(0.2,0.4,0.4);
	const CQuaternion cq = CQuaternion(1,0,0,0);
	pcBox = new CBoxEntity("testbox",
							cv3,
							cq,
							false,
							size3,
							1);

	AddEntity(*pcBox);
	
	//printf("%s\n",theObstacle->GetId().c_str());
	*/
}

void testLoopFunction::Destroy()
{
	testbench_close();
}

REGISTER_LOOP_FUNCTIONS(testLoopFunction, "testLoopFunction");
